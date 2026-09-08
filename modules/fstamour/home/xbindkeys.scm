(define-module (fstamour home xbindkeys)
  #:use-module ((gnu home services)
                #:select (home-profile-service-type))
  #:use-module ((gnu home services shepherd)
                #:select (home-shepherd-service-type
                          shepherd-service))
  #:use-module ((gnu packages xdisorg)
                #:select (xbindkeys))
  #:use-module ((gnu services)
                #:select (service-type service-extension))
  #:use-module (guix gexp)
  #:use-module (guix records)
  #:use-module ((srfi srfi-13)
                #:select (string-join))
  #:export (home-xbindkeys-configuration
            home-xbindkeys-configuration?
            home-xbindkeys-service-type))

(define-record-type* <home-xbindkeys-configuration>
  home-xbindkeys-configuration make-home-xbindkeys-configuration
  home-xbindkeys-configuration?
  (xbindkeys home-xbindkeys-configuration-xbindkeys
             (default xbindkeys))
  ;; path is a list of strings
  (path home-xbindkeys-configuration-path
        (default '())))

(define (home-xbindkeys-shepherd-services config)
  (list (shepherd-service
         (provision '(xbindkeys))
         (requirement '(x11-display))
         (documentation "Run xbindkeys as a shepherd service.")
         (modules '((srfi srfi-1)       ; for 'remove'
                    (srfi srfi-26)))    ; for 'cut'
         (start
          #~(make-forkexec-constructor
             (list #$(file-append (home-xbindkeys-configuration-xbindkeys config)
                                  "/bin/xbindkeys")
                   ;; don't become a daemon
                   "-n")
             #:environment-variables
             (cons (string-append
                    "PATH="
                    #$(string-join (home-xbindkeys-configuration-path config)
                                   ":" 'suffix)
                    "$PATH")
                   (remove (cut string-prefix? "PATH=" <>)
                           (default-environment-variables)))))
         (stop #~(make-kill-destructor)))))

(define home-xbindkeys-service-type
  (service-type
   (name 'home-xbindkeys)
   (extensions
    (list (service-extension home-shepherd-service-type
                             home-xbindkeys-shepherd-services)
          ;; also make xbindkeys available in the profile (e.g. to be
          ;; able to run it from the command line).
          (service-extension home-profile-service-type
                             (lambda (config)
                               (list (home-xbindkeys-configuration-xbindkeys
                                      config))))))
   (default-value (home-xbindkeys-configuration))
   (description
    "Run xbindkeys as a shepherd service..")))
