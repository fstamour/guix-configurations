
(define-module (fstamour home emacs))

(define-public %emacs-packages
  '("emacs"

    "emacs-magit"
    "emacs-guix"
    "emacs-envrc"

    ;; workaround: use straight to try out some packages without
    ;; packaging them with guix
    "emacs-straight"

;;; 👀
    "emacs-ellama"

;;; Aesthetic stuff
    ;; "emacs-darkroom" ; doesn't work (arithmetic error)
    "emacs-focus"
    "emacs-writeroom"

    "emacs-page-break-lines"
    "emacs-rainbow-delimiters"
    "emacs-diminish"


;;; Editing stuff
    "emacs-aggressive-indent"
    "emacs-emmet-mode"
    "emacs-web-mode"
    "emacs-lispy"
    "emacs-paredit"

    ;; Inspector for emacs lisp
    "emacs-inspector"
    "emacs-tree-inspector"

    ;; Formatter
    "emacs-prettier"

    ;; "emacs-sqlformat" ; not in guix
    "emacs-tempel"

;;; Window/frame/navigation/search stuff
    "emacs-ace-window"
    "emacs-deadgrep"
    "emacs-avy" ;; for "jumping to visible text using a char-based decision tree"


;;; Org-mode stuff
    "emacs-org-download"
    "emacs-org-roam"
    ;; "emacs-org-hugo" ; not in guix

    "emacs-howm" ;; note-taking tool for Emacs

;;; Completion stuff
    "emacs-vertico"
    ;; "emacs-vertico-prescient" ; not in guix
    "emacs-prescient"

    ;; nerdtree for emacs (kinda)
    ;;"emacs-neotree" ;; the guix's package is missing icons
    "emacs-treemacs"

    ;; Emacs ❤️ Debug Adapter Protocol
    ;; https://github.com/emacs-lsp/dap-mode
    ;; "emacs-dap-mode" ;; work only with lsp-mode, not eglot

    ;; Debug Adapter Protocol for Emacs https://github.com/svaante/dape
    "emacs-dape"


    ;; language modes
    "emacs-cmake-mode"
    "emacs-fish-mode"
    ;; "emacs-forth" ; not in guix
    "emacs-nix-mode"
    "emacs-jedi"
    ;; "emacs-virtualenvwrapper"  ; not in guix
    "emacs-terraform-mode"
    "emacs-yaml-mode"
    "emacs-docker"
    ;; "emacs-docker-tramp" by "tramp-container", which is not in guix
    "emacs-dockerfile-mode"
    "emacs-docker-compose-mode"
    "emacs-rec-mode"                  ; for editing recutils databases

    ;; emacs-gitlab-ci-mode
    ;; emacs-gitlab-snip-helm
    ))
