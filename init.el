;; (load-file "~/.emacs.d/package.el")

(load-file "~/.emacs.d/keywiz.el")

(add-hook 'after-init-hook 'ido-mode)
;;(require 'package)			

(require 'package)
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))
(package-initialize)

(add-to-list 'Info-default-directory-list "~/.emacs.d/elpa")

;; Smex

(add-to-list 'load-path "~/.emacs.d/smex")

(require 'smex)

(global-set-key [(meta x)] (lambda ()
                             (interactive)
                             (or (boundp 'smex-cache)
                                 (smex-initialize))
                             (global-set-key [(meta x)] 'smex)
                             (smex)))

(global-set-key [(shift meta x)] (lambda ()
                                   (interactive)
                                   (or (boundp 'smex-cache)
                                       (smex-initialize))
                                   (global-set-key [(shift meta x)] 'smex-major-mode-commands)
                                   (smex-major-mode-commands)))

(defadvice smex (around space-inserts-hyphen activate compile)
  (let ((ido-cannot-complete-command
         `(lambda ()
            (interactive)
            (if (string= " " (this-command-keys))
                (insert ?-)
              (funcall ,ido-cannot-complete-command)))))
    ad-do-it))


(defun iwb ()
  "indent whole buffer"
  (interactive)
  (delete-trailing-whitespace)
  (indent-region (point-min) (point-max) nil)
  (untabify (point-min) (point-max)))

(global-set-key [C-tab] 'iwb)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(TeX-PDF-mode t)
 '(custom-safe-themes
   (quote
    ("5c0e769024ee7f144c288e8397f1f0325e3aa78c0f60268675165a10d4dad8f8" "6335eec7e785c6164a1cf63a34613e3b640a7db3d06b37a1cd145e24d054e7bc" "a874b8ea34cc007dd3f91f1133f9c072e2d402c08cce2ec79dab50846d312910" "490016b5303e2c1efa25479652d19a2b0c954c0062028a467eeab7a90bad8cfc" "dbd0b6ed94c4c91c24cb55c283f23ccb17a38bd4e3f56be9ea68c1dd5d050558" "d3a3e2e7b4c7fa92ea02926f2d6b92de820a63710a3a392c9cebde8a1f0a277b" "1546189f0f232f48d32cd9baac67baa4fe94bfc31b53a142b426ce5b0d1c0d9b" "bf53e00050ceb46f04b08d3bb47905e32d9dc5680c004cd44f1e033be8e4b3b5" default)))
 '(inhibit-startup-screen t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(load-file "~/.emacs.d/web-mode/web-mode.el")
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.jsp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tmpl\\'" . web-mode))

(setq web-mode-engines-alist
      '(("php" . "\\.phtml\\'") ("blade" . "\\.blade\\."))
      )

;; Magit

(add-to-list 'load-path "~/.emacs.d/git-modes")
(add-to-list 'load-path "~/.emacs.d/magit")

(require 'magit)
(global-set-key (kbd "C-x M-g") 'magit-status)

;; Markdown Mode

(add-to-list 'load-path "~/.emacs.d/markdown-mode")

(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

(ispell-change-dictionary "english")

(add-to-list 'magic-mode-alist
             `(,(lambda ()
                  (and (string= (file-name-extension buffer-file-name) "h")
                       (re-search-forward "@\\<interface\\>"
                                          magic-mode-regexp-match-limit t)))
               . objc-mode))

(defun objc-in-header-file ()
  (let* ((filename (buffer-file-name))
         (extension (car (last (split-string filename "\\.")))))
    (string= "h" extension)))

(defun objc-jump-to-extension (extension)
  (let* ((filename (buffer-file-name))
         (file-components (append (butlast (split-string filename
                                                         "\\."))
                                  (list extension))))
    (find-file (mapconcat 'identity file-components "."))))

;;; Assumes that Header and Source file are in same directory
(defun objc-jump-between-header-source ()
  (interactive)
  (if (objc-in-header-file)
      (objc-jump-to-extension "m")
    (objc-jump-to-extension "h")))

(defun objc-mode-customizations ()
  (define-key objc-mode-map (kbd "C-c t") 'objc-jump-between-header-source))

(add-hook 'objc-mode-hook 'objc-mode-customizations)

(load-file "~/.emacs.d/abc-mode/abc-mode.el")
(add-to-list 'auto-mode-alist '("\\.abc\\'" . abc-mode))

;; AUCTeX

(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq-default TeX-master nil)

(add-hook 'LaTeX-mode-hook 'visual-line-mode)
(add-hook 'LaTeX-mode-hook 'flyspell-mode)
(add-hook 'LaTeX-mode-hook 'LaTeX-math-mode)

(add-hook 'LaTeX-mode-hook 'turn-on-reftex)
(setq reftex-plug-into-AUCTeX t)

;; Rinari

(add-to-list 'load-path "~/.emacs.d/rinari")

;; Lilypond

(load-file "~/.emacs.d/lilypond-init.el")
(autoload 'LilyPond-mode "lilypond-mode")
(setq auto-mode-alist
      (cons '("\\.ly$" . LilyPond-mode) auto-mode-alist))

(add-hook 'LilyPond-mode-hook (lambda () (turn-on-font-lock)))
(setq magit-last-seen-setup-instructions "1.4.0")
