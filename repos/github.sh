#!/usr/bin/env bash
#
# Script to fetch a list of repositories from GitHub
#
# TODO Move all of this into `cache-cache`

set -ueo pipefail

base=https://api.github.com

function get() {
    # try "curl -i" to also get the headers
    curl -sx $base/users/fstamour/repos?page=$1 | jq ".[]"
    # hint on how to know when to stop without looking at the headers:
    # - the api would return [] if you fetch one page too far
    # - `echo [] | jq ".[]"` == ""
    # - there's also `jq length`
}

# Don't fetch the list if we already have it
if [ ! -f github.json ]; then
    (
# this is super dumb, but it works
	get 1
	get 2
	get 3
	get 4
	get 5
    ) > github.json
fi

# Print some stats/info
# echo "I have $(jq -s length github.json) repositories in GitHub"
# echo "$(jq -s 'map(select(.fork == true)) | length' github.json) are forks"
# echo  "The forks:"
# jq -s 'map(select(.fork == true)) | map(.name)' github.json


if [ ! -f upstreams.sh ]; then
    # For each fork, get the upstream repo
    (
	jq -r -s 'map(select(.fork == true)) | .[] | .name + " " + .git_url' github.json \
	    | while read name origin; do
	    upstream=$(curl -s $base/repos/fstamour/$name | jq -r .parent.clone_url)
	    echo "### $origin $name $upstream"
	    echo "git clone --recursive $origin $name"
	    echo "cd $name"
	    echo "git remote add upstream $upstream"
	    echo
	done
    ) | tee upstreams.sh
fi

echo "
###
Forks:
"
awk '/^### / { print $3 }' upstreams.sh | sort | column

echo "
###
Mine:
"

echo "host:	github	git@github.com:fstamour/" > github.tsv
jq -r -s 'map(select(.fork == false)) | map(.name) | .[]' github.json \
    | sort \
    | tee -a  github.tsv \
    | column



# TODO use GitHub's API to sync my forks
# https://github.blog/changelog/2021-09-03-api-to-sync-fork-with-upstream/
