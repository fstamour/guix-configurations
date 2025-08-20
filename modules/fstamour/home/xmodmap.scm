(define-module (fstamour home xmodmap)
  #:use-module ((gnu home services)
                #:select (service))
  #:use-module ((gnu home services desktop)
                #:select (home-xmodmap-service-type
                          home-xmodmap-configuration)))


(define-public %xmodmap
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
