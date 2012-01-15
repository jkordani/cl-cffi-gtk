;;; ----------------------------------------------------------------------------
;;; gdk.drag-and-drop.lisp
;;;
;;; This file contains code from a fork of cl-gtk2.
;;; See http://common-lisp.net/project/cl-gtk2/
;;;
;;; The documentation has been copied from the GDK 2 Reference Manual
;;; See http://www.gtk.org
;;;
;;; Copyright (C) 2009, 2011 Kalyanov Dmitry
;;; Copyright (C) 2011, 2012 Dr. Dieter Kaiser
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
;;; Drag and Drop
;;; 
;;; Functions for controlling drag and drop handling
;;; 
;;; Synopsis
;;; 
;;;     GdkDragAction
;;;     GdkDragContext
;;;     gdk_drag_get_selection
;;;     gdk_drag_abort
;;;     gdk_drop_reply
;;;     gdk_drag_context_new
;;;     gdk_drag_drop
;;;     gdk_drag_find_window
;;;     gdk_drag_find_window_for_screen
;;;     gdk_drag_context_ref
;;;     gdk_drag_context_get_actions
;;;     gdk_drag_context_get_selected_action
;;;     gdk_drag_context_get_suggested_action
;;;     gdk_drag_context_list_targets
;;;     gdk_drag_context_get_source_window
;;;     gdk_drag_motion
;;;     gdk_drop_finish
;;;     gdk_drag_get_protocol
;;;     gdk_drag_get_protocol_for_display
;;;     GdkDragProtocol
;;;     gdk_drag_context_unref
;;;     gdk_drag_status
;;;     gdk_drag_drop_succeeded
;;; 
;;; Description
;;; 
;;; These functions provide a low level interface for drag and drop. The X 
;;; backend of GDK supports both the Xdnd and Motif drag and drop protocols 
;;; transparently, the Win32 backend supports the WM_DROPFILES protocol.
;;; 
;;; GTK+ provides a higher level abstraction based on top of these functions, 
;;; and so they are not normally needed in GTK+ applications. See the Drag and
;;; Drop section of the GTK+ documentation for more information.
;;; ----------------------------------------------------------------------------

(in-package :gdk)

;;; ----------------------------------------------------------------------------
;;; enum GdkDragAction
;;; 
;;; typedef enum
;;; {
;;;   GDK_ACTION_DEFAULT = 1 << 0,
;;;   GDK_ACTION_COPY    = 1 << 1,
;;;   GDK_ACTION_MOVE    = 1 << 2,
;;;   GDK_ACTION_LINK    = 1 << 3,
;;;   GDK_ACTION_PRIVATE = 1 << 4,
;;;   GDK_ACTION_ASK     = 1 << 5
;;; } GdkDragAction;
;;; 
;;; Used in GdkDragContext to indicate what the destination should do with the 
;;; dropped data.
;;; 
;;; GDK_ACTION_DEFAULT
;;; 	Means nothing, and should not be used.
;;; 
;;; GDK_ACTION_COPY
;;; 	Copy the data.
;;; 
;;; GDK_ACTION_MOVE
;;; 	Move the data, i.e. first copy it, then delete it from the source using 
;;;     the DELETE target of the X selection protocol.
;;; 
;;; GDK_ACTION_LINK
;;; 	Add a link to the data. Note that this is only useful if source and 
;;;     destination agree on what it means.
;;; 
;;; GDK_ACTION_PRIVATE
;;; 	Special action which tells the source that the destination will do 
;;;     something that the source doesn't understand.
;;; 
;;; GDK_ACTION_ASK
;;; 	Ask the user what to do with the data.
;;; ----------------------------------------------------------------------------

(define-g-flags "GdkDragAction" gdk-drag-action
  (:export t
   :type-initializer "gdk_drag_action_get_type")
  (:default 1)
  (:copy 2)
  (:move 4)
  (:link 8)
  (:private 16)
  (:ask 32))

;;; ----------------------------------------------------------------------------
;;; enum GdkDragProtocol
;;; 
;;; typedef enum
;;; {
;;;   GDK_DRAG_PROTO_MOTIF,
;;;   GDK_DRAG_PROTO_XDND,
;;;   GDK_DRAG_PROTO_ROOTWIN,        /* A root window with nobody claiming
;;;                                   * drags */
;;;   GDK_DRAG_PROTO_NONE,           /* Not a valid drag window */
;;;   GDK_DRAG_PROTO_WIN32_DROPFILES,/* The simple WM_DROPFILES dnd */
;;;   GDK_DRAG_PROTO_OLE2,           /* The complex OLE2 dnd (not implemented)*/
;;;   GDK_DRAG_PROTO_LOCAL           /* Intra-app */
;;; } GdkDragProtocol;
;;; 
;;; Used in GdkDragContext to indicate the protocol according to which DND is 
;;; done.
;;; 
;;; GDK_DRAG_PROTO_MOTIF
;;; 	The Motif DND protocol.
;;; 
;;; GDK_DRAG_PROTO_XDND
;;; 	The Xdnd protocol.
;;; 
;;; GDK_DRAG_PROTO_ROOTWIN
;;; 	An extension to the Xdnd protocol for unclaimed root window drops.
;;; 
;;; GDK_DRAG_PROTO_NONE
;;; 	no protocol.
;;; 
;;; GDK_DRAG_PROTO_WIN32_DROPFILES
;;; 	The simple WM_DROPFILES protocol.
;;; 
;;; GDK_DRAG_PROTO_OLE2
;;; 	The complex OLE2 DND protocol (not implemented).
;;; 
;;; GDK_DRAG_PROTO_LOCAL
;;; 	Intra-application DND.
;;; ----------------------------------------------------------------------------

(define-g-enum "GdkDragProtocol" gdk-drag-protocol
  (:export t :type-initializer "gdk_drag_protocol_get_type")
  (:motif 0)
  (:xdnd 1)
  (:rootwin 2)
  (:none 3)
  (:win32-dropfiles 4)
  (:ole2 5)
  (:local 6))

;;; ----------------------------------------------------------------------------
;;; struct GdkDragContext
;;; 
;;; struct GdkDragContext {
;;;   GObject parent_instance;
;;; 
;;;   
;;;   GdkDragProtocol GSEAL (protocol);
;;; 
;;;   gboolean GSEAL (is_source);
;;;   
;;;   GdkWindow *GSEAL (source_window);
;;;   GdkWindow *GSEAL (dest_window);
;;; 
;;;   GList *GSEAL (targets);
;;;   GdkDragAction GSEAL (actions);
;;;   GdkDragAction GSEAL (suggested_action);
;;;   GdkDragAction GSEAL (action);
;;; 
;;;   guint32 GSEAL (start_time);
;;; };
;;; 
;;; A GdkDragContext holds information about a drag in progress. It is used on 
;;; both source and destination sides.
;;; 
;;; GObject parent_instance;
;;; 	the parent instance
;;; ----------------------------------------------------------------------------

(defcstruct %gdk-drag-context
  (parent-instance gobject::%g-object)
  (protocol gdk-drag-protocol)
  (is-source :boolean)
  (source-window (g-object gdk-window))
  (dest-window (g-object gdk-window))
  (targets (glib:g-list gdk-atom-as-string :free-from-foreign nil))
  (actions gdk-drag-action)
  (suggested-action gdk-drag-action)
  (action gdk-drag-action)
  (start-time :uint32))

(defun %gdk-drag-context-get-protocol (context)
  (foreign-slot-value (pointer context) '%gdk-drag-context 'protocol))

(defun %gdk-drag-context-get-is-source (context)
  (foreign-slot-value (pointer context) '%gdk-drag-context 'is-source))

(defun %gdk-drag-context-get-source-window (context)
  (foreign-slot-value (pointer context) '%gdk-drag-context 'source-window))

(defun %gdk-drag-context-get-dest-window (context)
  (foreign-slot-value (pointer context) '%gdk-drag-context 'dest-window))

(defun %gdk-drag-context-get-targets (context)
  (foreign-slot-value (pointer context) '%gdk-drag-context 'targets))

(defun %gdk-drag-context-get-actions (context)
  (foreign-slot-value (pointer context) '%gdk-drag-context 'actions))

(defun %gdk-drag-context-get-suggested-action (context)
  (foreign-slot-value (pointer context) '%gdk-drag-context 'suggested-action))

(defun %gdk-drag-context-get-action (context)
  (foreign-slot-value (pointer context) '%gdk-drag-context 'action))

(defun %gdk-drag-context-get-start-time (context)
  (foreign-slot-value (pointer context) '%gdk-drag-context 'start-time))

;;; ----------------------------------------------------------------------------

(define-g-object-class "GdkDragContext" gdk-drag-context
  (:type-initializer "gdk_drag_context_get_type")
  ((:cffi protocol drag-context-protocol gdk-drag-protocol
          %gdk-drag-context-get-protocol nil)
   (:cffi is-source drag-context-is-source :boolean
          %gdk-drag-context-get-is-source nil)
   (:cffi source-window drag-context-source-window (g-object gdk-window)
          %gdk-drag-context-get-source-window nil)
   (:cffi dest-window drag-context-dest-window (g-object gdk-window)
          %gdk-drag-context-get-dest-window nil)
   (:cffi targets drag-context-targets (glib:g-list gdk-atom-as-string :free-from-foreign nil)
          %gdk-drag-context-get-targets nil)
   (:cffi actions drag-context-actions gdk-drag-action
          %gdk-drag-context-get-actions nil)
   (:cffi suggested-action drag-context-suggested-action gdk-drag-action
          %gdk-drag-context-get-suggested-action nil)
   (:cffi action drag-context-action gdk-drag-action
          %gdk-drag-context-get-action nil)
   (:cffi start-time drag-context-start-time :uint32
     %gdk-drag-context-get-start-time nil)))

;;; ----------------------------------------------------------------------------
;;; gdk_drag_get_selection ()
;;; 
;;; GdkAtom gdk_drag_get_selection (GdkDragContext *context);
;;; 
;;; Returns the selection atom for the current source window.
;;; 
;;; context :
;;; 	a GdkDragContext.
;;; 
;;; Returns :
;;; 	the selection atom.
;;; ----------------------------------------------------------------------------

(defcfun ("gdk_drag_get_selection" gdk-drag-get-selection) gdk-atom-as-string
  (context (g-object gdk-drag-context)))

(export 'gdk-drag-get-selection)

;;; ----------------------------------------------------------------------------
;;; gdk_drag_abort ()
;;; 
;;; void gdk_drag_abort (GdkDragContext *context, guint32 time_);
;;; 
;;; Aborts a drag without dropping.
;;; 
;;; This function is called by the drag source.
;;; 
;;; context :
;;; 	a GdkDragContext.
;;; 
;;; time_ :
;;; 	the timestamp for this operation.
;;; ----------------------------------------------------------------------------

(defcfun ("gdk_drag_abort" gdk-drag-abort) :void
  (context (g-object gdk-drag-context))
  (time :uint32))

(export 'gdk-drag-abort)

;;; ----------------------------------------------------------------------------
;;; gdk_drop_reply ()
;;; 
;;; void gdk_drop_reply (GdkDragContext *context, gboolean ok, guint32 time_)
;;; 
;;; Accepts or rejects a drop.
;;; 
;;; This function is called by the drag destination in response to a drop 
;;; initiated by the drag source.
;;; 
;;; context :
;;; 	a GdkDragContext.
;;; 
;;; ok :
;;; 	TRUE if the drop is accepted.
;;; 
;;; time_ :
;;; 	the timestamp for this operation.
;;; ----------------------------------------------------------------------------

(defcfun ("gdk_drop_reply" gdk-drop-reply) :void
  (context (g-object gdk-drag-context))
  (ok :boolean)
  (time :uint32))

(export 'gdk-drop-reply)

;;; ----------------------------------------------------------------------------
;;; gdk_drag_context_new ()
;;; 
;;; GdkDragContext * gdk_drag_context_new (void);
;;; 
;;; Warning
;;; 
;;; gdk_drag_context_new has been deprecated since version 2.24 and should not
;;; be used in newly-written code. This function is not useful, you always 
;;; obtain drag contexts by gdk_drag_begin() or similar.
;;; 
;;; Creates a new GdkDragContext.
;;; 
;;; Returns :
;;; 	the newly created GdkDragContext.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gdk_drag_drop ()
;;; 
;;; void gdk_drag_drop (GdkDragContext *context, guint32 time_);
;;; 
;;; Drops on the current destination.
;;; 
;;; This function is called by the drag source.
;;; 
;;; context :
;;; 	a GdkDragContext.
;;; 
;;; time_ :
;;; 	the timestamp for this operation.
;;; ----------------------------------------------------------------------------

(defcfun ("gdk_drag_drop" gdk-drag-drop) :void
  (context (g-object gdk-drag-context))
  (time :uint32))

(export 'gdk-drag-drop)

;;; ----------------------------------------------------------------------------
;;; gdk_drag_find_window ()
;;; 
;;; void gdk_drag_find_window (GdkDragContext *context,
;;;                            GdkWindow *drag_window,
;;;                            gint x_root,
;;;                            gint y_root,
;;;                            GdkWindow **dest_window,
;;;                            GdkDragProtocol *protocol);
;;; 
;;; Warning
;;; 
;;; gdk_drag_find_window has been deprecated since version 2.24 and should not 
;;; be used in newly-written code. Use gdk_drag_find_window_for_screen()
;;; instead.
;;; 
;;; Finds the destination window and DND protocol to use at the given pointer 
;;; position.
;;; 
;;; This function is called by the drag source to obtain the dest_window and 
;;; protocol parameters for gdk_drag_motion().
;;; 
;;; context :
;;; 	a GdkDragContext.
;;; 
;;; drag_window :
;;; 	a window which may be at the pointer position, but should be ignored, 
;;;     since it is put up by the drag source as an icon.
;;; 
;;; x_root :
;;; 	the x position of the pointer in root coordinates.
;;; 
;;; y_root :
;;; 	the y position of the pointer in root coordinates.
;;; 
;;; dest_window :
;;; 	location to store the destination window in. [out]
;;; 
;;; protocol :
;;; 	location to store the DND protocol in. [out]
;;; ----------------------------------------------------------------------------

(defcfun ("gdk_drag_find_window" %gdk-drag-find-window) :void
  (context (g-object gdk-drag-context))
  (window (g-object gdk-window))
  (x-root :int)
  (y-root :int)
  (dest-window (:pointer (g-object gdk-window)))
  (protocol (:pointer gdk-drag-protocol)))

(defun gdk-drag-find-window (context window x-root y-root)
  (with-foreign-objects ((dest-window :pointer) (protocol 'gdk-drag-protocol))
    (%gdk-drag-find-window context window x-root y-root dest-window protocol)
    (values (mem-ref dest-window '(g-object gdk-window))
            (mem-ref protocol 'gdk-drag-protocol))))

(export 'gdk-drag-find-window)

;;; ----------------------------------------------------------------------------
;;; gdk_drag_find_window_for_screen ()
;;; 
;;; void gdk_drag_find_window_for_screen (GdkDragContext *context,
;;;                                       GdkWindow *drag_window,
;;;                                       GdkScreen *screen,
;;;                                       gint x_root,
;;;                                       gint y_root,
;;;                                       GdkWindow **dest_window,
;;;                                       GdkDragProtocol *protocol);
;;; 
;;; Finds the destination window and DND protocol to use at the given pointer 
;;; position.
;;; 
;;; This function is called by the drag source to obtain the dest_window and 
;;; protocol parameters for gdk_drag_motion().
;;; 
;;; context :
;;; 	a GdkDragContext
;;; 
;;; drag_window :
;;; 	a window which may be at the pointer position, but should be ignored, 
;;;     since it is put up by the drag source as an icon.
;;; 
;;; screen :
;;; 	the screen where the destination window is sought.
;;; 
;;; x_root :
;;; 	the x position of the pointer in root coordinates.
;;; 
;;; y_root :
;;; 	the y position of the pointer in root coordinates.
;;; 
;;; dest_window :
;;; 	location to store the destination window in. [out]
;;; 
;;; protocol :
;;; 	location to store the DND protocol in. [out]
;;; 
;;; Since 2.2
;;; ----------------------------------------------------------------------------

(defcfun ("gdk_drag_find_window_for_screen" %gdk-drag-find-window-for-screen)
    :void
  (context (g-object gdk-drag-context))
  (window (g-object gdk-window))
  (screen (g-object gdk-screen))
  (x-root :int)
  (y-root :int)
  (dest-window (:pointer (g-object gdk-window)))
  (protocol (:pointer gdk-drag-protocol)))

(defun gdk-drag-find-window-for-screen (context window screen x-root y-root)
  (with-foreign-objects ((dest-window :pointer) (protocol 'gdk-drag-protocol))
    (%gdk-drag-find-window-for-screen context
                                      window
                                      screen
                                      x-root
                                      y-root
                                      dest-window
                                      protocol)
    (values (mem-ref dest-window '(g-object gdk-window))
            (mem-ref protocol 'gdk-drag-protocol))))

(export 'gdk-drag-find-window-for-screen)

;;; ----------------------------------------------------------------------------
;;; gdk_drag_context_ref ()
;;; 
;;; void gdk_drag_context_ref (GdkDragContext *context);
;;; 
;;; Warning
;;; 
;;; gdk_drag_context_ref has been deprecated since version 2.2 and should not
;;; be used in newly-written code. Use g_object_ref() instead.
;;; 
;;; Deprecated function; use g_object_ref() instead.
;;; 
;;; context :
;;; 	a GdkDragContext.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gdk_drag_context_get_actions ()
;;; 
;;; GdkDragAction gdk_drag_context_get_actions (GdkDragContext *context);
;;; 
;;; Determines the bitmask of actions proposed by the source if 
;;; gdk_drag_context_suggested_action() returns GDK_ACTION_ASK.
;;; 
;;; context :
;;; 	a GdkDragContext
;;; 
;;; Returns :
;;; 	the GdkDragAction flags
;;; 
;;; Since 2.22
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gdk_drag_context_get_selected_action ()
;;; 
;;; GdkDragAction gdk_drag_context_get_selected_action (GdkDragContext *context)
;;; 
;;; Determines the action chosen by the drag destination.
;;; 
;;; context :
;;; 	a GdkDragContext
;;; 
;;; Returns :
;;; 	a GdkDragAction value
;;; 
;;; Since 2.22
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gdk_drag_context_get_suggested_action ()
;;; 
;;; GdkDragAction gdk_drag_context_get_suggested_action(GdkDragContext *context)
;;; 
;;; Determines the suggested drag action of the context.
;;; 
;;; context :
;;; 	a GdkDragContext
;;; 
;;; Returns :
;;; 	a GdkDragAction value
;;; 
;;; Since 2.22
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gdk_drag_context_list_targets ()
;;; 
;;; GList * gdk_drag_context_list_targets (GdkDragContext *context);
;;; 
;;; Retrieves the list of targets of the context.
;;; 
;;; context :
;;; 	a GdkDragContext
;;; 
;;; Returns :
;;; 	a GList of targets.
;;; 
;;; Since 2.22
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gdk_drag_context_get_source_window ()
;;; 
;;; GdkWindow * gdk_drag_context_get_source_window (GdkDragContext *context);
;;; 
;;; Returns the GdkWindow where the DND operation started.
;;; 
;;; context :
;;; 	a GdkDragContext
;;; 
;;; Returns :
;;; 	a GdkWindow.
;;; 
;;; Since 2.22
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gdk_drag_begin ()
;;; 
;;; GdkDragContext * gdk_drag_begin (GdkWindow *window, GList *targets);
;;; 
;;; Starts a drag and creates a new drag context for it.
;;; 
;;; This function is called by the drag source.
;;; 
;;; window :
;;; 	the source window for this drag.
;;; 
;;; targets :
;;; 	the offered targets, as list of GdkAtoms.
;;; 
;;; Returns :
;;; 	a newly created GdkDragContext.
;;; ----------------------------------------------------------------------------

(defcfun ("gdk_drag_begin" gdk-drag-begin)
    (g-object gdk-drag-context :already-referenced)
  (window (g-object gdk-window))
  (targets (glib:g-list gdk-atom-as-string)))

(export 'gdk-drag-begin)

;;; ----------------------------------------------------------------------------
;;; gdk_drag_motion ()
;;; 
;;; gboolean gdk_drag_motion (GdkDragContext *context,
;;;                           GdkWindow *dest_window,
;;;                           GdkDragProtocol protocol,
;;;                           gint x_root,
;;;                           gint y_root,
;;;                           GdkDragAction suggested_action,
;;;                           GdkDragAction possible_actions,
;;;                           guint32 time_);
;;; 
;;; Updates the drag context when the pointer moves or the set of actions 
;;; changes.
;;; 
;;; This function is called by the drag source.
;;; 
;;; context :
;;; 	a GdkDragContext.
;;; 
;;; dest_window :
;;; 	the new destination window, obtained by gdk_drag_find_window().
;;; 
;;; protocol :
;;; 	the DND protocol in use, obtained by gdk_drag_find_window().
;;; 
;;; x_root :
;;; 	the x position of the pointer in root coordinates.
;;; 
;;; y_root :
;;; 	the y position of the pointer in root coordinates.
;;; 
;;; suggested_action :
;;; 	the suggested action.
;;; 
;;; possible_actions :
;;; 	the possible actions.
;;; 
;;; time_ :
;;; 	the timestamp for this operation.
;;; 
;;; Returns :
;;; 	FIXME
;;; ----------------------------------------------------------------------------

(defcfun ("gdk_drag_motion" gdk-drag-motion) :boolean
  (context (g-object gdk-drag-context))
  (dest-window (g-object gdk-window))
  (protocol gdk-drag-protocol)
  (x-root :int)
  (y-root :int)
  (suggested-action gdk-drag-action)
  (possible-actions gdk-drag-action)
  (time :uint32))

(export 'gdk-drag-motion)

;;; ----------------------------------------------------------------------------
;;; gdk_drop_finish ()
;;; 
;;; void gdk_drop_finish (GdkDragContext *context,
;;;                       gboolean success,
;;;                       guint32 time_);
;;; 
;;; Ends the drag operation after a drop.
;;; 
;;; This function is called by the drag destination.
;;; 
;;; context :
;;; 	a GtkDragContext.
;;; 
;;; success :
;;; 	TRUE if the data was successfully received.
;;; 
;;; time_ :
;;; 	the timestamp for this operation.
;;; ----------------------------------------------------------------------------

(defcfun ("gdk_drop_finish" gdk-drop-finish) :void
  (context (g-object gdk-drag-context))
  (success :boolean)
  (time :uint32))

(export 'gdk-drop-finish)

;;; ----------------------------------------------------------------------------
;;; gdk_drag_get_protocol ()
;;; 
;;; GdkNativeWindow gdk_drag_get_protocol (GdkNativeWindow xid,
;;;                                        GdkDragProtocol *protocol);
;;; 
;;; Warning
;;; 
;;; gdk_drag_get_protocol has been deprecated since version 2.24 and should not 
;;; be used in newly-written code. Use gdk_drag_get_protocol_for_display()
;;; instead.
;;; 
;;; Finds out the DND protocol supported by a window.
;;; 
;;; xid :
;;; 	the windowing system id of the destination window.
;;; 
;;; protocol :
;;; 	location where the supported DND protocol is returned.
;;; 
;;; Returns :
;;; 	the windowing system specific id for the window where the drop should 
;;;     happen. This may be xid or the id of a proxy window, or zero if xid
;;;     doesn't support Drag and Drop.
;;; ----------------------------------------------------------------------------

(defcfun ("gdk_drag_get_protocol" %gdk_drag_get_protocol) gdk-native-window
  (xid gdk-native-window)
  (protocol (:pointer gdk-drag-protocol)))

(defun gdk-drag-get-protocol (xid)
  (with-foreign-object (protocol 'gdk-drag-protocol)
    (let ((dest-window (%gdk_drag_get_protocol xid protocol)))
      (values dest-window (mem-ref protocol 'gdk-drag-protocol)))))

(export 'gdk-drag-get-protocol)

;;; ----------------------------------------------------------------------------
;;; gdk_drag_get_protocol_for_display ()
;;; 
;;; GdkNativeWindow gdk_drag_get_protocol_for_display(GdkDisplay *display,
;;;                                                   GdkNativeWindow xid,
;;;                                                   GdkDragProtocol *protocol)
;;; 
;;; Finds out the DND protocol supported by a window.
;;; 
;;; display :
;;; 	the GdkDisplay where the destination window resides
;;; 
;;; xid :
;;; 	the windowing system id of the destination window.
;;; 
;;; protocol :
;;; 	location where the supported DND protocol is returned.
;;; 
;;; Returns :
;;; 	the windowing system id of the window where the drop should happen. 
;;;     This may be xid or the id of a proxy window, or zero if xid doesn't
;;;     support Drag and Drop.
;;; 
;;; Since 2.2
;;; ----------------------------------------------------------------------------

(defcfun ("gdk_drag_get_protocol_for_display"
          %gdk_drag_get_protocol_for_display)
    gdk-native-window
  (display (g-object gdk-display))
  (xid gdk-native-window)
  (protocol (:pointer gdk-drag-protocol)))

(defun gdk-drag-get-protocol-for-dispaly (display xid)
  (with-foreign-object (protocol 'gdk-drag-protocol)
    (let ((dest-window (%gdk_drag_get_protocol_for_display display
                                                           xid
                                                           protocol)))
      (values dest-window (mem-ref protocol 'gdk-drag-protocol)))))

(export 'gdk-drag-get-protocol-for-display)

;;; ----------------------------------------------------------------------------
;;; gdk_drag_context_unref ()
;;; 
;;; void gdk_drag_context_unref (GdkDragContext *context);
;;; 
;;; Warning
;;; 
;;; gdk_drag_context_unref has been deprecated since version 2.2 and should not 
;;; be used in newly-written code. Use g_object_unref() instead.
;;; 
;;; Deprecated function; use g_object_unref() instead.
;;; 
;;; context :
;;; 	a GdkDragContext.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gdk_drag_status ()
;;; 
;;; void gdk_drag_status (GdkDragContext *context,
;;;                       GdkDragAction action,
;;;                       guint32 time_);
;;; 
;;; Selects one of the actions offered by the drag source.
;;; 
;;; This function is called by the drag destination in response to 
;;; gdk_drag_motion() called by the drag source.
;;; 
;;; context :
;;; 	a GdkDragContext.
;;; 
;;; action :
;;; 	the selected action which will be taken when a drop happens, or 0 to 
;;;     indicate that a drop will not be accepted.
;;; 
;;; time_ :
;;; 	the timestamp for this operation.
;;; ----------------------------------------------------------------------------

(defcfun ("gdk_drag_status" gdk-drag-status) :void
  (context (g-object gdk-drag-context))
  (action gdk-drag-action)
  (time :uint32))

(export 'gdk-drag-status)

;;; ----------------------------------------------------------------------------
;;; gdk_drag_drop_succeeded ()
;;; 
;;; gboolean gdk_drag_drop_succeeded (GdkDragContext *context);
;;; 
;;; Returns whether the dropped data has been successfully transferred. This 
;;; function is intended to be used while handling a GDK_DROP_FINISHED event,
;;; its return value is meaningless at other times.
;;; 
;;; context :
;;; 	a GdkDragContext
;;; 
;;; Returns :
;;; 	TRUE if the drop was successful.
;;; 
;;; Since 2.6
;;; ----------------------------------------------------------------------------

(defcfun ("gdk_drag_drop_succeeded" gdk-drag-drop-succeeded) :boolean
  (context (g-object gdk-drag-context)))

(export 'gdk-drag-drop-succeeded)

;;; --- End of file gdk.drag-and-drop.lisp -------------------------------------
