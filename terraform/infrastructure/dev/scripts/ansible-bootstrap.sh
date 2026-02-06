#!/usr/bin/env bash

sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y python3 python3-venv python3-pip python3-full git curl unzip jq
if ! command -v aws >/dev/null 2>&1; then
  curl -sSLo /tmp/awscliv2.zip https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip
  unzip -q /tmp/awscliv2.zip -d /tmp
  sudo /tmp/aws/install
fi
sudo python3 -m venv /opt/ansible-venv
sudo /opt/ansible-venv/bin/pip install --upgrade pip
sudo /opt/ansible-venv/bin/pip install ansible boto3 botocore
sudo ln -sf /opt/ansible-venv/bin/ansible-playbook /usr/local/bin/ansible-playbook
sudo ln -sf /opt/ansible-venv/bin/ansible-galaxy /usr/local/bin/ansible-galaxy
sudo ln -sf /opt/ansible-venv/bin/ansible-inventory /usr/local/bin/ansible-inventory
sudo mkdir -p /usr/share/ansible/collections
sudo /opt/ansible-venv/bin/ansible-galaxy collection install amazon.aws -p /usr/share/ansible/collections
if ! command -v session-manager-plugin >/dev/null 2>&1; then
  ARCH=$(uname -m)
  if [ "${ARCH}" = "x86_64" ]; then
    PKG_ARCH=64bit
  elif [ "${ARCH}" = "aarch64" ] || [ "${ARCH}" = "arm64" ]; then
    PKG_ARCH=arm64
  else
    PKG_ARCH=64bit
  fi
  PKG_URL=https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_${PKG_ARCH}/session-manager-plugin.deb
  curl -sSLo /tmp/session-manager-plugin.deb ${PKG_URL} && sudo dpkg -i /tmp/session-manager-plugin.deb || sudo DEBIAN_FRONTEND=noninteractive apt-get -f install -y
fi
if [ -x /usr/local/sessionmanagerplugin/bin/session-manager-plugin ] && [ ! -x /usr/local/bin/session-manager-plugin ]; then
  sudo ln -s /usr/local/sessionmanagerplugin/bin/session-manager-plugin /usr/local/bin/session-manager-plugin
fi
