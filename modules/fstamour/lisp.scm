
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
  #:use-module (guix build-system trivial))

;; TODO other implementations (e.g. ecl) see see asdf-build-system/ecl
;; TODO my fork of stumpwm

;;; tips:
;;; guix hash -rx . on the target's repo
;;; https://github.com/drewc/guix/blob/master/guix/licenses.scm
;;; on guix, asdf is patched to search for configurations files in xdg-config-dirs and? xdg-home

(define-public sbcl-breeze
  (let ((commit
         ;; main branch as of 2024-04-29
         "1fadd31dd3d10e5cafe90467c6e202ff09b2695f")
        ;; (repo-url "https://github.com/fstamour/breeze")
        (repo-url "https://gitlab.com/fstamour/breeze"))
    (package
     (name "sbcl-breeze")
     (version "0")
     (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url repo-url)
                    (commit commit)))
              (file-name (git-file-name name version))
              (sha256 (base32 "11nlgsdh8cy3s2q7vqpxwykanz21dgz3c16hhzirnnnirj9fzkgq"))))
     ;; (source (local-file "/home/fstamour/quicklisp/local-projects/breeze" #:recursive? #t))
     (build-system asdf-build-system/sbcl)
     ;; TODO I removed most of these dependencies since I created that package definition
     ;; 2024-04-29 (it's not merged in the main branch though...)
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

(define-public cl-breeze
  (sbcl-package->cl-source-package sbcl-breeze))

(define-public ecl-breeze
  (sbcl-package->ecl-package sbcl-breeze))


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

(define-public cl-simpbin
  (sbcl-package->cl-source-package sbcl-simpbin))

(define-public ecl-simpbin
  (sbcl-package->ecl-package sbcl-simpbin))
