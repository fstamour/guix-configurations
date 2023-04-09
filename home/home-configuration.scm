;;;;; WIP, I only generated it (with guix home import), it's not
;;;;; "reconfigured" yet (had to go).

;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules (gnu home)
             (gnu packages)
	     (gnu packages syncthing)
	     (gnu packages admin) ;; for shepherd
             (gnu services)
             (guix gexp)
             (gnu home services shells)
	     (gnu home services shepherd)
	     (gnu home services desktop))

;; Putting those in a variable because I'm using bash for now, but
;; I'll use fish in the future. I would be nice to have those aliases
;; defined for both!
;;
;; I'll have to decide which ones I would prefer to have abbrevs instead
(define %shell-aliases
  '(("..." . "cd ../..")
    ;; This one is not needed in fish though... that works out of the box
    (".." . "cd ..")
    ("grep" . "grep --color=auto")
    ("ll" . "ls -l")
    ("ls" . "ls -p --color=auto")
    ("cp" . "cp -i")
    ("rm" . "rm -i")
    ("mv" . "mv -i")
    ("gst" . "git status")))

(define %bash
  (service home-bash-service-type
           (home-bash-configuration
            (aliases %shell-aliases)
            (bashrc (list (local-file
                           "./.bashrc"
                           "bashrc")))
            (bash-profile (list (local-file
				 "./.bash_profile"
				 "bash_profile"))))))

(define %syncthing
  (simple-service 'syncthing home-shepherd-service-type
                  (list (shepherd-service
                         (provision '(syncthing))
			 (documentation "Run syncthing as a shepherd (user) service")
			 (start
			  #~(make-forkexec-constructor
			     (list
			      #$(file-append syncthing "/bin/syncthing")
			      ;; TODO Put synchting's log in its own file
			      ;; -logfile=...
			      ;; -logflag=... To specify the format?
                              "-no-browser")))
			 (stop #~(make-kill-destructor))))))

(define %my-poor-eyes-i-cant-adjust-my-backlight-because-i-didnt-install-the-right-drivers-yet
  (service home-redshift-service-type
           (home-redshift-configuration
            (location-provider 'manual)
	    ;; Took Ottawa's coordinates
            (latitude 45.4215)
            (longitude -75.6972))))

(define %where-have-you-been-all-my-life
  (service home-unclutter-service-type
           (home-unclutter-configuration
            (idle-timeout 2))))

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

	     "w3m"

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
  (list %bash
	%syncthing
	%my-poor-eyes-i-cant-adjust-my-backlight-because-i-didnt-install-the-right-drivers-yet
	%where-have-you-been-all-my-life)))
