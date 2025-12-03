# This justfile assumes some environment variables are set (see
# .envrc).
#
# Note on updating:
# 1. just update
# 2. commit & push
# 3. (on another computer) git pull
# 4. just pull-all

# By default, recipes run with the working directory set to the
# directory that contains the justfile.

######################################################################
### Targets to help with updates

# Update channel, pull system and home
update: update-channel pull-system home
# TODO perhaps reconfigure system too!

# Pull using the pinned channels
pull-all: pull pull-system

# Pull using the pinned channels
pull:
  ./guix pull --channels=channels.scm

# Pull and update channels-no-commit.scm
update-channel:
  ./guix pull --channels=channels-no-commit.scm
  ./guix describe --format=channels > channels.scm

# Update system
pull-system:
  sudo -i {{justfile_directory()}}/guix pull -C {{justfile_directory()}}/channels.scm

# Restart systemd guix service (this is for foreign distros)
restart-daemon:
  systemctl restart guix-daemon.service
# "On Guix System, upgrading the daemon is achieved by reconfiguring the system"

# Update all the packages installed "imperatively"
update-packages:
  guix upgrade

# Clean guile's build cache (often necessary when updating guix)
clean-guile-cache:
  rm ~/.cache/guile/

######################################################################
### Targets to help with Build

# reconfiguring home and system
build: build-home build-system-nu build-system-phi

# Reconfigure guix home
home:
  ./home reconfigure

# Build guix home
build-home:
  ./home build

# Reconfigure the system
host:
  host={{shell("hostname")}} ./system reconfigure

# Build the systems for the host "nu"
build-system-nu: (build-system "nu")

# Build the systems for the host "phi"
build-system-phi: (build-system "phi")

# Build a system
build-system host:
  @echo Building the system for the host {{host}}
  host={{host}} ./system build

# List all the hosts in system.scm
list-host-configurations:
  awk -F/ '/%hosts\// { print $$2 }' modules/fstamour/system.scm

######################################################################
### Targest to help clean-ups

# List the packages installed "imperatively"
list-installed-packages:
  guix package --list-installed

# Remove all the packages installed "imperatively"
remove-all-installed-package:
  guix package --list-installed | awk '{ print $1 }' | head | xargs guix package -r

gc: clean-system clean-home
    df -h /
    guix gc
    guix gc --optimize
    df -h

# Delete the system generations older than 1 month
clean-system:
  guix system delete-generations 1m || true

# Delete the home generations older than 1 month
clean-home:
  guix home delete-generations 1m || true

# Delete all the user profile's generations except the current
clean-profile:
  guix package --delete-generations || true

# List all generations
list-generations:
  guix system list-generations
  guix home list-generations
  guix package --list-generations

# List the user's GC roots
list-roots:
  guix gc --list-roots
