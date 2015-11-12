# CIBox (Continuous Integration Box)

## Quick Start

- Add your host credentials to the `inventory` file.
- `./ansible.sh jenkinsbox --project=NAME --limit=HOST`
- `./ansible.sh drupal --project=<NAME> [--cmf=drupal] [--version=7.41] [--host=https://github.com] [--vendor=drupal]`

## Dependencies

| Name        |    | Version |
| ----------- | -- | ------- |
| Git         | >= | 1.7     |
| Ansible     | >= | 1.9     |
| Vagrant     | >= | 1.7     |
| VirtualBox  | >= | 4.0     |

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

This repo consists basically from two playbooks:
- CI server installation/provisioning `jenkinsbox.yml`;
- `drupal.yml` repo builder with Drupal, vagrant, `pp` installation profile, scripts for reinstalling and sniffing

You have to use *64bit* Ubuntu 14.04 LTS system for CI server

## Common and base apps and packages

`cibox-misc` role contains all basic packages required for cibox and vagrant installation.

## Possible variations

Currently `jenkinsbox.yml` playbook powered with tags, so you can run only part of it.

```sh
./ansible.sh jenkinsbox --tags="TAGNAME"
```

- php-stack
- ansible-jetty-solr
- ansible-jenkins
- ansible-composer
- ansible-php-pear
- ansible-php-xhprof
- ansible-sniffers
- apache
- mysql
- cibox-mysql-config
- cibox-swap
- cibox-ssl-config


## OpenVZ support

If your system build on OpenVZ stack and swap is disabled you may bypass
it with using `fakeswap.sh` file within `files/fakeswap` directory.

```shell
chmod a+x fakeswap.sh
sh ./fakeswap.sh 4086
```

for adding `4086MB` swap size.

## Roles not used by default

- `cibox-phpdaemon`: HP project for installing phpdaemon;
- `ansible-role-php-pecl`: originally developed by @geerlingguy but without 
 dependency from his PHP playbook. Can be used for installing PECL packages.

