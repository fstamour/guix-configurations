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
    "kitty"

    "vscodium"

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
