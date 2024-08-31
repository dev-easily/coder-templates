terraform {
  required_providers {
    coder = {
      source = "coder/coder"
    }
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc3"
    }
  }
}

provider "proxmox" {
  pm_api_url          = "请修改：pve api地址，如https://192.168.0.3:8006/api2/json"
  pm_api_token_id     = "请修改：pve token id，如root@pam!changeme"
  pm_api_token_secret = "请修改：pve token secret, 如 11111-xxxxx-yyy"
}


data "coder_parameter" "cpu_cores" {
  name        = "CPU 个数"
  description = "要分配的CPU个数"
  type        = "number"

  default = 8

  validation {
    min = 2
    max = 16
  }

  mutable = true
}

data "coder_parameter" "memory" {
  name        = "内存大小（M）"
  description = "要分配的内存(memory size)"
  type        = "number"

  default = 16384

  validation {
    min = 2048
    max = 65536
  }

  mutable = true
}

data "coder_parameter" "disk_size" {
  name        = "硬盘大小"
  description = "硬盘大小，一定要大于基础虚拟机的硬盘大小，否则无法启动(must be larger than base vm disk size)"
  type        = "number"

  default = 30

  validation {
    min = 16
    max = 1024
  }

  mutable = false
}

locals {
  username = data.coder_workspace_owner.me.name
}

data "coder_provisioner" "me" {}

data "coder_workspace" "me" {}

data "coder_workspace_owner" "me" {}

resource "coder_agent" "main" {
  arch           = data.coder_provisioner.me.arch
  os             = "linux"
  startup_script = <<-EOT
    set -e

    # Prepare user home with default files on first start.
    if [ ! -f ~/.init_done ]; then
      cp -rT /etc/skel ~
      touch ~/.init_done
    fi

    # install and start code-server
    # curl -fsSL https://code-server.dev/install.sh | sh -s -- --method=standalone --prefix=/tmp/code-server --version 4.19.1
    # /tmp/code-server/bin/code-server --auth none --port 13337 >/tmp/code-server.log 2>&1 &
  EOT

  # These environment variables allow you to make Git commits right away after creating a
  # workspace. Note that they take precedence over configuration defined in ~/.gitconfig!
  # You can remove this block if you'd prefer to configure Git manually or using
  # dotfiles. (see docs/dotfiles.md)
  env = {
    GIT_AUTHOR_NAME     = coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)
    GIT_AUTHOR_EMAIL    = "${data.coder_workspace_owner.me.email}"
    GIT_COMMITTER_NAME  = coalesce(data.coder_workspace_owner.me.full_name, data.coder_workspace_owner.me.name)
    GIT_COMMITTER_EMAIL = "${data.coder_workspace_owner.me.email}"
  }

  # The following metadata blocks are optional. They are used to display
  # information about your workspace in the dashboard. You can remove them
  # if you don't want to display any information.
  # For basic resources, you can use the `coder stat` command.
  # If you need more control, you can write your own script.
  metadata {
    display_name = "CPU 使用率"
    key          = "0_cpu_usage"
    script       = "coder stat cpu"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "内存使用率"
    key          = "1_ram_usage"
    script       = "coder stat mem"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "HOME使用率"
    key          = "3_home_disk"
    script       = "coder stat disk --path $${HOME}"
    interval     = 60
    timeout      = 1
  }

  metadata {
    display_name = "CPU使用率(宿主机)"
    key          = "4_cpu_usage_host"
    script       = "coder stat cpu --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "内存使用率(宿主机)"
    key          = "5_mem_usage_host"
    script       = "coder stat mem --host"
    interval     = 10
    timeout      = 1
  }

  metadata {
    display_name = "平均负载(宿主机)"
    key          = "6_load_host"
    # get load avg scaled by number of cores
    script   = <<EOT
      echo "`cat /proc/loadavg | awk '{ print $1 }'` `nproc`" | awk '{ printf "%0.2f", $1/$2 }'
    EOT
    interval = 60
    timeout  = 1
  }

  metadata {
    display_name = "Swap 使用率(宿主机)"
    key          = "7_swap_host"
    script       = <<EOT
      free -b | awk '/^Swap/ { printf("%.1f/%.1f", $3/1024.0/1024.0/1024.0, $2/1024.0/1024.0/1024.0) }'
    EOT
    interval     = 10
    timeout      = 1
  }
}

resource "coder_app" "code-server" {
  agent_id     = coder_agent.main.id
  slug         = "code-server"
  display_name = "在线编码（code-server）"
  url          = "http://127.0.0.1:1024/?folder=/home/${local.username}"
  icon         = "/icon/code.svg"
  subdomain    = false
  share        = "owner"

  healthcheck {
    url       = "http://127.0.0.1:1024/healthz"
    interval  = 5
    threshold = 6
  }
}

resource "local_file" "cloud_init_user_data_file" {
  content = templatefile("cloud-config.yaml.tftpl", {
    username          = local.username
    init_script       = base64encode(coder_agent.main.init_script)
    coder_agent_token = coder_agent.main.token
    code_server_setup = true
  })
  filename = "${path.module}/files/user_data.yml"
}

resource "null_resource" "cloud_init_config_files" {
  connection {
    type     = "ssh"
    host     = "请修改：pve主机地址"
    user     = "请修改：pve用户名"
    password = "请修改：pve登录密码"
  }

  provisioner "file" {
    source      = local_file.cloud_init_user_data_file.filename
    destination = "/var/lib/vz/snippets/user_data_vm-coder-${data.coder_workspace_owner.me.name}-${lower(data.coder_workspace.me.name)}.yml"
  }
}

resource "proxmox_vm_qemu" "root" {
  name = "coder-${data.coder_workspace_owner.me.name}-${lower(data.coder_workspace.me.name)}"
  desc = "Coder workspace for ${data.coder_workspace_owner.me.name} (${data.coder_workspace.me.name})"

  target_node = "请修改：pve 的节点（node）"
  clone       = "请修改：要克隆的虚拟机名称"
  os_type     = "cloud-init"
  cores       = data.coder_parameter.cpu_cores.value
  sockets     = 1
  vcpus       = 0
  cpu         = "host"
  memory      = data.coder_parameter.memory.value
  scsihw      = "virtio-scsi-pci"
  cicustom    = "user=local:snippets/user_data_vm-coder-${data.coder_workspace_owner.me.name}-${lower(data.coder_workspace.me.name)}.yml"
  ipconfig0   = "ip=dhcp,ip6=dhcp"

  disks {
    ide {
      ide3 {
        cloudinit {
          storage = "请修改：硬盘存储id，如local-lvm"
        }
      }
    }

    scsi {
      scsi0 {
        disk {
          size    = data.coder_parameter.disk_size.value
          storage = "请修改：硬盘存储id，如local-lvm"
        }
      }
    }
  }

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  vm_state = data.coder_workspace.me.transition == "start" ? "running" : "stopped"

  depends_on = [null_resource.cloud_init_config_files]
}
