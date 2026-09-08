
(define-module (fstamour home laminar)
  #:use-module ((gnu services) #:select (simple-service))
  #:use-module ((gnu packages ci) #:prefix ci:)
  #:use-module ((gnu home services shepherd)
                #:select (home-shepherd-service-type
                          shepherd-service))
  #:use-module (guix gexp))

;; TODO proper service definition, like I did for xbindkeys

(define-public %laminar
  (simple-service
   'laminar home-shepherd-service-type
   (list (shepherd-service
          (provision '(laminar))
          (documentation "Run laminar as a shepherd service")
          (start
           #~(make-forkexec-constructor
              (list #$(file-append ci:laminar "/sbin/laminard"))
              #:environment-variables
              (append
               (default-environment-variables)
               (list
                (string-append
                 ;; TODO get XDG_CONFIG at runtime... not in the guix
                 ;; config...
                 "LAMINAR_HOME="
                 (or (getenv "$XDG_CONFIG_HOME")
                     (string-append (getenv "HOME") "/.config"))
                 "/laminar")
                (string-append "LAMINAR_TITLE=" (gethostname))
                "LAMINAR_KEEP_RUNDIRS=10"))))
          (stop #~(make-kill-destructor))))))
