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
 (guix gexp)
 (local-gitlab))

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
            (guix-defaults? #t)
            (aliases %shell-aliases)
            (bashrc
             (list (plain-file "bashrc" "eval \"$(direnv hook bash)\""))))))

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


(define %local-gitlab
  (simple-service 'local-gitlab home-shepherd-service-type
                  (list (shepherd-service
                         (provision '(local-gitlab))
                         (documentation "Run local-gitlab as a shepherd (user) service")
                         (start
                          #~(make-forkexec-constructor
                             (list
                              #$(file-append local-gitlab "/bin/local-gitlab")
                              "--serve")))
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
            ;; TODO This didn't do exactly what I intended, [] is now
            ;; (), but () is now {} and {} is now []...
            (key-map '( ;; Switch ( with [ and ) with ]
                       ("keycode 18" . "9 braceleft")
                       ("keycode 19" . "0 braceright")
                       ("keycode 34" . "parenleft bracketleft")
                       ("keycode 35" . "parenright bracketright"))))))

(define %ssh-agent
  (service home-ssh-agent-service-type
           (home-ssh-agent-configuration
            ;; TODO maybe another time... (extra-options '("-t" "1h30m"))
            )))

;; .xsession seems not to work when it's a symlink
;; update: .xession not being a symlink doesn't seem to be the source
;; of the problem, because now it works with a "manually" created
;; symlink.
(define %files
  (service home-files-service-type
           `(#|(".xsession" ,(local-file "xsession"))|#)))


(home-environment
 ;; Below is the list of packages that will show up in your
 ;; Home profile, under ~/.guix-home/profile.
 (packages (specifications->packages
            (list

             "bat"
             "coreutils"
             "direnv"
             "git"
             "less"
             "make"
             "mosh"
             "podman"
             "readline"
             "rlwrap"
             "ripgrep"
             "sqlite"
             "tmux"
             "tmux"
             "fd"

             ;; Not tested yet:
             ;; "cl-slime-swank"
             ;; "cl-slynk"
             ;; "emacs-slime"

             "sbcl-slynk"
             ;; "sbcl-swank" doesn't exists...
             "sbcl"
             "sbcl-cl+ssl"

             "stumpwm-with-slynk"

             "emacs-next" ;; for emacs 29.0; for built-in eglot and use-package
             "emacs-magit"
             "emacs-guix"
             "emacs-paredit"
             "emacs-vertico"
             "emacs-darkroom"
             "emacs-focus"
             ;; "emacs-slime"
             "emacs-sly"

             ;; TODO as of 2023-05-08 guix provides gforth 0.7.3,
             ;; which is very old...
             "gforth"

             "w3m"
             "hunspell"
             "hunspell-dict-en-ca"
             "hunspell-dict-en-us"
             "hunspell-dict-en-gb"
             "hunspell-dict-fr-toutesvariantes"
             "miscfiles"

             ;; "anki" the version in guix is way too old, I'll use
             ;; the flatpak for now
             "icecat"
             "kitty"
             "firefox" ;; nonguix
             "freecad"
             "keepassxc"
             "rofi"

             "pavucontrol"

             "flatpak"
             "steam-nvidia" ;; nonguix

             "xbacklight"

             "xclip"
             "xmodmap" "setxkbmap"
             "xrandr"
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
   %local-gitlab
   %ssh-agent
   %syncthing

   ;; Desktop
   %xmodmap
   %my-poor-eyes-i-cant-adjust-my-backlight-because-i-didnt-install-the-right-drivers-yet
   %where-have-you-been-all-my-life

   ;; Files
   %files)))
