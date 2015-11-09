#!/usr/bin/env bash

# Dependencies:
# - bash
# - cd
# - dirname
# - pwd
# - readlink
# - ls
# - time
# - eval
# - ansible-playbook

SELF_PATH=$(cd -P -- $(dirname -- ${0}) && pwd -P)
# List of variables which will be passed as parameters for "ansible-playbook".
APB_VARS="limit tags list-tags module-path"

while [ -h "${SELF_PATH}" ]; do
    # 1) cd to directory of the symlink
    # 2) cd to the directory of where the symlink points
    # 3) Get the pwd
    # 4) Append the basename
    SELF_PATH=$(cd $(dirname -- ${SELF_PATH}) && cd $(dirname -- $(readlink ${SELF_PATH})) && pwd)
done

cd ${SELF_PATH}/scripts

if [[ -z ${1} || ${1} == "--op" ]]; then
    echo "Available operations:"
    for operation in $(ls -A *.yml); do
        echo "- ${operation%%.*}"
    done
    exit 0
fi

extra_vars=""
params=""

# Parse extra varaiables.
for ((i = 2; i <= $#; i++)); do
    # Remove all data after "=" symbol.
    var=${!i%=*}
    val=${!i#*=}

    # Remove leading "--".
    var=${var#--}
    val=${val#--}

    for j in ${APB_VARS}; do
        if [ "${var}" == "${j}" ]; then
            params+=" --${var}"

            if [ "${var}" != "${val}" ]; then
                params+="=${val}"
            fi
        fi
    done

    if [ "${var}" == "${val}" ]; then
        val="True"
    fi

    # Replace all "-" by "_" in argument name.
    var=${var//-/_}

    if [[ ${val} != {* && ${val: -1} != "}" ]]; then
        val="\"${val}\""
    fi

    extra_vars+="\"${var}\":${val},"
done

# Remove last comma.
extra_vars=${extra_vars%%,}

if [ -n "${extra_vars}" ]; then
    params+=" --extra-vars='{${extra_vars}}'"
fi

export PYTHONUNBUFFERED=1

time eval "ansible-playbook -vvvv ${1}.yml -i ../inventory ${params}"
