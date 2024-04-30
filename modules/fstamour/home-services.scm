(define-module (fstamour home-services)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (gnu home services shepherd)
  #:use-module (gnu packages syncthing)
  #:export (%syncthing))

;; TODO a syncthing home-service was added recently, use that instead
(define-public %syncthing
  (simple-service 'syncthing home-shepherd-service-type
                  (list (shepherd-service
                         (provision '(syncthing))
                         (documentation "Run syncthing as a shepherd (user) service")
                         (start
                          #~(make-forkexec-constructor
                             (list
                              #$(file-append syncthing "/bin/syncthing")
                              ;; TODO Put synchting's log in its own file
                              ;; -logfile=...
                              ;; -logflag=... To specify the format?
                              "-no-browser")))
                         (stop #~(make-kill-destructor))))))
