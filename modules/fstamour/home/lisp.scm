;;;; Common lisp related packages

(define-module (fstamour home lisp))

(define-public %lisp-packages
  '("sbcl"

    "sbcl-cl+ssl"
    "sbcl-cffi"

    ;; Other common lisp implementations
    "abcl"
    "ecl"
    "clisp"
    "clasp-cl"
    "gcl"
    "ccl"
    "allegro-cl"

    "roswell"
    "cl-all"))
