;;; package --- Summary:
;;; Commentary:
;;; Code:
(use-package org
  :ensure t
  :mode ("\\.org\\'" . org-mode)
  :init (progn
	  (add-hook 'org-src-mode-hook 'samray/disable-flycheck-in-org-src-block)
	  )
  :config(progn
	   (setq org-todo-keyword-faces
		 '(
		   ("PROCESSING" . (:foreground "gold" :weight bold))
		   ))
	   (setq org-todo-keywords
		 '((sequence "TODO" "PROCESSING" "DONE")))
	   (setq org-priority-faces '((?A . (:foreground "red" :weight 'bold))
				      (?B . (:foreground "blue"))
				      (?C . (:foreground "green"))))
	   (defun samray/org-skip-subtree-if-priority (priority)
	     "Skip an agenda subtree if it has a priority of PRIORITY.
PRIORITY may be one of the characters ?A, ?B, or ?C."
	     (let ((subtree-end (save-excursion (org-end-of-subtree t)))
		   (pri-value (* 1000 (- org-lowest-priority priority)))
		   (pri-current (org-get-priority (thing-at-point 'line t))))
	       (if (= pri-value pri-current)
		   subtree-end
		 nil)))
	   (with-eval-after-load 'org
	     (setq org-agenda-files '("~/SyncDirectory/Org/agenda.org" "~/SyncDirectory/Org/todo.org"))
	     (setq org-agenda-custom-commands
		   '(("c" "agenda view with alltodo sorted by priorities"
		      ((tags "PRIORITY=\"A\""
			     ((org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
			      (org-agenda-overriding-header "High-priority unfinished tasks:")))
		       (agenda "")
		       (alltodo ""
				((org-agenda-skip-function
				  '(or (samray/org-skip-subtree-if-priority ?A)
				       (org-agenda-skip-if nil '(scheduled deadline))))))))))
	     ;;each time you turn an entry from a TODO (not-done) state
	     ;;into any of the DONE states, a line ‘CLOSED: [timestamp]’ will
	     ;;be inserted just after the headline
	     (setq org-log-done 'time)
	     (setq org-capture-templates
		   '(("a" "Agenda" entry (file  "~/SyncDirectory/Org/agenda.org" "Agenda")
		      "* TODO %?\n:PROPERTIES:\n\n:END:\nDEADLINE: %^T \n %i\n")
		     ("n" "Note" entry (file+headline "~/SyncDirectory/Org/notes.org" "Notes")
		      "* Note %?\n%T")
		     ("l" "Link" entry (file+headline "~/SyncDirectory/Org/links.org" "Links")
		      "* %? %^L %^g \n%T" :prepend t)
		     ("b" "Blog idea" entry (file+headline "~/SyncDirectory/Org/blog.org" "Blog Topics:")
		      "* %?\n%T" :prepend t)
		     ("t" "To Do Item" entry (file+headline "~/SyncDirectory/Org/todo.org" "To Do Items")
		      "* TODO  %?\n  %i\n" :prepend t)
		     ("j" "Journal" entry (file+datetree "~/SyncDirectory/Org/journal.org")
		      "* %?\nEntered on %U\n  %i\n  %a")
		     ))
	     ;;GUI Emacs could display image.But if the image is too large,
	     ;;it works so weird
	     (setq org-image-actual-width '(500))
	     ;; make sure org-mode syntax highlight source code
	     ;; Make TAB act as if it were issued in a buffer of the
	     ;;language’s major mode.
	     (setq org-src-fontify-natively t
		   org-src-tab-acts-natively t)
	     ;; When editing a code snippet,use the current window rather than
	     ;; popping open a new one
	     (setq org-src-window-setup 'current-window)
	     ;; I like seeing a little downward-pointing arrow instead of the
	     ;;usual ellipsis (...) that org displays when there’s stuff under
	     ;; a header.
             (setq org-ellipsis "⤵")
             ;; automatically open your agenda when start Emacs
             (org-agenda nil "c")
             ;;Its default value is (ascii html icalendar latex)
             (setq org-export-backends '(latex icalendar))
             ;; Show org-edit-special in the other-window
             (setq org-src-window-setup 'other-window)
             (setq org-latex-pdf-process    '("xelatex -interaction nonstopmode %f"
                                              "xelatex -interaction nonstopmode %f"))
	     (require 'ox-md nil t)
             )
           )
  )

;;; pomodoro tech
(use-package org-pomodoro
  :commands org
  :ensure t)


;;; show org-mode bullets as UTF-8 character
(use-package org-bullets
  :defer t
  :ensure t
  :init (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
  :config (progn
            (setq org-bullets-bullet-list '("☯" "☰" "☱" "☲" "☳" "☴" "☵" "☶" "☷"))
            ))

;; Org extra exports
;; Export to github flavored markdown
(use-package ox-gfm
  :ensure ox-gfm
  )

;;; Export to twitter bootstrap
(use-package ox-twbs
  :ensure ox-twbs
  )

;;; Export to reveal for presentation
(use-package ox-reveal
  :ensure ox-reveal)

(setq org-reveal-root "http://cdn.jsdelivr.net/reveal.js/3.0.0/")
(setq org-reveal-mathjax t)

;;; Syntax Highlight in html file
(use-package htmlize
  :ensure t)

;;; Drag and drop images to org-mode
(use-package org-download
  :ensure t)

;;; 
(use-package org-page
  :ensure t
  :config (progn
            (setq op/repository-directory "~/Documents/Blog" ;;local repo location
                  op/personal-github-link "https://github.com/samrayleung" ;;github link
                  op/site-domain "http://27.122.57.145"
                  op/site-main-title "从Hello World开始"
                  op/theme 'mdo) ;; theme
            (setq op/personal-disqus-shortname "Samray") ; use for disqus comments
            )
  )

(defun org-file-path (filename)
  "Return the absolute address of an org file FILENAME, given its relative name."
  (concat (file-name-as-directory org-directory) filename))

(defun samray/disable-flycheck-in-org-src-block ()
  "Disable emacs-lisp-checkdoc in org-src-mode."
  (setq-local flycheck-disabled-checkers '(emacs-lisp-checkdoc)))
(provide 'init-org)
;;; init-org.el ends here
