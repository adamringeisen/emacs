(defun set-exec-path-from-shell-PATH ()
  "Set up Emacs' `exec-path' and PATH environment variable to match
that used by the user's shell.

This is particularly useful under Mac OS X and macOS, where GUI
apps are not started from a shell."
  (interactive)
  (let ((path-from-shell (replace-regexp-in-string
			  "[ \t\n]*$" "" (shell-command-to-string
					  "$SHELL --login -c 'echo $PATH'"
						    ))))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

(set-exec-path-from-shell-PATH)

(set-face-attribute 'default nil
                  :font "DejaVu Sans Mono 14")

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

(delete-selection-mode 1)

(use-package vertico
      :ensure t
      :init
      (vertico-mode))

    ;; Save history for all completion buffers
    (use-package savehist
      :init
      (savehist-mode))

(define-key vertico-map "\M-q" #'vertico-quick-insert)
(define-key vertico-map "\C-q" #'vertico-quick-exit)
    (use-package marginalia
      :after vertico
      :ensure t
      :custom
      (marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
      :init
      (marginalia-mode))

    (use-package orderless
    :ensure t
    :custom (completion-styles '(orderless)))

;; Example configuration for Consult
  (use-package consult
    :ensure t
    ;; Replace bindings. Lazily loaded due by `use-package'.
    :bind (;; C-c bindings (mode-specific-map)
	   ("C-c h" . consult-history)
	   ("C-c m" . consult-mode-command)
	   ("C-c k" . consult-kmacro)
	   ;; C-x bindings (ctl-x-map)
	   ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
	   ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
	   ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
	   ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
	   ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
	   ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
	   ;; Custom M-# bindings for fast register access
	   ("M-#" . consult-register-load)
	   ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
	   ("C-M-#" . consult-register)
	   ;; Other custom bindings
	   ("M-y" . consult-yank-pop)                ;; orig. yank-pop
	   ("<help> a" . consult-apropos)            ;; orig. apropos-command
	   ;; M-g bindings (goto-map)
	   ("M-g e" . consult-compile-error)
	   ("M-g f" . consult-flycheck)               ;; Alternative: consult-flycheck
	   ("M-g g" . consult-goto-line)             ;; orig. goto-line
	   ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
	   ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
	   ("M-g m" . consult-mark)
	   ("M-g k" . consult-global-mark)
	   ("M-g i" . consult-imenu)
	   ("M-g I" . consult-imenu-multi)
	   ;; M-s bindings (search-map)
	   ("M-s d" . consult-find)
	   ("M-s D" . consult-locate)
	   ("M-s g" . consult-grep)
	   ("M-s G" . consult-git-grep)
	   ("M-s r" . consult-ripgrep)
	   ("M-s l" . consult-line)
	   ("M-s L" . consult-line-multi)
	   ("M-s m" . consult-multi-occur)
	   ("M-s k" . consult-keep-lines)
	   ("M-s u" . consult-focus-lines)
	   ;; Isearch integration
	   ("M-s e" . consult-isearch-history)
	   :map isearch-mode-map
	   ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
	   ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
	   ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
	   ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
	   ;; Minibuffer history
	   :map minibuffer-local-map
	   ("M-s" . consult-history)                 ;; orig. next-matching-history-element
	   ("M-r" . consult-history))                ;; orig. previous-matching-history-element

    ;; Enable automatic preview at point in the *Completions* buffer. This is
    ;; relevant when you use the default completion UI.
    :hook (completion-list-mode . consult-preview-at-point-mode)

    ;; The :init configuration is always executed (Not lazy)
    :init

    ;; Optionally configure the register formatting. This improves the register
    ;; preview for `consult-register', `consult-register-load',
    ;; `consult-register-store' and the Emacs built-ins.
    (setq register-preview-delay 0.5
	  register-preview-function #'consult-register-format)

    ;; Optionally tweak the register preview window.
    ;; This adds thin lines, sorting and hides the mode line of the window.
    (advice-add #'register-preview :override #'consult-register-window)

    ;; Use Consult to select xref locations with preview
    (setq xref-show-xrefs-function #'consult-xref
	  xref-show-definitions-function #'consult-xref)

    ;; Configure other variables and modes in the :config section,
    ;; after lazily loading the package.
    :config

    ;; Optionally configure preview. The default value
    ;; is 'any, such that any key triggers the preview.
    ;; (setq consult-preview-key 'any)
    ;; (setq consult-preview-key (kbd "M-."))
    ;; (setq consult-preview-key (list (kbd "<S-down>") (kbd "<S-up>")))
    ;; For some commands and buffer sources it is useful to configure the
    ;; :preview-key on a per-command basis using the `consult-customize' macro.
    (consult-customize
     consult-theme
     :preview-key '(:debounce 0.2 any)
     consult-ripgrep consult-git-grep consult-grep
     consult-bookmark consult-recent-file consult-xref
     consult--source-bookmark consult--source-recent-file
     consult--source-project-recent-file
     :preview-key (kbd "M-."))

    ;; Optionally configure the narrowing key.
    ;; Both < and C-+ work reasonably well.
    (setq consult-narrow-key "<") ;; (kbd "C-+")

    ;; Optionally make narrowing help available in the minibuffer.
    ;; You may want to use `embark-prefix-help-command' or which-key instead.
    ;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

    ;; By default `consult-project-function' uses `project-root' from project.el.
    ;; Optionally configure a different project root function.
    ;; There are multiple reasonable alternatives to chose from.
    ;;;; 1. project.el (the default)
    ;; (setq consult-project-function #'consult--default-project--function)
    ;;;; 2. projectile.el (projectile-project-root)
    ;; (autoload 'projectile-project-root "projectile")
    ;; (setq consult-project-function (lambda (_) (projectile-project-root)))
    ;;;; 3. vc.el (vc-root-dir)
    ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
    ;;;; 4. locate-dominating-file
    ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
  )

;; Use `consult-completion-in-region' if Vertico is enabled.
;; Otherwise use the default `completion--in-region' function.
(setq completion-in-region-function
      (lambda (&rest args)
        (apply (if vertico-mode
                   #'consult-completion-in-region
                 #'completion--in-region)
               args)))

(use-package rustic
  :ensure t
  :config
  (setq rustic-format-on-save t))

(setq visible-bell 1)

;; No lock files, because two users will never work on same file
(setq create-lockfiles nil)

(defvar --backup-directory (concat user-emacs-directory "backups"))
(if (not (file-exists-p --backup-directory))
        (make-directory --backup-directory t))
(setq backup-directory-alist `(("." . ,--backup-directory)))
(setq make-backup-files t               ; backup of a file the first time it is saved.
      backup-by-copying t               ; don't clobber symlinks
      version-control t                 ; version numbers for backup files
      delete-old-versions t             ; delete excess backup files silently
      delete-by-moving-to-trash t
      kept-old-versions 6               ; oldest versions to keep when a new numbered backup is made (default: 2)
      kept-new-versions 9               ; newest versions to keep when a new numbered backup is made (default: 2)
      auto-save-default t               ; auto-save every buffer that visits a file
      auto-save-timeout 20              ; number of seconds idle time before auto-save (default: 30)
      auto-save-interval 200            ; number of keystrokes between auto-saves (default: 300)
      )

(setq utf-translate-cjk-mode nil) ; disable CJK coding/encoding (Chinese/Japanese/Korean characters)
  (set-language-environment 'utf-8)
  (setq locale-coding-system 'utf-8)
  (set-default-coding-systems 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (unless (eq system-type 'windows-nt)
  (set-selection-coding-system 'utf-8))
  (prefer-coding-system 'utf-8)

(setq warning-minimum-level :error)

(menu-bar-mode -1)  
(tool-bar-mode -1)
(setq inhibit-startup-screen t)
(setq global-visual-line-mode t)
(setq blink-cursor-mode nil)

;; Update files with last modifed date, when #+lastmod: is available
(setq time-stamp-active t
      time-stamp-start "#\\+lastmod:[ \t]*"
      time-stamp-end "$"
      time-stamp-format "%04Y-%02m-%02d")
(add-hook 'before-save-hook 'time-stamp nil)

(use-package olivetti
  :ensure t
  )

(use-package ace-window
:ensure t
:init
   (global-set-key (kbd "M-o") 'ace-window)
   (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
)

(defun my-minor-modes ()
	"Enables my minor modes"
	(flyspell-mode t)
	(org-bullets-mode t)
	(company-mode t)
	(visual-line-mode t)
	)
(add-hook 'org-mode-hook 'my-minor-modes)


  
  (setq org-agenda-files '("~/org/agenda")) 
  (setq org-directory "~/org/")
  (setq org-html-checkbox-type 'html)
  (use-package org-bullets
    :ensure t
    :diminish org-bullets-mode)

  (setq org-src-tab-acts-natively t)
(setq org-edit-src-content-indentation 0)
  ;; Key binds

  (define-key org-mode-map (kbd "M-[") `org-backward-paragraph)
  (define-key org-mode-map (kbd "M-]") `org-forward-paragraph)
  (define-key org-mode-map (kbd "M-,") `org-previous-visible-heading)
  (define-key org-mode-map (kbd "M-.") `org-next-visible-heading)
  (define-key org-mode-map (kbd "C-c s") `org-insert-subheading)
  (global-set-key (kbd "C-c a") 'org-agenda)

(tab-bar-mode 1)

(use-package yasnippet
    :ensure t
    )
(eval-after-load 'yasnippet
  '(yas-global-mode))

  (setq yas-snippet-dirs
	'("~/.emacs.d/snippets"
	  ))

;;(load-theme 'misterioso t)
(use-package doom-themes
:ensure t
:config
;; Global settings (defaults)
(setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
      doom-themes-enable-italic t) ; if nil, italics is universally disabled
(load-theme 'doom-snazzy t)

;; Enable flashing mode-line on errors
(doom-themes-visual-bell-config)
(doom-themes-org-config))

;; (use-package format-all
;;   :ensure t
;;   )
;; (add-hook 'prog-mode-hook 'format-all-mode)

(use-package prettier-js
  :ensure t
  :init
  (add-hook 'js-mode-hook  'prettier-js-mode)
)

(use-package flycheck
    :ensure t
    :hook ((flycheck-mode . flymake-mode-off))
    :init (global-flycheck-mode))


    (use-package lsp-mode
     :ensure t
     :init
     ;; set prefix for lsp-command-kepmap
     (setq lsp-keymap-prefix "C-c l")
     :hook (
	     (csharp-mode . lsp)
	     (python-mode . lsp)
	     (typescript-mode . lsp)
	     (javascript-mode . lsp)
	     (js-mode . lsp)
	     (lsp-mode . lsp-enable-which-key-integration))
     :commands lsp)

    (use-package lsp-ui
      :ensure t
      :commands (lsp-ui-mode)
    ;;  :custom
      ;; Sideline
      ;; (lsp-ui-sideline-show-diagnostics t)
      ;; (lsp-ui-sideline-show-hover nil)
      ;; (lsp-ui-sideline-show-code-actions nil)
      ;; (lsp-ui-sideline-update-mode 'line)
      ;; (lsp-ui-sideline-delay 0)
      ;; ;; Peek
      ;; (lsp-ui-peek-enable t)
      ;; (lsp-ui-peek-show-directory nil)
      ;; ;; Documentation
      ;; (lsp-ui-doc-enable t)
      ;; (lsp-ui-doc-position 'at-point)
      ;; (lsp-ui-doc-delay 0.2)
      ;; ;; IMenu
      ;; (lsp-ui-imenu-window-width 0)
      ;; (lsp-ui-imenu--custom-mode-line-format nil)
      :hook (lsp-mode . lsp-ui-mode))


    (use-package which-key
      :ensure t
       :config
       (which-key-mode))

(use-package python-mode
  :hook
  (python-mode . pyvenv-mode)
  (python-mode . flycheck-mode)
  ;;(python-mode . blacken-mode)
  :custom
  ;; NOTE: Set these if Python 3 is called "python3" on your system!
  (python-shell-interpreter "python3")
  :config
  )

(use-package lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp))))  ; or lsp-deferred

(use-package pyvenv
  :ensure t
  :init
 ;; (setenv "WORKON_HOME" "~/.venv/")
  :config
  ;; (pyvenv-mode t)

  ;; Set correct Python interpreter
  (setq pyvenv-post-activate-hooks
        (list (lambda ()
                (setq python-shell-interpreter (concat pyvenv-virtual-env "bin/python")))))
  (setq pyvenv-post-deactivate-hooks
        (list (lambda ()
                (setq python-shell-interpreter "python3")))))

;; (use-package blacken
;;   :init
;;   (setq-default blacken-fast-unsafe t)
;;   (setq-default blacken-line-length 80)
;;   )

(require 'web-mode)
   (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
   (add-to-list 'auto-mode-alist '("\\.cshtml?\\'" . web-mode))
   (add-to-list 'auto-mode-alist '("\\.svelte?\\'" . web-mode))
   (add-to-list 'auto-mode-alist '("\\.j2?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
 (setq web-mode-engines-alist
       '(("razor"    . "\\.cshtml\\'")
	 ("blade"  . "\\.blade\\.")
	 ("svelte" . "\\.svelte\\.")
	 ("django" . "\\.j2\\.")
 ))
 (add-hook 'web-mode-hook
            (lambda ()
              (when (string-equal "tsx" (file-name-extension buffer-file-name))
                (setup-tide-mode))))

(use-package tide :ensure t)
  (use-package company :ensure t)
  (use-package flycheck :ensure t)
(flycheck-add-mode 'typescript-tslint 'web-mode)
  (defun setup-tide-mode ()
    (interactive)
    (tide-setup)
    (flycheck-mode +1)
    (setq flycheck-check-syntax-automatically '(save mode-enabled))
    (eldoc-mode +1)
    (tide-hl-identifier-mode +1)
    ;; company is an optional dependency. You have to
    ;; install it separately via package-install
    ;; `M-x package-install [ret] company`
    (company-mode +1))

  ;; aligns annotation to the right hand side
  (setq company-tooltip-align-annotations t)

  ;; formats the buffer before saving
  (add-hook 'before-save-hook 'tide-format-before-save)

  (add-hook 'typescript-mode-hook #'setup-tide-mode)

(use-package projectile
:ensure t
:init
(projectile-mode +1)
:bind (:map projectile-mode-map
            ("s-p" . projectile-command-map)
            ("C-c p" . projectile-command-map)))

(use-package ace-window
:ensure t
:init
   (global-set-key (kbd "M-o") 'ace-window)
   (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
)

(use-package dashboard
    :ensure t
    :diminish dashboard-mode
    :config
    (setq dashboard-banner-logo-title "Nil sin Labour")
    (setq dashboard-startup-banner "~/.emacs.d/logo.png.fix")
    (setq dashboard-items '((recents  . 5)
			    (bookmarks . 5)
			    (projects . 5)
			    (agenda . 5)
			    (registers . 5)))
    (dashboard-setup-startup-hook))

(recentf-mode 1)
(setq recentf-max-menu-items 25)
(setq recentf-max-saved-items 25)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)

(use-package which-key
 :ensure t
 :config
 (which-key-mode))

(use-package company
:ensure t
:config
(company-mode))

(defun aqr-search-from-begining ()
"Go to the begining of the file and search from there"
(interactive)
(goto-char (point-min))
(isearch-forward)
)

(progn
    ;; Map for killing things
    (define-prefix-command 'aqr-kill-map)
    (define-key aqr-kill-map (kbd "k") 'kill-whole-line)
    (define-key aqr-kill-map (kbd "l") 'kill-line)
    (define-key aqr-kill-map (kbd "m") 'avy-kill-region)
    (global-set-key (kbd "C-k") 'aqr-kill-map))



  (define-prefix-command 'aqr-map)
  (global-set-key (kbd "`") 'aqr-map)
  (define-key aqr-map (kbd "s") 'aqr-search-from-begining)
  (define-key aqr-map (kbd "f") 'projectile-find-file)
  (define-key aqr-map (kbd "p") 'projectile-switch-project)
  (define-key aqr-map (kbd "a") 'avy-goto-char-timer)
  (define-key aqr-map (kbd "`") (lambda () (interactive) (insert "`")))

;;(define-key aqr-map (kbd "k") 'kill-whole-line)
;; Use C-o for open new line below and C-O for above
(global-set-key (kbd "C-o") (kbd "C-e RET"))
  (global-set-key (kbd "C-S-o") (kbd "C-a RET C-p"))

  (global-set-key (kbd "M-[") `backward-paragraph)
  (global-set-key (kbd "M-]") `forward-paragraph)
  (use-package expand-region
    :ensure t
    :bind
    ("C-=" . er/expand-region)
    ("C--" . er/contract-region))
  (global-set-key (kbd "C-+") (lambda () (interactive) (message "Use C-= you idiot")))

(use-package key-chord
:ensure t
:init
   (key-chord-mode 1)
)


(key-chord-define-global "df" 'aqr-map)
(key-chord-define-global "qw" 'ace-window )
(key-chord-define-global "cx" 'isearch-forward)

;; (defun aqr-python-format-before-save ()
;;   "Format the file with black before saving it."
;;   (when (eq major-mode 'python-mode)
;;     (shell-command-to-string (format "black %s" buffer-file-name)

;; (add-hook 'before-save-hook #'aqr-python-format-before-save)
