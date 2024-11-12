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
  #:use-module ((gnu packages wm) #:select (stumpwm)))

(define-public stumpwm+swank
  (package
    (inherit stumpwm)
    (name "stumpwm-with-swank")
    (inputs
     (list
      ;; sbcl-swank
      cl-slime-swank
      stumpwm))
    (arguments
     (substitute-keyword-arguments (package-arguments stumpwm)
       ((#:phases phases)
        `(modify-phases ,phases
           (replace 'build-program
             (lambda* (#:key inputs outputs #:allow-other-keys)
               (let* ((out (assoc-ref outputs "out"))
                      (program (string-append out "/bin/stumpwm")))
                 (setenv "HOME" "/tmp")
                 (build-program program outputs
                                #:entry-program '((stumpwm:stumpwm) 0)
                                #:dependencies '("stumpwm" "swank")
                                #:dependency-prefixes
                                (map (lambda (input) (assoc-ref inputs input))
                                     '("stumpwm"
                                       "cl-slime-swank"
                                       ;; "sbcl-swank"
                                       ))))))
           (delete 'copy-source)
           (delete 'build)
           (delete 'check)
           (delete 'remove-temporary-cache)
           (delete 'cleanup)))))))
