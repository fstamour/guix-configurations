;;;;; WIP, I only generated it (with guix home import), it's not
;;;;; "reconfigured" yet (had to go).

;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules (gnu home)
             (gnu packages)
             (gnu services)
             (guix gexp)
             (gnu home services shells))

(home-environment
 ;; Below is the list of packages that will show up in your
 ;; Home profile, under ~/.guix-home/profile.
 (packages (specifications->packages
	    (list
             "fd"
	     "make"

	     "podman"

             "git"
             "tmux"
             "rlwrap"
             "readline"
             "sqlite"

	     "sbcl-slynk"
             "sbcl"
             "sbcl-cl+ssl"
	     "stumpwm-with-slynk" ;; TODO install as root or user??

             "emacs"
	     "emacs-magit"
	     "emacs-guix"
	     "emacs-paredit"
             "emacs-vertico"
             "emacs-darkroom"
             "emacs-focus"
             "emacs-sly"

	     "gforth"

             "kitty"
             "xbacklight"
             "xclip"
             "keepassxc"
             "steam-nvidia" ;; nonguix
             "freecad"
             "firefox" ;; nonguix
             "icecat")))

 ;; Below is the list of Home services.  To search for available
 ;; services, run 'guix home search KEYWORD' in a terminal.
 (services
  (list (service home-bash-service-type
                 (home-bash-configuration
                  (aliases '(("..." . "cd ../..")
			     (".." . "cd ..")
			     ("grep" . "grep --color=auto")
			     ("ll" . "ls -l")
                             ("ls" . "ls -p --color=auto")))
                  (bashrc (list (local-file
                                 "/home/fstamour/dev/guix-configurations/home/.bashrc"
                                 "bashrc")))
                  (bash-profile (list (local-file
                                       "/home/fstamour/dev/guix-configurations/home/.bash_profile"
                                       "bash_profile"))))))))
