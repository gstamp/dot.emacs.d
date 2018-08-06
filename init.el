;; Temporarily up GC limit to speed up start up
(setq gc-cons-threshold 100000000)
(run-with-idle-timer
  5 nil
  (lambda ()
    (setq gc-cons-threshold 1000000)))

;;;;;;;;;;;;;;;;;
;; Use Package ;;
;;;;;;;;;;;;;;;;;

;; Use package cheat sheet because I'm always forgetting them:
;; :init execute code before a package is loaded
;; :config can be used to execute code after a package is loaded
;; :bind ("C-." . ace-jump-mode) binds and defers load
;; :bind-keymap ("C-c p" . projectile-command-map) bind to keymap
;; :commands creates autoloads for those commands and defers loading of the module until they are used
;; :mode & :interpreter deferred binding within the auto-mode-alist and interpreter-mode-alist
;; :hook prog-mode  magically add hook for given mode
;; :if only execute on condition
;; :disabled turn off declaration
;; :diminish abbrev-mode  don't display mode in modeline
;; :ensure-system-package ensure system binaries exist alongside your package declarations


(require 'package)
(setq package-enable-at-startup nil) ;; Don't load packages on startup
(setq package-archives '(("marmalade" . "https://marmalade-repo.org/packages/")
                          ("melpa" . "http://melpa.milkbox.net/packages/")
                          ("org" . "https://orgmode.org/elpa/")
                          ("gnu" . "https://elpa.gnu.org/packages/")
                          ))
(package-initialize)

;; Bootstrap use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Debug package loads
(setq use-package-verbose t)
(setq use-package-always-ensure t)

;; Give me an imenu of packages in use
(setq use-package-enable-imenu-support t)

;; Gather stats during load. M-x use-package-report to see details
(setq use-package-compute-statistics nil)

(eval-when-compile
  (require 'use-package))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Start Server if we can ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(load "server")
(unless (server-running-p) (server-start))

;;;;;;;;;;;;;;;;;;;;;;;;;
;; Some base libraries ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(load "~/.emacs.secrets" t)

(use-package diminish)

(require 'cl) ;; common lisp functions

(diminish 'hi-lock-mode "")

;; UTF-8 Thanks
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(prefer-coding-system 'utf-8)
(setq org-export-coding-system 'utf-8)
(set-charset-priority 'unicode)
(setq default-process-coding-system '(utf-8-unix . utf-8-unix))

;; File paths
(defvar stamp/dotfiles-dir (file-name-directory load-file-name)
  "The root dir of my Emacs config.")
(defvar stamp/savefile-dir (expand-file-name "savefile" stamp/dotfiles-dir)
  "This folder stores all the automatically generated save/history-files.")

;; Ensure savefile directory exists
(unless (file-exists-p stamp/savefile-dir)
  (make-directory stamp/savefile-dir))

;; Keep emacs Custom-settings in separate file
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)

;; Set up load paths
(add-to-list 'load-path (expand-file-name "vendor" stamp/dotfiles-dir))

(setq user-full-name "Glen Stampoultzis"
      user-mail-address "gstamp@gmail.com")

;; Fix our shell environment on OSX
(when (eq system-type 'darwin)
  (use-package exec-path-from-shell
    :defer 1
    :init
    (setq exec-path-from-shell-variables '("PATH"
                                            "EDITOR"
                                            "GIT_EDITOR"
                                            "MANPATH"
                                            "BOXEN_HOME"
                                            "BOXEN_BIN_DIR"
                                            "BOXEN_CONFIG_DIR"
                                            "BOXEN_DATA_DIR"
                                            "BOXEN_ENV_DIR"
                                            "BOXEN_LOG_DIR"
                                            "BOXEN_SOCKET_DIR"
                                            "BOXEN_SRC_DIR"
                                            "BOXEN_DOWNLOAD_URL_BASE"
                                            "BOXEN_HOMEBREW_BOTTLE_URL"
                                            "BOXEN_GITHUB_LOGIN"
                                            "BOXEN_ELASTICSEARCH_HOST"
                                            "BOXEN_ELASTICSEARCH_PORT"
                                            "BOXEN_ELASTICSEARCH_URL"
                                            "BOXEN_MONGODB_HOST"
                                            "BOXEN_MONGODB_PORT"
                                            "BOXEN_MONGODB_URL"
                                            "BOXEN_POSTGRESQL_HOST"
                                            "BOXEN_POSTGRESQL_PORT"
                                            "BOXEN_POSTGRESQL_URL"
                                            "BOXEN_REDIS_HOST"
                                            "BOXEN_REDIS_PORT"
                                            "BOXEN_REDIS_URL"
                                            "BOXEN_MEMCACHED_PORT"
                                            "BOXEN_MEMCACHED_URL"
                                            "BOXEN_MYSQL_PORT"
                                            "BOXEN_MYSQL_SOCKET"
                                            "BOXEN_MYSQL_URL"
                                            "BOXEN_SETUP_VERSION"
                                            "RBENV_ROOT"
                                            "BUNDLE_JOBS"
                                            "GOPATH"))
    :config
    (exec-path-from-shell-initialize))

  ;; Default font thanks
  (set-frame-font "Operator Mono-14:weight=normal")
  ;;(set-frame-font "Office Code Pro D-14:weight=light")
  )

;; Switch alt and meta
(setq mac-option-modifier 'super)
(setq mac-command-modifier 'meta)

;; warn when opening files bigger than 100MB
(setq large-file-warning-threshold 100000000)

;; Some terminal key sequence mapping hackery
(defadvice terminal-init-xterm
  (after map-C-comma-escape-sequence activate)
  (define-key input-decode-map "\e[1;," (kbd "C-,")))

;;;;;;;;;;;
;; Lispy ;;
;;;;;;;;;;;

(use-package lispy
  :diminish (lispy-mode . " λ")

  :config
  (add-hook 'emacs-lisp-mode-hook (lambda ()
                                    (lispy-mode 1)
                                    ))
  ;; Undefine M-m
  (define-key lispy-mode-map "\M-m" nil))


;;;;;;;;;;;;;
;; General ;;
;;;;;;;;;;;;;

;; Faster
(setq font-lock-verbose nil)

;; no jerky scrolling
(setq scroll-conservatively 101)

;; Move point to the help window
(setq help-window-select t)

;; Get rid of chrome
(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)

;; Cursor blinking options
(setq cursor-type 'bar)
(setq blink-cursor-blinks 20)
(setq blink-cursor-interval 0.3)
(blink-cursor-mode 1)
(set-cursor-color "yellow")

;; No startup screen
(setq inhibit-startup-screen t)

;; Follow compilation output
(setq compilation-scroll-output t)

;; Scroll to first error
(setq compilation-scroll-output 'first-error)

;; No bell thanks
(setq ring-bell-function 'ignore)

;; Save clipboard contents into kill-ring before replacing them
(setq save-interprogram-paste-before-kill t)

;; Single space between sentences
(setq-default sentence-end-double-space nil)

;; Nice scrolling
(setq scroll-margin 0
  scroll-conservatively 100000
  scroll-preserve-screen-position 1)

;; Enable some stuff
(put 'set-goal-column  'disabled nil)
(put 'narrow-to-defun  'disabled nil)
(put 'narrow-to-page   'disabled nil)
(put 'narrow-to-region 'disabled nil)

;; Enable y/n answers
(fset 'yes-or-no-p 'y-or-n-p)

;; Echo commands quickly
(setq echo-keystrokes 0.02)

;; Slower mouse scroll
(setq mouse-wheel-scroll-amount '(1))

;; A more useful frame title, that show either a file or a
;; buffer name (if the buffer isn't visiting a file)
(setq frame-title-format
  '("" invocation-name " - " (:eval (if (buffer-file-name)
                                      (abbreviate-file-name (buffer-file-name))
                                      "%b"))))

;; Follow symlinks by default
(setq vc-follow-symlinks t)

;; Don't combine tag tables thanks
(setq tags-add-tables nil)

;; Automatically load changed tags files
(setq tags-revert-without-query t)

;; Don't pop up new frames on each call to open
(setq ns-pop-up-frames nil)

;; Use system trash
(setq delete-by-moving-to-trash t)

;; Wrap lines for text modes
(setq visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow))
;; Lighter line continuation arrows
(define-fringe-bitmap 'left-curly-arrow [0 64 72 68 126 4 8 0])
(define-fringe-bitmap 'right-curly-arrow [0 2 18 34 126 32 16 0])

(diminish 'visual-line-mode "")
(add-hook 'text-mode-hook 'turn-on-visual-line-mode)

;; Make files with the same name have unique buffer names
(setq uniquify-buffer-name-style 'forward)

;; Delete selected regions
(delete-selection-mode t)
(transient-mark-mode nil)

;; Revert buffers automatically when underlying files are changed externally
(global-auto-revert-mode t)
(diminish 'auto-revert-mode)

;; World times
(setq display-time-world-list '(("Australia/Brisbane" "Brisbane")
                                 ("Australia/Melbourne" "Melbourne")
                                 ("Europe/London" "London")
                                 ("America/New_York" "New York")
                                 ("America/Los_Angeles" "San Francisco")))

;; Base 10 for inserting quoted chars please
(setq read-quoted-char-radix 10)

;; Silence advice warnings
(setq ad-redefinition-action 'accept)


;;;;;;;;;;;;
;; Moving ;;
;;;;;;;;;;;;

(use-package move-text
             :bind
             (("C-S-<up>" . move-text-up)
              ("C-S-<down>" . move-text-down)))

(use-package windmove
             :bind
             (("S-<right>" . windmove-right)
              ("S-<left>"  . windmove-left)
              ("S-<up>"    . windmove-up)
              ("S-<down>"  . windmove-down)))

;;;;;;;;;;;;;;;;
;; Encryption ;;
;;;;;;;;;;;;;;;;

(setq epg-gpg-program "gpg2")
(setq epa-file-encrypt-to "gstamp@gmail.com")


;;;;;;;;;;;;
;; Themes ;;
;;;;;;;;;;;;

;; Must require this before spaceline.
;; anzu.el provides a minor mode which displays current match and
;; total matches information in the mode-line in various search modes.
(use-package anzu
  :diminish anzu-mode
  :defer 3
  :init (global-anzu-mode +1))

;; Disable themes before loading them (in daemon mode esp.)
(defadvice load-theme (before theme-dont-propagate activate)
  (mapc #'disable-theme custom-enabled-themes))

;; Set default frame size
(add-to-list 'default-frame-alist '(height . 60))
(add-to-list 'default-frame-alist '(width . 110))

(use-package base16-theme
  :ensure t
  :init
  (defun stamp/set-gui-config ()
    "Enable my GUI settings"
    (interactive)
    (menu-bar-mode +1)
    ;; Highlight the current line
    (global-hl-line-mode +1)
    ;; Load theme
    ;;(load-theme 'spacemacs-light)
    ;;(load-theme 'spacemacs-dark)
    ;;(load-theme 'idea-darkula)
    ;;(load-theme 'doom-one)
    ;;(load-theme 'doom-light)
    ;;(load-theme 'darkokai)
    ;;(load-theme 'hydandata-light)
    ;;(load-theme 'pastelmac)
    (load-theme 'base16-bespin)
    )

  (defun stamp/set-terminal-config ()
    "Enable my terminal settings"
    (interactive)
    (xterm-mouse-mode 1)
    (menu-bar-mode -1))

  (defun stamp/set-ui ()
    (if (display-graphic-p)
      (stamp/set-gui-config)
      (stamp/set-terminal-config)))

  (defun stamp/set-frame-config (&optional frame)
    "Establish settings for the current terminal."
    (with-selected-frame frame
      (stamp/set-ui))))

;; Only need to set frame config if we are in daemon mode
(if (daemonp)
  (add-hook 'after-make-frame-functions 'stamp/set-frame-config)
  ;; Load theme on app creation
  (stamp/set-ui))


(if (boundp 'darkokai)
    (custom-theme-set-faces
     'darkokai
     '(company-tooltip-common ((t (:inherit company-tooltip :weight bold :underline nil))))
     '(company-tooltip-common-selection ((t (:inherit company-tooltip-selection :weight bold :underline nil))))
     '(erm-syn-errline ((t (:underline (:color "Red" :style wave)))))
     '(erm-syn-warnline ((t (:underline (:color "Orange" :style wave)))))
     '(font-lock-comment-face ((t (:slant italic))))
     '(font-lock-doc-face ((t (:slant italic))))
     '(idle-highlight ((t (:inherit nil :underline t))))
     '(org-block ((t (:background "black" :foreground "#6A6D70"))))
     '(org-block-begin-line ((t (:background "lawn green" :foreground "black" :slant italic))))
     '(region ((t (:inherit highlight :background "dark salmon"))))
     '(show-paren-match ((t (:background "#707070"))))
     ))

;;;;;;;;;;;;;;;;;;;;;;;;
;; General Define Key ;;
;;;;;;;;;;;;;;;;;;;;;;;;

(use-package general)

;;;;;;;;;;;;;;;
;; UI & Help ;;
;;;;;;;;;;;;;;;

(use-package hydra)

;; Keep this for its scoring algorithm
(use-package flx-ido)

(use-package ivy
  :diminish (ivy-mode . "")
  :init
  (setq ivy-initial-inputs-alist '((org-refile . "^")
                                    (org-agenda-refile . "^")
                                    (org-capture-refile . "^")
                                    (counsel-M-x . "")
                                    (counsel-describe-function . "^")
                                    (counsel-describe-variable . "^")
                                    (man . "^")
                                    (woman . "^")))

  (setq ivy-height 20)
  (setq ivy-fixed-height-minibuffer nil)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-virtual-abbreviate 'full)   ; Show the full virtual file paths
  (setq ivy-extra-directories nil)      ; don't show . and ..
  (setq ivy-count-format "")            ;; Don't count candidates
  (setq ivy-re-builders-alist
    '((swiper . ivy--regex-plus)
       (t . ivy--regex-fuzzy)))

  (general-define-key :keymaps '(ivy-occur-mode-map ivy-occur-grep-mode-map)
    :states '(emacs)
    "C-c C-0" 'ivy-occur-revert-buffer)
  (general-define-key
    "C-x C-b" 'ivy-switch-buffer
    "C-c C-r" 'ivy-resume
    )
  (ivy-mode 1)

  (use-package ivy-posframe
    :init
    (setq ivy-display-function #'ivy-posframe-display)
    ;; (setq ivy-display-function #'ivy-posframe-display-at-point)
    :config
    (ivy-posframe-enable))

  :config
  (add-hook 'ivy-occur-grep-mode 'wgrep-ag-setup)
  (bind-keys :map ivy-occur-grep-mode-map
    ("e" . wgrep-change-to-wgrep-mode))

  ;; https://github.com/abo-abo/swiper/blob/master/ivy-hydra.el
  (use-package ivy-hydra
    :ensure t
    :config
    (progn
      ;; Re-define the `hydra-ivy' defined in `ivy-hydra' package.
      (defhydra hydra-ivy (:hint nil
                            :color pink)
        "
^ _,_ ^      _f_ollow      occ_u_r      _g_o          ^^_c_alling: %-7s(if ivy-calling \"on\" \"off\")      _w_(prev)/_s_(next)/_a_(read) action: %-14s(ivy-action-name)
_p_/_n_      _d_one        ^^           _i_nsert      ^^_m_atcher: %-7s(ivy--matcher-desc)^^^^^^^^^^^^      _C_ase-fold: %-10`ivy-case-fold-search
^ _._ ^      _D_o it!      ^^           _q_uit        _<_/_>_ shrink/grow^^^^^^^^^^^^^^^^^^^^^^^^^^^^       _t_runcate: %-11`truncate-lines
"
        ;; Arrows
        ("," ivy-beginning-of-buffer)      ;Default h
        ("p" ivy-previous-line)            ;Default j
        ("n" ivy-next-line)                ;Default k
        ("." ivy-end-of-buffer)            ;Default l
        ;; Quit ivy
        ("q" keyboard-escape-quit :exit t) ;Default o
        ("C-g" keyboard-escape-quit :exit t)
        ;; Quit hydra
        ("i" nil)
        ("C-o" nil)
        ;; actions
        ("f" ivy-alt-done :exit nil)
        ;; Exchange the default bindings for C-j and C-m
        ("C-m" ivy-alt-done :exit nil)  ;RET, default C-j
        ("C-j" ivy-done :exit t)        ;Default C-m
        ("d" ivy-done :exit t)
        ("D" ivy-immediate-done :exit t)
        ("g" ivy-call)
        ("c" ivy-toggle-calling)
        ("m" ivy-rotate-preferred-builders)
        (">" ivy-minibuffer-grow)
        ("<" ivy-minibuffer-shrink)
        ("w" ivy-prev-action)
        ("s" ivy-next-action)
        ("a" ivy-read-action)
        ("t" (setq truncate-lines (not truncate-lines)))
        ("C" ivy-toggle-case-fold)
        ("u" ivy-occur :exit t)
        ("?" (ivy-exit-with-action      ;Default D
               (lambda (_) (find-function #'hydra-ivy/body))) "Definition of this hydra" :exit t))

      (bind-keys
        :map ivy-minibuffer-map
        ("C-t" . ivy-rotate-preferred-builders)
        ("C-o" . hydra-ivy/body)
        ("M-o" . ivy-dispatching-done-hydra))))

  (bind-keys
    :map ivy-minibuffer-map
    ;; Exchange the default bindings for C-j and C-m
    ("C-m" . ivy-alt-done)              ;RET, default C-j
    ("C-j" . ivy-done)                  ;Default C-m
    ("C-S-m" . ivy-immediate-done))

  (bind-keys
    :map ivy-occur-mode-map
    ("n" . ivy-occur-next-line)
    ("p" . ivy-occur-previous-line)
    ("b" . backward-char)
    ("f" . forward-char)
    ("v" . ivy-occur-press)            ;Default f
    ("RET" . ivy-occur-press))

  
  )

(use-package counsel
  :init
  (general-define-key "M-x" 'counsel-M-x
    "C-x C-f" 'counsel-find-file
    "C-x f" 'counsel-recentf
    "C-c k" 'counsel-rg
    )
  (define-key read-expression-map (kbd "C-r") 'counsel-expression-history)
  (setq counsel-find-file-ignore-regexp
    (concat
      ;; file names beginning with # or .
      "\\(?:\\`[#.]\\)"
      ;; file names ending with # or ~
      "\\|\\(?:[#~]\\'\\)"
      ;; Those stupid .DS_Store files
      "\\|.*.DS_Store"
      ))
  )

;; Requiring smex keeps our command history
(use-package smex)

(use-package rg
  :commands (rg rg-project)
  :config
  (setq ag-group-matches nil))


(use-package ag
  :commands (ag ag-project)
  :config
  (setq ag-group-matches nil)

  (use-package wgrep-ag
    :config
    (add-hook 'ag-mode-hook 'wgrep-ag-setup)
    (bind-keys :map ivy-occur-grep-mode-map
      ("e" . wgrep-change-to-wgrep-mode))
    (bind-keys :map ag-mode-map
      ("e" . wgrep-change-to-wgrep-mode))))

(use-package swiper
  :commands swiper)

(defun swiper-current-word ()
  "Trigger swiper with current word at point"
  (interactive)
  (let (word beg)
    (with-current-buffer (window-buffer (minibuffer-selected-window))
      (save-excursion
        (skip-syntax-backward "w_")
        (setq beg (point))
        (skip-syntax-forward "w_")
        (setq word (buffer-substring-no-properties beg (point)))))
    (when word
      (swiper word))))

;; Subtle highlighting of matching parens (global-mode)
(add-hook 'prog-mode-hook (lambda ()
                            (show-paren-mode +1)
                            (setq show-paren-style 'parenthesis)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Backups and editing history ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Store all backup and autosave files in the tmp dir
(setq backup-directory-alist
  (list (cons ".*" (expand-file-name "~/.emacs-backups/"))))

(setq auto-save-file-name-transforms
  `((".*" "~/.cache/emacs/saves/" t)))

(use-package saveplace
  :config
  ;; Saveplace remembers your location in a file when saving files
  (setq save-place-file (expand-file-name "saveplace" stamp/savefile-dir))
  :init
  (save-place-mode 1))

;; UI highlight search and other actions
(use-package volatile-highlights
  :diminish volatile-highlights-mode
  :defer 3
  :config
  (volatile-highlights-mode t))

;; Save minibuffer history etc
(use-package savehist
  :defer 2
  :config
  (setq savehist-additional-variables
    ;; search entries
    '(search ring regexp-search-ring)
    ;; save every minute
    savehist-autosave-interval 60
    ;; keep the home clean
    savehist-file (expand-file-name "savehist" stamp/savefile-dir))
  (savehist-mode 1))

(use-package recentf
  :defer 2
  :commands recentf-mode
  :config
  (add-to-list 'recentf-exclude "\\ido.hist\\'")
  (add-to-list 'recentf-exclude "/TAGS")
  (add-to-list 'recentf-exclude "/.autosaves/")
  (add-to-list 'recentf-exclude "intero-script")
  (add-to-list 'recentf-exclude "emacs.d/elpa/")
  (add-to-list 'recentf-exclude "COMMIT_EDITMSG\\'")
  (setq recentf-save-file (expand-file-name "recentf" stamp/savefile-dir))
  (setq recentf-max-saved-items 100))

(add-hook 'find-file-hook (lambda () (unless recentf-mode
                                       (recentf-mode)
                                       (recentf-track-opened-file))))

(use-package undo-tree
  :diminish undo-tree-mode
  :commands undo-tree-visualize
  :init
  (global-undo-tree-mode))


(use-package which-key
  :diminish which-key-mode
  :init
  (setq which-key-idle-delay 0.3)
  (setq which-key-idle-secondary-delay 0.0)
  (setq which-key-min-display-lines 3)
  (setq which-key-sort-order 'which-key-key-order-alpha)

  (setq which-key-description-replacement-alist
    '(("Prefix Command" . "prefix")
       ("which-key-show-next-page" . "wk next pg")
       ("\\`calc-" . "") ; Hide "calc-" prefixes when listing M-x calc keys
       ("/body\\'" . "") ; Remove display the "/body" portion of hydra fn names
       ("string-inflection" . "si")
       ("counsel-" . "c/")
       ("crux-" . "cx/")
       ("stamp/" . "s/")
       ("\\`hydra-" . "+h/")
       ("\\`org-babel-" . "ob/")))
  (which-key-mode 1))


;;;;;;;;;;;;;;;;;;;;;;;;;
;; Seeing Is Beleiving ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

;; Seeing is beleiving
(defun see ()
  "Replace the current file with seeing is believing result."
  (interactive)
  (save-current-buffer
    (let ((origin (point)))
      (shell-command
       (concat "bundle exec seeing_is_believing -d 300 -x "
               (buffer-file-name (current-buffer)))
       (current-buffer))
      (goto-char origin))) )

(defun see-all ()
  "Replace the current file with seeing is believing result."
  (interactive)
  (save-current-buffer
    (let ((origin (point)))
      (shell-command
       (concat "bundle exec seeing_is_believing -d 600 "
               (buffer-file-name (current-buffer)))
        (current-buffer))
      (normal-mode)
      (toggle-truncate-lines 1)
      (goto-char origin))) )

(defun unsee ()
  "Clean seeing is believing buffer."
  (interactive)
  (save-current-buffer
    (let ((origin (point)))
      (shell-command
       (concat "bundle exec seeing_is_believing -c "
               (buffer-file-name (current-buffer)))
        (current-buffer))
      (normal-mode)
      (goto-char origin))) )


;;;;;;;;;;;;;;;
;; Selection ;;
;;;;;;;;;;;;;;;

(use-package expand-region
  :commands er/expand-region
  :bind (("C-=" . er/expand-region)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Autocomplete and snippets ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; abbrev-mode for common typos
(setq abbrev-file-name "~/.emacs.d/abbrev_defs")
(diminish 'abbrev-mode " ⓐ")
(setq-default abbrev-mode t)

(use-package company
  :diminish (company-mode . " ⓒ")
  :config
  (setq company-idle-delay 0.5)
  (setq company-minimum-prefix-length 3)
  (setq company-dabbrev-ignore-case nil)
  (setq company-dabbrev-downcase nil)
  (setq company-global-modes
    '(not markdown-mode org-mode erc-mode))

  ;; Tweak fonts
  (custom-set-faces
    '(company-tooltip-common
       ((t (:inherit company-tooltip :weight bold :underline nil))))
    '(company-tooltip-common-selection
       ((t (:inherit company-tooltip-selection :weight bold :underline nil))))))

(eval-after-load 'company
  '(progn
     (general-define-key :keymaps 'company-active-map
       "TAB" 'nil
       "<tab>" 'nil
       "S-TAB" 'company-select-previous
       "<backtab>" 'company-select-previous
       "ESC" 'company-abort)))

(add-hook 'after-init-hook 'global-company-mode)

;; replace dabbrev-expand with Hippie expand
(setq hippie-expand-try-functions-list
  '(
     ;; Try to expand yasnippet snippets based on prefix
     yas-hippie-try-expand

     ;; Try to expand word "dynamically", searching the current buffer.
     try-expand-dabbrev
     ;; Try to expand word "dynamically", searching all other buffers.
     try-expand-dabbrev-all-buffers
     ;; Try to expand word "dynamically", searching the kill ring.
     try-expand-dabbrev-from-kill
     ;; Try to complete text as a file name, as many characters as unique.
     try-complete-file-name-partially
     ;; Try to complete text as a file name.
     try-complete-file-name
     ;; Try to expand word before point according to all abbrev tables.
     try-expand-all-abbrevs
     ;; Try to complete the current line to an entire line in the buffer.
     try-expand-list
     ;; Try to complete the current line to an entire line in the buffer.
     try-expand-line
     ;; Try to complete as an Emacs Lisp symbol, as many characters as
     ;; unique.
     try-complete-lisp-symbol-partially
     ;; Try to complete word as an Emacs Lisp symbol.
     try-complete-lisp-symbol))

;;;;;;;;;;;;;;
;; Snippets ;;
;;;;;;;;;;;;;;

(use-package yasnippet
  :diminish (yas-minor-mode . " ⓨ")
  :defer 1
  :config
  (setq yas-snippet-dirs '("~/.emacs.d/snippets"))
  (setq yas-verbosity 1)
  (yas-global-mode 1))


;;;;;;;;;;;;
;; Parens ;;
;;;;;;;;;;;;

(use-package corral
  :commands (corral-parentheses-backward
              corral-parentheses-forward
              corral-brackets-backward
              corral-brackets-forward
              corral-braces-backward
              corral-braces-forward
              corral-single-quotes-backward
              corral-double-quotes-backward))

(defhydra hydra-surround (:columns 4)
  "Corral"
  ("(" corral-parentheses-backward "Back")
  (")" corral-parentheses-forward "Forward")
  ("[" corral-brackets-backward "Back")
  ("]" corral-brackets-forward "Forward")
  ("{" corral-braces-backward "Back")
  ("}" corral-braces-forward "Forward")
  ("\"" corral-double-quotes-backward "Back")
  ("'" corral-single-quotes-backward "Back")
  ("." hydra-repeat "Repeat"))

;; TODO: Use keybinds.


;;;;;;;;;;;;;;;
;; Alignment ;;
;;;;;;;;;;;;;;;

;; Modified function from http://emacswiki.org/emacs/AlignCommands
(defun align-repeat (start end regexp &optional justify-right after)
  "Repeat alignment with respect to the given regular expression.
If JUSTIFY-RIGHT is non nil justify to the right instead of the
left. If AFTER is non-nil, add whitespace to the left instead of
the right."
  (interactive "r\nsAlign regexp: ")
  (let ((complete-regexp (if after
                           (concat regexp "\\([ \t]*\\)")
                           (concat "\\([ \t]*\\)" regexp)))
         (group (if justify-right -1 1)))
    (align-regexp start end complete-regexp group 1 t)))

;; Modified answer from http://emacs.stackexchange.com/questions/47/align-vertical-columns-of-numbers-on-the-decimal-point
(defun align-repeat-decimal (start end)
  "Align a table of numbers on decimal points and dollar signs (both optional)"
  (interactive "r")
  (require 'align)
  (align-region start end nil
    '((nil (regexp . "\\([\t ]*\\)\\$?\\([\t ]+[0-9]+\\)\\.?")
        (repeat . t)
        (group 1 2)
        (spacing 1 1)
        (justify nil t)))
    nil))

(defmacro create-align-repeat-x (name regexp &optional justify-right default-after)
  (let ((new-func (intern (concat "align-repeat-" name))))
    `(defun ,new-func (start end switch)
       (interactive "r\nP")
       (let ((after (not (eq (if switch t nil) (if ,default-after t nil)))))
         (align-repeat start end ,regexp ,justify-right after)))))

(create-align-repeat-x "comma" "," nil t)
(create-align-repeat-x "semicolon" ";" nil t)
(create-align-repeat-x "colon" ":" nil t)
(create-align-repeat-x "equal" "=")
(create-align-repeat-x "hash" "=>")
(create-align-repeat-x "math-oper" "[+\\-*/]")
(create-align-repeat-x "ampersand" "&")
(create-align-repeat-x "bar" "|")
(create-align-repeat-x "left-paren" "(")
(create-align-repeat-x "right-paren" ")" t)

(add-hook 'align-load-hook
  (lambda ()
    ;; Alignment directives for built in align command
    (add-to-list 'align-rules-list
      '(ruby-comma-delimiter
         (regexp . ",\\(\\s-*\\)[^# \t\n]")
         (repeat . t)
         (modes  . '(ruby-mode))))

    (add-to-list 'align-rules-list
      '(ruby-hash-literal
         (regexp . "\\(\\s-*\\)=>\\s-*[^# \t\n]")
         (group 2 3)
         (repeat . t)
         (modes  . '(ruby-mode))))

    (add-to-list 'align-rules-list
      '(ruby-hash-literal2
         (regexp . "[a-z0-9]:\\(\\s-*\\)[^# \t\n]")
         (repeat . t)
         (modes  . '(ruby-mode))))

    (add-to-list 'align-rules-list
      '(ruby-assignment-literal
         (regexp . "\\(\\s-*\\)=\\s-*[^# \t\n]")
         (repeat . t)
         (modes  . '(ruby-mode))))

    (add-to-list 'align-rules-list
      '(ruby-xmpfilter-mark
         (regexp . "\\(\\s-*\\)# => [^#\t\n]")
         (repeat . nil)
         (modes  . '(ruby-mode))))
    ))


;;;;;;;;;;;;;;;
;; Prog mode ;;
;;;;;;;;;;;;;;;

(add-hook 'prog-mode-hook
    (lambda ()
      (display-line-numbers-mode 1)))

(use-package idle-highlight-mode
  :init
  (add-hook 'prog-mode-hook
    (lambda ()
      (idle-highlight-mode 1)))
  :diminish idle-highlight-mode)

(use-package rainbow-delimiters
  :commands rainbow-delimiters-mode)

;; Line numbers for coding please
(add-hook 'prog-mode-hook
  (lambda ()
    ;; Treat underscore as a word character
    (modify-syntax-entry ?_ "w")
    ;; (linum-mode 1)
    (rainbow-delimiters-mode)))

;;;;;;;;;;;;;;;;;;;
;; Dash At Point ;;
;;;;;;;;;;;;;;;;;;;

(use-package dash-at-point
  :bind (([S-f1] . dash-at-point)))

;;;;;;;;;;;;;;;;;;;;;
;; Version Control ;;
;;;;;;;;;;;;;;;;;;;;;

(use-package magit
  :commands magit-status
  :init
  (use-package magit-todos
    :config
    (magit-todos-mode))

  :config
  (setq magit-completing-read-function 'ivy-completing-read))

(use-package git-link
  :commands (git-link git-link-commit github-pr)
  :config
  (setq git-link-open-in-browser t)

  (defun github-pr (&optional prompt)
    (interactive "P")
    (command-execute 'git-link)  ;; this is just here to force autoloading of git-link
    (let* ((remote-name    (if prompt (read-string "Remote: " nil nil git-link-default-remote)
                             (git-link--remote)))
            (parsed-remote (git-link--parse-remote (git-link--remote-url remote-name)))
            (remote-host   (substring (car parsed-remote) 0 -4))
            (remote-dir    (car (cdr parsed-remote)))
            (branch        (git-link--current-branch))
            (commit        (git-link--last-commit))
            (handler       (nth 1 (assoc remote-host git-link-remote-alist))))

      (cond ((null remote-host)
              (message "Unknown remote '%s'" remote-name))
        ((and (null commit) (null branch))
          (message "Not on a branch, and repo does not have commits"))
        ;; functionp???
        ((null handler)
          (message "No handler for %s" remote-host))
        ;; null ret val
        ((browse-url
           (format "https://github.com/%s/compare/%s"
             remote-dir
             branch)))))))

(use-package github-browse-file
  :commands github-browse-file)

(use-package gist
  :commands
  (gist-buffer gist-buffer-private gist-list gist-region gist-region-private)
  :config
  (progn
    (general-define-key :keymaps '(gist-list-menu-mode-map gist-list-mode-map)
      :states '(normal)
      "RET" 'gist-fetch-current
      ",g" 'gist-list-reload
      ",e" 'gist-edit-current-description
      ",k" 'gist-kill-current
      ",+" 'gist-add-buffer
      ",-" 'gist-remove-file
      ",y" 'gist-print-current-url
      ",b" 'gist-browse-current-url
      ",*" 'gist-star
      ",^" 'gist-unstar
      ",f" 'gist-fork
      ",f" 'gist-fetch-current
      ",K" 'gist-kill-current
      ",o" 'gist-browse-current-url)))

(use-package git-timemachine
  :commands git-timemachine)

(use-package git-gutter-fringe
  :diminish git-gutter-mode
  :config
  (setq git-gutter-fr:side 'left-fringe)

  ;; custom graphics that works nice with half-width fringes
  (fringe-helper-define 'git-gutter-fr:added nil
    "..X...."
    "..X...."
    "XXXXX.."
    "..X...."
    "..X...."
    )
  (fringe-helper-define 'git-gutter-fr:deleted nil
    "......."
    "......."
    "XXXXX.."
    "......."
    "......."
    )
  (fringe-helper-define 'git-gutter-fr:modified nil
    "..X...."
    ".XXX..."
    "XXXXX.."
    ".XXX..."
    "..X...."
    )
  :init
  (global-git-gutter-mode t))

(use-package ediff
  :init
  (progn
    (setq-default
      ediff-window-setup-function 'ediff-setup-windows-plain
      ediff-split-window-function 'split-window-horizontally
      ediff-merge-split-window-function 'split-window-horizontally)

    ;; Restore window layout when done
    (add-hook 'ediff-quit-hook #'winner-undo)))

;;;;;;;;;;;;;;;;;;;;;
;; Window Handling ;;
;;;;;;;;;;;;;;;;;;;;;

(winner-mode 1)

(use-package windmove
  :commands
  (windmove-left windmove-down windmove-up windmove-right)
  )

(defun stamp/split-window-right-dwim ()
  "Like split-window-right but selects the test file or file under test"
  (interactive)
  (split-window-right)
  (other-window 1)
  (stamp/jump-between-test-files)
  (other-window -1))

(defun stamp/split-window-below-dwim ()
  "Like split-window-below but selects the test file or file under test"
  (interactive)
  (split-window-below)
  (other-window 1)
  (stamp/jump-between-test-files)
  (other-window -1))

(defun stamp/move-splitter-left (arg)
  "Move window splitter left."
  (interactive "p")
  (if (let ((windmove-wrap-around))
        (windmove-find-other-window 'right))
    (shrink-window-horizontally arg)
    (enlarge-window-horizontally arg)))

(defun stamp/move-splitter-right (arg)
  "Move window splitter right."
  (interactive "p")
  (if (let ((windmove-wrap-around))
        (windmove-find-other-window 'right))
    (enlarge-window-horizontally arg)
    (shrink-window-horizontally arg)))

(defun stamp/move-splitter-up (arg)
  "Move window splitter up."
  (interactive "p")
  (if (let ((windmove-wrap-around))
        (windmove-find-other-window 'up))
    (enlarge-window arg)
    (shrink-window arg)))

(defun stamp/move-splitter-down (arg)
  "Move window splitter down."
  (interactive "p")
  (if (let ((windmove-wrap-around))
        (windmove-find-other-window 'up))
    (shrink-window arg)
    (enlarge-window arg)))

(defun stamp/toggle-windows-split()
  "Switch back and forth between one window and whatever split of windows we might have in the frame. The idea is to maximize the current buffer, while being able to go back to the previous split of windows in the frame simply by calling this command again."
  (interactive)
  (if (not(window-minibuffer-p (selected-window)))
      (progn
        (if (< 1 (count-windows))
            (progn
              (window-configuration-to-register ?u)
              (delete-other-windows))
          (jump-to-register ?u)))))

(define-key global-map (kbd "C-|") 'stamp/toggle-windows-split)

(defun stamp/window-toggle-split-direction ()
  "Switch window split from horizontally to vertically, or vice versa."
  (interactive)
  (let ((done))
    (dolist (dirs '((right . down) (down . right)))
      (unless done
        (let* ((win (selected-window))
               (nextdir (car dirs))
               (neighbour-dir (cdr dirs))
               (next-win (windmove-find-other-window nextdir win))
               (neighbour1 (windmove-find-other-window neighbour-dir win))
               (neighbour2 (if next-win (with-selected-window next-win
                                          (windmove-find-other-window neighbour-dir next-win)))))
          ;;(message "win: %s\nnext-win: %s\nneighbour1: %s\nneighbour2:%s" win next-win neighbour1 neighbour2)
          (setq done (and (eq neighbour1 neighbour2)
                          (not (eq (minibuffer-window) next-win))))
          (if done
              (let* ((other-buf (window-buffer next-win)))
                (delete-window next-win)
                (if (eq nextdir 'right)
                    (split-window-vertically)
                  (split-window-horizontally))
                (set-window-buffer (windmove-find-other-window neighbour-dir) other-buf))))))))


;;;;;;;;;
;; Org ;;
;;;;;;;;;

(use-package org
  :defer t
  :bind (("C-C c" . org-capture)
          ("<f9>" . org-agenda)
          )

  :commands (org-store-link)
  :init
  ;; Make windmove work in org-mode
  (setq org-replace-disputed-keys t)
  (setq org-return-follows-link t)

  ;; Show indents
  (setq org-startup-indented t)
  (setq org-hide-leading-stars t)
  (setq org-agenda-files '("~/Dropbox/Documents/orgmodenotes"))

  ;; Display inline images
  (setq org-startup-with-inline-images t)

  ;; Prevent demoting heading also shifting text inside sections
  (setq org-adapt-indentation nil)

  ;; Show raw link text
  (setq org-descriptive-links t)
  ;; Start up fully open
  (setq org-startup-folded nil)

  ;; Allow bind in files to enable export overrides
  (setq org-export-allow-bind-keywords t)

  ;; Valid task states in org mode
  (setq org-todo-keywords
    '((sequence "TODO" "INPROGRESS" "|" "DONE")
       (sequence "ONHOLD" "|" "CANCELLED")))
  ;; When a task is finished log when it's done
  (setq org-log-done 'time)

  ;; Highlight source blocks
  (setq org-src-fontify-natively t
    org-src-tab-acts-natively t
    org-edit-src-content-indentation 0
    org-confirm-babel-evaluate nil)

  ;; No auto indent please
  (setq org-export-html-postamble nil)

  ;; Don't expand links by default
  (setq org-descriptive-links t)

  :config
  (add-hook 'org-shiftup-final-hook 'windmove-up)
  (add-hook 'org-shiftleft-final-hook 'windmove-left)
  (add-hook 'org-shiftdown-final-hook 'windmove-down)
  (add-hook 'org-shiftright-final-hook 'windmove-right)

  ;; TODO: Figure out how to enable org-mac-link

  (use-package ox-pandoc
    :init
    (setq org-pandoc-options-for-markdown '((atx-headers . t))
      org-pandoc-options-for-markdown_mmd '((atx-headers . t))
      org-pandoc-options-for-markdown_github '((atx-headers . t))))


  (use-package org-bullets)

  (defun org-summary-todo (n-done n-not-done)
    "Switch entry to DONE when all subentries are done, to TODO otherwise."
    (let (org-log-done org-log-states)  ; turn off logging
      (org-todo (if (= n-not-done 0) "DONE" "TODO"))))

  (add-hook 'org-after-todo-statistics-hook 'org-summary-todo)

  (defun stamp/html-filter-remove-src-blocks (text backend info)
    "Remove source blocks from html export."
    (when (org-export-derived-backend-p backend 'html) ""))

  ;; Code blocks
  (org-babel-do-load-languages
    'org-babel-load-languages
    '((emacs-lisp . t)
       (js . t)
       (ruby . t)
       (dot . t)
       (shell . t)))


  (require 'org-crypt)
  ;; Automatically encrypt entries tagged `crypt` on save.
  ;; (org-crypt-use-before-save-magic)
  (setq org-tags-exclude-from-inheritance '("crypt"))
  ;; GPG key to use for encryption
  (setq org-crypt-key "gstamp@gmail.com")
  (setq org-crypt-disable-auto-save nil)

  (add-hook 'org-mode-hook
    (lambda ()
      (diminish 'org-indent-mode)

      ;; Bullets
      (org-bullets-mode 1)

      ;; Encrypt on save
      (add-hook 'before-save-hook 'org-encrypt-entries nil t)

      ;; Fix tab key conflict
      (setq-local yas/trigger-key [tab])
      (define-key yas/keymap [tab] 'yas/next-field-or-maybe-expand))))

(use-package pandoc-mode
  :config
  (progn
    (add-hook 'markdown-mode-hook 'pandoc-mode)
    (add-hook 'pandoc-mode-hook 'pandoc-load-default-settings)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hideshow - Completion ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

(require 'hideshow)

(use-package hideshow
  :commands (stamp/hideshow-mode)
  :config
  (progn
    (defconst stamp/hs-minor-mode-hooks '(emacs-lisp-mode-hook
                                           enh-ruby-mode-hook
                                           ruby-mode-hook
                                           json-mode-hook
                                           verilog-mode-hook
                                           cperl-mode-hook
                                           elixir-mode)
      "List of hooks of major modes in which hs-minor-mode should be enabled.")

    (define-minor-mode stamp/hideshow-mode
      "Minor mode to toggle the `hs-minor-mode' and related modes in the
current buffer."
      :global     nil
      :init-value nil
      :lighter    " ḤṢ"
      (if stamp/hideshow-mode
        (progn
          (hs-minor-mode 1)
          (hideshowvis-minor-mode 1)
          (hs-org/minor-mode 1))
        (progn
          (hs-minor-mode -1)
          (hideshowvis-minor-mode -1)
          (hs-org/minor-mode -1)
          )))

    (defun stamp/turn-on-hs-minor-mode ()
      "Turn on hs-minor-mode only for specific modes."
      (interactive)
      (dolist (hook stamp/hs-minor-mode-hooks)
        (add-hook hook #'hs-minor-mode)
        (add-hook hook #'hs-org/minor-mode)
        (add-hook hook #'hideshowvis-minor-mode)))

    (defun stamp/turn-off-hs-minor-mode ()
      "Turn off hs-minor-mode only for specific modes."
      (interactive)
      (dolist (hook stamp/hs-minor-mode-hooks)
        (remove-hook hook #'hs-minor-mode)
        (remove-hook hook #'hs-org/minor-mode)
        (remove-hook hook #'hideshowvis-minor-mode)))))


(eval-after-load "hideshow"
  (progn
    '(add-to-list 'hs-special-modes-alist
       `(enh-ruby-mode
          ,"\\<\\(def\\|class\\|module\\|do\\)\\>"
          ,"\\<end\\>"
          ,(rx (or "#" "=begin"))       ; Comment start
          enh-ruby-forward-sexp nil)
       )

    '(add-to-list 'hs-special-modes-alist
       `(ruby-mode
          ,"\\<\\(def\\|class\\|module\\|do\\)\\>"
          ,"\\<end\\>"
          ,(rx (or "#" "=begin"))       ; Comment start
          ruby-forward-sexp nil)
       )

    '(add-to-list 'hs-special-modes-alist
       `(elixir-mode
          , "\\<\\(do\\|fn\\)"
          , "\\<end\\>"
          ,(rx (or "#"))                ; Comment start
          forward-sexp nil))))

(use-package hideshowvis
  :commands (hideshowvis-enable)
  :config
  (defface stamp/fold-face
    '((t (:foreground "deep sky blue" :slant italic)))
    "Face used for fold ellipsis.")

  (if (display-graphic-p)
    (progn
      (define-fringe-bitmap 'hs-expand-bitmap [
                                                0   ; 0 0 0 0 0 0 0 0
                                                24  ; 0 0 0 ▮ ▮ 0 0 0
                                                24  ; 0 0 0 ▮ ▮ 0 0 0
                                                126 ; 0 ▮ ▮ ▮ ▮ ▮ ▮ 0
                                                126 ; 0 ▮ ▮ ▮ ▮ ▮ ▮ 0
                                                24  ; 0 0 0 ▮ ▮ 0 0 0
                                                24  ; 0 0 0 ▮ ▮ 0 0 0
                                                0]) ; 0 0 0 0 0 0 0 0
      (defface stamp/hs-fringe-face
        '((t (:foreground "#888"
               :box (:line-width 2 :color "grey75" :style released-button))))
        "Face used to highlight the fringe on folded regions"
        :group 'hideshow)

      (defun stamp/display-code-line-counts (ov)
        (when (eq 'code (overlay-get ov 'hs))
          (let* ((marker-string "*fringe-dummy*"))
            ;; Place the + bitmap in the left fringe
            (put-text-property 0 (length marker-string)
              'display
              '(left-fringe hs-expand-bitmap stamp/hs-fringe-face)
              marker-string)
            (overlay-put ov
              'before-string
              marker-string)
            (overlay-put ov
              'display
              (propertize
                (format " ... [%d] "
                  (count-lines (overlay-start ov)
                    (overlay-end ov)))
                'face 'stamp/fold-face))
            (overlay-put ov
              'help-echo
              (buffer-substring (overlay-start ov)
                (overlay-end ov))))))

      (setq hs-set-up-overlay #'stamp/display-code-line-counts)))  )

(use-package hideshow-org
  :commands (hs-org/minor-mode)
  :init
  (setq hs-org/trigger-keys-block (list (kbd "TAB")
                                    (kbd "<C-tab>")) )
  )

;;;;;;;;;;;;;;;;;;;;;
;; Javascript/JSON ;;
;;;;;;;;;;;;;;;;;;;;;

(use-package js2-mode
  :mode  (("\\.js$" . js2-jsx-mode)
           ("\\.jsx?$" . js2-jsx-mode)
           ("\\.es6$" . js2-mode))
  :interpreter "node"
  :config
  (use-package js2-refactor
    :init
    (add-hook 'js2-mode-hook #'js2-refactor-mode)
    (js2r-add-keybindings-with-prefix "C-c RET"))

  (setq js2-bounce-indent-p t)

  ;; Rely on flycheck instead...
  (setq js2-show-parse-errors nil)
  ;; Reduce the noise
  (setq js2-strict-missing-semi-warning nil)
  ;; jshint does not warn about this now for some reason
  (setq js2-strict-trailing-comma-warning nil)

  ;; Quiet warnings
  (setq js2-mode-show-strict-warnings nil)

  (add-hook 'js2-mode-hook 'js2-imenu-extras-mode)

  (add-hook 'js2-mode-hook
    (lambda ()
      (flycheck-mode 1)
      (setq mode-name "JS2")
      (setq js2-global-externs '("module" "require" "buster" "jestsinon" "jasmine" "assert"
                                  "it" "expect" "describe" "beforeEach"
                                  "refute" "setTimeout" "clearTimeout" "setInterval"
                                  "clearInterval" "location" "__dirname" "console" "JSON"))

      (js2-imenu-extras-mode +1))))

(use-package rjsx-mode
  :mode  (("\\.jsx?$" . rjsx-mode)
           ("components\\/.*\\.js\\'" . rjsx-mode))
  :config
  ;; Clear out tag helper
  (define-key rjsx-mode-map "<" nil)
  (add-hook 'rjsx-mode-hook 'flycheck-mode)

  (flycheck-add-mode 'javascript-eslint 'rjsx-mode)
  )

(use-package json-mode
  :mode "\\.json$"
  :config
  (use-package flymake-json
    :init
    (add-hook 'json-mode 'flymake-json-load))
  (use-package jq-mode
    :config
    (define-key json-mode-map (kbd "C-c C-j") #'jq-interactively)))

(use-package typescript-mode
  :mode "\\.ts$"
  :config
  (setq typescript-indent-level 2)
  (setq typescript-expr-indent-offset 2)
  (use-package tss
    :init
    (setq tss-popup-help-key ", h")
    (setq tss-jump-to-definition-key ", j")
    (setq tss-implement-definition-key ", i")
    (tss-config-default)))

;; Install elm-format, elm-oracle, and the base elm package
(use-package elm-mode
  :mode "\\.elm$"
  :config

  (use-package flycheck-elm
    :init
    (eval-after-load 'flycheck
      '(add-hook 'flycheck-mode-hook #'flycheck-elm-setup)))

  (add-hook 'elm-mode-hook #'elm-oracle-setup-completion)
  (add-to-list 'company-backends 'company-elm)

  (general-define-key :keymaps 'elm-interactive-mode
    :states '(emacs)
    "<M-up>" 'comint-previous-input
    "<M-down>" 'comint-next-input)

  (diminish 'elm-indent-mode " ⇥")

  (add-hook 'elm-mode-hook
    (lambda ()

      (flycheck-mode 1)
      ;; Fancy indenting please
      (setq tab-always-indent t)
      (setq evil-shift-width 4)
      (setq tab-width 4)
      (setq elm-indent-offset 4))))

;;;;;;;;;;;;
;; Coffee ;;
;;;;;;;;;;;;

(defun stamp/indent-relative (&optional arg)
  "Newline and indent same number of spaces as previous line."
  (interactive)
  (let* ((indent (+ 0 (save-excursion
                        (back-to-indentation)
                        (current-column)))))
    (newline 1)
    (insert (make-string indent ?\s))))

(use-package coffee-mode
  :mode  "\\.coffee$"
  :config
  (progn
    ;; Proper indents when we evil-open-below etc...
    (defun stamp/coffee-indent ()
      (if (coffee-line-wants-indent)
        ;; We need to insert an additional tab because the last line was special.
        (coffee-insert-spaces (+ (coffee-previous-indent) coffee-tab-width))
        ;; Otherwise keep at the same indentation level
        (coffee-insert-spaces (coffee-previous-indent))))

    ;; Override indent for coffee so we start at the same indent level
    (defun stamp/coffee-indent-line ()
      "Indent current line as CoffeeScript."
      (interactive)
      (let* ((curindent (current-indentation))
              (limit (+ (line-beginning-position) curindent))
              (type (coffee--block-type))
              indent-size
              begin-indents)
        (if (and type (setq begin-indents (coffee--find-indents type limit '<)))
          (setq indent-size (coffee--decide-indent curindent begin-indents '>))
          (let ((prev-indent (coffee-previous-indent))
                 (next-indent-size (+ curindent coffee-tab-width)))
            (if (= curindent 0)
              (setq indent-size prev-indent)
              (setq indent-size (+ curindent coffee-tab-width) ))
            (coffee--indent-insert-spaces indent-size)))))

    (add-hook 'coffee-mode-hook
      (lambda ()
        (set (make-local-variable 'tab-width) 2)
        (setq indent-line-function 'stamp/coffee-indent-line)))))

;;;;;;;;;
;; Web ;;
;;;;;;;;;

(use-package web-mode
  :mode  (("\\.html?\\'"       . web-mode)
           ("\\.erb\\'"        . web-mode)
           ("\\.ejs\\'"        . web-mode)
           ("\\.eex\\'"        . web-mode)
           ("\\.handlebars\\'" . web-mode)
           ("\\.hbs\\'"        . web-mode)
           ("\\.eco\\'"        . web-mode)
           ("\\.ect\\'"        . web-mode)
           ("\\.as[cp]x\\'"    . web-mode)
           ("\\.mustache\\'"   . web-mode)
           ("\\.dhtml\\'"      . web-mode))
  :config
  (progn
    (defadvice web-mode-highlight-part (around tweak-jsx activate)
      (if (equal web-mode-content-type "jsx")
        (let ((web-mode-enable-part-face nil))
          ad-do-it)
        ad-do-it))

    (defun stamp/web-mode-hook ()
      "Hooks for Web mode."
      (setq web-mode-markup-indent-offset 2)
      (setq web-mode-css-indent-offset 2)
      (setq web-mode-code-indent-offset 2)
      (setq web-mode-enable-comment-keywords t)
      ;; Use server style comments
      (setq web-mode-comment-style 2)
      (setq web-mode-enable-current-element-highlight t))
    (add-hook 'web-mode-hook  'stamp/web-mode-hook)))

;; Setup for jsx
(defadvice web-mode-highlight-part (around tweak-jsx activate)
  (if (equal web-mode-content-type "jsx")
    (let ((web-mode-enable-part-face nil))
      ad-do-it)
    ad-do-it))

(use-package jade-mode
  :mode "\\.jade$"
  :config
  (require 'sws-mode)
  (require 'stylus-mode)
  (add-to-list 'auto-mode-alist '("\\.styl\\'" . stylus-mode)))

(use-package scss-mode
  :mode (("\\.scss$"  . scss-mode)
          ("\\.sass$" . scss-mode))
  :config
  (use-package rainbow-mode)
  (add-hook 'scss-mode-hook
    (lambda ()
      ;; Treat dollar and hyphen as a word character
      (modify-syntax-entry ?$ "w")
      (modify-syntax-entry ?- "w")
      (nlinum-mode 1)
      (rainbow-mode +1))))

(use-package css-mode
  :mode "\\.css$"
  :config
  (use-package rainbow-mode)
  (add-hook 'css-mode-hook
    (lambda ()
      (nlinum-mode 1)
      (rainbow-mode +1))))

(use-package web-beautify
  :commands (web-beautify-js web-beautify-css web-beautify-html))

;;;;;;;;;;;;;;
;; Markdown ;;
;;;;;;;;;;;;;;

(use-package markdown-mode
             :mode (("\\.markdown\\'" . markdown-mode)
                    ("\\.md$" . markdown-mode))
             :config
             (use-package pandoc-mode
                          :commands pandoc-mode
                          :diminish pandoc-mode)
             (add-hook 'markdown-mode-hook 'pandoc-mode)

             (use-package markdown-toc
                          :commands markdown-toc-generate-toc)

             (defun stamp/markdown-enter-key-dwim ()
               "If in a list enter a new list item, otherwise insert enter key as normal."
               (interactive)
               (let ((bounds (markdown-cur-list-item-bounds)))
                 (if bounds
                     ;; In a list
                     (call-interactively #'markdown-insert-list-item)
                   ;; Not in a list
                   (markdown-enter-key))))

             (define-key markdown-mode-map (kbd "RET") 'stamp/markdown-enter-key-dwim)

             (use-package mmm-mode
                          :commands mmm-parse-buffer
                          :config
                          (progn
                            (mmm-add-classes '((markdown-python
                                                :submode python-mode
                                                :face mmm-declaration-submode-face
                                                :front "^```python[\n\r]+"
                                                :back "^```$")))
                            (mmm-add-classes '((markdown-html
                                                :submode web-mode
                                                :face mmm-declaration-submode-face
                                                :front "^```html[\n\r]+"
                                                :back "^```$")))
                            (mmm-add-classes '((markdown-java
                                                :submode java-mode
                                                :face mmm-declaration-submode-face
                                                :front "^```java[\n\r]+"
                                                :back "^```$")))
                            (mmm-add-classes '((markdown-ruby
                                                :submode ruby-mode
                                                :face mmm-declaration-submode-face
                                                :front "^```ruby[\n\r]+"
                                                :back "^```$")))
                            (mmm-add-classes '((markdown-c
                                                :submode c-mode
                                                :face mmm-declaration-submode-face
                                                :front "^```c[\n\r]+"
                                                :back "^```$")))
                            (mmm-add-classes '((markdown-c++
                                                :submode c++-mode
                                                :face mmm-declaration-submode-face
                                                :front "^```c\+\+[\n\r]+"
                                                :back "^```$")))
                            (mmm-add-classes '((markdown-elisp
                                                :submode emacs-lisp-mode
                                                :face mmm-declaration-submode-face
                                                :front "^```elisp[\n\r]+"
                                                :back "^```$")))
                            (mmm-add-classes '((markdown-javascript
                                                :submode javascript-mode
                                                :face mmm-declaration-submode-face
                                                :front "^```javascript[\n\r]+"
                                                :back "^```$")))
                            (mmm-add-classes '((markdown-ess
                                                :submode R-mode
                                                :face mmm-declaration-submode-face
                                                :front "^```{?r.*}?[\n\r]+"
                                                :back "^```$")))
                            (mmm-add-classes '((markdown-rust
                                                :submode rust-mode
                                                :face mmm-declaration-submode-face
                                                :front "^```rust[\n\r]+"
                                                :back "^```$")))
                            (mmm-add-mode-ext-class 'markdown-mode nil 'markdown-python)
                            (mmm-add-mode-ext-class 'markdown-mode nil 'markdown-java)
                            (mmm-add-mode-ext-class 'markdown-mode nil 'markdown-ruby)
                            (mmm-add-mode-ext-class 'markdown-mode nil 'markdown-c)
                            (mmm-add-mode-ext-class 'markdown-mode nil 'markdown-c++)
                            (mmm-add-mode-ext-class 'markdown-mode nil 'markdown-elisp)
                            (mmm-add-mode-ext-class 'markdown-mode nil 'markdown-html)
                            (mmm-add-mode-ext-class 'markdown-mode nil 'markdown-javascript)
                            (mmm-add-mode-ext-class 'markdown-mode nil 'markdown-ess)
                            (mmm-add-mode-ext-class 'markdown-mode nil 'markdown-rust))
                          :init
                          (setq mmm-global-mode t))

             ;; Keep word movement instead of promotion mappings
             (define-key markdown-mode-map (kbd "<M-right>") nil)
             (define-key markdown-mode-map (kbd "<M-left>") nil)

             (setq markdown-imenu-generic-expression
                   '(("title"  "^\\(.*\\)[\n]=+$" 1)
                     ("h2-"    "^\\(.*\\)[\n]-+$" 1)
                     ("h1"   "^# \\(.*\\)$" 1)
                     ("h2"   "^## \\(.*\\)$" 1)
                     ("h3"   "^### \\(.*\\)$" 1)
                     ("h4"   "^#### \\(.*\\)$" 1)
                     ("h5"   "^##### \\(.*\\)$" 1)
                     ("h6"   "^###### \\(.*\\)$" 1)
                     ("fn"   "^\\[\\^\\(.*\\)\\]" 1)))

             (add-hook 'markdown-mode-hook
                       (lambda ()
                         ;; Remove for now as they interfere with indentation
                         ;; (define-key yas-minor-mode-map [(tab)] nil)
                         ;; (define-key yas-minor-mode-map (kbd "TAB") nil)
                         (setq imenu-generic-expression markdown-imenu-generic-expression))))


;;;;;;;;;;;
;; Emoji ;;
;;;;;;;;;;;

(use-package emojify
  :commands emojify-insert-emoji
  :init
  (progn
    (add-hook 'org-mode-hook 'emojify-mode)
    (add-hook 'markdown-mode-hook 'emojify-mode)))

(defun --set-emoji-font (frame)
  "Adjust the font settings of FRAME so Emacs can display emoji properly."
  (if (eq system-type 'darwin)
      ;; For NS/Cocoa
      (set-fontset-font t 'symbol (font-spec :family "Apple Color Emoji") frame 'prepend)
    ;; For Linux
    (set-fontset-font t 'symbol (font-spec :family "Symbola") frame 'prepend)))

;; For when Emacs is started in GUI mode:
(--set-emoji-font nil)
;; Hook for when a frame is created with emacsclient
;; see https://www.gnu.org/software/emacs/manual/html_node/elisp/Creating-Frames.html
(add-hook 'after-make-frame-functions '--set-emoji-font)


;;;;;;;;;;;;;
;; Clojure ;;
;;;;;;;;;;;;;

(use-package clojure-mode
  :commands clojure-mode
  :defer t
  :config

  (use-package flycheck-clojure
    :init
    (eval-after-load 'flycheck '(flycheck-clojure-setup)))

  ;; (add-hook 'clojure-mode-hook
  ;;   (lambda ()
  ;;     ;; Treat dash as part of a word
  ;;     (modify-syntax-entry ?- "w")))

  (use-package clojure-snippets
    :init
    (clojure-snippets-initialize))

  (use-package cider
    :init
    ;; REPL history file
    (setq cider-repl-history-file "~/.emacs.d/cider-history")

    ;; Nice pretty printing
    (setq cider-repl-use-pretty-printing t)

    ;; Nicer font lock in REPL
    (setq cider-repl-use-clojure-font-lock t)

    ;; Result prefix for the REPL
    (setq cider-repl-result-prefix ";; => ")

    ;; Neverending REPL history
    (setq cider-repl-wrap-history t)

    ;; Looong history
    (setq cider-repl-history-size 3000)

    ;; Error buffer not popping up
    (setq cider-show-error-buffer nil)

    ;; Highlight sexp in file from REPL
    (use-package cider-eval-sexp-fu)

    ;; eldoc for clojure
    (add-hook 'cider-mode-hook #'eldoc-mode)

    (use-package clj-refactor
      :init
      (add-hook 'clojure-mode-hook
        (lambda ()
          (clj-refactor-mode 1)

          ;; no auto sort
          (setq cljr-auto-sort-ns nil)

          ;; do not prefer prefixes when using clean-ns
          (setq cljr-favor-prefix-notation nil))))


    (define-clojure-indent
      ;; Compojure
      (ANY 2)
      (DELETE 2)
      (GET 2)
      (HEAD 2)
      (POST 2)
      (PUT 2)
      (context 2)
      (defroutes 'defun)
      ;; Cucumber
      (After 1)
      (Before 1)
      (Given 2)
      (Then 2)
      (When 2)
      ;; Schema
      (s/defrecord 2)
      ;; test.check
      (for-all 'defun))

    )

  (add-to-list 'auto-mode-alist '("\\.boot\\'" . clojure-mode))
  (add-to-list 'magic-mode-alist '(".* boot" . clojure-mode))
  )

;;;;;;;;;;;
;; Elisp ;;
;;;;;;;;;;;

;; Easier navigation of my .init.el
(defun imenu-elisp-sections ()
  (setq imenu-prev-index-position-function nil)
  (add-to-list 'imenu-generic-expression '("Sections" "^;; \\(.+\\) ;;$" 1) t))
(add-hook 'emacs-lisp-mode-hook 'imenu-elisp-sections)

(diminish 'eldoc-mode " ф")

;;;;;;;;;;;;;;;;;;;;;;
;; Multiple cursors ;;
;;;;;;;;;;;;;;;;;;;;;;

(use-package multiple-cursors
  :commands (mc/mark-next-like-this-symbol
              mc/mark-previous-like-this-symbol
              mc/mark-all-like-this-dwim)
  :bind
  (("C->" . mc/mark-next-like-this)
    ("C-<" . mc/mark-previous-like-this)
    ("C-x C-m" . mc/mark-all-like-this-dwim)
    ))

(use-package phi-search
  :commands (phi-search phi-search-backward)
  :bind (("C-s" . phi-search)
          ("C-r" . phi-search-backward)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Automatically Reindent Yanked Code ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(dolist (command '(yank yank-pop))
   (eval `(defadvice ,command (after indent-region activate)
            (and (not current-prefix-arg)
                 (member major-mode '(emacs-lisp-mode lisp-mode
                                                      clojure-mode    scheme-mode
                                                      haskell-mode    enh-ruby-mode
                                                      rspec-mode      python-mode
                                                      c-mode          c++-mode
                                                      objc-mode       latex-mode
                                                      plain-tex-mode  ruby-mode))
                 (let ((mark-even-if-inactive transient-mark-mode))
                   (indent-region (region-beginning) (region-end) nil))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Visual Regular Expression Mode ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(use-package visual-regexp
  :bind
  (("M-g M-r" . vr/replace)
    ("M-g r" . vr/query-replace)))


;;;;;;;;;;;;;;;;;;;
;; Expand region ;;
;;;;;;;;;;;;;;;;;;;

(use-package expand-region
  :commands (er/expand-region er/contract-region)
  :config
  (global-set-key (kbd "C-=") 'er/expand-region)
  )


;;;;;;;;;;;;
;; Elixir ;;
;;;;;;;;;;;;

(use-package elixir-mode
  :mode (("\\.exs?\\'"   . elixir-mode))
  :defer t
  :config
  (add-to-list 'elixir-mode-hook
    (defun auto-activate-ruby-end-mode-for-elixir-mode ()
      (set (make-variable-buffer-local 'ruby-end-expand-keywords-before-re)
        "\\(?:^\\|\\s-+\\)\\(?:do\\)")
      (set (make-variable-buffer-local 'ruby-end-check-statement-modifiers) nil)
      (ruby-end-mode +1)))

  ;; (use-package flycheck-elixir
  ;;   :config
  ;;   (add-hook 'elixir-mode-hook 'flycheck-mode))

  (require 'mix-format)
  (setq mixfmt-mix "/usr/local/bin/mix")
  (setq mixfmt-elixir "/usr/local/bin/elixir")

  (defun mix-format-and-save (&optional arg)
    (interactive "p")

    (if (buffer-modified-p)
      (save-buffer)
      (progn
        (if (eq major-mode 'elixir-mode)
          (mix-format))
        (call-interactively 'save-buffer))))

  (add-hook 'elixir-mode-hook
    (lambda () (general-define-key "C-x C-s" 'mix-format-and-save)))

  (use-package alchemist
    :diminish (alchemist-mode . " alc")
    :diminish (alchemist-phoenix-mode . " alc-ph")
    :init

    ;; Hack to disable company popup in Elixir if hanging
    (eval-after-load "alchemist"
      '(defun alchemist-company--wait-for-doc-buffer ()
         (setf num 50)
         (while (and (not alchemist-company-doc-lookup-done)
                  (> (decf num) 1))
           (sit-for 0.01))))))


;;;;;;;;;;;;;;;;;;;;
;; Comment DWIM 2 ;;
;;;;;;;;;;;;;;;;;;;;

(use-package comment-dwim-2 :bind ("M-;" . comment-dwim-2))


;;;;;;;;;;;;;;
;; Treemacs ;;
;;;;;;;;;;;;;;

(use-package treemacs
  :ensure t
  :defer nil
  :config
  (progn
    (setq
      treemacs-follow-after-init          t
      treemacs-width                      35
      treemacs-indentation                2
      treemacs-git-integration            t
      treemacs-collapse-dirs              3
      treemacs-silent-refresh             nil
      treemacs-change-root-without-asking nil
      treemacs-sorting                    'alphabetic-desc
      treemacs-show-hidden-files          t
      treemacs-never-persist              nil
      treemacs-is-never-other-window      nil
      treemacs-goto-tag-strategy          'refetch-index)
    )
  :bind
  (:map global-map
    ;;([f8]        . treemacs-toggle)
    ;;("M-0"       . treemacs-select-window)
    ;;("C-c 1"     . treemacs-delete-other-windows)
    ;;("M-m ft"    . treemacs-toggle)
    ;;("M-m fT"    . treemacs)
    ;;("M-m f C-t" . treemacs-find-file)
    ))
(use-package treemacs-projectile
  :defer t
  :ensure t
  :config
  (setq treemacs-header-function #'treemacs-projectile-create-header)
  :bind
  (:map global-map
    ([f8] . treemacs-projectile-toggle)
    ([shift f8] . treemacs-projectile))
  ;; :bind (:map global-map
  ;;         ("M-m fP" . treemacs-projectile)
  ;;         ("M-m fp" . treemacs-projectile-toggle))
  )

;;;;;;;;;;;;;;;;;;;;;
;; Other Languages ;;
;;;;;;;;;;;;;;;;;;;;;

(use-package puppet-mode
  :defer t)

(use-package powershell
  :defer t
  :mode  (("\\.ps1$" . powershell-mode)
           ("\\.psm$" . powershell-mode)))

(use-package python
  :defer t)

(use-package yaml-mode
  :defer t)

(use-package terraform-mode
  :defer t)

(use-package haml-mode
  :defer t
  :mode "\\.haml$"
  :config
  (add-hook 'haml-mode-hook
    (lambda ()
      (set (make-local-variable 'tab-width) 2))))

(use-package dockerfile-mode
  :defer t)

(use-package docker-tramp)


;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Comments and filling ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

;; 80 char wide paragraphs please
(setq-default fill-column 80)

;; Autofill where possible but only in comments when coding
;; http://stackoverflow.com/questions/4477357/how-to-turn-on-emacs-auto-fill-mode-only-for-code-comments
(setq comment-auto-fill-only-comments t)
(auto-fill-mode 1)

;; From http://mbork.pl/2015-11-14_A_simple_unfilling_function
(defun stamp/unfill-region (begin end)
  "Change isolated newlines in region into spaces."
  (interactive (if (use-region-p)
                 (list (region-beginning)
                   (region-end))
                 (list nil nil)))
  (save-restriction
    (narrow-to-region (or begin (point-min))
      (or end (point-max)))
    (goto-char (point-min))
    (while (search-forward "\n" nil t)
      (if (eq (char-after) ?\n)
        (skip-chars-forward "\n")
        (delete-char -1)
        (insert ?\s)))))

;; TODO Remove region params to interactive
;; http://stackoverflow.com/a/21051395/62023
(defun stamp/comment-box (beg end &optional arg)
  (interactive "*r\np")
  ;; (when (not (region-active-p))
  (when (not (and transient-mark-mode mark-active))
    (setq beg (point-at-bol))
    (setq end (point-at-eol)))
  (let ((fill-column (- fill-column 6)))
    (fill-region beg end))
  (comment-box beg end arg)
  (stamp/move-point-forward-out-of-comment))

(defun stamp/point-is-in-comment-p ()
  "t if point is in comment or at the beginning of a commented line, otherwise nil"
  (or (nth 4 (syntax-ppss))
    (looking-at "^\\s *\\s<")))

(defun stamp/move-point-forward-out-of-comment ()
  "Move point forward until it's no longer in a comment"
  (while (grass/point-is-in-comment-p)
    (forward-char)))

;; Comment annotations
(defun font-lock-comment-annotations ()
  "Highlight a bunch of well known comment annotations."
  (font-lock-add-keywords
    nil '(("\\<\\(FIX\\(ME\\)?\\|TODO\\|XXX\\|HACK\\|DEBUG\\|GRASS\\)"
            1 font-lock-warning-face t))))

(add-hook 'prog-mode-hook 'font-lock-comment-annotations)


;;;;;;;;;;;;;;;;;;;;;;;
;; Manipulating Text ;;
;;;;;;;;;;;;;;;;;;;;;;;

(use-package drag-stuff
  :diminish drag-stuff-mode
  :init
  (setq drag-stuff-except-modes '(org-mode))
  (setq drag-stuff-modifier '(meta super))
  (drag-stuff-global-mode 1)
  (drag-stuff-define-keys))

(use-package string-inflection
  :commands (string-inflection-underscore
              string-inflection-upcase
              string-inflection-lower-camelcase
              string-inflection-camelcase
              string-inflection-lisp))

;; Better zap to char
(use-package zop-to-char
  :commands (zop-to-char zop-up-to-char))

(global-set-key [remap zap-to-char] 'zop-to-char)

(defun new-line-dwim ()
  (interactive)
  (let ((break-open-pair (or (and (looking-back "{" 1) (looking-at "}"))
                           (and (looking-back ">" 1) (looking-at "<"))
                           (and (looking-back "(" 1) (looking-at ")"))
                           (and (looking-back "\\[" 1) (looking-at "\\]")))))
    (newline)
    (when break-open-pair
      (save-excursion
        (newline)
        (indent-for-tab-command)))
    (indent-for-tab-command)))

(global-set-key (kbd "<M-return>") 'new-line-dwim)

(defadvice kill-ring-save (before slick-copy activate compile)
  "When called interactively with no active region, copy the current line."
  (interactive
   (if mark-active
       (list (region-beginning) (region-end))
     (progn
       (message "Current line is copied.")
       (list (line-beginning-position) (line-beginning-position 2)) ) ) ))

(defadvice kill-region (before slick-copy activate compile)
  "When called interactively with no active region, cut the current line."
  (interactive
   (if mark-active
       (list (region-beginning) (region-end))
     (progn
       (list (line-beginning-position) (line-beginning-position 2)) ) ) ))


;;;;;;;;;;;;;
;; iTerm 2 ;;
;;;;;;;;;;;;;

(require 'iterm)

;;;;;;;;;;;
;; Dired ;;
;;;;;;;;;;;

(use-package dired
  :ensure nil
  :init
  ;; Allow editing of permissions in writable-dired-mode
  (setq wdired-allow-to-change-permissions 't)

  :config
  ;; dired-x extensions
  (require 'dired-x)

  (defun kill-dired-buffers ()
    "Kill all dired buffers."
    (interactive)
    (mapc (lambda (buffer)
            (when (eq 'dired-mode (buffer-local-value 'major-mode buffer))
              (kill-buffer buffer)))
      (buffer-list)))
  (global-set-key (kbd "C-c C-k") 'kill-dired-buffers)

  ;; Just use 'e' to enter edit dired mode
  (define-key dired-mode-map (kbd "e") 'wdired-change-to-wdired-mode))


;;;;;;;;;;;;;;;
;; Utilities ;;
;;;;;;;;;;;;;;;

(use-package crux
  :commands (crux-delete-file-and-buffer
              crux-duplicate-current-line-or-region
              crux-kill-other-buffers
              crux-indent-defun
              crux-cleanup-buffer-or-region
              crux-move-beginning-of-line
              crux-transpose-windows
              crux-view-url
              crux-top-join-line
              crux-smart-open-line
              crux-smart-open-line-above
              )
  :config
  (crux-with-region-or-buffer indent-region)
  (crux-with-region-or-buffer untabify)
  :bind
  (("C-S-j" . crux-top-join-line)
    ("C-c C-d" . crux-duplicate-current-line-or-region)
    ("C-c d" . crux-duplicate-and-comment-current-line-or-region)
    ("C-o" . crux-smart-open-line)
    ("C-S-o" . crux-smart-open-line-above)))

(use-package reveal-in-osx-finder
  :commands reveal-in-osx-in-finder)

(defun stamp/expand-lines ()
    (interactive)
    (let ((hippie-expand-try-functions-list
           '(try-expand-line-all-buffers)))
      (call-interactively 'hippie-expand)))

(global-set-key (kbd "C-x C-l") 'stamp/expand-lines) ; overloads downcase-region which I neve use anyway

(defun stamp/toggle-quotes ()
  (interactive)
  (save-excursion
    (let ((start (nth 8 (syntax-ppss)))
           (quote-length 0) sub kind replacement)
      (goto-char start)
      (setq sub (buffer-substring start (progn (forward-sexp) (point)))
        kind (aref sub 0))
      (while (char-equal kind (aref sub 0))
        (setq sub (substring sub 1)
          quote-length (1+ quote-length)))
      (setq sub (substring sub 0 (- (length sub) quote-length)))
      (goto-char start)
      (delete-region start (+ start (* 2 quote-length) (length sub)))
      (setq kind (if (char-equal kind ?\") ?\' ?\"))
      (loop for i from 0
        for c across sub
        for slash = (char-equal c ?\\)
        then (if (and (not slash) (char-equal c ?\\)) t nil) do
        (unless slash
          (when (member c '(?\" ?\'))
            (aset sub i
              (if (char-equal kind ?\") ?\' ?\")))))
      (setq replacement (make-string quote-length kind))
      (insert replacement sub replacement))))

(defun smart-kill-whole-line (&optional arg)
  "A simple wrapper around `kill-whole-line' that respects indentation."
  (interactive "P")
  (kill-whole-line arg)
  (back-to-indentation))

(global-set-key [remap kill-whole-line] 'smart-kill-whole-line)

;; http://stackoverflow.com/a/8257269/62023
(defun stamp/minibuffer-insert-word-at-point ()
  "Get word at point in original buffer and insert it to minibuffer."
  (interactive)
  (let (word beg)
    (with-current-buffer (window-buffer (minibuffer-selected-window))
      (save-excursion
        (skip-syntax-backward "w_")
        (setq beg (point))
        (skip-syntax-forward "w_")
        (setq word (buffer-substring-no-properties beg (point)))))
    (when word
      (insert word))))

(defun stamp/minibuffer-setup-hook ()
  (local-set-key (kbd "C-w") 'stamp/minibuffer-insert-word-at-point))

(add-hook 'minibuffer-setup-hook 'stamp/minibuffer-setup-hook)

(defun stamp/jump-between-test-files ()
  "Jump between file and the files test"
  (interactive)
  (save-buffer)
  (cond
    ((string= major-mode "elixir-mode") (alchemist-project-toggle-file-and-tests))
    ((or
       (string= major-mode "ruby-mode")
       (string= major-mode "enh-ruby-mode")) (rspec-toggle-spec-and-target))))

(defun stamp/test-file ()
  "Test file based on major mode"
  (interactive)
  (save-buffer)
  (cond
    ((string= major-mode "elixir-mode") (alchemist-project-run-tests-for-current-file))
    ((string= major-mode "rust-mode") (cargo-process-current-test))
    ((or
       (string= major-mode "ruby-mode")
       (string= major-mode "enh-ruby-mode")) (rspec-verify))))

(defun stamp/test-project ()
  "Test project based on major mode"
  (interactive)
  (save-buffer)
  (cond
    ((string= major-mode "elixir-mode") (alchemist-mix-test))
    ((string= major-mode "rust-mode") (cargo-process-test))
    ((or
       (string= major-mode "ruby-mode")
       (string= major-mode "enh-ruby-mode")) (rspec-verify-all))))

(defun stamp/today ()
  (format-time-string "%Y.%m.%d - %a"))

(defun stamp/insert-datetime (arg)
  "Without argument: insert date as yyyy-mm-dd
With C-u: insert date and time
With C-u C-u: insert time"
  (interactive "P")
  (cond ((equal arg '(16)) (insert (format-time-string "%T")))
    ((equal arg '(4)) (insert (format-time-string "%Y-%m-%d %T")))
    (t (insert (format-time-string "%Y-%m-%d")))))

(defun stamp/insert-date ()
  (interactive)
  (insert (stamp/today)))

(defun stamp/insert-org-date-header ()
  (interactive)
  (insert (concat "* " (stamp/today))))

(defun stamp/view-url-in-buffer ()
  "Open a new buffer containing the contents of URL."
  (interactive)
  (let* ((default (thing-at-point-url-at-point))
          (url (read-from-minibuffer "URL: " default)))
    (switch-to-buffer (url-retrieve-synchronously url))
    (rename-buffer url t)
    (cond ((search-forward "<?xml" nil t) (xml-mode))
      ((search-forward "<html" nil t) (html-mode)))))

(defun stamp/copy-buffer-filename ()
  "Copy filename of buffer into system clipboard."
  (interactive)
  ;; list-buffers-directory is the variable set in dired buffers
  (let ((file-name (or (buffer-file-name) list-buffers-directory)))
    (if file-name
      (message (simpleclip-set-contents file-name))
      (error "Buffer not visiting a file"))))

(defun stamp/indent-buffer ()
  "Indents the entire buffer."
  (indent-region (point-min) (point-max)))

(defun stamp/indent-region-or-buffer ()
  "Indents a region if selected, otherwise the whole buffer."
  (interactive)
  (save-excursion
    (if (region-active-p)
      (progn
        (indent-region (region-beginning) (region-end))
        (message "Indented selected region."))
      (progn
        (stamp/indent-buffer)
        (message "Indented buffer.")))))

(defun stamp/open-this-file-as-other-user (user)
  "Edit current file as USER, using `tramp' and `sudo'.  If the current
buffer is not visiting a file, prompt for a file name."
  (interactive "sEdit as user (default: root): ")
  (when (string= "" user)
    (setq user "root"))
  (let* ((filename (or buffer-file-name
                       (read-file-name (format "Find file (as %s): "
                                               user))))
         (tramp-path (concat (format "/sudo:%s@localhost:" user) filename)))
    (if buffer-file-name
        (find-alternate-file tramp-path)
      (find-file tramp-path))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Auto save on focus lost ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun stamp/toggle-auto-save ()
  "Toggle auto save setting"
  (interactive)
  (setq auto-save-default (if auto-save-default nil t)))

(defun stamp/auto-save-all()
  "Save all modified buffers that point to files."
  (interactive)
  (save-excursion
    (dolist (buf (buffer-list))
      (set-buffer buf)
      (if (and (buffer-file-name) (buffer-modified-p))
        (basic-save-buffer)))))

(add-hook 'auto-save-hook 'stamp/auto-save-all)
(add-hook 'mouse-leave-buffer-hook 'stamp/auto-save-all)
(add-hook 'focus-out-hook 'stamp/auto-save-all)


;;;;;;;;;;;;;;;;;
;; Direnv Mode ;;
;;;;;;;;;;;;;;;;;

(use-package direnv
  :init
  (setq direnv-always-show-summary t)
  :config
  (direnv-mode 1))

;;;;;;;;;;
;; Ruby ;;
;;;;;;;;;;

(use-package ruby-end
  :diminish (ruby-end-mode . " ☡")
  :commands ruby-end-mode)

(use-package ruby-mode
  :mode (("\\.rb$"        . enh-ruby-mode)
          ("\\.ru$"        . enh-ruby-mode)
          ("\\.rake$"      . enh-ruby-mode)
          ("\\.gemspec$"   . enh-ruby-mode)
          ("\\.?pryrc$"    . enh-ruby-mode)
          ("/Gemfile$"     . enh-ruby-mode)
          ("/Guardfile$"   . enh-ruby-mode)
          ("/Capfile$"     . enh-ruby-mode)
          ("/Vagrantfile$" . enh-ruby-mode)
          ("/Rakefile$"    . enh-ruby-mode))
  :interpreter "ruby"
  :bind (:map ruby-mode-map
          ("M-." . projectile-find-tag))

  :config

  ;; point to script that bundle exec's by default
  (setq flycheck-ruby-rubocop-executable "~/bin/rubocop")

  ;; editing my code for me is bad.
  (setq ruby-insert-encoding-magic-comment nil)
  (setq enh-ruby-add-encoding-comment-on-save nil)
  (setq enh-ruby-use-encoding-map nil)

  (use-package inf-ruby
    :config
    (setq inf-ruby-default-implementation "pry")
    (add-hook 'ruby-mode-hook 'inf-ruby-minor-mode))

  (use-package rspec-mode
    :config
    ;; Fix problem with running rspec with zsh
    (defadvice rspec-compile (around rspec-compile-around)
      "Use BASH shell for running the specs because of ZSH issues."
      (let ((shell-file-name "/bin/bash"))
        ad-do-it))
    (ad-activate 'rspec-compile)
    )

  (use-package projectile-rails
    :diminish (projectile-rails-mode . " ⇋")
    :init
    (progn
      (add-hook 'projectile-mode-hook 'projectile-rails-on)))

  (defun stamp/toggle-ruby-block-style ()
    (interactive)
    (ruby-beginning-of-block)
    (if (looking-at-p "{")
      (let ((beg (point)))
        (delete-char 1)
        (insert (if (looking-back "[^ ]") " do" "do"))
        (when (looking-at "[ ]*|.*|")
          (search-forward-regexp "[ ]*|.*|" (line-end-position)))
        (insert "\n")
        (goto-char (- (line-end-position) 1))
        (delete-char 1)
        (insert "\nend")
        (evil-indent beg (point))
        )
      (progn
        (ruby-end-of-block)
        ;; Join lines if block is 1 line of code long
        (save-excursion
          (let ((end (line-end-position)))
            (ruby-beginning-of-block)
            (if (= 2 (- (line-number-at-pos end) (line-number-at-pos)))
              (evil-join (point) end)))
          (kill-line)
          (insert " }")
          (ruby-beginning-of-block)
          (delete-char 2)
          (insert "{" )))))

  ;; We never want to edit Rubinius bytecode
  (add-to-list 'completion-ignored-extensions ".rbc")

  (add-hook 'ruby-mode-hook
    (lambda ()
      ;; turn off the annoying input echo in irb
      (setq comint-process-echoes t)

      (setq ruby-indent-level 2)
      (setq ruby-deep-indent-paren nil)

      ;; Flycheck on
      (flycheck-mode)))

  (add-hook 'enh-ruby-mode-hook
    (lambda ()
      ;; turn off the annoying input echo in irb
      (setq comint-process-echoes t)

      (set (make-variable-buffer-local 'ruby-end-insert-newline) nil)
      ;; Indentation
      (setq ruby-indent-level 2)
      (setq ruby-deep-indent-paren nil)
      (setq enh-ruby-bounce-deep-indent nil)
      (setq enh-ruby-hanging-brace-indent-level 2)
      (setq enh-ruby-indent-level 2)
      (setq enh-ruby-deep-indent-paren nil)

      ;; Flycheck on
      (flycheck-mode)

      ;; Abbrev mode seems broken for some reason
      (abbrev-mode -1))))

(use-package rbenv
  :init
  (progn
    ;; No bright red version in the modeline thanks
    (setq rbenv-modeline-function 'rbenv--modeline-plain)

    (defun stamp/enable-rbenv ()
      "Enable rbenv, use .ruby-version if exists."
      (require 'rbenv)

      (let ((version-file-path (rbenv--locate-file ".ruby-version")))
        (global-rbenv-mode)
        ;; try to use the ruby defined in .ruby-version
        (if version-file-path
          (progn
            (rbenv-use (rbenv--read-version-from-file
                         version-file-path))
            (message (concat "[rbenv] Using ruby version "
                       "from .ruby-version file.")))
          (message "[rbenv] Using the currently activated ruby."))))
    (add-hook 'ruby-mode-hook #'stamp/enable-rbenv)
    (add-hook 'enh-ruby-mode-hook #'stamp/enable-rbenv)))

(use-package rubocop
  :commands (rubocop-check-project rubocop-check-directory rubocop-check-current-file
              rubocop-autocorrect-project rubocop-autocorrect-directory
              rubocop-autocorrect-current-file))


;;;;;;;;;;
;; Rust ;;
;;;;;;;;;;

(use-package cargo
  :defer t
  :config
  (setq compilation-ask-about-save nil)
  (add-hook 'rust-mode-hook 'cargo-minor-mode)
  :commands (cargo-process-doc cargo-process-test cargo-process-run)
  :diminish cargo-minor-mode)

(use-package flycheck-rust
  :defer t
  :init (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

(use-package toml-mode
  :mode "/\\(Cargo.lock\\|\\.cargo/config\\)\\'")

(use-package rust-mode
  :defer t
  :config
  (progn
    (setq-local company-tooltip-align-annotations t)
    (when (memq window-system '(mac ns x))
      (exec-path-from-shell-copy-env "RUST_SRC_PATH"))))

(use-package racer
  :defer t
  :init
  (add-hook 'rust-mode-hook 'racer-mode)
  (add-hook 'rust-mode-hook 'eldoc-mode)
  :diminish racer-mode)


;;;;;;;;;;;;;;;;;;;;;;;
;; Move Where I Mean ;;
;;;;;;;;;;;;;;;;;;;;;;;

(use-package mwim
  :bind
  (("C-a" . mwim-beginning-of-code-or-line)
    ("<home>" . mwim-beginning-of-code-or-line)
    ("C-e" . mwim-end-of-code-or-line)
    ("<end>" . mwim-end-of-code-or-line)))


;;;;;;;;;;;;;;
;; Spelling ;;
;;;;;;;;;;;;;;

(use-package flyspell
  :defer t
  :commands (flyspell-mode flyspell-goto-next-error)
  :diminish (flyspell-mode . " spl")
  :config
  (setq-default ispell-program-name "aspell")
  ;; Silently save my personal dictionary when new items are added
  (setq ispell-silently-savep t)
  (ispell-change-dictionary "british" t)

  (add-hook 'markdown-mode-hook (lambda () (flyspell-mode 1)))
  (add-hook 'text-mode-hook (lambda () (flyspell-mode 1)))

  (add-hook 'flyspell-mode-hook
    (lambda ()
      (define-key flyspell-mode-map [(control ?\,)] nil))))

;; TODO: Incorporate into global keymap
;; (defhydra hydra-spelling ()
;;   "spelling"
;;   ("t" flyspell-mode "toggle")
;;   ("n" flyspell-goto-next-error "next error")
;;   ("w" ispell-word)
;;   ("q" nil "quit" :color blue))

(use-package spaceline
  :init
  (require 'spaceline-config)
  (setq powerline-default-separator 'bar)
  (setq powerline-default-separator 'bar)
  (setq spaceline-minor-modes-separator "⋅")
  (setq spaceline-highlight-face-func 'spaceline-highlight-face-evil-state)
  (spaceline-spacemacs-theme)
  (spaceline-info-mode))


;;;;;;;;;;;;;;;;;;;;;;;
;; Whitespace Butler ;;
;;;;;;;;;;;;;;;;;;;;;;;

(use-package ws-butler
  :init
  (add-hook 'prog-mode-hook 'ws-butler-mode)
  :diminish ws-butler-mode
  )


;;;;;;;;;;;;;;
;; Flycheck ;;
;;;;;;;;;;;;;;

(use-package flycheck
  :defer 3
  :diminish (flycheck-mode . " ⓢ")
  :defines stamp/toggle-flycheck-error-list
  :commands
  (flycheck-mode
    flycheck-clear
    flycheck-describe-checker
    flycheck-select-checker
    flycheck-set-checker-executable
    flycheck-verify-setup)
  :config
  (progn
    (when (fboundp 'define-fringe-bitmap)
      (define-fringe-bitmap 'my-flycheck-fringe-indicator
        (vector #b00000000
          #b00000000
          #b00000000
          #b00000000
          #b00000000
          #b00000000
          #b00000000
          #b00011100
          #b00111110
          #b00111110
          #b00111110
          #b00011100
          #b00000000
          #b00000000
          #b00000000
          #b00000000
          #b00000000)))

    (flycheck-define-error-level 'error
      :overlay-category 'flycheck-error-overlay
      :fringe-bitmap 'my-flycheck-fringe-indicator
      :fringe-face 'flycheck-fringe-error)

    (flycheck-define-error-level 'warning
      :overlay-category 'flycheck-warning-overlay
      :fringe-bitmap 'my-flycheck-fringe-indicator
      :fringe-face 'flycheck-fringe-warning)

    (flycheck-define-error-level 'info
      :overlay-category 'flycheck-info-overlay
      :fringe-bitmap 'my-flycheck-fringe-indicator
      :fringe-face 'flycheck-fringe-info)

    ;; use local eslint from node_modules before global
    ;; http://emacs.stackexchange.com/questions/21205/flycheck-with-file-relative-eslint-executable
    (defun stamp/use-eslint-from-node-modules ()
      (let* ((root (locate-dominating-file
                     (or (buffer-file-name) default-directory)
                     "node_modules"))
              (eslint (and root
                        (expand-file-name "node_modules/eslint/bin/eslint.js"
                          root))))
        (when (and eslint (file-executable-p eslint))
          (setq-local flycheck-javascript-eslint-executable eslint))))

    (add-hook 'flycheck-mode-hook #'stamp/use-eslint-from-node-modules)

    (defun stamp/toggle-flycheck-error-list ()
      "Toggle flycheck's error list window.
If the error list is visible, hide it.  Otherwise, show it."
      (interactive)
      (-if-let (window (flycheck-get-error-list-window))
        (quit-window nil window)
        (flycheck-list-errors)))

    (define-key flycheck-mode-map (kbd "C-c C-t") 'stamp/toggle-flycheck-error-list)

    ;; Beware that moving this window with a window manager can mess with tooltips
    (use-package flycheck-pos-tip
      :init
      (with-eval-after-load 'flycheck
        (flycheck-pos-tip-mode)))

    (setq flycheck-display-errors-delay 0.5)))

(defhydra hydra-flycheck
  (:pre (progn (setq hydra-lv t) (flycheck-list-errors))
    :post (progn (setq hydra-lv nil) (quit-windows-on "*Flycheck errors*"))
    :hint nil)
  "Errors"
  ("f"  flycheck-error-list-set-filter "Filter")
  ("<down>"  flycheck-next-error "Next")
  ("<up>"  flycheck-previous-error "Previous")
  ("M-<up>" flycheck-first-error "First")
  ("M-<down>"  (progn (goto-char (point-max)) (flycheck-previous-error)) "Last")
  (" "  nil)
  ("<return>"  nil)
  ("q"  nil)
  )

;;;;;;;;;;;;;;;
;; Proselint ;;
;;;;;;;;;;;;;;;

(with-eval-after-load 'flycheck
  ;; brew install proselint
  (flycheck-define-checker proselint
    "A linter for prose."
    :command ("proselint" source-inplace)
    :error-patterns
    ((warning line-start (file-name) ":" line ":" column ": "
       (id (one-or-more (not (any " "))))
       (message (one-or-more not-newline)
         (zero-or-more "\n" (any " ") (one-or-more not-newline)))
       line-end))
    :modes (text-mode markdown-mode gfm-mode org-mode))
  (add-to-list 'flycheck-checkers 'proselint))


;;;;;;;;;;;
;; Shell ;;
;;;;;;;;;;;

;; aliasii
(eval-after-load 'em-alias
  '(progn (eshell/alias "ll" "ls -la $*")
          (eshell/alias "ff" "find-file $*")
          (eshell/alias "ec" "find-file $*")
          (eshell/alias "g" "git $*")
          (eshell/alias "bi" "bundle install $*")
          (eshell/alias "bil" "bundle install --local $*")
          (eshell/alias "be" "bundle exec $*")
          (eshell/alias "gs" "git status")
          (eshell/alias "gco" "git checkout $*")
          (eshell/alias "rspec" "bundle exec rspec $*")
          (eshell/alias "d" "dired")
          ))

;; if there is a dired buffer displayed in the next window, use its
;; current subdir, instead of the current subdir of this dired buffer
(setq dired-dwim-target t)

;; Colour for shell output
(add-hook 'eshell-preoutput-filter-functions
  'ansi-color-apply)

;;;;;;;;;;;;;;;;;
;; REST Client ;;
;;;;;;;;;;;;;;;;;

(use-package restclient
  :mode ("\\.rest\\'" . restclient-mode)
  :config
  (progn
    (add-hook 'restclient-response-loaded-hook
      (lambda ()
        (local-set-key "q" '(lambda () (interactive) (quit-window t)))))
    ))

;;;;;;;;;;;;;;
;; Graphviz ;;
;;;;;;;;;;;;;;

(use-package graphviz-dot-mode
  :mode "\\.dot\\'"
  :config
  (progn
    (setf graphviz-dot-indent-width 2
      graphviz-dot-auto-indent-on-semi nil)
    (defun stamp/open-attribute-help ()
      (interactive)
      (browse-url "http://www.graphviz.org/doc/info/attrs.html")) ))


;;;;;;;;;;
;; Tmux ;;
;;;;;;;;;;

(use-package emamux
  :commands (emamux:send-command
              emamux:run-command
              emamux:run-last-command
              emamux:zoom-runner
              emamux:inspect-runner
              emamux:close-runner-pane
              emamux:close-panes
              emamux:clear-runner-history
              emamux:interrupt-runner
              emamux:copy-kill-ring
              emamux:yank-from-list-buffers))


;;;;;;;;;;;;;;;;;
;; Indentation ;;
;;;;;;;;;;;;;;;;;

;; Fancy tabbing. Set to nil to stop tab indenting a line
(setq-default tab-always-indent t)

(defun stamp/toggle-always-indent ()
  "Toggle tab-always-indent setting"
  (interactive)
  (setq tab-always-indent (if tab-always-indent nil t)))

;; Don't use tabs to indent
(setq-default indent-tabs-mode nil)

(setq-default tab-width 2)
(setq-default evil-shift-width 2)
(setq lisp-indent-offset 2)
(setq-default js2-basic-offset 2)
(setq-default sh-basic-offset 2)
(setq-default sh-indentation 2)
(setq-default js-indent-level 2)
(setq-default js2-indent-switch-body t)
(setq css-indent-offset 2)
(setq coffee-tab-width 2)
(setq-default py-indent-offset 2)
(setq-default nxml-child-indent 2)
(setq typescript-indent-level 2)
(setq ruby-indent-level 2)
(setq sgml-basic-offset 2)

;; Default formatting style for C based modes
(setq c-default-style "java")
(setq-default c-basic-offset 2)

;;;;;;;;;;;;;;;;
;; Whitespace ;;
;;;;;;;;;;;;;;;;

(require 'whitespace)
(diminish 'global-whitespace-mode)
;; Only show bad whitespace (Ignore empty lines at start and end of buffer)
(setq whitespace-style '(face tabs trailing space-before-tab indentation space-after-tab))
(global-whitespace-mode t)

(setq require-final-newline t)

;;;;;;;;;;;;;;;;
;; Projectile ;;
;;;;;;;;;;;;;;;;

(use-package projectile
  :diminish (projectile-mode . " ⓟ")
  :commands (projectile-mode projectile-project-root)
  :defines stamp/counsel-ag-current-project
  :config
  (setq projectile-tags-command "rtags -R -e")
  (setq projectile-enable-caching nil)
  (setq projectile-completion-system 'ivy)
  ;; Show unadded files also
  (setq projectile-hg-command "( hg locate -0 -I . ; hg st -u -n -0 )")

  (add-to-list 'projectile-globally-ignored-directories "gems")
  (add-to-list 'projectile-globally-ignored-directories "node_modules")
  (add-to-list 'projectile-globally-ignored-directories "bower_components")
  (add-to-list 'projectile-globally-ignored-directories "dist")
  (add-to-list 'projectile-globally-ignored-directories "/emacs.d/elpa/")
  (add-to-list 'projectile-globally-ignored-directories "vendor/cache/")
  (add-to-list 'projectile-globally-ignored-files ".keep")
  (add-to-list 'projectile-globally-ignored-files "TAGS"))

(use-package projectile-ripgrep
  ;; ripgrep-search-mode
  :config
  (use-package wgrep-ag
    :config
    (add-hook 'ripgrep-search-mode 'wgrep-ag-setup)
    (bind-keys :map ripgrep-search-mode-map
      ("e" . wgrep-change-to-wgrep-mode))))

(use-package counsel-projectile
  :init
  (progn
    (setq projectile-switch-project-action 'counsel-projectile-find-file)

    :init
    (projectile-global-mode t)))

;;;;;;;;;;;;;;;;;;;;;;
;; Buffer switching ;;
;;;;;;;;;;;;;;;;;;;;;;

(defun s-trim-left (s)
  "Remove whitespace at the beginning of S."
  (if (string-match "\\`[ \t\n\r]+" s)
      (replace-match "" t t s)
    s))

(defun stamp/useful-buffer-p (&optional potential-buffer-name)
  "Return t if current buffer is a user buffer, else nil.
Typically, if buffer name starts with *, it's not considered a user buffer.
This function is used by buffer switching command and close buffer command, so that next buffer shown is a user buffer.
You can override this function to get your idea of “user buffer”."
  (interactive)
  (if (string-equal "*" (substring (buffer-name) 0 1))
    nil
    (if (string-equal major-mode "dired-mode")
      nil
      (if (string-match "TAGS\\'" (buffer-name))
        nil
        t))))

(defun stamp/next-useful-buffer ()
  "Switch to the next user buffer."
  (interactive)
  (next-buffer)
  (let ((i 0))
    (while (< i 20)
      (if (not (stamp/useful-buffer-p))
          (progn (next-buffer)
                 (setq i (1+ i)))
        (progn (setq i 100))))))

(defun stamp/previous-useful-buffer ()
  "Switch to the previous user buffer."
  (interactive)
  (previous-buffer)
  (let ((i 0))
    (while (< i 20)
      (if (not (stamp/useful-buffer-p))
          (progn (previous-buffer)
                 (setq i (1+ i)))
        (progn (setq i 100))))))

(global-set-key [(super left)] 'stamp/previous-useful-buffer)
(global-set-key [(super right)] 'stamp/next-useful-buffer)

(global-set-key (kbd "C-c q") 'bury-buffer)

(defun stamp/switch-to-previous-buffer ()
  "Switch to previously open buffer.
Repeated invocations toggle between the two most recently open buffers."
  (interactive)
  (let* ((candidate-buffers (remove-if-not
                             #'stamp/useful-buffer-p
                             (mapcar (function buffer-name) (buffer-list))))
         (candidate-buffer (nth 1 candidate-buffers)))
    (if candidate-buffer
        (switch-to-buffer (nth 1 candidate-buffers)))))

(defun stamp/mark-line-or-next ()
  "Marks the current line or extends the mark if there is no current selection"
  (interactive)
  (if mark-active
      (forward-line)
    (progn
      (beginning-of-line)
      (push-mark (point))
      (end-of-line)
      (forward-char)
      (activate-mark))))

(global-set-key (kbd "C-;") 'stamp/mark-line-or-next)

(defun stamp/rename-file-and-buffer ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (error "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (read-file-name "New name: " filename)))
        (cond ((get-buffer new-name)
               (error "A buffer named '%s' already exists!" new-name))
              (t
               (rename-file filename new-name 1)
               (rename-buffer new-name)
               (set-visited-file-name new-name)
               (set-buffer-modified-p nil)
               (message "File '%s' successfully renamed to '%s'" name (file-name-nondirectory new-name))))))))

(defun stamp/switch-to-scratch-buffer ()
  "Switch to the `*scratch*' buffer."
  (interactive)
  (let ((exists (get-buffer "*scratch*")))
    (switch-to-buffer (get-buffer-create "*scratch*"))))

;;;;;;;;;;;;;;;;;
;; Beacon mode ;;
;;;;;;;;;;;;;;;;;

(use-package beacon
  :init
  (beacon-mode 1)
  :diminish beacon-mode
  )

;;;;;;;;;;;;;;;;;;;
;; Editor Config ;;
;;;;;;;;;;;;;;;;;;;

;; http://editorconfig.org/

(use-package editorconfig
  :ensure t
  :diminish editorconfig-mode
  :config
  (editorconfig-mode 1))

;;;;;;;;;;;;;
;; Shackle ;;
;;;;;;;;;;;;;

(use-package shackle
  :init
  (setq shackle-select-reused-windows nil) ; default nil
  (setq shackle-default-alignment 'below) ; default below
  (setq shackle-default-size 0.4) ; default 0.5

  (setq shackle-rules
    ;; CONDITION(:regexp)            :select     :inhibit-window-quit   :size+:align|:other     :same|:popup
    '(
       ("*HTTP Response*"             :select nil :size 0.4                                  )
       ("*rspec-compilation*"         :select nil :size 0.3 :align 'below                               )
       ("*alchemist help*"            :select nil :size 0.3 :align 'below                               )
       ("*alchemist test report*"     :select nil :size 0.3 :align 'below                               )
       ("*Flycheck errors*"           :select nil :size 0.3 :align 'below                               )
       (compilation-mode              :select nil                                                       )
       (" *undo-tree*"                :size 0.25 :align right                                           )
       (" *eshell*"                    :select t                          :other t                      )
       ("*Shell Command Output*"      :select nil                                                       )
       ("\\*Async Shell.*\\*"         :regexp t :ignore t                                               )
       (occur-mode                    :select nil                                   :align t            )
       ("*Help*"                      :select t   :inhibit-window-quit t :other t                       )
       ("*Completions*"                                                  :size 0.3  :align t            )
       ("*Messages*"                  :select nil :inhibit-window-quit t :other t                       )
       ("\\*[Wo]*Man.*\\*"    :regexp t :select t   :inhibit-window-quit t :other t                     )
       ("\\*poporg.*\\*"      :regexp t :select t                          :other t                     )
       ("\\`\\*helm.*?\\*\\'"   :regexp t                                    :size 0.3  :align t        )
       ("*Calendar*"                  :select t                          :size 0.3  :align below        )
       ("*xref*"                      :select t                                     :align below        )
       ("*info*"                      :select t   :inhibit-window-quit t                         :same t)
       (magit-status-mode             :select t   :inhibit-window-quit t                         :same t)
       (magit-log-mode                :select t   :inhibit-window-quit t                         :same t)
       ))
  :config
  (diminish 'shackle-mode)
  (shackle-mode 1))


;;;;;;;;;;;;;;;;;;;;
;; FiraCode Setup ;;
;;;;;;;;;;;;;;;;;;;;

(when (window-system)
  (set-default-font "Fira Code"))

(let ((alist '((33 . ".\\(?:\\(?:==\\|!!\\)\\|[!=]\\)")
                (35 . ".\\(?:###\\|##\\|_(\\|[#(?[_{]\\)")
                (36 . ".\\(?:>\\)")
                (37 . ".\\(?:\\(?:%%\\)\\|%\\)")
                (38 . ".\\(?:\\(?:&&\\)\\|&\\)")
                (42 . ".\\(?:\\(?:\\*\\*/\\)\\|\\(?:\\*[*/]\\)\\|[*/>]\\)")
                (43 . ".\\(?:\\(?:\\+\\+\\)\\|[+>]\\)")
                (45 . ".\\(?:\\(?:-[>-]\\|<<\\|>>\\)\\|[<>}~-]\\)")
                (46 . ".\\(?:\\(?:\\.[.<]\\)\\|[.=-]\\)")
                (47 . ".\\(?:\\(?:\\*\\*\\|//\\|==\\)\\|[*/=>]\\)")
                (48 . ".\\(?:x[a-zA-Z]\\)")
                (58 . ".\\(?:::\\|[:=]\\)")
                (59 . ".\\(?:;;\\|;\\)")
                (60 . ".\\(?:\\(?:!--\\)\\|\\(?:~~\\|->\\|\\$>\\|\\*>\\|\\+>\\|--\\|<[<=-]\\|=[<=>]\\||>\\)\\|[*$+~/<=>|-]\\)")
                (61 . ".\\(?:\\(?:/=\\|:=\\|<<\\|=[=>]\\|>>\\)\\|[<=>~]\\)")
                (62 . ".\\(?:\\(?:=>\\|>[=>-]\\)\\|[=>-]\\)")
                (63 . ".\\(?:\\(\\?\\?\\)\\|[:=?]\\)")
                (91 . ".\\(?:]\\)")
                (92 . ".\\(?:\\(?:\\\\\\\\\\)\\|\\\\\\)")
                (94 . ".\\(?:=\\)")
                (119 . ".\\(?:ww\\)")
                (123 . ".\\(?:-\\)")
                (124 . ".\\(?:\\(?:|[=|]\\)\\|[=>|]\\)")
                (126 . ".\\(?:~>\\|~~\\|[>=@~-]\\)")
                )
        ))
  (dolist (char-regexp alist)
    (set-char-table-range composition-function-table (car char-regexp)
      `([,(cdr char-regexp) 0 font-shape-gstring]))))

(mac-auto-operator-composition-mode)

;;;;;;;;;;;;;;;;;;;;;
;; Leader bindings ;;
;;;;;;;;;;;;;;;;;;;;;

;; Text zoom
(defhydra hydra-zoom-text ()
  "zoom text"
  ("=" text-scale-increase "in")
  ("+" text-scale-increase "in")
  ("-" text-scale-decrease "out")
  ("0" (text-scale-adjust 0) "reset")
  ("q" nil "quit" :color blue))

(defhydra hydra-window ()
  "
Movement^^        ^Split^          ^Switch^        ^Resize^
----------------------------------------------------------------
_h_ ←            _v_ertical        _b_uffer        _q_ X←
_j_ ↓            _x_ horizontal    _f_ind files    _w_ X↓
_k_ ↑            _z_ undo          _a_ce 1         _e_ X↑
_l_ →            _Z_ reset         _s_wap          _r_ X→
_F_ollow         _D_lt Other       _S_ave          max_i_mize
_SPC_ cancel     _o_nly this       _d_elete
                               _t_oggle split
"
  ("h" windmove-left nil)
  ("j" windmove-down nil)
  ("k" windmove-up nil)
  ("l" windmove-right nil)
  ("<left>" windmove-left nil)
  ("<down>" windmove-down nil)
  ("<up>" windmove-up nil)
  ("<right>" windmove-right nil)
  ("q" stamp/move-splitter-left nil)
  ("w" stamp/move-splitter-down nil)
  ("e" stamp/move-splitter-up nil)
  ("r" stamp/move-splitter-right nil)
  ("b" ivy-switch-buffer nil)
  ("f" counsel-find-file nil)
  ("F" follow-mode nil)
  ("t" stamp/window-toggle-split-direction nil)
  ("a" (lambda ()
         (interactive)
         (ace-window 1)
         (add-hook 'ace-window-end-once-hook
           'hydra-window/body))
    nil)
  ("v" (lambda ()
         (interactive)
         (split-window-right)
         (windmove-right))
    nil)
  ("x" (lambda ()
         (interactive)
         (split-window-below)
         (windmove-down))
    nil)
  ("s" (lambda ()
         (interactive)
         (ace-window 4)
         (add-hook 'ace-window-end-once-hook
           'hydra-window/body)) nil)
  ("S" save-buffer nil)
  ("d" delete-window nil)
  ("D" (lambda ()
         (interactive)
         (ace-window 16)
         (add-hook 'ace-window-end-once-hook
           'hydra-window/body))
    nil)
  ("o" delete-other-windows nil)
  ("i" ace-maximize-window nil)
  ("z" (progn
         (winner-undo)
         (setq this-command 'winner-undo))
    nil)
  ("Z" winner-redo nil)
  ("SPC" nil nil)
  ("<return>" nil nil))

(defhydra hydra-change-case ()
  "toggle word case"
  ("c" capitalize-word "Capitalize")
  ("u" upcase-word "UPPER")
  ("l" downcase-word "lower")
  ("s" string-inflection-underscore "lower_snake")
  ("n" string-inflection-upcase "UPPER_SNAKE")
  ("a" string-inflection-lower-camelcase "lowerCamel")
  ("m" string-inflection-camelcase "UpperCamel")
  ("d" string-inflection-lisp "dash-case"))

(global-unset-key (kbd "M-m"))

(general-define-key
  :prefix "M-m"
  "TAB" '(stamp/switch-to-previous-buffer :which-key "previous buffer")

  "b"  '(:ignore t :which-key "buffers")
  "bR" 'crux-rename-buffer-and-file
  "bb" 'ivy-switch-buffer
  "bc" '(hydra-flycheck/body :which-key "flycheck mini-state")
  "bi" 'ibuffer
  "bk" 'kill-this-buffer
  "bm" '(hydra-buffer/body :which-key "buffer mini-state")
  "bo" 'crux-kill-other-buffers
  "bq" 'bury-buffer
  "br" 'rubocop-autocorrect-current-file
  "bs" 'stamp/switch-to-scratch-buffer
  "bt" '(stamp/test-file :which-key "test file")
  "b'" '(stamp/toggle-quotes :which-key "toggle quotes")

  "l" '(:ignore t :which-key "language")
  "lc" '(alchemist-mix-compile :which-key "compile")
  "ld" '(alchemist-help-search-at-point :which-key "documentation at point")

  "w"  '(:ignore t :which-key "windows/ui")
  "wr" '((lambda () (interactive) (window-configuration-to-register 97)) :which-key "remember windows")
  "wj" '((lambda () (interactive) (jump-to-register 97)) :which-key "jump to remembered window")
  "ww" '(hydra-window/body :which-key "window mini state")
  "wz"  '(hydra-zoom-text/body :which-key "zoom")
  "ws"  'ace-swap-window

  "p" '(:ignore t :which-key "project")
  "pS" '(projectile-ag :which-key "search project (new window)")
  "pb" '(counsel-projectile-switch-to-buffer :which-key "buffer in project")
  "pd" '(counsel-projectile-find-dir :which-key "find dir")
  "pf" '(counsel-projectile-find-file :which-key "find file")
  "pj" '(projectile-toggle-between-implementation-and-test :which-key "jump between src/test")
  "pm" '(:keymap projectile-command-map :package projectile :which-key "all projectile")
  "pp" '(counsel-projectile :which-key "switch project")
  "ps" '(counsel-projectile-ag :which-key "search project (interative)")
  "pt" '(stamp/test-project :which-key "test project")

  "t" '(:ignore t :which-key "text")
  "tc" '(hydra-change-case/body :which-key "case change")
  "ts" '(hydra-surround/body :which-key "corral surround")

  "v" '(:ignore t :which-key "version control")
  "vb" 'magit-blame
  "vd" 'vc-diff
  "vt" '(git-timemachine :which-key "git timemachine")
  "vs" '(magit-status :which-key "git status")
  "vl" '(git-link :which-key "git link")
  "vp" '(github-pr :which-key "create github pr")
  )

(general-define-key "<f1>" 'counsel-projectile-find-file)
(general-define-key "<f2>" 'counsel-projectile-rg)
(general-define-key "C-S-s" 'swiper)
(general-define-key "C-M-s" 'swiper-all)
(general-define-key "s-i" 'counsel-imenu)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Find custom peronal file ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(let ((filename (expand-file-name "personal.el" user-emacs-directory)))
  (if (file-exists-p filename)
    (load-file filename)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(message "Enjoy your finely crafted editing experience")

(provide 'init)
;;; init.el ends here

