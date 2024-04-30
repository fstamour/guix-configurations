(define-module (fstamour streamdeck)
  ;; #:use-module (gnu packages)
  #:use-module (gnu packages python-xyz) ; for python-pillow
  #:use-module (gnu packages libusb) ; for hidapi
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system python)
  #:use-module (guix build-system pyproject)
  #:use-module (gnu packages python-build)
  #:use-module (guix transformations)
  #:use-module (gnu packages python-web)
  #:use-module (gnu packages python-crypto)
  )

;; TODO udev rules


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


(define-public streamdeck-linux-ui
  (package
   (name "streamdeck-linux-ui")
   (version "v4.1.2")
   (synopsis "Linux compatible UI for the Elgato Stream Deck")
   (description "Linux compatible UI for the Elgato Stream Deck")
   (license license:expat)
   (home-page "https://streamdeck-linux-gui.github.io/streamdeck-linux-gui/")
   (source (origin
            (method git-fetch)
            (uri (git-reference
                  (url "https://github.com/streamdeck-linux-gui/streamdeck-linux-gui")
                  (commit "759f5a0913e997a65aef56501a9269c419a4b92c")))
            (file-name (git-file-name name version))
            (sha256 (base32 "1aj4a1lsvp6j5zc9w2rr5wlkbvkwch7ki61y6h10amfad4y0aaq9"))))
   (build-system pyproject-build-system)
   ;; (native-inputs (list poetry))
   (native-inputs (list poetry-1.8.2))
   ))

;; 2024-04-29
;; Build error:
;;   RuntimeError: The Poetry configuration is invalid:
;;   - Additional properties are not allowed ('group' was unexpected)
;;
;; From https://github.com/python-poetry/poetry/issues/4938#issuecomment-1001116794:
;;   dependency groups are only available from the current preview release (1.2.0a2) of poetry onwards.
;;
;; currently, guix packages poetry 1.1.12
;; latest version of poetry is 1.8.2
;;
;; https://github.com/python-poetry/poetry


;; Builds ok
(define-public poetry-1.1.13
  (package
   (inherit poetry)
   (version "1.1.13")
   (source
    (origin
     (method url-fetch)
     (uri (pypi-uri "poetry" version))
     (sha256
      (base32
       "1i3s6ncz7s9rmxrgcbz1xbwvy0hc4q4hwkjpc6m6ixc501hys1dr"))))))

;; Builds ok
(define-public poetry-1.1.14
  (package
   (inherit poetry)
   (version "1.1.14")
   (source
    (origin
     (method url-fetch)
     (uri (pypi-uri "poetry" version))
     (sha256
      (base32
       "1kpdr15kfksym67vidj7yvibdg6aa8infg3lf5ffifd9rmv7cnlb"))))))

;; Builds ok
(define-public poetry-1.1.15
  (package
   (inherit poetry)
   (version "1.1.15")
   (source
    (origin
     (method url-fetch)
     (uri (pypi-uri "poetry" version))
     (sha256
      (base32
       "1zfzrrjgaf8mk7840brsaz50j7pa06i8fszfdcpipwq5sa7q8wx3"))))))

(define poetry-1.2.0b1-base
  (package
   (inherit poetry)
   (version "1.2.0b1")
   (source
    (origin
     (method url-fetch)
     (uri (pypi-uri "poetry" version))
     (sha256
      (base32
       "1gvspiqan1yvwcfw11mqr85576lqb8hw46c2frfz5zvlk8q8vkr6"))))))

;; error: in phase 'patch-setup-py': uncaught exception:
;; system-error "stat" "~A: ~S" ("No such file or directory" "setup.py") (2)
;; (define-public poetry-1.2.0b1 poetry-1.2.0b1-base)

;; error: in phase 'build': uncaught exception:
;; misc-error #f "no setup.py found" () #f
;; (define-public poetry-1.2.0b1
;;   (package
;;    (inherit poetry-1.2.0b1-base)
;;    (arguments `(#:phases %standard-phases))))

;; error: in phase 'patch-setup-py': uncaught exception:
;; system-error "stat" "~A: ~S" ("No such file or directory" "setup.py") (2)
;; (define-public poetry-1.2.0b1
;;   (package
;;    (inherit poetry-1.2.0b1-base)
;;    (build-system pyproject-build-system)
;;    ))


;; N.B. poetry-core is defined in guix's python-build.scm

;; error: in phase 'check': uncaught exception:
;; %exception #<&test-system-not-found>
;; (define-public poetry-1.2.0b1
;;   (package
;;    (inherit poetry-1.2.0b1-base)
;;    (build-system pyproject-build-system)
;;    (arguments `(#:phases %standard-phases))))



;; starting phase `sanity-check'
;; validating 'poetry' /gnu/store/wcs2pv9cj1gkzrsfg8snnczsllwzigc2-poetry-1.2.0b1/lib/python3.10/site-packages
;; ...checking requirements: ERROR: poetry==1.2.0b1 ContextualVersionConflict(poetry-core 1.0.7 (/gnu/store/llr0gz8mgzgc39857fnd7ghz1xhcz83m-python-poetry-core-1.0.7/lib/python3.10/site-packages), Requirement.parse('poetry-core<2.0.0,>=1.1.0a7'), {'poetry'})
;; error: in phase 'sanity-check': uncaught exception:
;; %exception #<&invoke-error program: "python" arguments: ("/gnu/store/iqsjkp55pcx5bfcp2jm9yj5rlx9a0whd-sanity-check.py" "/gnu/store/wcs2pv9cj1gkzrsfg8snnczsllwzigc2-poetry-1.2.0b1/lib/python3.10/site-packages") exit-status: 1 term-signal: #f stop-signal: #f>
;; (define-public poetry-1.2.0b1
;;   (package
;;    (inherit poetry-1.2.0b1-base)
;;    (build-system pyproject-build-system)
;;    (arguments `(#:tests? #f
;;                 #:phases %standard-phases))))


(define-public python-poetry-core-1.1.0
  (package
   (inherit python-poetry-core)
   (version "1.1.0")
   (source
    (origin
     (method url-fetch)
     (uri (pypi-uri "poetry-core" version))
     (sha256
      (base32 "01qzjam37ajnq7psmf2yylbcrvf4a74z4q0vj2l1i4gp3h9awifi"))))))

;; python-packaging is too recent...
;; checking requirements: ERROR: poetry==1.2.0b1 ContextualVersionConflict(packaging 21.3 (/gnu/store/4ifgdvhqad0nv4gq1vbx36af9bxkk9fx-python-packaging-21.3/lib/python3.10/site-packages), Requirement.parse('packaging<21.0,>=20.4'), {'poetry'})
(define-public poetry-1.2.0b1
  (package
   (inherit poetry-1.2.0b1-base)
   (build-system pyproject-build-system)
   (arguments `(#:tests? #f
                #:phases %standard-phases
                ;; #:phases (modify-phases %standard-phases (delete 'sanity-check))
                ))
   ;; (propagated-inputs
   ;;  `(,python-poetry-core
   ;;    ,@(map cdar (filter (lambda (x) (not (string= "python-poetry-core" (car x))))
   ;;                        (package-propagated-inputs poetry)))))
   (propagated-inputs
    (list python-cachecontrol
          python-cachy
          python-cleo
          python-crashtest
          python-entrypoints
          python-html5lib
          python-keyring
                                        ; Use of deprecated version of msgpack reported upstream:
                                        ; https://github.com/python-poetry/poetry/issues/3607
          python-msgpack-transitional
          python-packaging
          python-pexpect
          python-pip
          python-pkginfo
          ;; python-poetry-core-1.0
          python-poetry-core-1.1.0
          python-requests
          python-requests-toolbelt
          python-shellingham
          python-tomlkit
          python-virtualenv))))



;; ...checking requirements: ERROR: poetry==1.2.0 DistributionNotFound(Requirement.parse('poetry-plugin-export<2.0.0,>=1.0.6'), {'poetry'})
(define-public poetry-1.2.0
  (package
   (inherit poetry)
   (version "1.2.0")
   (source
    (origin
     (method url-fetch)
     (uri (pypi-uri "poetry" version))
     (sha256
      (base32
       "17x5pcqfas6y1i9j2qqq3z7l7mkpy23qsd0lbiy5lnjhspajgi8p"))))
   (build-system pyproject-build-system)
   (arguments `(#:tests? #f
                ;; #:phases %standard-phases
                #:phases (modify-phases %standard-phases
                                        (delete 'sanity-check))
                ))
   (propagated-inputs
    (list python-cachecontrol
          python-cachy
          python-cleo
          python-crashtest
          python-entrypoints
          python-html5lib
          python-keyring
                                        ; Use of deprecated version of msgpack reported upstream:
                                        ; https://github.com/python-poetry/poetry/issues/3607
          python-msgpack-transitional
          python-packaging
          python-pexpect
          python-pip
          python-pkginfo
          ;; python-poetry-core-1.0
          python-poetry-core-1.1.0
          python-requests
          python-requests-toolbelt
          python-shellingham
          python-tomlkit
          python-virtualenv))))

(define-public poetry-1.8.2
  ;; TODO try python-poetry-core instead of python-poetry-core-1.0
  ;; e.g. ((options->transformation '((with-input . "...")))
  (package
   (inherit poetry)
   (version "1.8.2")
   (source
    (origin
     (method url-fetch)
     (uri (pypi-uri "poetry" version))
     (sha256
      (base32
       "0wyb55x6izlhka23zlqqrh23f1f62d7kl7q2w71lfihh70wfpk29"))))
   (build-system pyproject-build-system)
   (arguments `(#:tests? #f
                #:phases %standard-phases))))
