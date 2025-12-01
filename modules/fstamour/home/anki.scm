;;;;; TODO WIP this file is not used yet

(define-module (fstamour home anki)
  #:use-module ((gnu home services)
                #:select (service ;; for using a service
                          ;; for defining a service
                          simple-service))
  ;; for defining a shepherd service
  #:use-module ((gnu home services shepherd)
                #:select (home-shepherd-service-type
                          shepherd-service))
  ;; to be able to use g-expressions
  #:use-module (guix gexp))


(define-public %anki
  (filter
   (compose not unspecified?)
   (list
    "anki"
    "emacs-anki-editor")))
