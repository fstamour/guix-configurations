
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

;; TODO add
;; https://github.com/compufox/with-user-abort

(define-public sbcl-local-gitlab
  (let ((commit "e6a7d91210cfd7ece2beafd2066b16a2b34529f2")
        (repo-url "https://github.com/fstamour/local-gitlab"))
    (package
     (name "sbcl-local-gitlab")
     (version "0.0.1")
     (source
      ;; (local-file "../" "local-gitlab" #:recursive? #t)
      (origin
       (method git-fetch)
       (uri (git-reference
             (url repo-url)
             (commit commit)))
       (file-name (git-file-name name version))
       (sha256 (base32 "0jv1fm9zp5mcsfyjpq35dv8nz2q679hfaqqvk99l8d3rvwrmr2h4"))))
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
                   sbcl-simpbin))
     (home-page "https://github.com/fstamour/local-gitlab")
     (synopsis "")
     (description "Caching gitlab issues and more locally, for bazingly fast search")
     (license license:expat))))

(define-public local-gitlab
  (package
   (inherit sbcl-local-gitlab)
   (name "local-gitlab")
   (source #f)
   (build-system trivial-build-system)
   (arguments
    (list #:builder
          (let ((local-gitlab-build-script
                 (scheme-file "build-local-gitlab.lisp"
                              #~((require :asdf)
                                 (asdf:load-system '#:local-gitlab)
                                 (uiop/image:dump-image "local-gitlab" :executable t))
                              #:splice? #t)))
            (with-imported-modules '((guix build utils))
                                   #~(let ((bin (string-append #$output "/bin")))
                                       (use-modules (guix build utils))
                                       (setenv "XDG_CONFIG_DIRS" #$(file-append (this-package-input "sbcl-local-gitlab") "/etc"))
                                       (mkdir-p bin)
                                       (chdir bin)
                                       (system* #$(file-append sbcl "/bin/sbcl")
                                                "--no-userinit"
                                                "--disable-debugger"
                                                "--eval" "(require 'asdf)"
                                                "--load" #$local-gitlab-build-script))))))
   (inputs (list sbcl-local-gitlab))))
