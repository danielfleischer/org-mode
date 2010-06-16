;;; ob-sqlite.el --- org-babel functions for sqlite database interaction

;; Copyright (C) 2009 Eric Schulte

;; Author: Eric Schulte
;; Keywords: literate programming, reproducible research
;; Homepage: http://orgmode.org
;; Version: 0.01

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Org-Babel support for evaluating sqlite source code.

;;; Code:
(require 'ob)

(org-babel-add-interpreter "sqlite")

(add-to-list 'org-babel-tangle-langs '("sqlite" "sqlite"))

(defun org-babel-expand-body:sqlite
  (body params &optional processed-params) body)

(defvar org-babel-sqlite3-command "sqlite3")

(defun org-babel-execute:sqlite (body params)
  "Execute a block of Sqlite code with org-babel.  This function is
called by `org-babel-execute-src-block'."
  (message "executing Sqlite source code block")
  (let ((result-params (split-string (or (cdr (assoc :results params)) "")))
	(vars (org-babel-ref-variables params)))
    (with-temp-buffer
      (insert
       (shell-command-to-string
	(format "%s -csv %s %S"
		org-babel-sqlite3-command
		(cdr (assoc :db params))
		(org-babel-sqlite-expand-vars body vars))))
      (if (or (member "scalar" result-params)
	      (member "code" result-params))
	  (buffer-string)
	(org-table-convert-region (point-min) (point-max))
	(org-babel-sqlite-table-or-scalar (org-table-to-lisp))))))

(defun org-babel-sqlite-expand-vars (body vars)
  "Expand the variables held in VARS in BODY."
  (mapc
   (lambda (pair)
     (setq body (replace-regexp-in-string
		 (format "\$%s" (car pair))
		 (format "%S" (cdr pair))
		 body)))
   vars)
  body)

(defun org-babel-sqlite-table-or-scalar (result)
  "If RESULT looks like a trivial table, then unwrap it."
  (if (and (equal 1 (length result))
	   (equal 1 (length (car result))))
      (caar result)
    result))

(defun org-babel-prep-session:sqlite (session params)
  "Prepare SESSION according to the header arguments specified in PARAMS."
  (error "sqlite sessions not yet implemented"))

(provide 'ob-sqlite)
;;; ob-sqlite.el ends here
