
(display "Loading repl.scm ...\n")

;; guix install guile guile-readline guile-colorized
(use-modules (ice-9 readline) (ice-9 colorized))

(activate-readline)
(activate-colorized)

;; (use-modules (guix)) ;; == ,use (guix)

(display "command-line: ")
(display (command-line))
(display "\n")

(let ((arg0 (car (command-line))))
  (when (or (string-suffix? "guix" arg0)
            (string= "repl.scm" arg0))
    (display "The repl was started using `guix repl`, using guix module...\n")
    (use-modules (guix))))

;; (use-modules (guix monad-repl) #:select %build-verbosity)
;; %build-verbosity

(display "repl.scm loaded!\n")
