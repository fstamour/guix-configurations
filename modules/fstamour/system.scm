
(define-module (fstamour system)
  #:use-module (gnu services cuirass)
  #:use-module (gnu services docker)
  #:use-module (gnu services sddm)
  #:use-module (gnu services virtualization)
  #:use-module (gnu system nss)
  #:use-module (gnu system shadow)
  #:use-module (gnu)
  #:use-module (gnu packages shells)
  #:use-module (nongnu packages linux)
  #:use-module (nongnu packages nvidia)
  #:use-module (nongnu system linux-initrd))

(use-service-modules cups desktop networking ssh xorg)

(define-public %keyboard-layout
  (keyboard-layout "us" #:options '("compose:caps")))

(define-public %xorg
  (xorg-configuration (keyboard-layout %keyboard-layout)))

(define-public %sddm
  (service sddm-service-type
           (sddm-configuration (xorg-configuration %xorg))))

(define-public %fstamour/desktop-services
  (modify-services
   %desktop-services

   ;; I use sddm instead of gdm
   (delete gdm-service-type)

   ;; Add nonguix
   (guix-service-type
    config => (guix-configuration
               (inherit config)
               (substitute-urls
                (append (list "https://substitutes.nonguix.org")
                        %default-substitute-urls))
               (authorized-keys
                (append (list
                         (local-file "./nonguix-substitutes-signing-key.pub")
                         (local-file "./phi.pub")
                         (local-file "./nu.pub"))
                        %default-authorized-guix-keys))))))

(define-public %packages
  (specifications->packages
   '(
     "fish"
     ;; "xfce"
     "gnome"
     "dmenu"
     "nss-certs"

     "btrfs-progs"
     "btrbk"

     ;; These are added system-wide to make it easier
     ;; to use them from ssh. (The default .bashrc
     ;; that guix provides doesn't source the
     ;; guix-home's /etc/profile)
     "git"
     "mosh"
     )))

(define-public %cuirass-specs
  #~(list (specification
           (name "fstamour")
           (build '(channels fstamour))
           (priority 5)                 ; 0 is highest, 9 is lowest
           ;; (build-outputs (list (build-output (job "*"))))
           (channels
            (cons (channel
                   (name 'fstamour)
                   (url "https://github.com/fstamour/guix-configurations.git")
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


;; TODO
;; adjust brightness without sudo
(define %backlight-udev-rule
  (udev-rule
   "90-backlight.rules"
   (string-append "ACTION==\"add\", SUBSYSTEM==\"backlight\", "
                  "RUN+=\"/run/current-system/profile/bin/chgrp video /sys/class/backlight/%k/brightness\""
                  "\n"
                  "ACTION==\"add\", SUBSYSTEM==\"backlight\", "
                  "RUN+=\"/run/current-system/profile/bin/chmod g+w /sys/class/backlight/%k/brightness\"")))

;; support for transparent emulation of program binaries built for
;; different architectures
(define-public %qemu-binfmt-service
  (service qemu-binfmt-service-type
           (qemu-binfmt-configuration
            (platforms (lookup-qemu-platforms "arm" "aarch64")))))

(define-public %cuirass-service
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

(define-public %services
  (list
   ;; To configure OpenSSH, pass an 'openssh-configuration'
   ;; record as a second argument to 'service' below.
   (service openssh-service-type)
   (service guix-publish-service-type
            (guix-publish-configuration
             (host "0.0.0.0")
             (port 9876)
             (advertise? #t)))
   (service docker-service-type)
   (service cups-service-type)))

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
      "wheel"))
   (shell (file-append fish "/bin/fish"))))

(define-public %hosts/nu
  (operating-system
   (host-name "nu")
   (locale "en_CA.utf8")
   (timezone "America/New_York")
   (keyboard-layout %keyboard-layout)
   (name-service-switch %mdns-host-lookup-nss)

   (kernel linux)
   (initrd microcode-initrd)
   (firmware (list linux-firmware
                   amdgpu-firmware))

   (users (cons* %users/fstamour %base-user-accounts))
   (packages (append
              (specifications->packages '("xf86-video-amdgpu"))
              %packages
              %base-packages))

   (services (append
              (list
               %sddm                                ; instead of gdm
               %cuirass-service
               %qemu-binfmt-service)
              %services
              %fstamour/desktop-services))
   (bootloader (bootloader-configuration
                (bootloader grub-efi-removable-bootloader)
                (targets (list "/boot/efi"))
                (keyboard-layout %keyboard-layout)))
   (swap-devices (list (swap-space
                        (target (uuid
                                 "5cc04005-8263-4bc7-9532-1d5180cf9dc1")))))
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
                         (type "ext4")) %base-file-systems))))


(define-public %hosts/phi
  (operating-system
   (host-name "phi")

   (locale "en_CA.utf8")
   (timezone "America/New_York")
   (keyboard-layout (keyboard-layout "us"))
   (name-service-switch %mdns-host-lookup-nss)

   (kernel linux)

   ;; Intel Wi-Fi
   (initrd microcode-initrd)
   (firmware (cons* iwlwifi-firmware
                    %base-firmware))

   (users (cons* %users/fstamour
                 %base-user-accounts))

   (packages (append %packages
                     %base-packages))

   (services (append
              (list
               ;; instead of gdm
               %sddm)
              %services
              %fstamour/desktop-services))

   (bootloader (bootloader-configuration
                (bootloader grub-bootloader)
                (targets (list "/dev/sda"))
                (keyboard-layout %keyboard-layout)))
   (mapped-devices (list (mapped-device
                          (source (uuid
                                   "149df863-0e36-4b84-b92b-9767999e406a"))
                          (target "cryptroot")
                          (type luks-device-mapping))))
   (file-systems (cons* (file-system
                         (mount-point "/")
                         (device "/dev/mapper/cryptroot")
                         (type "ext4")
                         (dependencies mapped-devices)) %base-file-systems))))
