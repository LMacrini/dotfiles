(setq catppuccin-flavor 'macchiato)
(load-theme 'catppuccin :no-confirm)

(when (display-graphic-p)
    (menu-bar-mode -1)
    (tool-bar-mode -1)
    (scroll-bar-mode -1))

(require 'nerd-icons)
(setq nerd-icons-font-family "FiraCode Nerd Font Mono")

(require 'direnv)
(direnv-mode)

(use-package lsp-mode
  :ensure t
  :hook ((python-mode . lsp)
         (js-mode . lsp)
         (rust-mode . lsp))
  :commands lsp)


(use-package lsp-nix
  :ensure lsp-mode
  :after (lsp-mode)
  :demand t
  :custom
  (lsp-nix-nil-formatter ["nix" "fmt"]))

(use-package nix-mode
  :hook (nix-mode . lsp-deferred)
  :ensure t)

(setq dashboard-banner-logo-title "Welcome to Emacs :3")
(setq dashboard-startup-banner (expand-file-name "./icon.png" user-emacs-directory))
(setq dashboard-center-content t)
(setq dashboard-vertically-center-content t)

(setq dashboard-display-icons-p t)
(setq dashboard-icon-type 'nerd-icons)

(setq dashboard-set-heading-icons t)
(setq dashboard-set-file-icons t)

(setq dashboard-projects-backend 'projectile)

(setq dashboard-items '((recents   . 5)
                        (bookmarks . 5)
                        (projects  . 5)
                        (agenda    . 5)
                        (registers . 5)))

(require 'dashboard)
(dashboard-setup-startup-hook)

(global-set-key (kbd "C-c e") 'eshell)

(require 'projectile)
(setq projectile-search-path '("~/Documents"))
(setq projectile-completion-system 'auto)
(projectile-mode +1)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

(require 'ivy)
(ivy-mode)

(defun meow-setup ()
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-colemak-dh)
  (meow-motion-define-key
   ;; Use e to move up, n to move down.
   ;; Since special modes usually use n to move down, we only overwrite e here.
   '("e" . meow-next)
   '("u" . meow-prev)
   '("n" . meow-left)
   '("i" . meow-right)

   '("j" . meow-search)
   '("/" . meow-visit)
   '("Q" . meow-quit)
   '("<escape>" . ignore))
  (meow-leader-define-key
   '("?" . meow-cheatsheet)
   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument))
  (meow-normal-define-key
   '("0" . meow-expand-0)
   '("1" . meow-expand-1)
   '("2" . meow-expand-2)
   '("3" . meow-expand-3)
   '("4" . meow-expand-4)
   '("5" . meow-expand-5)
   '("6" . meow-expand-6)
   '("7" . meow-expand-7)
   '("8" . meow-expand-8)
   '("9" . meow-expand-9)
   '("'" . meow-reverse)

   ; movement
   '("u" . meow-prev)
   '("e" . meow-next)
   '("n" . meow-left)
   '("i" . meow-right)

   '("j" . meow-search)
   '("/" . meow-visit)

   ; expansion
   '("U" . meow-prev-expand)
   '("E" . meow-next-expand)
   '("N" . meow-left-expand)
   '("I" . meow-right-expand)

   '("l" . meow-back-word)
   '("L" . meow-back-symbol)
   '("y" . meow-next-word)
   '("Y" . meow-next-symbol)

   '("a" . meow-mark-word)
   '("A" . meow-mark-symbol)
   '("r" . meow-line)
   '("R" . meow-goto-line)
   '("w" . meow-block)
   '("q" . meow-join)
   '("Q" . meow-quit)
   '("g" . meow-grab)
   '("G" . meow-pop-grab)
   '("h" . meow-swap-grab)
   '("H" . meow-sync-grab)
   '(";" . meow-cancel-selection)
   '(":" . meow-pop-selection)

   '("c" . meow-till)
   '("x" . meow-find)

   '("," . meow-beginning-of-thing)
   '("." . meow-end-of-thing)
   '("<" . meow-inner-of-thing)
   '(">" . meow-bounds-of-thing)

   ; editing
   '("s" . meow-kill)
   '("t" . meow-change)
   '("b" . meow-delete)
   '("d" . meow-save)
   '("v" . meow-yank)
   '("V" . meow-yank-pop)

   '("f" . meow-insert)
   '("F" . meow-open-above)
   '("p" . meow-append)
   '("P" . meow-open-below)

   '("m" . undo-only)
   '("M" . undo-redo)

   '("z" . open-line)
   '("Z" . split-line)

   '("[" . indent-rigidly-left-to-tab-stop)
   '("]" . indent-rigidly-right-to-tab-stop)

   ; prefix n
   '("<C-c>" . meow-comment)
   '("kb" . meow-start-kmacro-or-insert-counter)
   '("kp" . meow-start-kmacro)
   '("kf" . meow-end-or-call-kmacro)
   ;; ...etc

   ; prefix ;
   '("ot" . save-buffer)
   '("oT" . save-some-buffers)
   '("os" . meow-query-replace-regexp)
   ;; ... etc

   '("<escape>" . ignore)))

(require 'meow)
(meow-setup)
(meow-global-mode 1)
