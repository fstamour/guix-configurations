;; provide a stumpwm with swank included

(define-module (fstamour stumpwm)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system asdf)
  #:use-module ((guix utils) #:select (substitute-keyword-arguments))
  #:use-module (gnu packages)
  #:use-module (gnu packages lisp-check)
  #:use-module (gnu packages lisp-xyz)
  #:use-module ((gnu packages wm) #:select (stumpwm))
  #:use-module ((ice-9 format) #:select (format)))

;; TODO stumpwm's version.lisp needs to be patched because it saves
;; the build-time (the time at which stumpwm was built) :/

;; TODO if available, use ~/quicklisp/local-projects/slime instead

(define-public stumpwm+swank
  (package
   (inherit stumpwm)
   (name "stumpwm-with-swank")
   ;; (version "23.11")
   (version "9.11-556-gc48fecb")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/stumpwm/stumpwm")
           ;; (url "https://github.com/fstamour/stumpwm")
           ;; (commit version)
           ;; Commit "WIP WIP WIP... " from branch "wip"
           (commit "c48fecb23f1cd8023de360c02e05b192e358d36f")
           ))
     (file-name (git-file-name "stumpwm" version))
     (sha256
      ;; (base32 "0akrkxwmlk2596b0kl3q0nfi81ypfrpyyyf65vw7px5x17gsnq5i")
      (base32 "1sv30llqsbrrfj48gsskaijrilxk8inh0iim2zip0l86v47rkp2v"))))
   (inputs
    (list
     sbcl-mcclim
     sbcl-slime-swank
     stumpwm))
   (arguments
    (substitute-keyword-arguments (package-arguments stumpwm)
                                  ((#:phases phases)
                                   `(modify-phases ,phases
                                                   (replace 'build-program
                                                            (lambda* (#:key inputs outputs #:allow-other-keys)
                                                              (let* ((out (assoc-ref outputs "out"))
                                                                     (program (string-append out "/bin/stumpwm"))
                                                                     (dependency-prefixes (map (lambda (input)
                                                                                                 (let ((prefix (assoc-ref inputs input)))
                                                                                                   (unless prefix
                                                                                                     (raise-exception
                                                                                                      (format #f "dependency-prefixes: Failed to find input ~s" input)))
                                                                                                   prefix))
                                                                                               '("stumpwm"
                                                                                                 "sbcl-slime-swank"
                                                                                                 "sbcl-mcclim"
                                                                                                 ))))
                                                                (setenv "HOME" "/tmp")
                                                                (build-program program outputs
                                                                               #:entry-program '((stumpwm:stumpwm) 0)
                                                                               #:dependencies '("stumpwm" "swank" "mcclim")
                                                                               #:dependency-prefixes dependency-prefixes))))
                                                   (delete 'copy-source)
                                                   (delete 'build)
                                                   (delete 'check)
                                                   (delete 'remove-temporary-cache)
                                                   (delete 'cleanup)))))))


;; TODO stumpish + patches
;; to make it work when it's not running as a child process of stumpwm
;; - use pgrep to find stumpwm
;; - use /pid/${STUMPWM_PID}/environ to grab XAUTHORITY (don't know if it needs DISPLAY too)
