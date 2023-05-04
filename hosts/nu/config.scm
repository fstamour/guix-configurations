;; This is an operating system configuration generated
;; by the graphical installer.
;;
;; Once installation is complete, you can learn and modify
;; this file to tweak the system configuration, and pass it
;; to the 'guix system reconfigure' command to effect your
;; changes.


;; Indicate which modules to import to access the variables
;; used in this configuration.

(define-module (host-nu)
  #:use-module (gnu)
  #:use-module (gnu packages xorg) ;; for xorg-server
  #:use-module (gnu services linux) ;; for kernel-module-loader-service-type
  #:use-module (gnu services sddm)
  #:use-module (gnu services docker)
  #:use-module (guix transformations) ;; for options->transformation
  #:use-module (nongnu packages linux) ;; for linux-lts (which is not linux-libre)
  #:use-module (nongnu packages nvidia))

;; (use-package-modules linux)

(use-service-modules
 cups
 desktop
 ;; linux
 networking
 ssh
 xorg)

(define transform
  (options->transformation
   '((with-graft . "mesa=nvda"))))

(define %users/fstamour
  (user-account
   (name "fstamour")
   (comment "Francis St-Amour")
   (group "users")
   (home-directory "/home/fstamour")
   (supplementary-groups '("wheel" "netdev" "audio" "video"))))

(operating-system
 (host-name "nu")

 (locale "en_CA.utf8")
 (timezone "America/New_York")
 (keyboard-layout (keyboard-layout "us"))

 (kernel linux-lts)
 
 ;; Blacklist the "nouveau" kernel module
 (kernel-arguments (append
                    '("modprobe.blacklist=nouveau")
                    %default-kernel-arguments))

 ;; Add "nvidia-driver" to the list of loadable kernel modules
 (kernel-loadable-modules (list nvidia-module))


 ;; The list of user accounts ('root' is implicit).
 (users (cons* %users/fstamour
               %base-user-accounts))

 ;; Packages installed system-wide.  Users can also install packages
 ;; under their own account: use 'guix search KEYWORD' to search
 ;; for packages and 'guix install PACKAGE' to install a package.
 (packages (append (list (specification->package "i3-wm")
                         (specification->package "i3status")
			 (specification->package "xfce")
                         (specification->package "dmenu")
                         (specification->package "nss-certs"))
                   %base-packages))

 ;; Below is the list of system services.  To search for available
 ;; services, run 'guix system search KEYWORD' in a terminal.
 (services
  (append (list

           ;; To configure OpenSSH, pass an 'openssh-configuration'
           ;; record as a second argument to 'service' below.
           (service openssh-service-type)

	   ;; Printer!
	   (service cups-service-type)

	   ;; Use SDDM desktop manager (because I hate GDM)
	   (service sddm-service-type
		    (sddm-configuration
		     (xorg-configuration
		      (xorg-configuration
		       (keyboard-layout keyboard-layout)
		       ;; list nvidia-driver to the list of modules
		       ;(modules (cons* nvidia-driver %default-xorg-modules))
		       ;; graft!
                       ;(server (transform xorg-server))
		       ;; specify which driver to use (spoiler: nvidia)
					;(drivers '("nvidia"))
		       ))))

	   ;; Udev rule for nvidia cards
	   (simple-service 'custom-udev-rules udev-service-type (list nvidia-driver))
	   ;; Service to load nvidia's kernel modules
	   (service kernel-module-loader-service-type
		    '("ipmi_devintf"
		      "nvidia"
		      "nvidia_modeset"
		      "nvidia_uvm"))

	  ;; Add a docker daemon
	   (service docker-service-type)

	   ;; End of the first list of services
	   ) 

	  (modify-services
	   ;; This is the default list of services
	   %desktop-services

	   ;; I use sddm instead of gdm
	   (delete gdm-service-type)

	   ;; Configure guix to use substitutes for nonguix
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
