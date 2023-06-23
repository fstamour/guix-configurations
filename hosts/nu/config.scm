(define-module (host-nu)
  #:use-module (gnu)
  #:use-module (gnu services sddm)
  #:use-module (gnu services docker)
  #:use-module (nongnu packages nvidia))

(use-service-modules cups desktop networking ssh xorg)

(define %users/fstamour
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

(operating-system
 (locale "en_CA.utf8")
 (timezone "America/New_York")
 (keyboard-layout (keyboard-layout "us"
                                   #:options '("compose:caps")))
 (host-name "nu")

 ;; The list of user accounts ('root' is implicit).
 (users (cons* %users/fstamour
               %base-user-accounts))

 ;; Packages installed system-wide.  Users can also install packages
 ;; under their own account: use 'guix search KEYWORD' to search
 ;; for packages and 'guix install PACKAGE' to install a package.
 (packages (append (specifications->packages
                    '(
                      "fish"
                      "i3-wm"
                      "i3status"
                      ;; "xfce"
                      "gnome"
                      "dmenu"
                      "nss-certs"
                      ))
                   %base-packages))

 ;; Below is the list of system services.  To search for available
 ;; services, run 'guix system search KEYWORD' in a terminal.
 (services
  (append (list

           ;; To configure OpenSSH, pass an 'openssh-configuration'
           ;; record as a second argument to 'service' below.
           (service openssh-service-type)

           (service cups-service-type)

           (service sddm-service-type
                    (sddm-configuration
                     (xorg-configuration (xorg-configuration (keyboard-layout keyboard-layout)))))

           (service docker-service-type))

          ;; This is the default list of services we
          ;; are appending to.
          (modify-services
           %desktop-services

           ;; I use sddm instead of gdm
           (delete gdm-service-type)

           (guix-service-type
            config => (guix-configuration
                       (inherit config)
                       (substitute-urls
                        (append (list "https://substitutes.nonguix.org")
                                %default-substitute-urls))
                       (authorized-keys
                        (append (list (local-file "../nonguix-substitutes-signing-key.pub"))
                                %default-authorized-guix-keys)))))))
 (bootloader (bootloader-configuration
              (bootloader grub-efi-bootloader)
              (targets (list "/boot/efi"))
              (keyboard-layout keyboard-layout)))
 (swap-devices (list (swap-space
                      (target (uuid
                               "5cc04005-8263-4bc7-9532-1d5180cf9dc1")))))

 ;; The list of file systems that get "mounted".  The unique
 ;; file system identifiers there ("UUIDs") can be obtained
 ;; by running 'blkid' in a terminal.
 (file-systems (cons* (file-system
                       (mount-point "/boot/efi")
                       (device (uuid "9EB9-A785"
                                     'fat32))
                       (type "vfat"))
                      (file-system
                       (mount-point "/")
                       (device (uuid
                                "8f881dd3-b8e4-477f-9c56-e41c1d1d0eea"
                                'ext4))
                       (type "ext4")) %base-file-systems)))
