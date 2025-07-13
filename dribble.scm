;;;; Taking notes about how to use the repl.

;; Configure EMACS to start a repl with the right guix and paths:
;; (setf geiser-guile-binary (expand-file-name "~/dev/git/guix-configurations/repl"))
;; M-x geiser

In geiser's repl:
,use (guix)
,help
,help guix
,verbosity 3

,build (@ (fstamour stumpwm) stumpwm+swank)




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
(@ (fstamour lisp) cl-simpbin)
(@ (fstamour stumpwm) stumpwm+swank)

(use-modules ((fstamour system) #:prefix s:))


(use-modules (guix)) ;; == ,use (guix)

;; guile's repl's metacommands are defind in `monad-repl.scm'
;; (e.g. /gnu/store/7fxv49j14rxg2h793kqcxjz76rwx3hwc-guix-module-union/share/guile/site/3.0/guix/monad-repl.scm)
;;
;; using the macro `define-meta-command', imported from the module
;; (system repl command)

;; TODO make a patch so that "verbosity level is actually documented..."
,verbosity LEVEL - Change build verbosity to LEVEL.

;; I found `logger-for-level' in status.scm (next to the monad-repl
;; file)
;; LEVEL 0 = minimal logs
;; LEVEL 1 = "quiet"
;; LEVEL 2 = "quiet with urls"
;; else = all?
