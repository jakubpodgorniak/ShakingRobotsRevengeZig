(tool-bar-mode -1)
(load-theme 'tsdh-dark t)
(set-frame-font "Roboto Mono" nil t)
(setq column-number-mode t)
(global-display-line-numbers-mode)

(setq make-backup-files nil) ; stop creating ~ files

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)
(package-refresh-contents)

(progn
  (package-initialize)
  (require 'lsp-mode)
  (define-key lsp-mode-map (kbd "C-c C-l") lsp-command-map)
  (switch-to-buffer "lsp-check")
  (zig-mode)
  (lsp-mode))

(if (>= emacs-major-version 28)
    (add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)
  (progn
    (defun colorize-compilation-buffer ()
      (let ((inhibit-read-only t))
        (ansi-color-apply-on-region compilation-filter-start (point))))
    (add-hook 'compilation-filter-hook 'colorize-compilation-buffer)))

(define-key lsp-mode-map (kbd "C-c C-l") lsp-command-map)

(defun move-line-up ()
  (interactive)
  (transpose-lines 1)
  (forward-line -2))

(defun move-line-down ()
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1))

(global-set-key (kbd "M-<up>") 'move-line-up)
(global-set-key (kbd "M-<down>") 'move-line-down)
