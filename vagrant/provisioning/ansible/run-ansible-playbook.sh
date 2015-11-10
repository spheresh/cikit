#!/usr/bin/env bash

export ANSIBLE_PLAYBOOKS_PATH=$(cd -P $(dirname ${BASH_SOURCE}) && pwd)

for operation in $(ls -A ${ANSIBLE_PLAYBOOKS_PATH}/*.yml); do
    operation=${operation%%.*}
    ./../../ansible.sh ${operation}

    if [ $? -eq 0 ]; then
        echo "Finished installing ${operation}"
    else
        echo "Failed installing ${operation}"
        exit 1
    fi
done
