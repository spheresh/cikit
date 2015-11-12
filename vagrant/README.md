# Drupal Vagrant box for CIBox support

## Installation

- [Vagrant](https://www.vagrantup.com/downloads.html)
- [VirtualBox](https://www.virtualbox.org/wiki/Downloads)
- Useful plugins:
  - [vagrant plugin install vagrant-hostsupdater](https://github.com/cogitatio/vagrant-hostsupdater)
  - [vagrant plugin install vagrant-vbguest](https://github.com/dotless-de/vagrant-vbguest)

## Usage

Start and provision the virtual machine:

```shell
vagrant up
vagrant ssh
```

Re-installation from scratch:

```shell
./ansible.sh reinstall [--windows]
```

- By default your site will be accessible using this URL: `http://drupal.192.168.56.132.xip.io/`.
- If `xip.io` not working - create a row with `192.168.56.112 drupal.192.168.56.132.xip.io` in `/etc/hosts` or just use another ServerName in www.yml

## Tools

- XDebug
- Drush
- Selenium 2
- Composer
- Adminer
- XHProf
- PHP Daemon
- PHP, SASS, JS sniffers/lints/hints

### Adminer

Adminer for MySQL administration (credentials drupal:drupal and root:root): `http://192.168.56.112.xip.io/adminer.php`.

### PHP Profiler XHProf

It is installed by default, but to use it as Devel module integration use:

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
VAGRANT_CI=yes vagrant up
```

### Windows Containers

- Install [Cygwin](https://servercheck.in/blog/running-ansible-within-windows) according to provided steps.
- Run Cygwin as administrator.
- Add `export VAGRANT_DETECTED_OS=cygwin` to `~/.bash_profile` using Cygwin CLI.
- Use default flow to up Vagrant.
