#!/bin/bash

if [ -z "$1" ]
  then
    echo "You need to supply a username. ./ubuntu76 <username>"
    exit 1
fi
lxc stop penguin --force
lxc delete debian-old
lxc rename penguin debian-old

lxc launch ubuntu:19.04 penguin
sleep 5

lxc exec penguin -- sh -c 'apt-get update && apt-get -y upgrade'
lxc exec penguin -- sh -c 'echo "deb https://storage.googleapis.com/cros-packages buster main" > /etc/apt/sources.list.d/cros.list'
lxc exec penguin -- sh -c 'sed -i s?packages?packages/76? /etc/apt/sources.list.d/cros.list && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 7721F63BD38B4796 && apt-get update'
lxc exec penguin -- sh -c 'apt-get install -y binutils python3 git libxss1 libasound2 gpg wget curl bzip2 apt-transport-https ca-certificates gnupg2 software-properties-common'
lxc exec penguin -- sh -c 'apt download cros-ui-config'
lxc exec penguin -- sh -c 'ar x cros-ui-config_0.12_all.deb data.tar.gz'
lxc exec penguin -- sh -c 'gunzip data.tar.gz'
lxc exec penguin -- sh -c 'tar f data.tar --delete ./etc/gtk-3.0/settings.ini'
lxc exec penguin -- sh -c 'gzip data.tar'
lxc exec penguin -- sh -c 'ar r cros-ui-config_0.12_all.deb data.tar.gz'
lxc exec penguin -- sh -c 'rm -rf data.tar.gz'
lxc exec penguin -- sh -c 'apt install -y cros-guest-tools ./cros-ui-config_0.12_all.deb'
lxc exec penguin -- sh -c 'rm cros-ui-config_0.12_all.deb'
lxc exec penguin -- sh -c 'apt install -y adwaita-icon-theme-full'
lxc exec penguin -- sh -c 'rm -rf /tmp/*'


lxc exec penguin -- sh -c 'groups ubuntu >update-groups'
lxc exec --env USER=$1 penguin -- sh -c 'sed -i "y/ /,/; s/ubuntu,:,ubuntu,/sudo usermod -aG /; s/$/ $USER/" update-groups'
lxc exec penguin -- sh -c 'killall -u ubuntu'
lxc exec penguin -- sh -c 'userdel -r ubuntu'
lxc exec --env USER=$1 penguin -- sh -c 'sed -i s/^ubuntu/$USER/ /etc/sudoers.d/90-cloud-init-users'
lxc exec penguin -- sh -c 'sed -i s?stretch?bionic?g /etc/apt/sources.list.d/cros-gpu.list'
lxc exec penguin -- sh -c 'sed -i "s/^\(deb https:\/\/deb.*\)/#\1/g" /etc/apt/sources.list.d/cros-gpu.list'
lxc exec penguin -- sh -c 'apt update && apt upgrade -y'
lxc exec penguin -- sh -c 'apt install -y libwayland-client0 libwayland-server0 libwayland-cursor0 libwayland-bin wayland-protocols'

lxc stop penguin
                          
