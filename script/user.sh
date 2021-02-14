#!/bin/bash -eu

date > /etc/box_build_time

SSH_USER=${SSH_USERNAME:-vagrant}
SSH_PASS=${SSH_PASSWORD:-vagrant}
SSH_USER_HOME=${SSH_USER_HOME:-/home/${SSH_USER}}
SSH_USER_PUBKEY=${SSH_USER_PUBKEY:-""}

# Create Vagrant user (if not already present)
if ! id -u $SSH_USER > /dev/null 2>&1; then
    echo "==> Creating $SSH_USER user"
    groupadd $SSH_USER
    useradd $SSH_USER -g $SSH_USER -G sudo -d $SSH_USER_HOME --create-home
    echo "${SSH_USER}:${SSH_PASS}" | chpasswd
fi

echo "==> Giving ${SSH_USER} sudo powers"
echo "${SSH_USER}        ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers.d/${SSH_USER}
chmod 440 /etc/sudoers.d/${SSH_USER}

# Fix stdin not being a tty
if grep -q "^mesg n" /root/.profile && sed -i "s/^mesg n/tty -s \\&\\& mesg n/g" /root/.profile; then
    echo "==> Fixed stdin not being a tty."
fi

echo "==> Installing vagrant key"
mkdir ${SSH_USER_HOME}/.ssh
chmod 700 ${SSH_USER_HOME}/.ssh
cd ${SSH_USER_HOME}/.ssh

echo "${SSH_USER_PUBKEY}" >> ${SSH_USER_HOME}/.ssh/authorized_keys

chmod 600 ${SSH_USER_HOME}/.ssh/authorized_keys
chown -R ${SSH_USER}:${SSH_USER} ${SSH_USER_HOME}/.ssh
