# Continuous Integration Box

**CIBox** - is [Ansible](https://github.com/ansible/ansible) based system for deployment environment for web application development. With this tool you able to deploy local web-server based on [Vagrant](https://github.com/mitchellh/vagrant) and/or remote one.

The power of the system - simplicity. All provisioning is the same for local and remote machines, except logic for installing additional software on remote (Jenkins, for example), but it quite simple too (just `when: not vagrant` as condition for Ansible tasks).

```ascii
  ██████╗██╗     ██████╗  ██████╗ ██╗  ██╗
 ██╔════╝██║     ██╔══██╗██╔═══██╗╚██╗██╔╝
 ██║     ██║     ██████╔╝██║   ██║ ╚███╔╝
 ██║     ██║     ██╔══██╗██║   ██║ ██╔██╗
 ╚██████╗██║     ██████╔╝╚██████╔╝██╔╝ ██╗
  ╚═════╝╚═╝     ╚═════╝  ╚═════╝ ╚═╝  ╚═╝
```

## Main possibilities

- Automated builds for every commit in a pull request on GitHub (private repositories supported).
- Multi CMS/CMF support. To add support of a new one, you just need to put pre-configurations to `cmf/<NAME>/<MAJOR_VERSION>` and ensure that core files can be downloaded via Git.
- Opportunity to keep multiple projects on the same CI server.
- Triggering builds via comments in pull requests.
- Midnight server cleaning :)

## Quick Start

- Add your host credentials to the `inventory` file.
- `./ansible.sh provision --project=<NAME> [--limit=<HOST>]`
- `./ansible.sh repository --project=<NAME> [--cmf=drupal] [--version=7.41] [--host=https://github.com] [--vendor=drupal] [--adminer=4.2.2|none]`

### Examples

**Drupal 7** (standard system):

```shell
./ansible.sh repository --project=test
```

**WordPress 4** (supported system):

```shell
./ansible.sh repository --project=test --cmf=wordpress --version=4.3.1
```

## CIBox mailing list

- To post to this group, send email to ci_box@googlegroups.com
- To unsubscribe from this group, send email to ci_box+unsubscribe@googlegroups.com
- Visit and Join this group at https://groups.google.com/d/forum/ci_box
- For more options, visit https://groups.google.com/d/optout

## WIKI

https://github.com/propeoplemd/cibox/wiki

## TIP:

Don't forget to setup all http://ci_hostname:8080/configure settings with CHANGE_ME... placeholders to be able meet project requirements.
Also you should change all CHANGE_ME placeholders for DEMO and PR builders jobs as well.

You have to use *64bit* Ubuntu 14.04 LTS system for CI server

## Possible variations

Currently `provision.yml` playbook powered with tags, so you can run only part of it.

```sh
./ansible.sh provision --tags="TAGNAME"
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

## OpenVZ support

If your system build on OpenVZ stack and swap is disabled you may bypass
it with using `fakeswap.sh` file within `files` directory.

```shell
chmod a+x fakeswap.sh
sh ./fakeswap.sh 4086
```

for adding `4086MB` swap size.

## Roles not used by default

- `cibox-phpdaemon`: HP project for installing phpdaemon;
- `ansible-role-php-pecl`: originally developed by @geerlingguy but without 
 dependency from his PHP playbook. Can be used for installing PECL packages.

## Dependencies

| Name        | Version |
| ----------- | ------- |
| Vagrant     | 1.7+    |
| Ansible     | 1.9+    |
| VirtualBox  | 4.0+    |
