
(define-module (fstamour home)
  #:use-module (gnu home services)
  #:use-module ((gnu home services desktop)
                #:select (home-unclutter-service-type
                          home-unclutter-configuration
                          home-x11-service-type))
  #:use-module (gnu home services shells)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services ssh)
  #:use-module (gnu packages ssh) ;; for autossh
  #:use-module (gnu packages fonts)
  #:use-module (gnu home)
  #:use-module (gnu packages admin) ;; for shepherd
  #:use-module ((gnu packages lisp) #:prefix lisp:)
  #:use-module (gnu packages shells)
  #:use-module (gnu packages syncthing)
  #:use-module (gnu packages)
  #:use-module (gnu packages wm) ;; for dunst
  #:use-module (gnu services)
  #:use-module (guix gexp)
  ;; #:use-module (fstamour lisp)
  ;; WIP (fstamour streamdeck)
  ;; #:use-module (fstamour stumpwm)
  #:use-module ((fstamour stumpwm) #:select (stumpwm+swank))
  #:use-module ((fstamour syncthing) #:select (%syncthing))
  #:use-module ((fstamour home lisp) #:select (%lisp-packages))
  #:use-module ((fstamour home emacs) #:select (%emacs-packages)))

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
                    ("PATH" . "$HOME/go/bin:$HOME/.local/bin:$PATH")
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

(define %unclutter ; hide the mouse after some time of inactivity
  (service home-unclutter-service-type
           (home-unclutter-configuration
            (idle-timeout 2))))

(define %xmodmap
  (service home-xmodmap-service-type
           (home-xmodmap-configuration
            ;; TIPS: use =xmodmap -pm= to print the current modifiers
            (key-map '(
                       ;; Use CapsLock key (keycode 66) for compose key (called "multi key")
                       ("keycode 66" . "Multi_key")
                       ;; Remove shift lock functionality
                       "clear Lock"
                       ;; I use () the most often, make it easier to
                       ;; type.
                       ;;
                       ;; the keys for [] becomes ()
                       ;; the keys for () becomes {}
                       ;; the keys for {} becomes []
                       ("keycode 18" . "9 braceleft")
                       ("keycode 19" . "0 braceright")
                       ("keycode 34" . "parenleft bracketleft")
                       ("keycode 35" . "parenright bracketright")
                       ;; Alternative:
                       ;; ! Swap () <=> []
                       ;; keycode  18 = 9 bracketleft 9 bracketleft
                       ;; keycode  19 = 0 bracketright 0 bracketright
                       ;; keycode  34 = parenleft braceleft parenleft braceleft
                       ;; keycode  35 = parenright braceright parenright braceright


                       ;; This make "right control" a plain key (i.e. not a modifier)
                       "remove control = Control_R"
                       ;; Map "rigth control" to "hyper"
                       ("keycode 105" . "Hyper_L")
                       ;; This make the "left hyper" a plain key
                       "remove mod4 = Hyper_L"
                       ;; This make the "left hyper" a different kind of modifier
                       "add mod3 = Hyper_L"

                       ;; "add mod3 = Control_R"
                       ;;  ("keycode 108" ;; Alt_R
                       )))))

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
    "tig"
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
    "just"
    "libiconv"                          ; for iconv — character encoding conversion

    ;; "man-db" ; included by the "host"... somewhere
    "man-pages" ; Development manual pages from the Linux project

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
    "recutils"
    "ranger"                            ; file manager
    "mc"                                ; file manager
    "strace"
    "tesseract-ocr"
    "zip" "unzip"
    "zoxide"
    "lzip" "lunzip"
    "sshfs"
    ))

;; bsd-games

(define %lisp-scheme-and-emacs
  `(
    ;; "stumpwm-with-slynk"
    "stumpwm-with-swank"
    ;; "stumpwm"
    "stumpish"
    ;; TODO try "sawfish"

    "guile"
    "guile-readline"
    "guile-colorized"


    ;; Themes (I don't know which one I want 😅)
    ;; guix search emacs theme | grep name: | grep -e '-theme$' | awk '{print $2}' | copy
    ;; ,@`("emacs-spacemacs-theme"
    ;;     "emacs-tao-theme"
    ;;     "emacs-rebecca-theme"
    ;;     "emacs-abyss-theme"
    ;;     "emacs-cyberpunk-theme"
    ;;     "emacs-zenburn-theme"
    ;;     "emacs-sweet-theme"
    ;;     "emacs-suneater-theme"
    ;;     "emacs-dream-theme"
    ;;     "emacs-zeno-theme"
    ;;     "emacs-spacegray-theme"
    ;;     "emacs-monokai-theme"
    ;;     "emacs-exotica-theme"
    ;;     "emacs-dracula-theme"
    ;;     "emacs-danneskjold-theme"
    ;;     "emacs-chocolate-theme"
    ;;     "emacs-acme-theme"
    ;;     "emacs-weyland-yutani-theme"
    ;;     "emacs-starlit-theme"
    ;;     "emacs-solarized-theme"
    ;;     "emacs-sakura-theme"
    ;;     "emacs-railscasts-theme"
    ;;     "emacs-poet-theme"
    ;;     "emacs-atom-one-dark-theme"
    ;;     "emacs-ample-theme"
    ;;     "emacs-ahungry-theme"
    ;;     "emacs-zerodark-theme"
    ;;     "emacs-soothe-theme"
    ;;     "emacs-punpun-theme"
    ;;     "emacs-base16-theme"
    ;;     "emacs-afternoon-theme"
    ;;     "emacs-nord-theme"
    ;;     "emacs-org-beautify-theme"
    ;;     "emacs-adwaita-dark-theme"
    ;;     "emacs-gruvbox-theme"
    ;;     )



    "emacs-geiser"
    "emacs-geiser-guile"


    ;; "picolisp" ,lisp:picolisp
    ))

(define %rust
  (list
   "rust-analyzer"))

(define %golang
  (list
   "go"
   "gccgo"
   ;; gopls in guix is out of date -_-
   ;; "gopls" ;; Official language server
   "emacs-go-mode"))

(define %prolog
  (list
   "emacs-ediprolog" ;; to interact with SWI-Prolog
   "swi-prolog"))

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
;; TODO AVR (define %embedded-dev (list "microcom" "avr-toolchain" "avrdude" "avr-gdb" "picom"))

(define %cad
  (list
   "f3d"                                ; VTK-based viewer
   "openscad"
   ;; 2024-04-29 freecad's pivy (bindings to coin3d) fails to build
   "freecad"
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
   "tla2tools"
   "tree-sitter-tlaplus"

   "coq"
   "proof-general"
   "opam" ; ocaml's package manager, used by coq
   ))

(define %mail
  (list
   "mutt"
   "offlineimap3"))

(define %browsers
  (filter
   (compose not unspecified?)
   (list
    "icecat"
    ;; chromium as of 2024-11-14
    ;; version from guix: 112
    ;; version from nix : 124
    ;; "ungoogled-chromium"
    ;; For some reason, firefox started crashing on ubuntu...
    (unless (host-other?)
      ;; nonguix
      "firefox"))))

(define %image
  (list
   "gimp"))

(define %desktop
  (filter
   (compose not unspecified?)
   (list
    "kitty"

    (unless (host-other?)
      "vscodium")

    "keepassxc"
    "rofi"
    "flameshot"

    "dunst"                             ; for notifications

    "flatpak"
    ;; "flatpak-xdg-utils"
    ;; "xdg-desktop-portal"                 ; this is also for flatpak
    ;; "xdg-desktop-portal-gtk"             ; this is also for flatpak

    "pavucontrol"
    "playerctl"
    "vlc"

    "x11vnc"
    ;; Remote access to individual applications or full desktops
    "xpra"

    "xdg-utils"
    "xbindkeys"
    "slop"                       ; select a region and print its bound
    "xclip"
    "xbacklight"                        ; TODO laptop-only
    "xmodmap" "setxkbmap"
    "xrandr"
    "arandr"
    "xdotool"
    "xset" ;; for "xset -dpms", to disable shutting down the screen automatically

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
    "python-pdftotext" ;; Simple PDF text extraction

    "libreoffice"

    ;;   # fonts.fonts = with pkgs; [
    ;; #   noto-fonts
    ;; #   noto-fonts-cjk
    ;; #   noto-fonts-emoji
    ;; #   liberation_ttf
    ;; #   fira-code
    ;; #   fira-code-symbols
    ;; #   mplus-outline-fonts
    ;; #   dina-font
    ;; #   proggyfonts
    ;; # ];

    "font-fira-mono"
    "font-fira-code"
    "font-google-noto"
    "font-google-noto-emoji"

    )))

(define %screencast
  (list
   "python-screenkey"
   ;; 2025-01-07 flatpak _might_ be a better way to use OBS... depending on which plugins one wants to use
   ;; guix search obs-
   "obs"
   ;; "obs-vkcapture"
   ))

(define %packages
  (cons*
   ;; WIP python-elgato-streamdeck
   (specifications->packages
    (append
     %command-line-stuff

     %emacs-packages
     %lisp-packages
     %lisp-scheme-and-emacs
     %vim
     %spelling
     ;; (unless (host-other?) %cad)
     %voice
     %desktop
     %browsers
     %image
     %screencast
     %mail
     %rust
     %golang
     %prolog
     %formal-methods
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
      "gnuplot"

      "shellcheck")))))


;; TODO maybe heroic and steam; although I use flatpak for these atm


(define-public %home
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
      (service home-x11-service-type)
      %xmodmap

      %unclutter
      %dunst)))))
