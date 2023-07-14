
(define-module (fstamour user)
  #:use-module (gnu system shadow))

(define-public %users/fstamour
  (user-account
   (name "fstamour")
   (comment "Francis St-Amour")
   (group "users")
   (home-directory "/home/fstamour")
   (supplementary-groups
    '("audio"
      "cdrom"
      "dialout"
      "disk"
      "docker"
      "lp"
      "netdev"
      "video"
      "wheel"))))
