#!/bin/bash
# must be converted to crt to be installed into system
openssl x509 -in ca.pem -inform PEM -out letsEncrypt.crt