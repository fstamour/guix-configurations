(define-module (fstamour home x11)
  #:use-module ((gnu home services)
                #:select (service
                          simple-service))
  #:use-module ((gnu home services shepherd)
                #:select (home-shepherd-service-type
                          shepherd-service))
  #:use-module ((gnu home services desktop)
                #:select (home-unclutter-service-type
                          home-unclutter-configuration
                          home-x11-service-type))
  #:use-module (gnu packages fonts)
  #:use-module ((gnu packages wm)
                #:select (dunst))
  #:use-module (guix gexp))

;; hide the mouse after some time of inactivity
(define-public %unclutter
  (service home-unclutter-service-type
           (home-unclutter-configuration
            (idle-timeout 2))))

(define-public %dunst
  (simple-service 'dunst home-shepherd-service-type
                  (list (shepherd-service
                         (provision '(dunst))
                         (documentation "Run dunst as a shepherd (user) service")
                         (start
                          #~(make-forkexec-constructor
                             (list
                              #$(file-append dunst "/bin/dunst"))))
                         (stop #~(make-kill-destructor))))))

(define-public %browsers
  (filter
   (compose not unspecified?)
   (list
    "icecat"
    ;; chromium as of 2024-11-14
    ;; version from guix: 112
    ;; version from nix : 124
    ;; "ungoogled-chromium"
    "firefox")))

(define-public %desktop
  (filter
   (compose not unspecified?)
   (list
    ;; for dbus-launch
    "dbus"

    "kitty"

    "xauth"  ; used by ssh for setting up xauthority when forwarding X

    "vscodium"

    "keepassxc"
    "rofi"
    "flameshot"

    "dunst"                             ; for notifications

    "thunar"             ; file explorer
    "thunar-volman"      ; removable media manager
    "thunar-media-tags-plugin" ; allow editing tags ; allow using tags in the bulk renamer
    "thunar-archive-plugin"    ; create and extract archives
    "gvfs"                   ; used by thunar (required for trash -_-)

    "eom"                               ; image view (Eye Of Mate)
    "qiv"                               ; image viewer

    "espanso-x11"                       ; text expander
    "jumpapp"                           ; run-or-raise

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
    "xauth"   ; used e.g. by ssh to configure ssh forwarding correctly

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

    ;; monospaced, bitmap font; aimed at programmers
    "font-dina"

    ;; Fira Sans is a humanist sans-serif typeface with an emphasis on legibility
    "font-fira-sans"
    ;; Monospace cut of Fira Sans
    "font-fira-mono"
    ;;  Monospaced font with programming ligatures
    "font-fira-code"

    "font-google-noto"
    "font-google-noto-emoji"

    "font-awesome"
    "font-awesome-nonfree"

    "fontmanager"           ; note: the binary is named "font-manager"
    )))
