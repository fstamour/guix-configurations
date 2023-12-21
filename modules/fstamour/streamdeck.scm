(define-module (fstamour streamdeck)
  ;; #:use-module (gnu packages)
  #:use-module (gnu packages python-xyz) ; for python-pillow
  #:use-module (gnu packages libusb) ; for hidapi

  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system python))

;; TODO udev rules

(define-public python-elgato-streamdeck
  (package
    (name "python-elgato-streamdeck")
    (version "0.9.3") ;; TODO 0.9.4 https://github.com/abcminiuser/python-elgato-streamdeck/tags
    (source (origin
              (method url-fetch)
              (uri (pypi-uri "streamdeck" version))
              (sha256
               (base32
                "0wgcvz3l3qllwvsadsq6y96wc3p16agzmwwx26v3ir0ns6q5dczm"))))
    (build-system python-build-system)
    (arguments
     (list #:phases #~(modify-phases %standard-phases
                        (add-after 'unpack 'patch-source
                          (lambda* (#:key inputs #:allow-other-keys)
                            (substitute* "src/StreamDeck/Transport/LibUSBHIDAPI.py"
                              (("libhidapi-libusb.so")
                               (search-input-file inputs
                                                  "/lib/libhidapi-libusb.so"))))))))
    (home-page "https://github.com/abcminiuser/python-elgato-streamdeck")
    (synopsis "Library to control Elgato StreamDeck devices")
    (description "Library to control Elgato StreamDeck devices.")
    (license (license:non-copyleft
              (string-append
               "https://github.com/abcminiuser/python-elgato-streamdeck"
               "/blob/master/LICENSE")))
    (propagated-inputs (list python-pillow))
    (inputs (list hidapi))))

;; TODO check out this fork: https://github.com/streamdeck-linux-gui/streamdeck-linux-gui


;; TODO https://github.com/timothycrosley/streamdeck-ui
;; streamdeck-ui uses streamdeck-ui AFAIK

;; TODO Try botswain https://gitlab.gnome.org/World/boatswain (can
;; install it from flathup (flatpak) I didn't use it at first (in
;; 2022) because it cannot execute arbitraty commands, only .desktop
;; files...  2023-09-18 ... it's still that way
;; https://gitlab.gnome.org/World/boatswain/-/issues/28

;; A Node.js library for interfacing with the Elgato Stream Deck.
;; https://github.com/julusian/node-elgato-stream-deck
;; > With WebHID being made publicly available it is now possible to
;; > use the Steam Deck directly in the browser.
;;


;; TODO try burgled-batteries with python-elgato-streamdeck
;; https://github.com/pinterface/burgled-batteries

;; TODO Or even https://github.com/soemraws/cl-libusb


;; TODO Stream Deck Control Daemon https://github.com/drepper/streamdeckd
