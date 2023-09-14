;;;; Daemon offloading
;; https://guix.gnu.org/manual/en/html_node/Daemon-Offload-Setup.html
;;
;; This file should be place at /etc/guix/machines.scm
;;
;; TODO use avahi!
;;
;; Prerequisites:
;; - The guix command must be in the search path on the
;;   build machines.
;; - public keys...

(list (build-machine
       ;; (name "nu.local")
       (name "192.168.0.104")
       (systems (list "x86_64-linux" "i686-linux"))
       (host-key "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDtcPFnhdBdJ5OAw9t+O+qCWyPOi+AArOnaFkp5cl93v root@(none)")
       (user "fstamour")
       (private-key "/root/.ssh/id_ed25519")
       (speed 2.)))
