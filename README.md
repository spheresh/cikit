# Continuous Integration Box

**CIBox** - is [Ansible](https://github.com/ansible/ansible) based system for deployment environment for web application development. With this tool you able to deploy local web-server based on [Vagrant](https://github.com/mitchellh/vagrant) and/or remote one.

The power of the system - simplicity. All provisioning is the same for local and remote machines, except logic for installing additional software on remote (Jenkins, for example), but it quite simple too (just `when: not vagrant` as condition for Ansible tasks).

*Currently based on `Ubuntu 14.04 LTS (64bit)`*.

```ascii
  ██████╗ ██╗     ██████╗   ██████╗  ██╗  ██╗
 ██╔════╝ ██║     ██╔══██╗ ██╔═══██╗ ╚██╗██╔╝
 ██║      ██║     ██████╔╝ ██║   ██║  ╚███╔╝
 ██║      ██║     ██╔══██╗ ██║   ██║  ██╔██╗
 ╚██████╗ ██║     ██████╔╝ ╚██████╔╝ ██╔╝ ██╗
  ╚═════╝ ╚═╝     ╚═════╝   ╚═════╝  ╚═╝  ╚═╝
```

## Main possibilities

- [Create matrix of virtual servers (droplets).](matrix)
- Automated builds for every commit in a pull request on GitHub (private repositories supported).
- Multi CMS/CMF support. To add support of a new one, you just need to put pre-configurations to `cmf/<NAME>/<MAJOR_VERSION>` and ensure that core files can be downloaded via Git.
- Opportunity to keep multiple projects on the same CI server.
- Triggering builds via comments in pull requests.
- Midnight server cleaning :)

## Quick Start

- Add your host credentials to the `inventory` file.
- `./cibox repository --project=<NAME> [--cmf=drupal] [--version=7.43] [--host=https://github.com] [--vendor=drupal]`
- `./cibox provision --project=<NAME> [--limit=<HOST>]`

### Examples

**Drupal 7** (standard system):

```shell
./cibox repository --project=test
```

**WordPress 4** (supported system):

```shell
./cibox repository --project=test --cmf=wordpress --version=4.4.2
```

## WIKI

https://github.com/propeoplemd/cibox/wiki

## TIP

Don't forget to setup all http://ci_hostname:8080/configure settings with `CHANGE_ME` placeholders to be able meet project requirements. Also you should change all `CHANGE_ME` for all Jenkins jobs.

## Variations

Currently `provision.yml` playbook powered with tags, so you can run only part of it.

```shell
./cibox provision --tags=TAGNAME
```

- php-stack
- solr
- jenkins
- composer
- pear
- drush
- xhprof
- sniffers
- apache
- mysql
- swap
- ssl-config

For provisioning Vagrant you also able to specify tags:

```shell
ANSIBLE_ARGS="--tags=TAGNAME" vagrant provision
```

As you see, any set of arguments can be passed for `ansible-playbook` command.

## The power of `cibox` utility

Run with custom inventory file:

```shell
ANSIBLE_INVENTORY="/path/to/inventory" ./cibox
```

Run with custom set of arguments:

```shell
ANSIBLE_ARGS="-vvvv" ./cibox
```

By default, `cibox` - is a global utility which looks for a project in `/var/www/`. But, if you specify a playbook outside of this directory, then working folder will be the path of this playbook.

## Dependencies

On your host machine you should have the following software:

| Name        | Version |
| ----------- | ------- |
| Vagrant     | 1.7+    |
| Ansible     | 2.0+    |
| VirtualBox  | 4.0+    |
