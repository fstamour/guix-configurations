;;;;; WIP, I only generated it (with guix home import), it's not
;;;;; "reconfigured" yet (had to go).

;; This "home-environment" file can be passed to 'guix home reconfigure'
;; to reproduce the content of your profile.  This is "symbolic": it only
;; specifies package names.  To reproduce the exact same profile, you also
;; need to capture the channels being used, as returned by "guix describe".
;; See the "Replicating Guix" section in the manual.

(use-modules
 (gnu home services)
 (gnu home services desktop)
 (gnu home services shells)
 (gnu home services shepherd)
 (gnu home services ssh)
 (gnu home)
 (gnu packages admin) ;; for shepherd
 (gnu packages shells)
 (gnu packages syncthing)
 (gnu packages)
 (gnu services)
 (guix gexp))

(define %environment-variables
  (simple-service 'some-useful-env-vars-service
                  home-environment-variables-service-type
                  `(("EDITOR" . "emacsclient -nw -a emacs -nw")
                    ;; Meh
                    ;; ("VISUAL" . "emacsclient -a emacs")
                    )))

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
            (aliases %shell-aliases))))

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

(define %xmodmap
  (service home-xmodmap-service-type
           (home-xmodmap-configuration
            (key-map '(;; Switch ( with [ and ) with ]
                       ("keycode 18" . "9 braceleft")
                       ("keycode 19" . "0 braceright")
                       ("keycode 34" . "parenleft bracketleft")
                       ("keycode 35" . "parenright bracketright")
                       ;; Use Caps Lock as a compose key
                       ("keysym Caps_Lock" . "Multi_key Caps_Lock")
                       "clear Lock")))))

(define %ssh-agent
  (service home-ssh-agent-service-type
         (home-ssh-agent-configuration
          ;; TODO maybe another time... (extra-options '("-t" "1h30m"))
          )))

(define %files
  (service home-files-service-type
           `((".xsession" ,(local-file "xsession")))))

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

             "emacs-next" ;; for emacs 29.0
             "emacs-magit"
             "emacs-guix"
             "emacs-paredit"
             "emacs-vertico"
             "emacs-darkroom"
             "emacs-focus"
             "emacs-sly"

             "gforth"

             "w3m"

             "icecat"
             "kitty"
             "firefox" ;; nonguix
             "freecad"
             "keepassxc"
             "rofi"
             "steam-nvidia" ;; nonguix
             "xbacklight"
             "xclip"
             "xmodmap" "setxkbmap"
             )))

 ;; Below is the list of Home services.  To search for available
 ;; services, run 'guix home search KEYWORD' in a terminal.
 (services
  (list
   ;; Essentials
   %environment-variables

   ;; Shell
   %bash

   ;; Various daemons
   %ssh-agent
   %syncthing

   ;; Desktop
   %xmodmap
   %my-poor-eyes-i-cant-adjust-my-backlight-because-i-didnt-install-the-right-drivers-yet
   %where-have-you-been-all-my-life

   ;; Files
   %files)))
