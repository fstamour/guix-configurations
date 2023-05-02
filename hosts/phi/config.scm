;; Indicate which modules to import to access the variables
;; used in this configuration.
(use-modules (gnu))
(use-modules (nongnu packages linux)
             (nongnu system linux-initrd)
	     (nongnu packages nvidia)
	     (guix transformations))

(use-service-modules cups desktop networking ssh xorg)

(operating-system
 (kernel linux)

 ;; Intel Wi-Fi
 (initrd microcode-initrd)
 (firmware (cons* iwlwifi-firmware
                  %base-firmware))

 ;; Locale etc
 (locale "en_CA.utf8")
 (timezone "America/New_York")
 (keyboard-layout (keyboard-layout "us"))

 (host-name "phi")

 ;; The list of user accounts ('root' is implicit).
 (users (cons* (user-account
                (name "fstamour")
                (comment "Francis St-Amour")
                (group "users")
                (home-directory "/home/fstamour")
                (supplementary-groups '("wheel" "netdev" "audio" "video")))
               %base-user-accounts))

 ;; Packages installed system-wide.  Users can also install packages
 ;; under their own account: use 'guix search KEYWORD' to search
 ;; for packages and 'guix install PACKAGE' to install a package.
 (packages (append (specifications->packages
		    (list
                     "nss-certs"
       		     "fish"))
                   %base-packages))

 ;; Below is the list of system services.  To search for available
 ;; services, run 'guix system search KEYWORD' in a terminal.
 (services
  (append (list (service gnome-desktop-service-type)
                ;; To configure OpenSSH, pass an 'openssh-configuration'
                ;; record as a second argument to 'service' below.
                (service openssh-service-type)
                (set-xorg-configuration
                 (xorg-configuration (keyboard-layout keyboard-layout))))

          ;; This is the default list of services we
          ;; are appending to.
          (modify-services
	   %desktop-services
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
              (bootloader grub-bootloader)
              (targets (list "/dev/sda"))
              (keyboard-layout keyboard-layout)))
 
 (mapped-devices (list (mapped-device
                        (source (uuid
                                 "149df863-0e36-4b84-b92b-9767999e406a"))
                        (target "cryptroot")
                        (type luks-device-mapping))))

 ;; The list of file systems that get "mounted".  The unique
 ;; file system identifiers there ("UUIDs") can be obtained
 ;; by running 'blkid' in a terminal.
 (file-systems (cons* (file-system
                       (mount-point "/")
                       (device "/dev/mapper/cryptroot")
                       (type "ext4")
                       (dependencies mapped-devices)) %base-file-systems)))
