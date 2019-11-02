#!/bin/bash
set -euo pipefail; IFS=$'\n\t'

#
# 기본 유틸리티들 설치
#
sudo yum update -y
sudo yum install -y \
  htop \
  tmux \
  git \
  yum-cron \
  'https://www.atoptool.nl/download/atop-2.4.0-1.x86_64.rpm'
sudo amazon-linux-extras install -y vim

#
# yum-cron 설치
#
sudo sed -i "s/update_cmd = default/update_cmd = security/" /etc/yum/yum-cron-hourly.conf
sudo sed -i "s/update_cmd = default/update_cmd = security/" /etc/yum/yum-cron.conf
sudo systemctl enable yum-cron

#
# ripgrep 설치
#
curl -Lo /tmp/ripgrep.tgz 'https://github.com/BurntSushi/ripgrep/releases/download/0.10.0/ripgrep-0.10.0-x86_64-unknown-linux-musl.tar.gz'
sudo tar -x \
  --strip-component=1 \
  -C /usr/local/bin/ \
  --no-same-owner \
  -f /tmp/ripgrep.tgz \
  ripgrep-0.10.0-x86_64-unknown-linux-musl/rg
rm /tmp/ripgrep.tgz

#
# 도커 설치
# Reference: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/docker-basics.html#install_docker
#
sudo amazon-linux-extras install -y docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
# 이후 로그아웃한 뒤 재로그인

#
# 스왑 메모리 생성
# 아마존 리눅스에서는 기본으로 XFS를 쓰는데, 이 경우 fallocate 명령어를 쓰지 못한다.
#
sudo dd if=/dev/zero of=/swapfile bs=256M count=6
sudo chmod 600 /swapfile
sudo mkswap /swapfile
echo '/swapfile swap swap defaults 0 0' | sudo tee -a /etc/fstab
sudo swapon -a
