;;; ----------------------------------------------------------------------------
;;; gtk.icon-theme.lisp
;;;
;;; This file contains code from a fork of cl-gtk2.
;;; See http://common-lisp.net/project/cl-gtk2/
;;;
;;; The documentation has been copied from the GTK+ 3 Reference Manual
;;; Version 3.2.3. See http://www.gtk.org.
;;;
;;; Copyright (C) 2009 - 2011 Kalyanov Dmitry
;;; Copyright (C) 2011 - 2012 Dieter Kaiser
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
;;; GtkIconTheme
;;; 
;;; Looking up icons by name
;;; 
;;; Synopsis
;;; 
;;;                     GtkIconInfo
;;; struct              GtkIconTheme
;;; enum                GtkIconLookupFlags
;;;
;;; #define             GTK_ICON_THEME_ERROR
;;;
;;; enum                GtkIconThemeError
;;;
;;; GtkIconTheme *      gtk_icon_theme_new
;;; GtkIconTheme *      gtk_icon_theme_get_default
;;; GtkIconTheme *      gtk_icon_theme_get_for_screen
;;; void                gtk_icon_theme_set_screen
;;; void                gtk_icon_theme_set_search_path
;;; void                gtk_icon_theme_get_search_path
;;; void                gtk_icon_theme_append_search_path
;;; void                gtk_icon_theme_prepend_search_path
;;; void                gtk_icon_theme_set_custom_theme
;;; gboolean            gtk_icon_theme_has_icon
;;; GtkIconInfo *       gtk_icon_theme_lookup_icon
;;; GtkIconInfo *       gtk_icon_theme_choose_icon
;;; GtkIconInfo *       gtk_icon_theme_lookup_by_gicon
;;; GdkPixbuf *         gtk_icon_theme_load_icon
;;; GList *             gtk_icon_theme_list_contexts
;;; GList *             gtk_icon_theme_list_icons
;;; gint *              gtk_icon_theme_get_icon_sizes
;;; char *              gtk_icon_theme_get_example_icon_name
;;; gboolean            gtk_icon_theme_rescan_if_needed
;;; void                gtk_icon_theme_add_builtin_icon
;;; GtkIconInfo *       gtk_icon_info_copy
;;; void                gtk_icon_info_free
;;; GtkIconInfo *       gtk_icon_info_new_for_pixbuf
;;; gint                gtk_icon_info_get_base_size
;;; const gchar *       gtk_icon_info_get_filename
;;; GdkPixbuf *         gtk_icon_info_get_builtin_pixbuf
;;; GdkPixbuf *         gtk_icon_info_load_icon
;;; GdkPixbuf *         gtk_icon_info_load_symbolic
;;; GdkPixbuf *         gtk_icon_info_load_symbolic_for_style
;;; GdkPixbuf *         gtk_icon_info_load_symbolic_for_context
;;; void                gtk_icon_info_set_raw_coordinates
;;; gboolean            gtk_icon_info_get_embedded_rect
;;; gboolean            gtk_icon_info_get_attach_points
;;; const gchar *       gtk_icon_info_get_display_name
;;; 
;;; Object Hierarchy
;;; 
;;;   GObject
;;;    +----GtkIconTheme
;;; 
;;; Signals
;;; 
;;;   "changed"                                        : Run Last
;;; 
;;; Description
;;; 
;;; GtkIconTheme provides a facility for looking up icons by name and size. The
;;; main reason for using a name rather than simply providing a filename is to
;;; allow different icons to be used depending on what icon theme is selected by
;;; the user. The operation of icon themes on Linux and Unix follows the Icon
;;; Theme Specification. There is a default icon theme, named hicolor where
;;; applications should install their icons, but more additional application
;;; themes can be installed as operating system vendors and users choose.
;;; 
;;; Named icons are similar to the Themeable Stock Images(3) facility, and the
;;; distinction between the two may be a bit confusing. A few things to keep in
;;; mind:
;;; 
;;;     Stock images usually are used in conjunction with Stock Items(3), such
;;;     as GTK_STOCK_OK or GTK_STOCK_OPEN. Named icons are easier to set up and
;;;     therefore are more useful for new icons that an application wants to
;;;     add, such as application icons or window icons.
;;;     Stock images can only be loaded at the symbolic sizes defined by the
;;;     GtkIconSize enumeration, or by custom sizes defined by
;;;     gtk_icon_size_register(), while named icons are more flexible and any
;;;     pixel size can be specified.
;;;     Because stock images are closely tied to stock items, and thus to
;;;     actions in the user interface, stock images may come in multiple
;;;     variants for different widget states or writing directions.
;;; 
;;; A good rule of thumb is that if there is a stock image for what you want to
;;; use, use it, otherwise use a named icon. It turns out that internally stock
;;; images are generally defined in terms of one or more named icons. (An
;;; example of the more than one case is icons that depend on writing direction;
;;; GTK_STOCK_GO_FORWARD uses the two themed icons "gtk-stock-go-forward-ltr"
;;; and "gtk-stock-go-forward-rtl".)
;;; 
;;; In many cases, named themes are used indirectly, via GtkImage or stock
;;; items, rather than directly, but looking up icons directly is also simple.
;;; The GtkIconTheme object acts as a database of all the icons in the current
;;; theme. You can create new GtkIconTheme objects, but its much more efficient
;;; to use the standard icon theme for the GdkScreen so that the icon
;;; information is shared with other people looking up icons. In the case where
;;; the default screen is being used, looking up an icon can be as simple as:
;;; 
;;; GError *error = NULL;
;;; GtkIconTheme *icon_theme;
;;; GdkPixbuf *pixbuf;
;;; 
;;; icon_theme = gtk_icon_theme_get_default ();
;;; pixbuf = gtk_icon_theme_load_icon (icon_theme,
;;;                                    "my-icon-name", // icon name
;;;                                    48, // size
;;;                                    0,  // flags
;;;                                    &error);
;;; if (!pixbuf)
;;;   {
;;;     g_warning ("Couldn't load icon: %s", error->message);
;;;     g_error_free (error);
;;;   }
;;; else
;;;   {
;;;     // Use the pixbuf
;;;     g_object_unref (pixbuf);
;;;   }
;;; 
;;; ----------------------------------------------------------------------------
;;;
;;; Signal Details
;;;
;;; ----------------------------------------------------------------------------
;;; The "changed" signal
;;; 
;;; void user_function (GtkIconTheme *icon_theme,
;;;                     gpointer      user_data)       : Run Last
;;; 
;;; Emitted when the current icon theme is switched or GTK+ detects that a
;;; change has occurred in the contents of the current icon theme.
;;; 
;;; icon_theme :
;;;     the icon theme
;;; 
;;; user_data :
;;;     user data set when the signal handler was connected.
;;; ----------------------------------------------------------------------------

(in-package :gtk)

;;; ----------------------------------------------------------------------------
;;; GtkIconInfo
;;; 
;;; typedef struct _GtkIconInfo GtkIconInfo;
;;;
;;; Contains information found when looking up an icon in an icon theme.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; struct GtkIconTheme
;;; 
;;; struct GtkIconTheme;
;;;
;;; Acts as a database of information about an icon theme. Normally, you
;;; retrieve the icon theme for a particular screen using
;;; gtk_icon_theme_get_for_screen() and it will contain information about
;;; current icon theme for that screen, but you can also create a new
;;; GtkIconTheme object and set the icon theme name explicitely using
;;; gtk_icon_theme_set_custom_theme().
;;; ----------------------------------------------------------------------------

(define-g-object-class "GtkIconTheme" gtk-icon-theme
  (:superclass g-object
    :export t
    :interfaces nil
    :type-initializer "gtk_icon_theme_get_type")
  nil)

;;; ----------------------------------------------------------------------------
;;; enum GtkIconLookupFlags
;;; 
;;; typedef enum {
;;;   GTK_ICON_LOOKUP_NO_SVG           = 1 << 0,
;;;   GTK_ICON_LOOKUP_FORCE_SVG        = 1 << 1,
;;;   GTK_ICON_LOOKUP_USE_BUILTIN      = 1 << 2,
;;;   GTK_ICON_LOOKUP_GENERIC_FALLBACK = 1 << 3,
;;;   GTK_ICON_LOOKUP_FORCE_SIZE       = 1 << 4
;;; } GtkIconLookupFlags;
;;; 
;;; GTK_ICON_LOOKUP_NO_SVG
;;;     Never return SVG icons, even if gdk-pixbuf supports them. Cannot be used
;;;     together with GTK_ICON_LOOKUP_FORCE_SVG.
;;; 
;;; GTK_ICON_LOOKUP_FORCE_SVG
;;;     Return SVG icons, even if gdk-pixbuf doesn't support them. Cannot be
;;;     used together with GTK_ICON_LOOKUP_NO_SVG.
;;; 
;;; GTK_ICON_LOOKUP_USE_BUILTIN
;;;     When passed to gtk_icon_theme_lookup_icon() includes builtin icons as
;;;     well as files. For a builtin icon, gtk_icon_info_get_filename()
;;; 
;;; GTK_ICON_LOOKUP_GENERIC_FALLBACK
;;;     
;;; 
;;; GTK_ICON_LOOKUP_FORCE_SIZE
;;; ----------------------------------------------------------------------------

(define-g-flags "GtkIconLookupFlags" gtk-icon-lookup-flags
  (:export t
   :type-initializer "gtk_icon_lookup_flags_get_type")
  (:no-svg 1)
  (:force-svg 2)
  (:use-builtin 4)
  (:generic-fallback 8)
  (:force-size 16))

;;; ----------------------------------------------------------------------------
;;; GTK_ICON_THEME_ERROR
;;; 
;;; #define GTK_ICON_THEME_ERROR gtk_icon_theme_error_quark ()
;;; 
;;; The GQuark used for GtkIconThemeError errors.
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; enum GtkIconThemeError
;;; 
;;; typedef enum {
;;;   GTK_ICON_THEME_NOT_FOUND,
;;;   GTK_ICON_THEME_FAILED
;;; } GtkIconThemeError;
;;; 
;;; Error codes for GtkIconTheme operations.
;;; 
;;; GTK_ICON_THEME_NOT_FOUND
;;;     The icon specified does not exist in the theme
;;; 
;;; GTK_ICON_THEME_FAILED
;;;     An unspecified error occurred.
;;; ----------------------------------------------------------------------------

(define-g-enum "GtkIconThemeError" gtk-icon-theme-error
  (:export t
   :type-initializer "gtk_icon_theme_error_get_type")
  (:not-found 0)
  (:failed 1))

;;; ----------------------------------------------------------------------------
;;; gtk_icon_theme_new ()
;;; 
;;; GtkIconTheme * gtk_icon_theme_new (void);
;;; 
;;; Creates a new icon theme object. Icon theme objects are used to lookup up
;;; an icon by name in a particular icon theme. Usually, you'll want to use
;;; gtk_icon_theme_get_default() or gtk_icon_theme_get_for_screen() rather
;;; than creating a new icon theme object for scratch.
;;; 
;;; Returns :
;;;     the newly created GtkIconTheme object.
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_theme_get_default ()
;;; 
;;; GtkIconTheme * gtk_icon_theme_get_default (void);
;;; 
;;; Gets the icon theme for the default screen.
;;; See gtk_icon_theme_get_for_screen().
;;; 
;;; Returns :
;;;     A unique GtkIconTheme associated with the default screen. This icon
;;;     theme is associated with the screen and can be used as long as the
;;;     screen is open. Do not ref or unref it.
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

(defcfun ("gtk_icon_theme_get_default" gtk-icon-theme-get-default)
    (g-object gtk-icon-theme))

(export 'gtk-icon-theme-get-default)

;;; ----------------------------------------------------------------------------
;;; gtk_icon_theme_get_for_screen ()
;;; 
;;; GtkIconTheme * gtk_icon_theme_get_for_screen (GdkScreen *screen);
;;; 
;;; Gets the icon theme object associated with screen; if this function has not
;;; previously been called for the given screen, a new icon theme object will
;;; be created and associated with the screen. Icon theme objects are fairly
;;; expensive to create, so using this function is usually a better choice than
;;; calling than gtk_icon_theme_new() and setting the screen yourself; by using
;;; this function a single icon theme object will be shared between users.
;;; 
;;; screen :
;;;     a GdkScreen
;;; 
;;; Returns :
;;;     A unique GtkIconTheme associated with the given screen. This icon theme
;;;     is associated with the screen and can be used as long as the screen is
;;;     open. Do not ref or unref it.
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

(defcfun ("gtk_icon_theme_get_for_screen" gtk-icon-theme-get-for-screen)
    (g-object gtk-icon-theme)
  (screen (g-object gdk-screen)))

(export 'gtk-icon-theme-get-for-screen)

;;; ----------------------------------------------------------------------------
;;; gtk_icon_theme_set_screen ()
;;; 
;;; void gtk_icon_theme_set_screen (GtkIconTheme *icon_theme, GdkScreen *screen)
;;; 
;;; Sets the screen for an icon theme; the screen is used to track the user's
;;; currently configured icon theme, which might be different for different
;;; screens.
;;; 
;;; icon_theme :
;;;     a GtkIconTheme
;;; 
;;; screen :
;;;     a GdkScreen
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_theme_set_search_path ()
;;; 
;;; void gtk_icon_theme_set_search_path (GtkIconTheme *icon_theme,
;;;                                      const gchar *path[],
;;;                                      gint n_elements);
;;; 
;;; Sets the search path for the icon theme object. When looking for an icon
;;; theme, GTK+ will search for a subdirectory of one or more of the directories
;;; in path with the same name as the icon theme. (Themes from multiple of the
;;; path elements are combined to allow themes to be extended by adding icons in
;;; the user's home directory.)
;;; 
;;; In addition if an icon found isn't found either in the current icon theme or
;;; the default icon theme, and an image file with the right name is found
;;; directly in one of the elements of path, then that image will be used for
;;; the icon name. (This is legacy feature, and new icons should be put into the
;;; default icon theme, which is called DEFAULT_THEME_NAME, rather than directly
;;; on the icon path.)
;;; 
;;; icon_theme :
;;;     a GtkIconTheme
;;; 
;;; path :
;;;     array of directories that are searched for icon themes.
;;; 
;;; n_elements :
;;;     number of elements in path.
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_theme_get_search_path ()
;;; 
;;; void gtk_icon_theme_get_search_path (GtkIconTheme *icon_theme,
;;;                                      gchar **path[],
;;;                                      gint *n_elements);
;;; 
;;; Gets the current search path. See gtk_icon_theme_set_search_path().
;;; 
;;; icon_theme :
;;;     a GtkIconTheme
;;; 
;;; path :
;;;     location to store a list of icon theme path directories or NULL. The
;;;     stored value should be freed with g_strfreev().
;;; 
;;; n_elements :
;;;     location to store number of elements in path, or NULL
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_theme_append_search_path ()
;;; 
;;; void gtk_icon_theme_append_search_path (GtkIconTheme *icon_theme,
;;;                                         const gchar *path);
;;; 
;;; Appends a directory to the search path.
;;; See gtk_icon_theme_set_search_path().
;;; 
;;; icon_theme :
;;;     a GtkIconTheme
;;; 
;;; path :
;;;     directory name to append to the icon path. [type filename]
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_theme_prepend_search_path ()
;;; 
;;; void gtk_icon_theme_prepend_search_path (GtkIconTheme *icon_theme,
;;;                                          const gchar *path);
;;; 
;;; Prepends a directory to the search path.
;;; See gtk_icon_theme_set_search_path().
;;; 
;;; icon_theme :
;;;     a GtkIconTheme
;;; 
;;; path :
;;;     directory name to prepend to the icon path. [type filename]
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_theme_set_custom_theme ()
;;; 
;;; void gtk_icon_theme_set_custom_theme (GtkIconTheme *icon_theme,
;;;                                       const gchar *theme_name);
;;; 
;;; Sets the name of the icon theme that the GtkIconTheme object uses overriding
;;; system configuration. This function cannot be called on the icon theme
;;; objects returned from gtk_icon_theme_get_default() and
;;; gtk_icon_theme_get_for_screen().
;;; 
;;; icon_theme :
;;;     a GtkIconTheme
;;; 
;;; theme_name :
;;;     name of icon theme to use instead of configured theme, or NULL to unset
;;;     a previously set custom theme
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_theme_has_icon ()
;;; 
;;; gboolean gtk_icon_theme_has_icon (GtkIconTheme *icon_theme,
;;;                                   const gchar *icon_name);
;;; 
;;; Checks whether an icon theme includes an icon for a particular name.
;;; 
;;; icon_theme :
;;;     a GtkIconTheme
;;; 
;;; icon_name :
;;;     the name of an icon
;;; 
;;; Returns :
;;;     TRUE if icon_theme includes an icon for icon_name.
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_theme_lookup_icon ()
;;; 
;;; GtkIconInfo * gtk_icon_theme_lookup_icon (GtkIconTheme *icon_theme,
;;;                                           const gchar *icon_name,
;;;                                           gint size,
;;;                                           GtkIconLookupFlags flags);
;;; 
;;; Looks up a named icon and returns a structure containing information such as
;;; the filename of the icon. The icon can then be rendered into a pixbuf using
;;; gtk_icon_info_load_icon(). (gtk_icon_theme_load_icon() combines these two
;;; steps if all you need is the pixbuf.)
;;; 
;;; icon_theme :
;;;     a GtkIconTheme
;;; 
;;; icon_name :
;;;     the name of the icon to lookup
;;; 
;;; size :
;;;     desired icon size
;;; 
;;; flags :
;;;     flags modifying the behavior of the icon lookup
;;; 
;;; Returns :
;;;     a GtkIconInfo structure containing information about the icon, or NULL
;;;     if the icon wasn't found. Free with gtk_icon_info_free()
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_theme_choose_icon ()
;;; 
;;; GtkIconInfo * gtk_icon_theme_choose_icon (GtkIconTheme *icon_theme,
;;;                                           const gchar *icon_names[],
;;;                                           gint size,
;;;                                           GtkIconLookupFlags flags);
;;; 
;;; Looks up a named icon and returns a structure containing information such as
;;; the filename of the icon. The icon can then be rendered into a pixbuf using
;;; gtk_icon_info_load_icon(). (gtk_icon_theme_load_icon() combines these two
;;; steps if all you need is the pixbuf.)
;;; 
;;; If icon_names contains more than one name, this function tries them all in
;;; the given order before falling back to inherited icon themes.
;;; 
;;; icon_theme :
;;;     a GtkIconTheme
;;; 
;;; icon_names :
;;;     NULL-terminated array of icon names to lookup.
;;; 
;;; size :
;;;     desired icon size
;;; 
;;; flags :
;;;     flags modifying the behavior of the icon lookup
;;; 
;;; Returns :
;;;     a GtkIconInfo structure containing information about the icon, or NULL
;;;     if the icon wasn't found. Free with gtk_icon_info_free()
;;; 
;;; Since 2.12
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_theme_lookup_by_gicon ()
;;; 
;;; GtkIconInfo * gtk_icon_theme_lookup_by_gicon (GtkIconTheme *icon_theme,
;;;                                               GIcon *icon,
;;;                                               gint size,
;;;                                               GtkIconLookupFlags flags);
;;; 
;;; Looks up an icon and returns a structure containing information such as the
;;; filename of the icon. The icon can then be rendered into a pixbuf using
;;; gtk_icon_info_load_icon().
;;; 
;;; icon_theme :
;;;     a GtkIconTheme
;;; 
;;; icon :
;;;     the GIcon to look up
;;; 
;;; size :
;;;     desired icon size
;;; 
;;; flags :
;;;     flags modifying the behavior of the icon lookup
;;; 
;;; Returns :
;;;     a GtkIconInfo structure containing information about the icon, or NULL
;;;     if the icon wasn't found. Free with gtk_icon_info_free()
;;; 
;;; Since 2.14
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_theme_load_icon ()
;;; 
;;; GdkPixbuf * gtk_icon_theme_load_icon (GtkIconTheme *icon_theme,
;;;                                       const gchar *icon_name,
;;;                                       gint size,
;;;                                       GtkIconLookupFlags flags,
;;;                                       GError **error);
;;; 
;;; Looks up an icon in an icon theme, scales it to the given size and renders
;;; it into a pixbuf. This is a convenience function; if more details about the
;;; icon are needed, use gtk_icon_theme_lookup_icon() followed by
;;; gtk_icon_info_load_icon().
;;; 
;;; Note that you probably want to listen for icon theme changes and update the
;;; icon. This is usually done by connecting to the GtkWidget::style-set signal.
;;; If for some reason you do not want to update the icon when the icon theme
;;; changes, you should consider using gdk_pixbuf_copy() to make a private copy
;;; of the pixbuf returned by this function. Otherwise GTK+ may need to keep the
;;; old icon theme loaded, which would be a waste of memory.
;;; 
;;; icon_theme :
;;;     a GtkIconTheme
;;; 
;;; icon_name :
;;;     the name of the icon to lookup
;;; 
;;; size :
;;;     the desired icon size. The resulting icon may not be exactly this size;
;;;     see gtk_icon_info_load_icon().
;;; 
;;; flags :
;;;     flags modifying the behavior of the icon lookup
;;; 
;;; error :
;;;     Location to store error information on failure, or NULL.
;;; 
;;; Returns :
;;;     the rendered icon; this may be a newly created icon or a new reference
;;;     to an internal icon, so you must not modify the icon. Use
;;;     g_object_unref() to release your reference to the icon. NULL if the
;;;     icon isn't found.
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_theme_list_contexts ()
;;; 
;;; GList * gtk_icon_theme_list_contexts (GtkIconTheme *icon_theme);
;;; 
;;; Gets the list of contexts available within the current hierarchy of icon
;;; themes
;;; 
;;; icon_theme :
;;;     a GtkIconTheme
;;; 
;;; Returns :
;;;     a GList list holding the names of all the contexts in the theme. You
;;;     must first free each element in the list with g_free(), then free the
;;;     list itself with g_list_free().
;;; 
;;; Since 2.12
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_theme_list_icons ()
;;; 
;;; GList * gtk_icon_theme_list_icons (GtkIconTheme *icon_theme,
;;;                                    const gchar *context);
;;; 
;;; Lists the icons in the current icon theme. Only a subset of the icons can
;;; be listed by providing a context string. The set of values for the context
;;; string is system dependent, but will typically include such values as
;;; "Applications" and "MimeTypes".
;;; 
;;; icon_theme :
;;;     a GtkIconTheme
;;; 
;;; context :
;;;     a string identifying a particular type of icon, or NULL to list all
;;;     icons
;;; 
;;; Returns :
;;;     a GList list holding the names of all the icons in the theme. You must
;;;     first free each element in the list with g_free(), then free the list
;;;     itself with g_list_free()
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_theme_get_icon_sizes ()
;;; 
;;; gint * gtk_icon_theme_get_icon_sizes (GtkIconTheme *icon_theme,
;;;                                       const gchar *icon_name);
;;; 
;;; Returns an array of integers describing the sizes at which the icon is
;;; available without scaling. A size of -1 means that the icon is available in
;;; a scalable format. The array is zero-terminated.
;;; 
;;; icon_theme :
;;;     a GtkIconTheme
;;; 
;;; icon_name :
;;;     the name of an icon
;;; 
;;; Returns :
;;;     An newly allocated array describing the sizes at which the icon is
;;;     available. The array should be freed with g_free() when it is no longer
;;;     needed.
;;; 
;;; Since 2.6
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_theme_get_example_icon_name ()
;;; 
;;; char * gtk_icon_theme_get_example_icon_name (GtkIconTheme *icon_theme)
;;; 
;;; Gets the name of an icon that is representative of the current theme (for
;;; instance, to use when presenting a list of themes to the user.)
;;; 
;;; icon_theme :
;;;     a GtkIconTheme
;;; 
;;; Returns :
;;;     the name of an example icon or NULL. Free with g_free().
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_theme_rescan_if_needed ()
;;; 
;;; gboolean gtk_icon_theme_rescan_if_needed (GtkIconTheme *icon_theme);
;;; 
;;; Checks to see if the icon theme has changed; if it has, any currently cached
;;; information is discarded and will be reloaded next time icon_theme is
;;; accessed.
;;; 
;;; icon_theme :
;;;     a GtkIconTheme
;;; 
;;; Returns :
;;;     TRUE if the icon theme has changed and needed to be reloaded.
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_theme_add_builtin_icon ()
;;; 
;;; void gtk_icon_theme_add_builtin_icon (const gchar *icon_name,
;;;                                       gint size,
;;;                                       GdkPixbuf *pixbuf);
;;; 
;;; Registers a built-in icon for icon theme lookups. The idea of built-in icons
;;; is to allow an application or library that uses themed icons to function
;;; requiring files to be present in the file system. For instance, the default
;;; images for all of GTK+'s stock icons are registered as built-icons.
;;; 
;;; In general, if you use gtk_icon_theme_add_builtin_icon() you should also
;;; install the icon in the icon theme, so that the icon is generally available.
;;; 
;;; This function will generally be used with pixbufs loaded via
;;; gdk_pixbuf_new_from_inline().
;;; 
;;; icon_name :
;;;     the name of the icon to register
;;; 
;;; size :
;;;     the size at which to register the icon (different images can be
;;;     registered for the same icon name at different sizes.)
;;; 
;;; pixbuf :
;;;     GdkPixbuf that contains the image to use for icon_name.
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_info_copy ()
;;; 
;;; GtkIconInfo * gtk_icon_info_copy (GtkIconInfo *icon_info);
;;; 
;;; Make a copy of a GtkIconInfo.
;;; 
;;; icon_info :
;;;     a GtkIconInfo
;;; 
;;; Returns :
;;;     the new GtkIconInfo
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_info_free ()
;;; 
;;; void gtk_icon_info_free (GtkIconInfo *icon_info);
;;; 
;;; Free a GtkIconInfo and associated information
;;; 
;;; icon_info :
;;;     a GtkIconInfo
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_info_new_for_pixbuf ()
;;; 
;;; GtkIconInfo * gtk_icon_info_new_for_pixbuf (GtkIconTheme *icon_theme,
;;;                                             GdkPixbuf *pixbuf);
;;; 
;;; Creates a GtkIconInfo for a GdkPixbuf.
;;; 
;;; icon_theme :
;;;     a GtkIconTheme
;;; 
;;; pixbuf :
;;;     the pixbuf to wrap in a GtkIconInfo
;;; 
;;; Returns :
;;;     a GtkIconInfo
;;; 
;;; Since 2.14
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_info_get_base_size ()
;;; 
;;; gint gtk_icon_info_get_base_size (GtkIconInfo *icon_info);
;;; 
;;; Gets the base size for the icon. The base size is a size for the icon that
;;; was specified by the icon theme creator. This may be different than the
;;; actual size of image; an example of this is small emblem icons that can be
;;; attached to a larger icon. These icons will be given the same base size as
;;; the larger icons to which they are attached.
;;; 
;;; icon_info :
;;;     a GtkIconInfo
;;; 
;;; Returns :
;;;     the base size, or 0, if no base size is known for the icon.
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_info_get_filename ()
;;; 
;;; const gchar * gtk_icon_info_get_filename (GtkIconInfo *icon_info);
;;; 
;;; Gets the filename for the icon. If the GTK_ICON_LOOKUP_USE_BUILTIN flag was
;;; passed to gtk_icon_theme_lookup_icon(), there may be no filename if a
;;; builtin icon is returned; in this case, you should use
;;; gtk_icon_info_get_builtin_pixbuf().
;;; 
;;; icon_info :
;;;     a GtkIconInfo
;;; 
;;; Returns :
;;;     the filename for the icon, or NULL if gtk_icon_info_get_builtin_pixbuf()
;;;     should be used instead. The return value is owned by GTK+ and should not
;;;     be modified or freed
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_info_get_builtin_pixbuf ()
;;; 
;;; GdkPixbuf * gtk_icon_info_get_builtin_pixbuf (GtkIconInfo *icon_info);
;;; 
;;; Gets the built-in image for this icon, if any. To allow GTK+ to use built in
;;; icon images, you must pass the GTK_ICON_LOOKUP_USE_BUILTIN to
;;; gtk_icon_theme_lookup_icon().
;;; 
;;; icon_info :
;;;     a GtkIconInfo structure
;;; 
;;; Returns :
;;;     the built-in image pixbuf, or NULL. No extra reference is added to the
;;;     returned pixbuf, so if you want to keep it around, you must use
;;;     g_object_ref(). The returned image must not be modified.
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_info_load_icon ()
;;; 
;;; GdkPixbuf * gtk_icon_info_load_icon (GtkIconInfo *icon_info, GError **error)
;;; 
;;; Renders an icon previously looked up in an icon theme using
;;; gtk_icon_theme_lookup_icon(); the size will be based on the size passed to
;;; gtk_icon_theme_lookup_icon(). Note that the resulting pixbuf may not be
;;; exactly this size; an icon theme may have icons that differ slightly from
;;; their nominal sizes, and in addition GTK+ will avoid scaling icons that it
;;; considers sufficiently close to the requested size or for which the source
;;; image would have to be scaled up too far. (This maintains sharpness.). This
;;; behaviour can be changed by passing the GTK_ICON_LOOKUP_FORCE_SIZE flag when
;;; obtaining the GtkIconInfo. If this flag has been specified, the pixbuf
;;; returned by this function will be scaled to the exact size.
;;; 
;;; icon_info :
;;;     a GtkIconInfo structure from gtk_icon_theme_lookup_icon()
;;; 
;;; error :
;;;     location to store error information on failure, or NULL
;;; 
;;; Returns :
;;;     the rendered icon; this may be a newly created icon or a new reference
;;;     to an internal icon, so you must not modify the icon. Use
;;;     g_object_unref() to release your reference to the icon
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_info_load_symbolic ()
;;; 
;;; GdkPixbuf * gtk_icon_info_load_symbolic (GtkIconInfo *icon_info,
;;;                                          const GdkRGBA *fg,
;;;                                          const GdkRGBA *success_color,
;;;                                          const GdkRGBA *warning_color,
;;;                                          const GdkRGBA *error_color,
;;;                                          gboolean *was_symbolic,
;;;                                          GError **error);
;;; 
;;; Loads an icon, modifying it to match the system colours for the foreground,
;;; success, warning and error colors provided. If the icon is not a symbolic
;;; one, the function will return the result from gtk_icon_info_load_icon().
;;; 
;;; This allows loading symbolic icons that will match the system theme.
;;; 
;;; Unless you are implementing a widget, you will want to use
;;; g_themed_icon_new_with_default_fallbacks() to load the icon.
;;; 
;;; As implementation details, the icon loaded needs to be of SVG type, contain
;;; the "symbolic" term as the last component of the icon name, and use the
;;; 'fg', 'success', 'warning' and 'error' CSS styles in the SVG file itself.
;;; 
;;; See the Symbolic Icons spec for more information about symbolic icons.
;;; 
;;; icon_info :
;;;     a GtkIconInfo
;;; 
;;; fg :
;;;     a GdkRGBA representing the foreground color of the icon
;;; 
;;; success_color :
;;;     a GdkRGBA representing the warning color of the icon or NULL to use the
;;;     default color
;;; 
;;; warning_color :
;;;     a GdkRGBA representing the warning color of the icon or NULL to use the
;;;     default color
;;; 
;;; error_color :
;;;     a GdkRGBA representing the error color of the icon or NULL to use the
;;;     default color (allow-none)
;;; 
;;; was_symbolic :
;;;     a gboolean, returns whether the loaded icon was a symbolic one and
;;;     whether the fg color was applied to it
;;; 
;;; error :
;;;     location to store error information on failure, or NULL
;;; 
;;; Returns :
;;;     a GdkPixbuf representing the loaded icon
;;; 
;;; Since 3.0
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_info_load_symbolic_for_style ()
;;; 
;;; GdkPixbuf * gtk_icon_info_load_symbolic_for_style (GtkIconInfo *icon_info,
;;;                                                    GtkStyle *style,
;;;                                                    GtkStateType state,
;;;                                                    gboolean *was_symbolic,
;;;                                                    GError **error);
;;; 
;;; Warning
;;; 
;;; gtk_icon_info_load_symbolic_for_style has been deprecated since version 3.0
;;; and should not be used in newly-written code. Use
;;; gtk_icon_info_load_symbolic_for_context() instead
;;; 
;;; Loads an icon, modifying it to match the system colours for the foreground,
;;; success, warning and error colors provided. If the icon is not a symbolic
;;; one, the function will return the result from gtk_icon_info_load_icon().
;;; 
;;; This allows loading symbolic icons that will match the system theme.
;;; 
;;; See gtk_icon_info_load_symbolic() for more details.
;;; 
;;; icon_info :
;;;     a GtkIconInfo
;;; 
;;; style :
;;;     a GtkStyle to take the colors from
;;; 
;;; state :
;;;     the widget state to use for colors
;;; 
;;; was_symbolic :
;;;     a gboolean, returns whether the loaded icon was a symbolic one and
;;;     whether the fg color was applied to it
;;; 
;;; error :
;;;     location to store error information on failure, or NULL
;;; 
;;; Returns :
;;;     a GdkPixbuf representing the loaded icon
;;; 
;;; Since 3.0
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_info_load_symbolic_for_context ()
;;; 
;;; GdkPixbuf * gtk_icon_info_load_symbolic_for_context
;;;                                                   (GtkIconInfo *icon_info,
;;;                                                    GtkStyleContext *context,
;;;                                                    gboolean *was_symbolic,
;;;                                                    GError **error);
;;; 
;;; Loads an icon, modifying it to match the system colors for the foreground,
;;; success, warning and error colors provided. If the icon is not a symbolic
;;; one, the function will return the result from gtk_icon_info_load_icon().
;;; This function uses the regular foreground color and the symbolic colors with
;;; the names "success_color", "warning_color" and "error_color" from the
;;; context.
;;; 
;;; This allows loading symbolic icons that will match the system theme.
;;; 
;;; See gtk_icon_info_load_symbolic() for more details.
;;; 
;;; icon_info :
;;;     a GtkIconInfo
;;; 
;;; context :
;;;     a GtkStyleContext
;;; 
;;; was_symbolic :
;;;     a gboolean, returns whether the loaded icon was a symbolic one and
;;;     whether the fg color was applied to it
;;; 
;;; error :
;;;     location to store error information on failure, or NULL
;;; 
;;; Returns :
;;;     a GdkPixbuf representing the loaded icon
;;; 
;;; Since 3.0
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_info_set_raw_coordinates ()
;;; 
;;; void gtk_icon_info_set_raw_coordinates (GtkIconInfo *icon_info,
;;;                                         gboolean raw_coordinates);
;;; 
;;; Sets whether the coordinates returned by gtk_icon_info_get_embedded_rect()
;;; and gtk_icon_info_get_attach_points() should be returned in their original
;;; form as specified in the icon theme, instead of scaled appropriately for the
;;; pixbuf returned by gtk_icon_info_load_icon().
;;; 
;;; Raw coordinates are somewhat strange; they are specified to be with respect
;;; to the unscaled pixmap for PNG and XPM icons, but for SVG icons, they are in
;;; a 1000x1000 coordinate space that is scaled to the final size of the icon.
;;; You can determine if the icon is an SVG icon by using
;;; gtk_icon_info_get_filename(), and seeing if it is non-NULL and ends in
;;; '.svg'.
;;; 
;;; This function is provided primarily to allow compatibility wrappers for
;;; older API's, and is not expected to be useful for applications.
;;; 
;;; icon_info :
;;;     a GtkIconInfo
;;; 
;;; raw_coordinates :
;;;     whether the coordinates of embedded rectangles and attached points
;;;     should be returned in their original (unscaled) form.
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_info_get_embedded_rect ()
;;; 
;;; gboolean gtk_icon_info_get_embedded_rect (GtkIconInfo *icon_info,
;;;                                           GdkRectangle *rectangle);
;;; 
;;; Gets the coordinates of a rectangle within the icon that can be used for
;;; display of information such as a preview of the contents of a text file.
;;; See gtk_icon_info_set_raw_coordinates() for further information about the
;;; coordinate system.
;;; 
;;; icon_info :
;;;     a GtkIconInfo
;;; 
;;; rectangle :
;;;     GdkRectangle in which to store embedded rectangle coordinates;
;;;     coordinates are only stored when this function returns TRUE.
;;; 
;;; Returns :
;;;     TRUE if the icon has an embedded rectangle
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_info_get_attach_points ()
;;; 
;;; gboolean gtk_icon_info_get_attach_points (GtkIconInfo *icon_info,
;;;                                           GdkPoint **points,
;;;                                           gint *n_points);
;;; 
;;; Fetches the set of attach points for an icon. An attach point is a location
;;; in the icon that can be used as anchor points for attaching emblems or
;;; overlays to the icon.
;;; 
;;; icon_info :
;;;     a GtkIconInfo
;;; 
;;; points :
;;;     location to store pointer to an array of points, or NULL free the array
;;;     of points with g_free()
;;; 
;;; n_points :
;;;     location to store the number of points in points, or NULL
;;; 
;;; Returns :
;;;     TRUE if there are any attach points for the icon.
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------

;;; ----------------------------------------------------------------------------
;;; gtk_icon_info_get_display_name ()
;;; 
;;; const gchar * gtk_icon_info_get_display_name (GtkIconInfo *icon_info);
;;; 
;;; Gets the display name for an icon. A display name is a string to be used in
;;; place of the icon name in a user visible context like a list of icons.
;;; 
;;; icon_info :
;;;     a GtkIconInfo
;;; 
;;; Returns :
;;;     the display name for the icon or NULL, if the icon doesn't have a
;;;     specified display name. This value is owned icon_info and must not be
;;;     modified or free.
;;; 
;;; Since 2.4
;;; ----------------------------------------------------------------------------


;;; --- End of file gtk.icon-theme.lisp ----------------------------------------