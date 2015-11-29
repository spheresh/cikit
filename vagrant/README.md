# CIBox

## Installation

- [Ansible](http://docs.ansible.com/ansible/intro_installation.html#latest-releases-via-pip)
- [Vagrant](https://www.vagrantup.com/downloads.html)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)

## Usage

### Up

You able to automatically re-install web application when machine is in provisioning. Use `export REINSTALL=true` to do this.

```shell
vagrant up
vagrant ssh
```

### Re-install

Re-install web application (should be executed inside of VM).

```shell
./ansible.sh reinstall
```

### Provision

Provision or re-provision VM using tags:

```shell
ANSIBLE_ARGS="--tags=php-stack" vagrant provision
```

### Run tests

```shell
cd /var/www/tests/behat/
../../bin/behat
```

**Note**: If something happened and tests is not run, try the following steps:

Check a `Selenium` processes on guest and host machines:

```shell
ps aux | grep selenium
```

If you'll see nothing, then boldly re-provision your VM:

```shell
ANSIBLE_ARGS="--tags=selenium" vagrant provision
```

## Tools

- Drush
- Adminer
- Composer
- XDebug
- XHProf
- Selenium 2
- Sniffers, lints and hints for PHP, CSS, JS

### Adminer

**Adminer** for MySQL administration (credentials `drupal/drupal` and `root/root`): `http://192.168.56.112.xip.io/adminer.php`.

### PHP Profiler XHProf

It is installed by default, but to use it as `Devel` module integration use:

```shell
drush en devel -y
drush vset devel_xhprof_enabled 1
drush vset devel_xhprof_directory '/usr/share/php'
drush vset devel_xhprof_url '/xhprof_html/index.php'
ln -s /usr/share/php/xhprof_html xhprof_html
```

After `vset devel_xhprof_enabled` it could return an error about `Class 'XHProfRuns_Default' not found` - ignore it.

### Linux Containers

When your system enpowered with linux containers(lxc), you can speedup a lot of things by
using them and getting rid of virtualization. For approaching lxc, please install vagrant plugin.

```shell
vagrant plugin install vagrant-lxc
apt-get install redir lxc cgroup-bin
```

Also you may need to apply this patch: `https://github.com/fgrehm/vagrant-lxc/pull/354`.

When your system is enpowered by `apparmor`, you should enable `nfs` mounts for your host
machine. Do that by editing `/etc/apparmor.d/lxc/lxc-default` file with one line

```ruby
profile lxc-container-default flags=(attach_disconnected,mediate_deleted) {
  ...
    mount options=(rw, bind, ro),
  ...
```

and reload `apparmor` service:

```shell
sudo /etc/init.d/apparmor reload
```

and run the box by command:

```shell
VAGRANT_CI=lxc vagrant up
```

### Windows Containers

- Install [Cygwin](https://servercheck.in/blog/running-ansible-within-windows) according to provided steps.
- Run `Cygwin` as administrator.
- Use default flow to [up Vagrant](#up).
