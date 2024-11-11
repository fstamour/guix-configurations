(define-module (fstamour freerdp)
  #:use-module ((gnu packages rdesktop) #:select (freerdp))
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module (guix transformations))

(define-public freerdp-3.5.1
  (package
   (inherit freerdp)
   (version "3.5.1")
   (source
    (origin
     (method git-fetch)
     (uri (git-reference
           (url "https://github.com/FreeRDP/FreeRDP")
           (commit version)))
     (file-name (git-file-name name version))
     (sha256
      (base32 "0h7yxjnl4zgl07ilh7dzbig8r7phll0wid72hm92jav6s4q75v63"))))))

;; https://github.com/FreeRDP/FreeRDP/commit/eda5c99686e15327f2f37b9cadf307e852b96adf
