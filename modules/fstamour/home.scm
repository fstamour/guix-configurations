
(define-module (fstamour home)
  #:use-module (gnu home services)
  #:use-module ((gnu home services desktop)
                #:select (home-x11-service-type))
  #:use-module (gnu home services shells)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu home services ssh)
  #:use-module (gnu packages ssh) ;; for autossh
  #:use-module (gnu home)
  #:use-module (gnu packages admin) ;; for shepherd
  #:use-module (gnu packages shells)
  #:use-module (gnu packages syncthing)
  #:use-module (gnu packages)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module ((fstamour stumpwm) #:select (stumpwm+swank))
  #:use-module ((fstamour syncthing) #:select (%syncthing))
  #:use-module ((fstamour home lisp) #:select (%lisp-packages))
  #:use-module ((fstamour home myelin) #:select (%myelin))
  #:use-module ((fstamour home emacs) #:select (%emacs-packages))
  #:use-module ((fstamour home xmodmap) #:select (%xmodmap))
  #:use-module ((fstamour home x11)
                #:select (%unclutter %dunst %browsers %desktop)))

(define (host-nu?)
  (string= "nu" (gethostname)))

(define (host-phi?)
  (string= "phi" (gethostname)))

(define (host-other?)
  (and
   (not (host-nu?))
   (not (host-phi?))))

(define %profile
  (simple-service 'profile-extra
                  home-shell-profile-service-type
                  (list (plain-file "shell-profile"
                                    "export GUIX_PROFILE_SOURCED=1"))))

(define %environment-variables
  (simple-service 'some-useful-env-vars-service
                  home-environment-variables-service-type
                  `(
                    ;; N.B. emacs's -a argument takes only an
                    ;; executable, not a full command, which means that
                    ;; if I really want to use emacs (with arguments) as
                    ;; an alternative, I'll probably have to make a
                    ;; small wrapper script for that.
                    ("EDITOR" . "emacsclient -t -nw -a nvim")
                    ;; ("EDITOR" . "emacsclient -t -nw -a emacs -t -nw")
                    ;; Meh
                    ;; ("VISUAL" . "emacsclient -a emacs")
                    ("PAGER" . "less")
                    ("LESS" . "-R --mouse --quit-if-one-screen")
                    ("PATH" . "$HOME/go/bin:$HOME/.local/bin:$PATH")
                    ("GUIX_PROFILES" . "${HOME_ENVIRONMENT}${GUIX_PROFILES:+:}$GUIX_PROFILES")
                    )))

;; Putting those in a variable to be able to define those aliases for
;; both bash and fish
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

(define %command-line-stuff
  `(
    ;; This should be installed on the OS (too?)
    ;; The one in guix is newer than the on on my ubuntu host
    "fish"
    "fish-foreign-env"

    "nushell"
    ;; TODO treesitter for nushell
    "emacs-nushell-mode"
    ;; TODO there's tons of plugins
    ;; TODO it _looks_ like there's a built-in lsp in nushell

    "git" "git-lfs"
    "tig"
    ,@(if (host-other?)
          (list)
          ;; amixer, aplay
          `("alsa-utils"))
    "bind:utils"                        ; nslookup, dig, etc
    "coreutils"
    "moreutils"                         ; sponge, ts, etc.

    "btop"
    "curl"
    "direnv"
    "du-dust"
    "entr"
    "eza"
    "fd"
    "ffmpeg"
    "file"
    "fzf"
    "htop"
    "jq"
    "less"
    "lsd"
    "m4"
    "make"
    "just"
    "libiconv"             ; for iconv — character encoding conversion

    ;; need to include "man-db", othetwise "MANPATH" is not set
    "man-db"         ; included by the "host"... somewhere
    "man-pages"      ; Development manual pages from the Linux project

    "mosh"
    "net-tools"                         ; netstat (and much more)
    "netcat-openbsd"
    "nmap"
    "qrencode"                          ; qrencode -t UTF8 "example"
    "readline"
    "ripgrep"                          ; grep -R
    "rlwrap"                           ; add readline to other command
    "skopeo"                           ; to copy containers around
    "screen"
    "sqlite"
    "tldr"
    "tmux"                              ; terminal multiplexer
    "tree"                              ; list file
    "w3m"                               ; browser
    "xxd"                               ; hex
    "bat"                               ; viewer
    "recutils"
    "ranger"                            ; file manager
    "mc"                                ; file manager
    "stow"                              ; symlink farm
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
   ;; gopls in guix is out of date -_-
   ;; "gopls" ;; Official language server
   "emacs-go-mode"
   "tree-sitter-go"
   "tree-sitter-gomod"))

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

;; TODO STM (see package stlink)
;; TODO AVR (define %embedded-dev (list "microcom" "avr-toolchain" "avrdude" "avr-gdb" "picom" "gcc-cross-avr-toolchain"))
;; TODO maybe mingw32: "gcc-cross-i686-w64-mingw32-toolchain"

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

(define %image
  (list
   "gimp"))

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

      ;; TODO as of 2023-05-08 guix provides gforth 0.7.3,
      ;; which is very old...
      "gforth"

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
      %profile

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
