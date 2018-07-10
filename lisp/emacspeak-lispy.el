;;; emacspeak-lispy.el --- Speech-enable LISPY  -*- lexical-binding: t; -*-
;;; $Author: tv.raman.tv $
;;; Description:  Speech-enable LISPY An Emacs Interface to lispy
;;; Keywords: Emacspeak,  Audio Desktop lispy
;;{{{  LCD Archive entry:

;;; LCD Archive Entry:
;;; emacspeak| T. V. Raman |raman@cs.cornell.edu
;;; A speech interface to Emacs |
;;; $Date: 2007-05-03 18:13:44 -0700 (Thu, 03 May 2007) $ |
;;;  $Revision: 4532 $ |
;;; Location undetermined
;;;

;;}}}
;;{{{  Copyright:

;;;Copyright (C) 1995 -- 2007, 2011, T. V. Raman
;;; Copyright (c) 1994, 1995 by Digital Equipment Corporation.
;;; All Rights Reserved.
;;;
;;; This file is not part of GNU Emacs, but the same permissions apply.
;;;
;;; GNU Emacs is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 2, or (at your option)
;;; any later version.
;;;
;;; GNU Emacs is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNLISPY FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; You should have received a copy of the GNU General Public License
;;; along with GNU Emacs; see the file COPYING.  If not, write to
;;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;;}}}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;{{{  introduction

;;; Commentary:
;;; LISPY ==  smart Navigation Of Lisp code
;;; This module speech-enables lispy.
;;; Code:

;;}}}
;;{{{  Required modules

(require 'cl-lib)
(cl-declaim  (optimize  (safety 0) (speed 3)))
(require 'emacspeak-preamble)
(eval-when-compile (require 'lispy "lispy" 'no-error))

;;}}}
;;{{{ Map Faces:

(voice-setup-add-map 
'(
(lispy-command-name-face voice-bolden)
(lispy-cursor-face voice-animate)
(lispy-face-hint voice-smoothen)
(lispy-face-key-nosel voice-monotone)
(lispy-face-key-sel voice-brighten)
(lispy-face-opt-nosel voice-monotone)
(lispy-face-opt-sel voice-lighten)
(lispy-face-req-nosel voice-monotone )
(lispy-face-req-sel voice-brighten-extra)
(lispy-face-rst-nosel voice-monotone)
(lispy-face-rst-sel voice-lighten-extra)
(lispy-test-face voice-annotate)))

;;}}}
;;{{{ Setup:

(defun emacspeak-lispy-setup ()
  "Setup emacspeak for use with lispy"
  (cl-declare (special lispy-mode-map))
  (define-key lispy-mode-map (kbd "C-e") 'emacspeak-prefix-command))

(emacspeak-lispy-setup)

;;}}}
;;{{{ Advice Navigation:

(cl-loop
 for f in
 '(
   lispy-ace-paren lispy-ace-symbol lispy-teleport lispy-ace-char lispy-ace-subword
   lispy-move-up lispy-move-down lispy-undo
   lispy-right-nostring lispy-left lispy-right lispy-up lispy-down lispy-back
   lispy-different lispy-backward lispy-forward lispy-flow
   lispy-to-defun lispy-beginning-of-defun
   lispy-move-beginning-of-line lispy-move-end-of-line)
 do
 (eval
  `(defadvice ,f (after emacspeak pre act comp)
     "speak line with show-point turned on."
     (when (ems-interactive-p)
       (let ((emacspeak-show-point t))
         (emacspeak-auditory-icon 'large-movement)
         (emacspeak-speak-line))))))

;;}}}
;;{{{Advice Insertions:

(defadvice lispy-clone (before emacspeak pre act comp)
  "Provide auditory feedback."
  (when (ems-interactive-p)
    (emacspeak-speak-sexp)
    (emacspeak-auditory-icon 'yank-object)
    ))


(defadvice lispy-comment (after emacspeak pre act comp)
  "Provide auditory feedback."
  (when (ems-interactive-p)
    (emacspeak-auditory-icon 'select-object)
    (cond
     ((use-region-p)(emacspeak-speak-region (region-beginning) (region-end)))
     (t (emacspeak-speak-line)))))

(defadvice lispy-backtick (after emacspeak pre act comp)
  "Provide auditory feedback."
  (when (ems-interactive-p)
    (let ((emacspeak-show-point t))
      (emacspeak-speak-line))))

(defadvice lispy-tick (after emacspeak pre act comp)
  "Provide auditory feedback."
  (when (ems-interactive-p)
    (cond
     ((region-active-p)
      (emacspeak-speak-region (region-beginning) (region-end)))
     (t (emacspeak-speak-line)))))


(cl-loop
 for f in
 '(lispy-colon lispy-hash lispy-hat)
 do
 (eval
  `(defadvice ,f (after emacspeak pre act comp)
     "Provide auditory feedback."
     (when (ems-interactive-p)
       (emacspeak-speak-this-char (preceding-char))))))

(cl-loop
 for f in 
 '(lispy-parens lispy-braces lispy-brackets lispy-quotes)
 do
 (eval
  `(defadvice ,f (after emacspeak pre act comp)
     "Provide auditory feedback."
     (when (ems-interactive-p)
       (emacspeak-auditory-icon 'item)
       (save-excursion
         (forward-char 1)
         (forward-sexp -1)
         (emacspeak-speak-sexp))))))



;;}}}
;;{{{ Slurp and barf:

(cl-loop
 for f in
 '(
   lispy-barf lispy-slurp lispy-join lispy-split
               lispy-alt-multiline
              lispy-out-forward-newline lispy-parens-down lispy-meta-return)
 do
 (eval
  `(defadvice ,f (after emacspeak pre act comp)
     "speak line with show-point turned on."
     (when (ems-interactive-p)
       (let ((emacspeak-show-point t))
         (emacspeak-auditory-icon 'large-movement)
         (emacspeak-speak-line))))))

;;}}}
;;{{{Advice Marking:

(defadvice lispy-mark-symbol (after emacspeak pre act comp)
  "Provide auditory feedback."
  (when (ems-interactive-p)
    (emacspeak-auditory-icon 'mark-object)
    (emacspeak-speak-region  (region-beginning) (region-end))))

;;}}}
;;{{{Advice WhiteSpace Manipulation:
(defadvice lispy-fill (after emacspeak pre act comp)
  "Provide auditory feedback."
  (when (ems-interactive-p)
    (emacspeak-auditory-icon 'fill-object)
    (emacspeak-speak-line)))

(cl-loop
 for f in 
 '(lispy-newline-and-indent lispy-newline-and-indent-plain)
 do
 (eval
  `(defadvice ,f (after emacspeak pre act comp)
     "Provide auditory feedback."
     (when (ems-interactive-p)
       (let ((emacspeak-show-point t))
         (emacspeak-speak-line))))))
(defadvice lispy-tab (after emacspeak pre act comp)
  "Provide auditory feedback."
  (when (ems-interactive-p)
    (emacspeak-auditory-icon 'fill-object)
       (emacspeak-speak-line)))

;;}}}
;;{{{Advice Kill/Yank:

(cl-loop
 for f in
 '(lispy-kill lispy-kill-word lispy-backward-kill-word
              lispy-kill-sentencelispy-kill-at-point)
 do
 (eval
  `(defadvice ,f (after emacspeak pre act comp)
     "Provide auditory feedback."
     (when (ems-interactive-p)
       (emacspeak-auditory-icon 'delete-object)
       (emacspeak-speak-current-kill)))))

(defadvice lispy-yank (after emacspeak pre act comp)
  "Provide auditory feedback."
  (when (ems-interactive-p)
    (emacspeak-auditory-icon 'yank-object)
    (emacspeak-speak-region (region-beginning) (region-end))))



 
 
 
(defadvice lispy-delete-backward(around emacspeak pre act comp)
     "Provide auditory feedback."
     (cond
      ((ems-interactive-p)
       (emacspeak-auditory-icon 'delete-object)
       (emacspeak-speak-this-char (preceding-char))
       ad-do-it)
      (t ad-do-it)))


(defadvice lispy-delete (around emacspeak pre act comp)
  "Provide auditory feedback."
  (cond
      ((ems-interactive-p)
       (dtk-tone-deletion)
       (emacspeak-speak-char t)
       ad-do-it)
      (t ad-do-it)))

;;}}}
;;{{{Advice Help:

 
 
(defadvice lispy-describe-inline (after emacspeak pre act comp)
  "Provide auditory feedback."
  (when
      (and 
       (ems-interactive-p)
       (buffer-live-p (get-buffer "*lispy-help*"))
       (window-live-p (get-buffer-window "*lispy-help*")))
    (with-current-buffer  "*lispy-help*"
      (emacspeak-auditory-icon 'help)
      (emacspeak-speak-buffer))))

;;}}}
(provide 'emacspeak-lispy)
;;{{{ end of file

;;; local variables:
;;; folded-file: t
;;; byte-compile-dynamic: t
;;; end:

;;}}}
