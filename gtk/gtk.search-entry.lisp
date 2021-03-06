;;; ----------------------------------------------------------------------------
;;; gtk.seach-entry.lisp
;;;
;;; The documentation of this file is taken from the GTK+ 3 Reference Manual
;;; Version 3.6.4 and modified to document the Lisp binding to the GTK library.
;;; See <http://www.gtk.org>. The API documentation of the Lisp binding is
;;; available from <http://www.crategus.com/books/cl-cffi-gtk/>.
;;;
;;; Copyright (C) 2013 Dieter Kaiser
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU Lesser General Public License for Lisp
;;; as published by the Free Software Foundation, either version 3 of the
;;; License, or (at your option) any later version and with a preamble to
;;; the GNU Lesser General Public License that clarifies the terms for use
;;; with Lisp programs and is referred as the LLGPL.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU Lesser General Public License for more details.
;;;
;;; You should have received a copy of the GNU Lesser General Public
;;; License along with this program and the preamble to the Gnu Lesser
;;; General Public License.  If not, see <http://www.gnu.org/licenses/>
;;; and <http://opensource.franz.com/preamble.html>.
;;; ----------------------------------------------------------------------------
;;;
;;; GtkSearchEntry
;;;
;;; An entry which shows a search icon
;;;
;;; Synopsis
;;;
;;;     GtkSearchEntry
;;;     gtk_search_entry_new
;;;
;;; Object Hierarchy
;;;
;;;   GObject
;;;    +----GInitiallyUnowned
;;;          +----GtkWidget
;;;                +----GtkEntry
;;;                      +----GtkSearchEntry
;;;
;;; Implemented Interfaces
;;;
;;; GtkSearchEntry implements AtkImplementorIface, GtkBuildable, GtkEditable
;;; and GtkCellEditable.
;;; ----------------------------------------------------------------------------

(in-package :gtk)

;;; ----------------------------------------------------------------------------
;;; struct GtkSearchEntry
;;; ----------------------------------------------------------------------------

(define-g-object-class "GtkSearchEntry" gtk-search-entry
  (:superclass gtk-entry
   :export t
   :interfaces ("AtkImplementorIface"
                "GtkBuildable"
                "GtkEditable"
                "GtkCellEditable")
   :type-initializer "gtk_search_entry_get_type")
  nil)

#+cl-cffi-gtk-documentation
(setf (documentation 'gtk-search-entry 'type)
 "@version{2013-8-30}
  @begin{short}
    @sym{gtk-search-entry} is a subclass of @class{gtk-entry} that has been
    tailored for use as a search entry.
  @end{short}

  It will show an inactive symbolic \"find\" icon when the search entry is
  empty, and a symbolic \"clear\" icon when there is text. Clicking on the
  \"clear\" icon will empty the search entry.

  Note that the search/clear icon is shown using a secondary icon, and thus
  does not work if you are using the secondary icon position for some other
  purpose.
  @see-class{gtk-entry}")

;;; ----------------------------------------------------------------------------
;;; gtk_search_entry_new ()
;;; ----------------------------------------------------------------------------

#+gtk-3-6
(declaim (inline gtk-search-entry-new))

#+gtk-3-6
(defun gtk-search-entry-new ()
 #+cl-cffi-gtk-documentation
 "@version{2013-8-30}
  @return{A new @class{gtk-search-entry} widget.}
  @begin{short}
    Creates a @class{gtk-search-entry}, with a find icon when the search field
    is empty, and a clear icon when it is not.
  @end{short}

  Since 3.6
  @see-class{gtk-search-entry}"
  (make-instance 'gtk-search-entry))

#+gtk-3-6
(export 'gtk-search-entry-new)

;;; --- End of file gtk.search-entry.lisp --------------------------------------
