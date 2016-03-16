# Droplets management

Control a situation on a physical server using `Ansible`.

## List of droplets

```shell
./cibox matrix/matrix.yml --limit=<HOSTNAME> --tags=vm --droplet-list
```

Result of execution of this command will be similar to this:

```shell
ok: [m2.propeople.com.ua] => {
    "msg": [
        "\"cibox01\" {f06aec56-3b0b-4a4c-9109-acf17601dc9b}"
    ]
}
```

On the left is the name of VM, on the right - UUID.

## Create new droplet

```shell
./cibox matrix/matrix.yml --limit=<HOSTNAME> --tags=vm --droplet-add
```

## Delete droplet

To know the name of droplet desired to delete, look at list of available droplets.

```shell
./cibox matrix/matrix.yml --limit=<HOSTNAME> --tags=vm --droplet-delete=<NAME|UUID>
```
