#!/usr/bin/env bash

set -euo pipefail

cmd=(   
    # Find candidate store paths
    find /gnu/store -mindepth 1 -maxdepth 1 -type d -name "'*system'"
   
    # Match the name of the derivation exactly
    \| grep "'^/gnu/store/[a-z0-9]\{32\}-system'"

    # call grep on each config
    \| xargs -n 1 -I %  grep "$@" %/configuration.scm -H --color
)

echo "${cmd[*]}"
echo "${cmd[*]}" | bash


