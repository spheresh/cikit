# Vagrant Box

## Creation process

- Create virtual machine with name `CIKit Ubuntu 16.04 LTS`, disabled audio and USB.
- Install Ubuntu, downloaded from https://www.ubuntu.com/download/server.
- Set password for `root` and `vagrant` users to "[vagrant](../../../matrix/roles/virtualmachine/tasks/droplet/bootstrap.yml#L46)".
- Deny `root` user to be logged in via password (set `PermitRootLogin` to `prohibit-password` in `/etc/ssh/sshd_config`). It is important since password for this user not just weak - it's known for all the world and grants an access to this virtual machine for everyone!
- Permit `vagrant` user to run `sudo` without password (`/etc/sudoers.d/vagrant`).
- Add [official public key of Vagrant](https://github.com/mitchellh/vagrant/tree/master/keys) to `/home/vagrant/.ssh/authorized_keys`.
- Install OpenSSH.
- Install VirtualBox Guest Additions.

Nice, detailed instruction available here: https://blog.engineyard.com/2014/building-a-vagrant-box

![Starting message](images/cikit-vagrant-box-motd.png)
