
# By default, recipes run with the working directory set to the
# directory that contains the justfile.

update: pull-update pull-system home

pull:
  ./guix pull --channels=channels.scm

pull-update:
  ./guix pull --channels=channels-no-commit.scm
  ./guix describe --format=channels > channels.scm

# This is for foreign distros
pull-system:
  sudo -i ./guix pull -C ~/.config/guix/channels.scm
  systemctl restart guix-daemon.service

# This is for foreign distros
# "On Guix System, upgrading the daemon is achieved by reconfiguring the system"
restart-daemon:
  systemctl restart guix-daemon.service

home:
  ./home reconfigure

# List the packages installed "imperatively"
list-installed-packages:
  guix package --list-installed

# Remove all the packages installed "imperatively"
remove-all-installed-package:
  guix package --list-installed | awk '{ print $1 }' | head | xargs guix package -r

# Update all the packages installed "imperatively"
update-packages:
  guix upgrade

clean-guile-cache:
  rm ~/.cache/guile/
