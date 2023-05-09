#!/usr/bin/env -S awk -f
#
# Use awk to generate a makefile from a tsv-like file
#
# TODO check for repos with the same name? (e.g. if I want to clone an
# official repo and my fork at the same time).

######################################################################
# Functions

# print a "meta" target (a phony target that only groups a bunch of
# targets)
function meta(target, prerequisites) {
    print ".PHONY: " target
    for(prerequisite in prerequisites) {
	print target ": " prerequisite
    }
    print ""
}

function deref(var) {
    return "$(" var ")"
}

# TODO I don't use this anymore
function join(array, sep,    result, i)
{
    if (sep == "") {
       sep = " "
    } else if (sep == SUBSEP) {
       sep = ""
    }
    for(key in array) {
        result = result sep key
    }
    return result
}

######################################################################
# Global initialisation

BEGIN {
    # Split the records by tabs (in this case, 1 line = 1 record).
    FS="\t"

    # repos: variable to keep track of all the targets to clone
    # repositories.

    # links: variable to keep track of all the phony targets to create
    # the symlinks.

    # hostnames: variable to keep track of each "hosts", to be able to
    # generate one phony target per host.
}

# Skip empty lines
NF == 0 { next }

# Skip comments
/^\s*#/ { next }

######################################################################
# Extract the data

# Init some variables (for each line)
{
    url = ""
    repo_name = ""
    destination = ""
}

# If there is a line that starts with "host:", the following lines
# will assume the first field is the name of the repo, and that the
# repo located on that host.
/^host:/ {
    host = $3 # e.g. git@...
    hostname = $2 # e.g mylittlegitforge
    if(!hostname) {
	hostname = "other"
    }
    print "####################"
    print "### " hostname " (" host ")"
    print ""
    # Skip the rest of the processing for this line, and process the
    # next line.
    next
}

# Minimal error-checking
NF > 2 {
    print "ERROR: Line " NR " has too many fields:"
    print
    exit(1)
}

host {
    repo_name = $1
    url = host repo_name ".git"
}

# If the url was not set from the "host" variable, then the first
# column is the whole url.
!url {
    if(match($1, /.git$/)){
	url = $1
    } else {
	url = $1 ".git"
    }
}

# Extract the name of the repo from the URL, if not already set
!repo_name {
    match(url, /\/[^/]*\.git$/)
    repo_name = substr(url, RSTART+1, RLENGTH-5)
}

# Optionally, the second field contains the path of an extra symlink
# to create OR an alternative name to use for the repo
NF > 1 {
    if($2 !~ /\//) {
	repo_name = $2
    } else {
	destination = $2
    }
}

host  { hostnames[hostname] = hostnames[hostname] " " repo_name }
!host { hostnames["other"] = hostnames["other"] " " repo_name }

######################################################################
# Generate each repositories' targets

# Print the makefile target to clone the repository
{
    print "# " repo_name
    print repo_name ":"
    print "\tgit clone --recursive " url " " repo_name
    print ""
    
    repos[repo_name]
}

function print_symlink_target(destination, suffix) {
    var = toupper(repo_name "_" suffix)
    gsub(/-/, "_", var)
    print var  " := " destination

    print deref(var) ": | " repo_name
    print "\tln -s $(abspath " repo_name ") $@"

    # Print a phony makefile target for the same thing
    link_target = "link-" repo_name "-" suffix
    print ".PHONY: " link_target
    print link_target ": " deref(var)

    print ""
    
    links[link_target]
}

# Print the makefile targetS to create the symlink
{
    print_symlink_target("~/dev/" repo_name, "dev")
}

destination {
    print_symlink_target(destination, "extra")
}

{ print "" }

######################################################################
# Generate the "clone" and "link" phony targets

END {
    print "###\n"
    meta("clone", repos)
    meta("link", links)

    # That over-engineered, but... print per-host targets
    for(host in hostnames) {

	print ".PHONY: " host
	print host ": " host "-clone " host "-link"
	
	print ".PHONY: " host "-clone"
	print host "-clone: " hostnames[host]

	print ".PHONY: " host "-link"
	# this sets the "targets" variable
	split(hostnames[host], targets, " ")
	for(i in targets) {
	    target = targets[i]

	    print host "-link: link-" target "-dev"
	    
	    extra_link = "link-" target "-extra"
	    if(extra_link in links) {
		print host "-link: " extra_link
	    }
	}
	print ""
    }
}


