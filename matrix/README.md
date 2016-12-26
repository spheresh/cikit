# Matrix

You are able to create your own matrix with virtual servers using this tool.

Let's describe both structure and technologies. First of all, we need to get acquainted with two basic terms: `host` and `droplet`.

- `host` is a physical computer (server);
- `droplet`is a virtual machine, located on the `host`.

As much droplets as needed can be created on a host machine (depending on hardware configuration, of course).

Host machine operates only with minimal set of software:

- VirtualBox
- NGINX
- PHP
- phpVirtualBox

Each droplet has its own private network, which is forwarded to a host. For example, you have 10 virtual servers. Each of them forwards to three ports: `80<NN>`, `443<NN>` and `22<NN>` (`<NN>` is a serial number of the droplet). NGINX is listening `80<NN>` and `443<NN>` ports in a host and forwards connection inside the droplets. `80<NN>` forwards to 80, `443<NN>` - to 443. `22<NN>` forwards to 22, for SSH connections.

That's all! And it's cool! Each virtual server may be additionally provisioned by main `cikit` tool to convert it to CI server.

## Usage

Add your own host inside the `inventory` file and run the following command:

```shell
./cikit matrix/matrix.yml --limit=<HOSTNAME>
```

New droplets (VMs) will be based on an image, which is assumed as [base](vars/virtualmachine.yml#L13) for the matrix.

### Add trusted SSL certificate

There are two files inside the `/path/to/directory/`, they must be located: `*.crt` and `*.key`. They will be copied and NGINX will start use them immediately.

```shell
./cikit matrix/matrix.yml --limit=<HOSTNAME> --tags=ssl --ssl-src=/path/to/directory/ --restart=nginx
```

## Management

You are able to choose two ways for managing your virtual machines: whether using [Ansible](docs/droplet/ANSIBLE.md) or [UI of PHP Virtual Box](docs/droplet/UI.md).

## To do

- [ ] Permission to add SSH keys to the droplet on creation phase
- [ ] Reuse roles from Matrix in CIKit (`nginx`, `ssl`)
- [ ] Set hostname for each new droplet
