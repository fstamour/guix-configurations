
(define-module (fstamour home myelin)
  #:use-module ((gnu services) #:select (simple-service))
  #:use-module ((gnu packages lisp) #:prefix lisp:)
  #:use-module ((gnu home services shepherd)
                #:select (home-shepherd-service-type
                          shepherd-service))
  #:use-module (guix gexp)
  #:use-module ((srfi srfi-1) #:select (find)))

(define-public %myelin
  (let ((root (let ((suffix "myelin/")
                    (home (getenv "HOME")))
                (find
                 (lambda (path)
                   (file-exists? path))
                 (list
                  (string-append home "/dev/" suffix)
                  (string-append home "/dev/git/" suffix)
                  (string-append
                   home "/quicklisp/local-projects/" suffix))))))
    (unless (eq? #f root)
      (simple-service 'myelin home-shepherd-service-type
                      (list (shepherd-service
                             (provision '(myelin))
                             (documentation "Run myelin as a shepherd (user) service")
                             (start
                              #~(make-forkexec-constructor
                                 (list
                                  #$(file-append lisp:sbcl "/bin/sbcl")
                                  "--noinform"
                                  "--non-interactive"
                                  "--disable-debugger"
                                  "--load" #$(string-append root "loader.lisp")
                                  "--load" #$(string-append root "scripts/dev.lisp")
                                  "--eval" "(loop (sleep 1))")))
                             (stop #~(make-kill-destructor))))))))
