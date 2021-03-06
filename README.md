# Continuous Integration Kit

**CIKit** - [Ansible](https://github.com/ansible/ansible)-based system for deploying development environments or clusters of them. With this tool everyone is able to create virtual machine (based on [Vagrant](https://github.com/mitchellh/vagrant) using VirtualBox provider) for particular team member, matrix of continuous integration servers or single CI server for project(s).

*Currently based on [Ubuntu 16.04 LTS (64 bit)](docs/vagrant/box)*.

```ascii
 ██████╗ ██╗    ██╗  ██╗ ██╗ ████████╗
██╔════╝ ██║    ██║ ██╔╝ ██║ ╚══██╔══╝
██║      ██║    █████╔╝  ██║    ██║   
██║      ██║    ██╔═██╗  ██║    ██║   
╚██████╗ ██║    ██║  ██╗ ██║    ██║   
 ╚═════╝ ╚═╝    ╚═╝  ╚═╝ ╚═╝    ╚═╝   
```

## Main possibilities

- [Create matrix of virtual servers (droplets)](docs/matrix).
- Automated builds for each commit in a pull request on GitHub (private repositories are supported).
- Multi CMS/CMF support (`Drupal` and `WordPress` at the moment). To introduce a new one, you just have to add pre-configurations to `cmf/<NAME>/<MAJOR_VERSION>` and make sure that system is downloadable as an archive.
- Opportunity to keep multiple projects on the same CI server.
- Triggering builds via comments in pull requests.
- Applying [sniffers](docs/project/sniffers) to control code quality.
- Possibility to choose software versions.
- Midnight server cleaning :)

## Documentation

Global project documentation [available here](docs#documentation).

## Slack

All communications are available in our Slack account at https://cikit.slack.com

## Quick Start

- Get the **CIKit**.

  ```shell
  git clone --recursive https://github.com/BR0kEN-/cikit.git
  cd cikit
  ```

- Create CIKit-based project.

  ```shell
  ./cikit repository --project=<NAME> [--cmf=drupal|wordpress] [--version=7.54|8.3.x-dev|4.7.5] [--without-sources]
  git init
  git add .
  git commit -m 'Init of CIKit project'
  ```

  The `--without-sources` option for project creation task affects CMF sources downloading. Use it if you want to create an empty project (CIKit-structured package with empty `docroot` directory, where you have to store the source code of Drupal/WordPress/whatever).

- Build virtual machine for local development.

  ```shell
  vagrant up --provision
  ```

  Build website inside of ready VM (will be accessible at `https://<NAME>.dev`).

  ```shell
  vagrant ssh
  cikit reinstall
  ```

- Add your host credentials to the [inventory](docs/ansible/inventory) file (not needed to continue without remote CI server).

- Provision remote CI server.

  ```
  cd <NAME>
  ./cikit .cikit/provision --limit=<HOST>
  ```

Last two steps are not mandatory. You can omit them and use CIKit as local environment for development.

## Provisioning variations

**Provision** - is an operation that configure CI server or virtual machine and install necessary software there to convert it to unit for development.

Initially (at the very first time) you are required to run full provisioning to build the environment correctly. After that you may decide to reinstall or reset configuration of some part of it. This is feasible thanks to separation of the provisioning.

Get the list of components to provision:

```shell
./cikit .cikit/provision --list-tags
```

Run provisioning of specific component (CI server):

```shell
ANSIBLE_ARGS="--tags=COMPONENT" ./cikit .cikit/provision
```

Run provisioning of specific component (virtual machine):

```shell
ANSIBLE_ARGS="--tags=COMPONENT" vagrant provision
```

## The power of `cikit` utility

Run with custom inventory file:

```shell
ANSIBLE_INVENTORY="/path/to/inventory" ./cikit
```

Run with custom set of arguments:

```shell
ANSIBLE_ARGS="-vvvv" ./cikit
```

By default, `cikit` - is a global utility (only inside of VM) which looks for a project in `/var/www/`. But if you specify a playbook outside of this directory, then working folder will be the path of this playbook.

## Dependencies

You should have the following software on your host machine:

| Name        | Version |
| ----------- | ------- |
| Vagrant     | 1.9+    |
| Ansible     | 2.2+    |
| VirtualBox  | 5.1+    |
