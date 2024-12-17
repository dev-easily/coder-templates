FROM ghcr.io/coder/coder:latest

USER root

COPY ./letsEncrypt/letsEncrypt.crt /usr/local/share/ca-certificates/letsEncrypt.crt
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories \
    && apk update \
    && apk add curl unzip ca-certificates && rm -rf /var/cache/apk/* \
    && update-ca-certificates

# https://coder.com/docs/install/offline
RUN mkdir -p /home/coder/.terraform.d/plugins/registry.terraform.io
ADD filesystem-mirror.tfrc /home/coder/.terraformrc
WORKDIR /home/coder/.terraform.d/plugins/registry.terraform.io

# ARG PVE_PROVIDER_VERSION=3.0.1-rc3
# RUN echo "Adding telmate/terraform-provider-proxmox v${PVE_PROVIDER_VERSION}" \
#     && mkdir -p telmate/proxmox && cd telmate/proxmox \
#     && curl -LOs https://www.ghproxy.cn/https://github.com/Telmate/terraform-provider-proxmox/releases/download/v${PVE_PROVIDER_VERSION}/terraform-provider-proxmox_${PVE_PROVIDER_VERSION}_linux_amd64.zip# 

# ARG CODER_PROVIDER_VERSION=1.0.1
# RUN echo "Adding coder/coder v${CODER_PROVIDER_VERSION}" \
#     && mkdir -p coder/coder && cd coder/coder \
#     && curl -LOs https://www.ghproxy.cn/https://github.com/coder/terraform-provider-coder/releases/download/v${CODER_PROVIDER_VERSION}/terraform-provider-coder_${CODER_PROVIDER_VERSION}_linux_amd64.zip
#     
# ARG DOCKER_PROVIDER_VERSION=3.0.2
# RUN echo "Adding kreuzwerker/docker v${DOCKER_PROVIDER_VERSION}" \
#     && mkdir -p kreuzwerker/docker && cd kreuzwerker/docker \
#     && curl -LOs https://www.ghproxy.cn/https://github.com/kreuzwerker/terraform-provider-docker/releases/download/v${DOCKER_PROVIDER_VERSION}/terraform-provider-docker_${DOCKER_PROVIDER_VERSION}_linux_amd64.zip# 

# ARG KUBERNETES_PROVIDER_VERSION=2.23.0
# RUN echo "Adding hashicorp/kubernetes v${KUBERNETES_PROVIDER_VERSION}" \
#     && mkdir -p hashicorp/kubernetes && cd hashicorp/kubernetes \
#     && curl -LOs https://releases.hashicorp.com/terraform-provider-kubernetes/${KUBERNETES_PROVIDER_VERSION}/terraform-provider-kubernetes_${KUBERNETES_PROVIDER_VERSION}_linux_amd64.zip# 

# ARG AWS_PROVIDER_VERSION=5.19.0
# RUN echo "Adding aws/aws v${AWS_PROVIDER_VERSION}" \
#     && mkdir -p aws/aws && cd aws/aws \
#     && curl -LOs https://releases.hashicorp.com/terraform-provider-aws/${AWS_PROVIDER_VERSION}/terraform-provider-aws_${AWS_PROVIDER_VERSION}_linux_amd64.zip# 
# 

# ARG HASHICORP_LOCAL_VERSION=2.5.1
# RUN echo "Adding hashicorp/local v${HASHICORP_LOCAL_VERSION}" \
#     && mkdir -p hashicorp/local && cd hashicorp/local \
#     && curl -LOs https://releases.hashicorp.com/terraform-provider-local/${HASHICORP_LOCAL_VERSION}/terraform-provider-local_${HASHICORP_LOCAL_VERSION}_linux_amd64.zip# 

# ARG HASHICORP_NULL_VERSION=3.2.2
# RUN echo "Adding hashicorp/null v${HASHICORP_NULL_VERSION}" \
#     && mkdir -p hashicorp/null && cd hashicorp/null \
#     && curl -LOs https://releases.hashicorp.com/terraform-provider-null/${HASHICORP_NULL_VERSION}/terraform-provider-null_${HASHICORP_NULL_VERSION}_linux_amd64.zip
            

RUN chown -R coder:coder /home/coder/.terraform*
WORKDIR /home/coder
USER coder

# Use the .terraformrc file to inform Terraform of the locally installed providers.
ENV TF_CLI_CONFIG_FILE=/home/coder/.terraformrc
