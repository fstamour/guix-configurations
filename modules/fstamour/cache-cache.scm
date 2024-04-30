(define-module (fstamour cache-cache)
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
  #:use-module (gnu services)
  #:use-module (gnu home services shepherd)
  #:use-module ((fstamour lisp) #:select (sbcl-simpbin))
  #:export (sbcl-cache-cache
            cache-cache
            %cache-cache))

;; (use-modules
;;  (gnu packages admin)
;;  (gnu home services shepherd)
;;  (gnu services))

(define-public sbcl-cache-cache
  (let ((commit
         ;; main branch as of 2024-04-29
         "8f21a05b1dd85a845f097de461fba3741a4a6613")
        (repo-url "https://gitlab.com/fstamour/cache-cache"))
    (package
     (name "sbcl-cache-cache")
     (version "0.0.1")
     (source
      ;; (local-file "/home/fstamour/dev/cache-cache" #:recursive? #t)
      (origin
       (method git-fetch)
       (uri (git-reference
             (url repo-url)
             (commit commit)))
       (file-name (git-file-name name version))
       (sha256 (base32 "1z6nn0392v0hfxzz8f0pb597pchw0hasdvf54xvfac8jjqcf3w30"))))
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
                   sbcl-serapeum
                   sbcl-mcclim))
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
