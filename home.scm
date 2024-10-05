
(define-module (home home-configuration)
  #:use-module (gnu home services)
  #:use-module (gnu home services desktop)
  #:use-module (gnu home services shells)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services ssh)
  #:use-module (gnu packages ssh) ;; for autossh
  #:use-module (gnu home)
  #:use-module (gnu packages admin) ;; for shepherd
  #:use-module ((gnu packages lisp) #:prefix lisp:)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages syncthing)
  #:use-module (gnu packages)
  #:use-module (gnu packages wm) ;; for dunst
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (fstamour lisp)
  ;; WIP (fstamour streamdeck)
  #:use-module ((fstamour syncthing) #:select (%syncthing)))

(use-modules
 (gnu home services)
 (gnu home services desktop)
 (gnu home services shells)
 (gnu home services shepherd)
 (gnu home services ssh)
 (gnu packages ssh) ;; for autossh
 (gnu home)
 (gnu packages admin) ;; for shepherd
 ((gnu packages lisp) #:prefix lisp:)
 (gnu packages shells)
 (gnu packages syncthing)
 (gnu packages)
 (gnu packages wm) ;; for dunst
 (gnu services)
 (guix gexp)
 (fstamour lisp)
 ;; WIP (fstamour streamdeck)
 )

(define (host-nu?)
  (string= "nu" (gethostname)))

(define (host-phi?)
  (string= "phi" (gethostname)))

(define (host-other?)
  (and
   (not (host-nu?))
   (not (host-phi?))))

(define %environment-variables
  (simple-service 'some-useful-env-vars-service
                  home-environment-variables-service-type
                  `(("EDITOR" . "emacsclient -nw -a emacs -nw")
                    ;; Meh
                    ;; ("VISUAL" . "emacsclient -a emacs")
                    ("PAGER" . "less")
                    ("PATH" . "$HOME/.local/bin:$PATH")
                    )))

;; Putting those in a variable because I'm using bash for now, but
;; I'll use fish in the future. I would be nice to have those aliases
;; defined for both!
;;
;; I'll have to decide which ones I would prefer to have abbrevs instead
;; TODO https://fishshell.com/docs/current/cmds/alias.html
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
            (aliases %shell-aliases))))

(define %myelin
  (let ((entrypoint (string-append (getenv "HOME")
                                   "/dev/myelin/scripts/dev.lisp")))
    (when (file-exists? entrypoint)
      (simple-service 'myelin home-shepherd-service-type
                      (list (shepherd-service
                             (provision '(myelin))
                             (documentation "Run myelin as a shepherd (user) service")
                             (start
                              #~(make-forkexec-constructor
                                 (list
                                  #$(file-append lisp:sbcl "/bin/sbcl")
                                  "--noinform"
                                  "--non-interactive"
                                  "--disable-debugger"
                                  "--load"
                                  (string-append (getenv "HOME")
                                                 "/dev/myelin/loader.lisp")
                                  "--load"
                                  (string-append (getenv "HOME")
                                                 "/dev/myelin/scripts/dev.lisp")
                                  "--eval" "(loop (sleep 1))")))
                             (stop #~(make-kill-destructor))))))))

(define %my-poor-eyes-i-cant-adjust-my-backlight-because-i-didnt-install-the-right-drivers-yet
  (service home-redshift-service-type
           (home-redshift-configuration
            (location-provider 'manual)
            ;; Took Ottawa's coordinates
            (latitude 45.4215)
            (longitude -75.6972))))

(define %unclutter ; hide the mouse after some time of inactivity
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

(define %autossh-vps
  (simple-service 'autossh home-shepherd-service-type
                  (list (shepherd-service
                         (provision '(autossh))
                         (documentation "Run autossh as a shepherd (user) service")
                         (start
                          #~(make-forkexec-constructor
                             (list
                              #$(file-append autossh "/bin/autossh")
                              "-M" "2223"
                              "-C" ; compression of all data
                              ;; "-g"
                              "-o" "ServerAliveCountMax=3"
                              "-o" "ServerAliveInterval=60"
                              "-o" "ExitOnForwardFailure=yes"
                              ;; No tty
                              "-T"
                              ;; Do not execute a remote command.
                              "-N"
                              ;; Remote forward: port 2222 on "sartre"
                              ;; is forwarded to localhost's port 22
                              "-R" "2222:localhost:22" "sartre")))
                         (stop #~(make-kill-destructor))))))

(define %dunst
  (simple-service 'dunst home-shepherd-service-type
                  (list (shepherd-service
                         (provision '(dunst))
                         (documentation "Run dunst as a shepherd (user) service")
                         (start
                          #~(make-forkexec-constructor
                             (list
                              #$(file-append dunst "/bin/dunst"))))
                         (stop #~(make-kill-destructor))))))

(define %command-line-stuff
  `(
    ;; This should be installed on the OS (too?)
    ;; The one in guix is newer than the on on my ubuntu host
    "fish"
    "fish-foreign-env"

    "git" "git-lfs"
    ,@(if (host-other?)
          (list)
          ;; amixer, aplay
          `("alsa-utils"))
    "bind:utils"                        ; nslookup, dig, etc
    "coreutils"
    "moreutils"                         ; sponge, ts, etc.
    "curl"
    "direnv"
    "entr"
    "fd"
    "file"
    "fzf"
    "htop"
    "jq"
    "less"
    "m4"
    "make"
    "mandoc"
    "mosh"
    "net-tools"                         ; netstat (and much more)
    "netcat-openbsd"
    "nmap"
    "readline"
    "ripgrep"                          ; grep -R
    "rlwrap"                           ; add readline to other command
    "skopeo"                           ; to copy containers around
    "screen"
    "sqlite"
    "tmux"                              ; terminal multiplexer
    "tree"                              ; list file
    "w3m"                               ; browser
    "xxd"                               ; hex
    "bat"                               ; viewer
    "ranger"                            ; file manager
    "mc"                                ; file manager
    "strace"
    "tesseract-ocr"
    "zip" "unzip"
    "sshfs"
    ))

;; bsd-games

(define %lisp-scheme-and-emacs
  `(
    ;; Not tested yet:
    ;; "cl-slime-swank"
    ;; "cl-slynk"
    ;; "emacs-slime"

    ;; "sbcl-slynk"
    ;; "sbcl-swank" doesn't exists...
    "sbcl"
    ;; to be able to load ssl without too much fuss
    "sbcl-cl+ssl"
    "sbcl-cffi"
    ;; "emacs-slime"
    ;; "emacs-sly"

    ;; "stumpwm-with-slynk"
    "stumpwm"
    "stumpish"
    ;; TODO try "sawfish"

    "guile"
    "guile-readline"
    "guile-colorized"

    "emacs"
    "emacs-magit"
    "emacs-guix"
    "emacs-envrc"

   ;;; Editing stuff
    "emacs-aggressive-indent"
    "emacs-emmet-mode"
    "emacs-lispy"
    "emacs-paredit"
    "emacs-prettier"
    ;; "emacs-sqlformat" ; not in guix
    "emacs-tempel"

   ;;; Aesthetic stuff
    ;; "emacs-darkroom" ; doesn't work (arithmetic error)
    "emacs-focus"
    "emacs-writeroom"

    "emacs-page-break-lines"
    "emacs-rainbow-delimiters"
    "emacs-diminish"

    ;; Themes (I don't know which one I want 😅)
    ;; guix search emacs theme | grep name: | grep -e '-theme$' | awk '{print $2}' | copy
    ,@`("emacs-spacemacs-theme"
        "emacs-tao-theme"
        "emacs-rebecca-theme"
        "emacs-abyss-theme"
        "emacs-cyberpunk-theme"
        "emacs-zenburn-theme"
        "emacs-sweet-theme"
        "emacs-suneater-theme"
        "emacs-dream-theme"
        "emacs-zeno-theme"
        "emacs-spacegray-theme"
        "emacs-monokai-theme"
        "emacs-exotica-theme"
        "emacs-dracula-theme"
        "emacs-danneskjold-theme"
        "emacs-chocolate-theme"
        "emacs-acme-theme"
        "emacs-weyland-yutani-theme"
        "emacs-starlit-theme"
        "emacs-solarized-theme"
        "emacs-sakura-theme"
        "emacs-railscasts-theme"
        "emacs-poet-theme"
        "emacs-atom-one-dark-theme"
        "emacs-ample-theme"
        "emacs-ahungry-theme"
        "emacs-zerodark-theme"
        "emacs-soothe-theme"
        "emacs-punpun-theme"
        "emacs-base16-theme"
        "emacs-afternoon-theme"
        "emacs-nord-theme"
        "emacs-org-beautify-theme"
        "emacs-adwaita-dark-theme"
        "emacs-gruvbox-theme"
        )

;;; Window/frame/navigation/search stuff
    "emacs-ace-window"
    "emacs-deadgrep"

   ;;; Org-mode stuff
    "emacs-org-download"
    "emacs-org-roam"
    ;; "emacs-org-hugo" ; not in guix

   ;;; Completion stuff
    "emacs-vertico"
    ;; "emacs-vertico-prescient" ; not in guix

    ;; language modes
    "emacs-cmake-mode"
    "emacs-fish-mode"
    ;; "emacs-forth" ; not in guix
    "emacs-nix-mode"
    "emacs-jedi"
    ;; "emacs-virtualenvwrapper"  ; not in guix
    "emacs-terraform-mode"
    "emacs-yaml-mode"
    "emacs-docker"
    ;; "emacs-docker-tramp" by "tramp-container", which is not in guix
    "emacs-dockerfile-mode"
    "emacs-docker-compose-mode"

    ;; emacs-gitlab-ci-mode
    ;; emacs-gitlab-snip-helm
    ))

(define %vim
  (list
   "neovim"
   "vim-full"

   ;; common lisp stuff
   "vim-vlime"
   "vim-slime"
   "vim-paredit"

   ;; N.B. parinfer-rust is a plugin for vim, nvim, emacs, and kakoune
   "parinfer-rust"))

(define %spelling
  (list
   ;; Packages for spell pcheck
   "hunspell"
   "hunspell-dict-en-ca"
   "hunspell-dict-en-us"
   "hunspell-dict-en-gb"
   "hunspell-dict-fr-toutesvariantes"
   "miscfiles" ;; provides a wordlist
   "python-codespell"))

;; TODO STM
;; TODO AVR (define %embedded-dev (list "microcom" "avr-toolchain" "avrdude" "avr-gdb"))

(define %cad
  (list
   "f3d"                                ; VTK-based viewer
   "openscad"
   ;; 2024-04-29 freecad's pivy (bindings to coin3d) fails to build
   ;; "freecad"
   "kicad"
   "kicad-templates"
   "kicad-symbols"
   "kicad-packages3d"
   "kicad-footprints"
   "kicad-doc"
   ;; "paraview"
   "blender"
   ))

(define %voice
  (list
   "nerd-dictation"
   ;; "nerd-dictation-xdotool"
   "nerd-dictation-sox-ydotool"
   ;; "nerd-dictation-sox-xdotool"
   ;; "nerd-dictation-sox-wtype"
   ))

;; TODO Not used yet
(define %video
  (list "ffmpeg" "shotcut"))

(define %formal-methods
  (list
   ;; TLA+
   "tla2tools"))

(define %desktop
  (list
   ;; "anki" the version in guix is way too old, I'll use
   ;; the flatpak for now
   "icecat"
   "kitty"
   "firefox" ;; nonguix
   "keepassxc"
   "rofi"
   "flameshot"

   "dunst"                              ; for notifications

   "pavucontrol"

   "flatpak"
   ;; "flatpak-xdg-utils"
   ;; "xdg-desktop-portal"                 ; this is also for flatpak
   ;; "xdg-desktop-portal-gtk"             ; this is also for flatpak

   "playerctl"
   "vlc"

   "x11vnc"

   "xdg-utils"
   "xbindkeys"
   "xclip"
   "xbacklight"                         ; TODO laptop-only
   "xmodmap" "setxkbmap"
   "xrandr"
   "arandr"
   "xdotool"

   ;; PDF viewers
   "mupdf"
   ;; "zathura-pdf-mupdf"
   ;; ;; Other document formats
   ;; "zathura"
   ;; "zathura-ps"
   ;; "zathura-djvu"
   ;; ;; Comic books
   ;; "zathura-cb"
   ;; "mcomix"

   "libreoffice"
   ))

(define %screencast
  (list
   "python-screenkey"
   "obs"
   ;; "obs-vkcapture"
   ))

(define %packages
  (cons*
   ;; WIP python-elgato-streamdeck
   (specifications->packages
    (append
     %command-line-stuff
     %lisp-scheme-and-emacs
     %vim
     %spelling
     %cad
     %voice
     %desktop
     %screencast
     ;; Others...
     (list
      ;; This one is needed on my ubuntu host, because the
      ;; GUIX...LOCPATH is not set correctly, it only contains
      ;; the guix-home's profile
      "glibc-locales"

      ;; Music Player Daemon
      "mpd"
      "mpd-mpc"
      "ncmpc"

      "quodlibet"
      ;; TODO ffmpeg plugin for gstreamer, to be able to play wma files
      "gst-libav"

      "rakudo"                          ; aka perl6

      ;; TODO as of 2023-05-08 guix provides gforth 0.7.3,
      ;; which is very old...
      "gforth"
      "gauche" ;; gosh

      ;; TODO Add a home-service for this too
      "laminar"

      ;; TODO I only need these packages on non-GuixSD systems
      ;; set -xU SSL_CERT_FILE ~/.guix-home/profile/etc/ssl/certs/ca-certificates.crt
      "le-certs"
      "nss-certs"
      "shepherd"

      ;; add syncthing's command line on the right hosts to be able to
      ;; run commands like =syncthing -paths=
      "syncthing"

      "ditaa"
      "plantuml"
      "graphviz"
      )))))


;; TODO maybe heroic and steam; although I use flatpak for these atm

(home-environment
 ;; Below is the list of packages that will show up in your
 ;; Home profile, under ~/.guix-home/profile.
 (packages %packages)

 ;; Below is the list of Home services.  To search for available
 ;; services, run 'guix home search KEYWORD' in a terminal.
 (services
  (filter
   (compose not unspecified?)
   (list
    ;; Essentials
    %environment-variables

    ;; Shell
    %bash

    ;; Various daemons
    %ssh-agent
    (unless (host-other?) %syncthing)
    (when (host-nu?) %autossh-vps)

    %myelin

    ;; Desktop
    %xmodmap
    ;; TODO laptop-only
    %my-poor-eyes-i-cant-adjust-my-backlight-because-i-didnt-install-the-right-drivers-yet
    %unclutter
    %dunst))))
