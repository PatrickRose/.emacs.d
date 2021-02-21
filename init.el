(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(TeX-PDF-mode t)
 '(custom-safe-themes
   (quote
    ("59f42f7028e0cf1d8d6a7bc172dc37da64e4cd11fd29cf03c6ca950451cc2a00" "5c0e769024ee7f144c288e8397f1f0325e3aa78c0f60268675165a10d4dad8f8" "6335eec7e785c6164a1cf63a34613e3b640a7db3d06b37a1cd145e24d054e7bc" "a874b8ea34cc007dd3f91f1133f9c072e2d402c08cce2ec79dab50846d312910" "490016b5303e2c1efa25479652d19a2b0c954c0062028a467eeab7a90bad8cfc" "dbd0b6ed94c4c91c24cb55c283f23ccb17a38bd4e3f56be9ea68c1dd5d050558" "d3a3e2e7b4c7fa92ea02926f2d6b92de820a63710a3a392c9cebde8a1f0a277b" "1546189f0f232f48d32cd9baac67baa4fe94bfc31b53a142b426ce5b0d1c0d9b" "bf53e00050ceb46f04b08d3bb47905e32d9dc5680c004cd44f1e033be8e4b3b5" default)))
 '(git-commit-fill-column 70)
 '(inhibit-startup-screen t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(when (display-graphic-p) (load-theme 'earthsong))

;; (load-file "~/.emacs.d/package.el")

(add-hook 'after-init-hook 'ido-mode)
(require 'cl)
(require 'package)
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("melpa" . "http://melpa.org/packages/")))

(add-to-list 'Info-default-directory-list "~/.emacs.d/elpa")

(setq prelude-packages
      '(smex web-mode markdown-mode less-css-mode scss-mode csharp-mode rust-mode abc-mode rinari auctex magit cargo company-php company groovy-mode org feature-mode
             )
      )

(package-initialize)

(defun require-package (package)
  "Install given PACKAGE if it was not installed before."
  (if (package-installed-p package)
      t
    (progn
      (unless (assoc package package-archive-contents)
        (package-refresh-contents))
      (package-install package))))

(dolist
    (p prelude-packages)
  (require-package p)
  )

;; Smex
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

(require 'company)
;; Web mode
(add-hook 'web-mode-hook  '(lambda ()
                             (require 'company-php)
                             (company-mode t)
                             (add-to-list 'company-backends 'company-ac-php-backend )))
;; (add-to-list 'company-dabbrev-code-modes 'web-mode)
(add-hook 'web-mode-hook  '(lambda ()
                             (setq indent-tabs-mode t)
                             (web-mode-use-tabs)))

(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.jsp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tmpl\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html\.*\\'" . web-mode))
(setq web-mode-engines-alist
      '(("php" . "\\.phtml\\'") ("blade" . "\\.blade\\.") ("php" . "\\.html\.*\\'"))
      )

;; Magit
(global-set-key (kbd "C-x M-g") 'magit-status)

;; Markdown Mode
(autoload 'markdown-mode "markdown-mode"
  "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.text\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

(add-hook 'markdown-mode-hook 'visual-line-mode)
(add-hook 'markdown-mode-hook 'flyspell-mode)

(ispell-change-dictionary "english")

(add-to-list 'magic-mode-alist
             `(,(lambda ()
                  (and (string= (file-name-extension (if buffer-file-name buffer-file-name "test")) "h")
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

;; Lilypond
(load-file "~/.emacs.d/lilypond-init.el")
(autoload 'LilyPond-mode "lilypond-mode")
(setq auto-mode-alist
      (cons '("\\.ly$" . LilyPond-mode) auto-mode-alist))

(add-hook 'LilyPond-mode-hook (lambda () (turn-on-font-lock)))
(setq magit-last-seen-setup-instructions "1.4.0")

;; CSharp Mode

;; Sass
(add-to-list 'auto-mode-alist '("\\.scss\\'" . scss-mode))

;; Less
(add-to-list 'auto-mode-alist '("\\.less\\'" . less-css-mode))

;; Turn off the stupid beeping
(setq ring-bell-function 'ignore)

(fset 'delete-buffer-contents
      (lambda (&optional arg) "Keyboard macro." (interactive "p") (kmacro-exec-ring-item (quote ([24 104 134217848 100 101 108 101 tab 114 tab 103 tab return] 0 "%d")) arg)))

(global-set-key (kbd "C-x C-k C-b") 'delete-buffer-contents)

;; Po mode
(load-file "~/.emacs.d/start-po.el")
(load-file "~/.emacs.d/po-mode.el")
(load-file "~/.emacs.d/po-compat.el")

;; Rust mode
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))
(add-hook 'rust-mode-hook 'cargo-minor-mode)
(setq-default indent-tabs-mode nil)

;; Groovy
;; Never write groovy at home, so we should insert tabs in groovy mode
(add-hook 'groovy-mode-hook  '(lambda ()
                                (setq indent-tabs-mode t)
                                ))

(add-to-list 'auto-mode-alist '("\\.groovy\\'" . groovy-mode))
(add-to-list 'auto-mode-alist '("\\Jenkinsfile\\'" . groovy-mode))
(add-to-list 'auto-mode-alist '("\\composer.lock\\'" . js-mode))
(add-to-list 'auto-mode-alist '("\\bash-fc\\'" . sh-mode))

(setq-default tab-width 4)
(setq-default c-basic-offset 4)

(defun add-brief-helper ()
  (interactive)
  (insert "1. Background
 - What the system does now
 - Are there any manual processes
2. Aim/business case
 - what the issue is trying to achieve
 - why are we bothering
 - e.g. automate process X which all trusts spend n minutes doing a week or allow role A access to B to save going via person C
 - not e.g. \"add field X to report Y\" but \"Add field X to report Y so that recruitment can show the head nurse that some time is waiting for managers to do something\"
3. Outline requirements & scope
 - e.g. \"Record the date X happens and the person who made it happen\"
 - e.g. \"Send chasers in the morning, give users time to respond and don't chase more than two or three times\"
4. Any permissions/roles that are relevant
5. Any assumptions
6. Are there other devs this is linked to, are they being considered with this, is this an alternative, is this a quickfix for now.
7. Ballpark time estimate
8. Any other resources e.g. SSL certs, sysadmin time, postcode files
9. An executive summary, summarising relevant parts of the above"))

(defun add-infosec-helper ()
  (interactive)
  (insert "h1. Info sec
|| When | |
||Who discovered |  |
|| Systems affected | |
|| Who has been informed | |
|| Actions taken so far |  |"))

(defun add-estimates-helper ()
  (interactive)
  (insert "|| Stage || Amount ||
| Planning | |
| Implementation | |
| Review | |
| Internal Testing | |
|| Subtotal | |
| Contingency | |
|| Total || ||"))

(defun jira-mode ()
  (interactive)
  (flyspell-mode)
  (visual-line-mode)
  (local-set-key (kbd "C-c C-j C-b") 'add-brief-helper)
  (local-set-key (kbd "C-c C-j C-i") 'add-infosec-helper)
  (local-set-key (kbd "C-c C-j C-e") 'add-estimates-helper)
  )


;;  Org mode
(define-key global-map (kbd "C-c l") 'org-store-link)
(define-key global-map (kbd "C-c a") 'org-agenda)

(require 'org)
(setq org-agenda-files (list "~/org/work.org"))
(add-hook 'org-mode-hook 'visual-line-mode)
(add-hook 'org-mode-hook 'org-indent-mode)

(defun feature-add-keyword (keyword)
  (indent-new-comment-line)
  (insert keyword)
  (indent-according-to-mode)
  )

(defun feature-add-given ()
  (interactive)
  (feature-add-keyword "Given")
  )


(defun feature-add-when ()
  (interactive)
  (feature-add-keyword "When")
  )

(defun feature-add-and ()
  (interactive)
  (feature-add-keyword "And")
  )

(defun feature-add-but ()
  (interactive)
  (feature-add-keyword "But")
  )

(defun feature-add-then ()
  (interactive)
  (feature-add-keyword "Then")
  )

(defun feature-add-scenario ()
  (interactive)
  (indent-new-comment-line)
  (feature-add-keyword "Scenario:")
  )

(defun feature-add-feature ()
  (interactive)
  (feature-add-keyword "Feature:")
  )

(defun feature-add-scenario-outline ()
  (interactive)
  (indent-new-comment-line)
  (feature-add-keyword "Scenario Outline:")
  )

(defun feature-add-examples ()
  (interactive)
  (indent-new-comment-line)
  (feature-add-keyword "Examples:")
  (indent-new-comment-line)
  (insert "||")
  (backward-char)
  )

(add-hook 'feature-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c i g") 'feature-add-given)
            (local-set-key (kbd "C-c i w") 'feature-add-when)
            (local-set-key (kbd "C-c i a") 'feature-add-and)
            (local-set-key (kbd "C-c i b") 'feature-add-but)
            (local-set-key (kbd "C-c i t") 'feature-add-then)
            (local-set-key (kbd "C-c i s") 'feature-add-scenario)
            (local-set-key (kbd "C-c i f") 'feature-add-feature)
            (local-set-key (kbd "C-c i o") 'feature-add-scenario-outline)
            (local-set-key (kbd "C-c i e") 'feature-add-examples)
            )
          )
