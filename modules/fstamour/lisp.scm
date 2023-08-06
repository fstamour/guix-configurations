
(define-module (fstamour lisp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages)
  #:use-module (gnu packages lisp)
  #:use-module (gnu packages lisp-xyz)
  #:use-module (gnu packages lisp-check)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git)
  #:use-module (guix git-download)
  #:use-module (guix build-system asdf)
  #:use-module (guix build-system trivial)
  #:export (sbcl-simpbin
            sbcl-cache-cache
            cache-cache
            %cache-cache))

;; TODO cl-simpbin cl-cache-cache
;; TODO other implementations (e.g. ecl) see see asdf-build-system/ecl
;; TODO my fork of stumpwm

;;; tips:
;;; guix hash -rx . on the target's repo
;;; https://github.com/drewc/guix/blob/master/guix/licenses.scm
;;; on guix, asdf is patched to search for configurations files in xdg-config-dirs and? xdg-home

(define-public sbcl-breeze
  (let ((commit "e76ce087980fdb30a4124c77177d06748ad5c73e")
        (repo-url "https://github.com/fstamour/breeze"))
    (package
     (name "sbcl-breeze")
     (version "0")
     ;; (source (origin
     ;;          (method git-fetch)
     ;;          (uri (git-reference
     ;;                (url repo-url)
     ;;                (commit commit)))
     ;;          (file-name (git-file-name name version))
     ;;          (sha256 (base32 "0rq57ccbbxp48g37xrpcqj07asxrl1xd3iql49r0msqjhhys6n8n"))))
     (source (local-file "/home/fstamour/quicklisp/local-projects/breeze"
                         #:recursive? #t))
     (build-system asdf-build-system/sbcl)
     (inputs (list
              sbcl-3bmd
              sbcl-spinneret
              sbcl-alexandria
              sbcl-anaphora
              sbcl-bordeaux-threads
              sbcl-chanl
              ;; sbcl-cl-hash-util
              sbcl-cl-ppcre
              sbcl-closer-mop
              sbcl-eclector
              sbcl-quickproject
              sbcl-cl-str
              sbcl-trivial-features
              sbcl-trivial-package-local-nicknames
              sbcl-trivial-timeout
              sbcl-trivial-file-size
              ))
     ;; (native-inputs (list sbcl-parachute))
     ;; Propagated inputs: Installed in the store and in the profile,
     ;; as well as being present at build time.
     (propagated-inputs
      (list
       sbcl-parachute))
     (arguments
      (list #:phases
            #~(modify-phases %standard-phases
                             (add-after 'unpack 'disable-failing-tests
                                        (lambda _
                                          (substitute* "breeze.asd"
                                                       ;; Guix does not have Quicklisp, and probably never will.
                                                       (("\\(:file \"quicklisp\"\\)") "")))))))
     (home-page repo-url)
     (synopsis "Experiments on workflow with common lisp.")
     (description "Experiments on workflow with common lisp.")
     (license license:bsd-2))))

(define-public sbcl-simpbin
  (let ((commit "6f9f1c196ca8f363b478bab0a8623f53b89e5586")
        (repo-url "https://github.com/fstamour/simpbin"))
    (package
     (name "sbcl-simpbin")
     (version (git-version "0.0.1" "0" commit))
     (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url repo-url)
                    (commit commit)))
              (file-name (git-file-name name version))
              (sha256 (base32 "1q768amvmjnmasy9kz3qik2p4inxc68a6ih3m51cm85zn1hr9c0l"))))
     (build-system asdf-build-system/sbcl)
     (inputs (list sbcl-alexandria sbcl-flexi-streams sbcl-fast-io sbcl-nibbles))
     (native-inputs (list sbcl-parachute))
     (home-page repo-url)
     (synopsis "A common lisp library to store data in a simple binary format")
     (description "")
     (license license:gpl3))))

;; sbcl-package->cl-source-package is supposed to be exported by (guix
;; build-system asdf), but...
;;
;; (define-public cl-simpbin
;;   (sbcl-package->cl-source-package sbcl-simpbin))

;; (define-public ecl-simpbin
;;   (sbcl-package->ecl-source-package sbcl-simpbin))

;; TODO add
;; https://github.com/compufox/with-user-abort

(define-public sbcl-cache-cache
  (let ((commit "9d763c2ba2608724e92da9aef0d4672d692d8e18")
        (repo-url "https://github.com/fstamour/cache-cache"))
    (package
     (name "sbcl-cache-cache")
     (version "0.0.1")
     (source
      (local-file "/home/fstamour/dev/cache-cache"
                  #:recursive? #t)
      ;; (local-file "../" "cache-cache" #:recursive? #t)
      ;; (origin
      ;;  (method git-fetch)
      ;;  (uri (git-reference
      ;;        (url repo-url)
      ;;        (commit commit)))
      ;;  (file-name (git-file-name name version))
      ;;  (sha256 (base32 "0jv1fm9zp5mcsfyjpq35dv8nz2q679hfaqqvk99l8d3rvwrmr2h4")))
      )
     (build-system asdf-build-system/sbcl)
     (inputs (list sbcl-adopt
                   sbcl-drakma
                   sbcl-log4cl
                   sbcl-hunchentoot
                   sbcl-find-port
                   sbcl-kebab
                   sbcl-cl-str
                   sbcl-local-time
                   sbcl-cl-cron
                   sbcl-jzon
                   sbcl-simpbin
                   sbcl-with-user-abort
                   sbcl-serapeum))
     (home-page "https://github.com/fstamour/cache-cache")
     (synopsis "")
     (description "Caching gitlab issues and more locally, for bazingly fast search")
     (license license:expat))))

(define-public cache-cache
  (package
   (inherit sbcl-cache-cache)
   (name "cache-cache")
   (source #f)
   (build-system trivial-build-system)
   (arguments
    (list #:builder
          (let ((cache-cache-build-script
                 (scheme-file "build-cache-cache.lisp"
                              #~((require :asdf)
                                 (asdf:load-system '#:cache-cache)
                                 (uiop/image:dump-image "cache-cache" :executable t))
                              #:splice? #t)))
            (with-imported-modules '((guix build utils))
                                   #~(let ((bin (string-append #$output "/bin")))
                                       (use-modules (guix build utils))
                                       (setenv "XDG_CONFIG_DIRS" #$(file-append (this-package-input "sbcl-cache-cache") "/etc"))
                                       (mkdir-p bin)
                                       (chdir bin)
                                       (system* #$(file-append sbcl "/bin/sbcl")
                                                "--no-userinit"
                                                "--disable-debugger"
                                                "--eval" "(require 'asdf)"
                                                "--load" #$cache-cache-build-script))))))
   (inputs (list sbcl-cache-cache))))

(use-modules
 (gnu packages admin)
 (gnu home services shepherd)
 (gnu services))

(define-public %cache-cache
  (simple-service 'cache-cache home-shepherd-service-type
                  (list (shepherd-service
                         (provision '(cache-cache))
                         (documentation "Run cache-cache as a shepherd (user) service")
                         (start
                          #~(make-forkexec-constructor
                             (list
                              #$(file-append cache-cache "/bin/cache-cache")
                              "--serve")))
                         (stop #~(make-kill-destructor))))))
