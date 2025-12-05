;; -*- compile-command: "sh -c \"echo ',use (fstamour system)' | ./repl\""; -*-

(define-module (fstamour system)
  #:use-module (gnu services cuirass)
  #:use-module (gnu services docker)
  #:use-module (gnu services nix)
  #:use-module (gnu services sddm)
  #:use-module (gnu services databases) ; for postgres
  #:use-module (gnu services virtualization)
  #:use-module (gnu system nss)
  #:use-module (gnu system shadow)
  #:use-module ((gnu services base) :select (file->udev-rule))
  #:use-module (gnu)
  ;; #:use-module ((gnu) #:select (use-service-modules))
  ;; #:use-module ((gnu system keyboard) #:select (keyboard-layout))
  ;; #:use-module ((gnu services) #:select (service modify-services))
  #:use-module ((gnu services) #:prefix gnu:services:)
  ;; #:use-module ((gnu services base)
  ;;               #:select (%default-authorized-guix-keys
  ;;                         guix-service-type
  ;;                         guix-configuration))
  ;; #:use-module (gnu packages shells)
  #:use-module ((guix store) #:prefix store:)
  ;; #:use-module ((guix gexp) #:select (local-file))
  ;; ;; #:use-module ((guix gexp) #:select (local-file))
  ;; ;; #:use-module ((guix gexp) #:prefix gexp)
  ;; #:use-module ((gnu packages) #:select (specifications->packages))
  #:use-module ((gnu packages shells) #:select (fish))
  #:use-module ((gnu packages linux) #:select (acpilight))
  #:use-module ((gnu packages admin) #:select (solaar))
  #:use-module (nongnu packages linux)
  #:use-module (nongnu packages nvidia)
  #:use-module (nongnu system linux-initrd))

(use-package-modules databases) ; for postgres
(use-service-modules cups desktop networking ssh xorg)
;; (use-service-modules cups desktop networking ssh xorg)

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
   (gnu:services:delete gdm-service-type)

   ;; Add nonguix
   (guix-service-type
    config => (guix-configuration
               (inherit config)
               (substitute-urls
                ;; --substitute-urls='https://ci.guix.gnu.org https://bordeaux.guix.gnu.org'
                (append (list "https://substitutes.nonguix.org"
                              ;; New North American based Guix Substitute Server, cuirass.genenetwork
                              ;; https://lists.gnu.org/archive/html/guix-devel/2024-11/msg00174.html
                              "https://cuirass.genenetwork.org")
                        store:%default-substitute-urls))
               (authorized-keys
                (append (list
                         (local-file "./nonguix-substitutes-signing-key.pub")
                         (local-file "./phi.pub")
                         (local-file "./nu.pub"))
                        %default-authorized-guix-keys))
               ;; discover substitute servers using mdns
               (discover? #t)))))

(define-public %packages
  (specifications->packages
   '(
     "acpilight" ; not needed on on-laptop...
     "fish"
     "xfce"
     ;; "gnome"
     ;; "dmenu"

     "btrfs-progs"
     "btrbk"

     ;; logitech unify
     "solaar"

     ;; These are added system-wide to make it easier
     ;; to use them from ssh. (The default .bashrc
     ;; that guix provides doesn't source the
     ;; guix-home's /etc/profile)
     "git"
     "mosh")))


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

;; For solaar
(define %logitech-unify-udev-rule
  (file->udev-rule
   "42-logitech-unify-permissions.rules"
   (file-append solaar
                "/lib/udev/rules.d/42-logitech-unify-permissions.rules")))

;; TODO
;; adjust brightness without sudo
(define %backlight-udev-rule
  (udev-rule
   "90-backlight.rules"
   (string-append
    "ACTION==\"add\", SUBSYSTEM==\"backlight\", "
    "RUN+=\"/run/current-system/profile/bin/chgrp video $sys$devpath/brightness\", "
    "RUN+=\"/run/current-system/profile/bin/chmod g+w $sys$devpath/brightness\"")))

(define %udev-rules-for-controller
  (udev-rule
   "91-steam-controller-perms.rules"
   "# This rule is needed for basic functionality of the controller in Steam and keyboard/mouse emulation
SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"28de\", MODE=\"0666\"

# This rule is necessary for gamepad emulation; make sure you replace 'pgriffais' with a group that the user that runs Steam belongs to
KERNEL==\"uinput\", MODE=\"0660\", GROUP=\"pgriffais\", OPTIONS+=\"static_node=uinput\"

# Valve HID devices over USB hidraw
KERNEL==\"hidraw*\", ATTRS{idVendor}==\"28de\", MODE=\"0666\"

# Valve HID devices over bluetooth hidraw
KERNEL==\"hidraw*\", KERNELS==\"*28DE:*\", MODE=\"0666\"

# DualShock 4 over USB hidraw
KERNEL==\"hidraw*\", ATTRS{idVendor}==\"054c\", ATTRS{idProduct}==\"05c4\", MODE=\"0666\"

# DualShock 4 wireless adapter over USB hidraw
KERNEL==\"hidraw*\", ATTRS{idVendor}==\"054c\", ATTRS{idProduct}==\"0ba0\", MODE=\"0666\"

# DualShock 4 Slim over USB hidraw
KERNEL==\"hidraw*\", ATTRS{idVendor}==\"054c\", ATTRS{idProduct}==\"09cc\", MODE=\"0666\"

# DualShock 4 over bluetooth hidraw
KERNEL==\"hidraw*\", KERNELS==\"*054C:05C4*\", MODE=\"0666\"

# DualShock 4 Slim over bluetooth hidraw
KERNEL==\"hidraw*\", KERNELS==\"*054C:09CC*\", MODE=\"0666\"
"))

;; support for transparent emulation of program binaries built for
;; different architectures
(define-public %qemu-binfmt-service
  (service qemu-binfmt-service-type
           (qemu-binfmt-configuration
            (platforms (lookup-qemu-platforms "arm" "aarch64")))))

(define-public %postgres-service
  (service postgresql-service-type
           (postgresql-configuration
            (postgresql postgresql-16))))

(define-public %postgres-roles
  (service postgresql-role-service-type
           (postgresql-role-configuration
            (roles
             (list (postgresql-role
                     (name "cuirass")
                     (create-database? #t))
                   (postgresql-role
                     (name "fstamour")
                     (create-database? #t)))))))

(define-public %cuirass-service
  (service cuirass-service-type
           (cuirass-configuration
            (specifications %cuirass-specs)
            ;; (specifications #~(list))
            ;; When substituting a pre-built binary fails, fall back
            ;; to building packages locally.
            (fallback? #t))))

(define-public %services
  (list
   ;; To configure OpenSSH, pass an 'openssh-configuration'
   ;; record as a second argument to 'service' below.
   (service openssh-service-type)
   ;; make it possible to serve guix's store
   (service guix-publish-service-type
            (guix-publish-configuration
             (host "0.0.0.0")
             (port 9876)
             (advertise? #t)))
   ;; add containerd, required by dockerd
   (service containerd-service-type)
   ;; add docker
   (service docker-service-type)
   ;; add CUPS
   (service cups-service-type)
   (udev-rules-service 'controllers %udev-rules-for-controller)
   (udev-rules-service 'logitech-unify %logitech-unify-udev-rule)
   (service nix-service-type)))

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
                %postgres-service
                %postgres-roles
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
                           (type "ext4"))
                         (file-system
                           (mount-point "/home/fstamour/data")
                           (device (uuid
                                    "5f17883e-732e-4e86-b3d9-2fc7b3c96600"
                                    'btrfs))
                           (type "btrfs"))
                         %base-file-systems))))


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
               %sddm
               ;; I gotta be honest, I'm not sure which udev rule made
               ;; it work.
               ;;
               ;; I used `ll /sys/class/backlight/nv_backlight/` to
               ;; validate that the file `brightness` was editable by
               ;; the group "video".
               (udev-rules-service 'backlight %backlight-udev-rule)
               (udev-rules-service 'backlight acpilight #:groups '("video")))
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
