;;;; Taking notes about how to use the repl.

;; Configure emacs to start a repl with the right guix and paths:
;; (setf geiser-guile-binary (expand-file-name "~/dev/guix-configurations/repl"))
;; M-x geiser

;; Checking some configurations
;; %load-path
;; (getenv "GUIX_PACKAGE_PATH")
;; (add-to-load-path "...")

;; Get the name of the current module
;; repl command: ,module
(module-name (current-module))
;; in case the current module doesn't use (guile):
((@ (guile) module-name) ((@ (guile) current-module)))

;; Check which modules the current modules uses.
(map module-name (module-uses (current-module)))

;; Change the current module
;; repl command: ,module (fstamour system)
;; (set-current-module (resolve-module '(fstamour system)))
;; Calling "set-current-module" doesn't change geiser's current module
;;
;; WARNING using ,module doesn't mean the module's code has been loaded!!!

;; Calling "module-filename" will load the module or return #f if it
;; can't be found:
(module-filename (resolve-module '(fstamour system)))

(@ (fstamour system) %hosts/phi)

(use-modules ((fstamour system) #:prefix s:))
