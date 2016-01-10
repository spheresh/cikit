#!/usr/bin/env bash

# http://www.caliban.org/bash/#completion

_cibox_complete()
{
  COMPREPLY=($(compgen -W "$(cibox)" -- "${COMP_WORDS[COMP_CWORD]}"))
}

complete -F _cibox_complete cibox
