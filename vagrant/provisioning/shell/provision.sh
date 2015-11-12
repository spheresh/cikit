#!/usr/bin/env bash

export DEBIAN_FRONTEND="noninteractive"

. /vagrant/provisioning/shell/os-detect.sh

echo "
   ██████╗██╗    ██████╗  ██████╗ ██╗  ██╗
  ██╔════╝██║    ██╔══██╗██╔═══██╗╚██╗██╔╝
  ██║     ██║    ██████╔╝██║   ██║ ╚███╔╝
  ██║     ██║    ██╔══██╗██║   ██║ ██╔██╗
  ╚██████╗██║    ██████╔╝╚██████╔╝██╔╝ ██╗
   ╚═════╝╚═╝    ╚═════╝  ╚═════╝ ╚═╝  ╚═╝
"

if [[ "${ID}" == "debian" || "${ID}" == "ubuntu" ]]; then
    echo "Running apt-get update"
    apt-get update >/dev/null
fi

if [[ "${ID}" == "ubuntu" && ("${CODENAME}" == "lucid" || "${CODENAME}" == "precise") ]]; then
    echo "Installing basic CURL packages (Ubuntu only)"
    apt-get install -y libcurl3 libcurl4-gnutls-dev curl >/dev/null
fi

echo "Installing base packages for Ansible"
apt-get -y --force-yes install python python-dev python-simplejson sudo curl make rsync git libmysqlclient-dev apparmor-utils >/dev/null
# Because basic ubuntu is too stripped down we need to add logging.
apt-get --reinstall install -y --force-yes bsdutils >/dev/null
# Needed to use apt-add-repository.
apt-get -y --force-yes install software-properties-common python-software-properties >/dev/null

echo "Installing pip via easy_install"
wget https://raw.githubusercontent.com/ActiveState/ez_setup/v0.9/ez_setup.py
python ez_setup.py
rm -f ez_setup.py
easy_install pip
# Make sure setuptools are installed crrectly.
pip install setuptools --no-use-wheel --upgrade

echo "Installing required Python modules"
pip install paramiko pyyaml jinja2 markupsafe MySQL-python

echo "Installing Ansible"
pip install ansible

/var/www/ansible.sh /vagrant/provisioning/scripts/provision.yml
