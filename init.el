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
 '(package-selected-packages '(wc-mode s magit projectile use-package evil)))
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

(use-package magit
  :ensure t)

(use-package wc-mode
  :ensure t)

;;
;; writer-vision-mode
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
    ("\\b\\(so\\)\\b\\|\\b\\(literally\\)\\b\\|\\b\\(stuff\\)\\b\\|\\b\\(never\\)\\b\\|\\b\\(believe\\)\\b\\|\\b\\(think\\)\\b\\|\\b\\(often\\)\\b\\|\\\b\\(\\)\\b\\|\\b\\(small\\)\\b\\|\\b\\(big\\)\\b\\|\b\\(almost\\)\\b\\|\\b\\(thing\\)\\b\\|\\b\\(got\\)\\b\\|\\b\\(just\\)\\b\\|\\b\\(very\\)\\b\\|\\b\\w*\\(ly\\)\\b" . 'writer-vision-weak-face)
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
;; Configure linum-mode
;;

(setq reading-wpm 230)

(defun change-average-wpm (a)
  (interactive
   (list
    (read-number "New WPM: ")))
  (setq reading-wpm a))

(defface word-count-face
  `((t :inherit 'linum
       :background "#102235"
       :foreground "#FBFF8A"))
  "Face for word count"
  :group 'linum)

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

;; Gets the time in minutes it would take the
;; average reader to reader the passed in number
;; of words.
(defun get-read-time (words)
  (/ (float words) (float reading-wpm)))

;; Returns a string containing the time to read based
;; on a passed in word count.
(defun get-formatted-read-time (words)
  (setq time (get-read-time words))
  (setq seconds_str (concat (number-to-string (truncate (* 60.0 (mod time 1.0)))) "s"))
  (setq minutes_str (concat (number-to-string (truncate time)) "m"))
  (concat minutes_str " : " seconds_str))

	
;; Counts the number of words in line of the
;; passed in line number
(defun get-linum-display-string (line)
  (setq count (s-count-matches "\\b\\w+\\b" (get-nth-line line)))
  (setq time_str (get-formatted-read-time count))
  
  (cond ((< count 0) "")
	((> count 0)
	 (propertize
	  (concat " " (number-to-string count) " (" time_str ")")
	  'face 'word-count-face
	  ))))

;; Linum now displays word count
(setq linum-format (lambda (line) (get-linum-display-string line)))

;;
;; Mode Line Formatting
;;

(setq-default mode-line-format
	      (list
	       "[Buffer: %b"
	       "] "
	       '(:eval
		     (wc-format-modeline-string "[WC: %tw]"))
	       '(:eval (concat
			" [T: " 
			(get-formatted-read-time (+ wc-orig-words wc-words-delta))
			"] "))
	       "<%l:%c>"
		   
	       ))


;;
;; Generic Configuration
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
(setq default-directory "D:/Writing/")

;; Set Monokai as default theme
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(load-theme 'underwater t)

;; Set font and font size
(set-frame-font "Courier Prime 10" nil t)

(defun enable-writing-minor-modes ()
  (text-mode 1)
  (writer-vision-mode 1)
  (visual-line_mode 1))

;; Associate some file extensions with text-mode
(add-to-list 'auto-mode-alist '("\\.txt\\'" . text-mode))
(add-to-list 'auto-mode-alist '("\\.text\\'" . text-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . text-mode))
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . text-mode))

;; Add hooks for additional modes when text mode is
;; activated.
(add-hook 'text-mode-hook 'writer-vision-mode)
(add-hook 'text-mode-hook 'visual-line-mode)
(add-hook 'text-mode-hook 'linum-mode)
(add-hook 'text-mode-hook 'wc-mode)

;; Add keybinding for word count
(global-set-key (kbd "C-c w") 'count-words)




