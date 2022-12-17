;; Author: Stephen Czekalski
;; Date: December 2022

;;
;;
;;
;; Third-Party Package Configuration
;;
;;
;;

;; Install and Configure Melpa
(require 'package)
(add-to-list 'package-archives
	     '("melpa-stable" . "https://stable.melpa.org/packages/") t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(s projectile use-package evil)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(linum ((t (:background "black" :foreground "#F00")))))

(use-package s
  :ensure t)

;; Configure Evil
(use-package evil
  :ensure t
  :init
  (evil-mode 1)
  :config
  (define-key evil-motion-state-map "j" 'evil-next-visual-line)
  (define-key evil-motion-state-map "k" 'evil-previous-visual-line)
  (define-key evil-visual-state-map "j" 'evil-next-visual-line)
  (define-key evil-visual-state-map "k" 'evil-previous-visual-line))

;; Configure Projectile
(use-package projectile
  :ensure t
  :init
  (projectile-global-mode +1))
  :config
  (define-key projectile-mode-map (kbd "C-x p") 'projectile-command-map)


;;
;;
;;
;; writer-vision-mode
;;
;;
;;

(defgroup writer-vision-group nil
  "Group for customization for writer-vision-mode"
  :prefix "writer-vision-")

(defface writer-vision-punc-face
  '((t :inherit (default)
       :foreground "#F00"))
  "A face for punctuation highlighting"
  :group 'writer-vision-group)

(defface writer-vision-weak-face
  '((t :inherit (default)
       :foreground "#FF0"))
  "A face for highlighting potentially weak language"
  :group 'writer-vision-group)

(defface writer-vision-dialogue-face
  '((t :inherit (default)
       :foreground "#0F0"))
  "A face for dialogue highlighting"
  :group 'writer-vision-group)

(defvar writer-vision-keywords
  '(
    ("\\(\".*?\"\\)" . 'writer-vision-dialogue-face)
    ("[!@#$%&*,<>/?;:.-]" . 'writer-vision-punc-face)
    ("\\b\\(thing\\)\\b\\|\\b\\(got\\)\\b\\|\\b\\(just\\)\\b\\|\\b\\(very\\)\\b\\|\\b\\w*\\(ly\\)\\b" . 'writer-vision-weak-face)
  )
  "Keywords for writer-vision-mode")

(define-minor-mode writer-vision-mode
  "A minor mode for syntax highlighting for writers."
  :lighter " writer-vision"
  :group 'writer-vision-group
  (when (bound-and-true-p writer-vision-keywords)
    (font-lock-add-keywords nil writer-vision-keywords)
    (font-lock-fontify-buffer))
  (when (not (bound-and-true-p writer-vision-keywords))
    (font-lock-remove-keywords keywords)
    (font-lock-fontify-buffer)))

(provide 'writer-vision-mode)

;;
;;
;;
;; Configure linum-mode
;;
;;
;;

(setq reading-wpm 230)
(setq linum-time-mode 0)

(defface word-count-face
  `((t :inherit 'linum
       :background "#102235"
       :foreground "#FBFF8A"))
  "Face for word count"
  :group 'linum)

;; Gets the time in minutes it would take the
;; average reader to reader the passed in number
;; of words.
(defun get-read-time (words)
  (/ (float words) (float reading-wpm)))


(defun get-formatted-read-time (words)
  (setq time (get-read-time words))
  (cond ((< time 1.0) (concat (number-to-string (* 60.0 time )) " sec"))
	((>= time 1.0) (concat (number-to-string time) " min"))))

;; Gets the text at the passed in line number
(defun get-nth-line (number)
  "Get line with number"
  (save-restriction
    (widen)
    (save-excursion
      (goto-line number)
      (buffer-substring-no-properties
       (line-beginning-position)
       (line-end-position)))))

;; Counts the number of words in line of the
;; passed in line number
(defun count-words-in-line (line)
  (setq count (s-count-matches "\\b\\w+\\b" (get-nth-line line)))
  (if (>= linum-time-mode 1) 
  (cond ((< count 0) "")
	((> count 0)
	 (propertize
	  (concat " " (get-formatted-read-time count))
	  'face 'word-count-face
	  ))))

  (if (<= linum-time-mode 0) 
  (cond ((< count 0) "")
	((> count 0)
	 (propertize
	  (concat " " (number-to-string count))
	  'face 'word-count-face
	  )))))

;; Linum now displays word count
(setq linum-format (lambda (line) (count-words-in-line line)))

;;
;;
;;
;; Generic Configuration
;;
;;
;;

;; Turn of the annoying ass bell
(setq ring-bell-function 'ignore)

;; Disable menu bar, toolbar, and scrollbar
(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)

;; Turn off startup screen
(setq inhibit-startup-screen t)

;; For windows, set default directory to the desktop
(setq default-directory "~/.emacs/")

;; Set Monokai as default theme
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(load-theme 'underwater t)

;; Set font and font size
(set-frame-font "Courier Prime 10" nil t)
;;(set-frame-font "Fira Code 10" nil t)

(defun enable-writing-minor-modes ()
  (text-mode 1)
  (writer-vision-mode 1)
  (visual-line_mode 1))

;; Associate some file extensions with text-mode
(add-to-list 'auto-mode-alist '("\\.txt\\'" . text-mode))
(add-to-list 'auto-mode-alist '("\\.text\\'" . text-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . text-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . text-mode))

(add-hook 'text-mode-hook 'writer-vision-mode)
(add-hook 'text-mode-hook 'visual-line-mode)
(add-hook 'text-mode-hook 'linum-mode)

;; Add keybinding for word count
(global-set-key (kbd "C-c w") 'count-words)




