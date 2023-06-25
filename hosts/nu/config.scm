(define-module (host-nu)
  #:use-module (gnu)
  #:use-module (gnu services sddm)
  #:use-module (gnu services docker)
  #:use-module (gnu system nss)
  #:use-module (nongnu packages nvidia)
  #:use-module (gnu services cuirass)
  #:use-module (gnu services virtualization))

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

(define %cuirass-specs
  #~(list (specification
           (name "fstamour_local-gitlab")
           (build '(channels fstamour_local-gitlab))
           (priority 5)                 ; 0 is highest, 9 is lowest
           ;; (build-outputs (list (build-output (job "*"))))
           (channels
            (cons (channel
                   (name 'fstamour_local-gitlab)
                   (url "https://github.com/fstamour/local-gitlab.git")
                   (branch "main"))
                  %default-channels))
           ;; See guix system --list-systems
           (systems (list
                     "x86_64-linux"
                     ;; for raspberry pi, perhaps
                     "aarch64-linux"
                     ;; sbcl seems to be broken for armhf
                     ;; "armhf-linux"
                     )))))

(define %cuirass-service
  (service cuirass-service-type
           (cuirass-configuration
            (specifications %cuirass-specs)
            ;; (specifications #~(list))
            ;; Allows using substitutes to avoid building every
            ;; dependencies of a job from source.
            (use-substitutes? #t)
            ;; When substituting a pre-built binary fails, fall back
            ;; to building packages locally.
            (fallback? #t))))

;; support for transparent emulation of program binaries built for
;; different architectures
(define %qemu-binfmt-service
  (service qemu-binfmt-service-type
           (qemu-binfmt-configuration
            (platforms (lookup-qemu-platforms "arm" "aarch64")))))

(operating-system
  (locale "en_CA.utf8")
  (timezone "America/New_York")
  (keyboard-layout (keyboard-layout "us"
                                    #:options '("compose:caps")))
  (host-name "nu")
  (name-service-switch %mdns-host-lookup-nss)

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
                       "podman"

                       ;; These are added system-wide to make it easier
                       ;; to use them from ssh. (The default .bashrc
                       ;; that guix provides doesn't source the
                       ;; guix-home's /etc/profile)
                       "git"
                       "mosh"
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

            (service docker-service-type)

            (service guix-publish-service-type
                     (guix-publish-configuration
                      (host "0.0.0.0")
                      (port 9876)
                      (advertise? #t)))

            %cuirass-service
            %qemu-binfmt-service)

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
                          (append (list
                                   (local-file "../nonguix-substitutes-signing-key.pub")
                                   (local-file "../phi.pub"))
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
