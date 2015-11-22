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

# List of allowed variables for passing as parameters for "ansible-playbook".
APB_VARS="limit tags list-tags module-path"

locate_path()
{
    local SELF_PATH=$(cd -P -- $(dirname -- ${1}) && pwd -P)

    while [ -h "${SELF_PATH}" ]; do
        # 1) cd to directory of the symlink
        # 2) cd to the directory of where the symlink points
        # 3) Get the pwd
        # 4) Append the basename
        SELF_PATH=$(cd $(dirname -- ${SELF_PATH}) && cd $(dirname -- $(readlink ${SELF_PATH})) && pwd)
    done

    echo ${SELF_PATH}
}

exit_with_help()
{
    echo "Available operations:"
    for operation in $(ls -A *.yml); do
        echo "- ${operation%%.*}"
    done
    exit 0
}

SELF_PATH=$(locate_path ${0})
SCRIPTS_PATH=${SELF_PATH}/scripts

if [ -z ${1} ]; then
    cd ${SCRIPTS_PATH}
    exit_with_help
fi

POSSIBLE_SELF_PATH=${1}/empty
locate_path ${POSSIBLE_SELF_PATH} > /dev/null 2>&1

if [ $? -gt 0 ]; then
    POSSIBLE_SELF_PATH=$(locate_path ${POSSIBLE_SELF_PATH})
fi

if [ -d ${POSSIBLE_SELF_PATH} ]; then
    cd ${POSSIBLE_SELF_PATH}
    exit_with_help
fi

PLAYBOOK=${1%%.*}.yml

for playbook in ${SCRIPTS_PATH}/${PLAYBOOK} ${SELF_PATH}/${PLAYBOOK} ${PLAYBOOK}; do
    if [ -f ${playbook} ]; then
        break
    fi
done

if [ ! -f ${playbook} ]; then
    cd ${SCRIPTS_PATH}
    exit_with_help
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

if [ -z "${ANSIBLE_HOSTS}" ]; then
  params+="-i ${SELF_PATH}/inventory"
  chmod -x ${SELF_PATH}/inventory
fi

if [ -n "${extra_vars}" ]; then
    params+=" --extra-vars='{${extra_vars}}'"
fi

export PYTHONUNBUFFERED=1

time eval "ansible-playbook -vvvv ${playbook} ${params}"
