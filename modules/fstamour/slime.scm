;;;;; TODO WIP this file is not used yet
;;
;; I have slime cloned locally, I would like to build stumpwm using
;; that version to avoid version mismatch
;;

(define-module (fstamour slime)
  #:use-module (guix packages)
  #:use-module (guix gexp)
  #:use-module (guix git-download)
  #:use-module (guix build-system asdf)
  #:use-module ((guix utils) #:select (substitute-keyword-arguments))
  #:use-module (gnu packages)
  #:use-module (gnu packages lisp-check)
  #:use-module ((gnu packages lisp-xyz) #:select (sbcl-slime-swank))
  #:use-module ((ice-9 format) #:select (format)))


;; sbcl-package->cl-source-package
;; (define-public cl-slime-swank (sbcl-package->cl-source-package sbcl-slime-swank))
