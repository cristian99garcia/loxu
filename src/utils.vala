/*
Copyright (C) 2015, Cristian García <cristian99garcia@gmail.com>

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
*/

namespace Loxu {

    public enum ViewMode {
        ICON,
        LIST
    }

    public enum ActivationMode {
        SINGLE,
        DOBLE
    }

    public enum SortMode {
        NAME,
        SIZE,
    }
}

namespace Utils {

    public string get_home_dir() {
        return GLib.Environment.get_home_dir();
    }

    public string get_desktop_dir() {
        return GLib.Environment.get_variable("XDG_DESKTOP_DIR");
    }

    public string get_home_dir_name() {
        return "Personal folder";
    }

    public string get_path_name(string path) {
        if (path != get_home_dir()) {
            return GLib.Path.get_basename(path);
        } else {
            return get_home_dir_name();
            //return GLib.Environment.get_real_name();
        }
    }

    public Gtk.Image get_image_from_name(string name, Gtk.IconSize size = Gtk.IconSize.BUTTON) {
        return new Gtk.Image.from_icon_name(name, size);
    }

    public void list_directory(string folder, Loxu.SortMode mode, bool reverse_sort, out GLib.List<string> folders, out GLib.List<string> files, bool hidden_files = false) {
        GLib.File file = GLib.File.new_for_path(folder);
        GLib.Cancellable cancellable = new GLib.Cancellable();

        folders = new GLib.List<string>();
        files = new GLib.List<string>();

        GLib.FileEnumerator enumerator = file.enumerate_children("standard::*", FileQueryInfoFlags.NOFOLLOW_SYMLINKS, cancellable);
	    GLib.FileInfo info = null;

        try {
            while (cancellable.is_cancelled() == false && ((info = enumerator.next_file(cancellable)) != null)) {
                string name = info.get_name();
                string path = GLib.Path.build_filename(folder, name);
                if (!info.get_is_hidden() || hidden_files) {
    	    	    if (info.get_file_type() == GLib.FileType.DIRECTORY) {
	        		    folders.append(path);
	        	    } else {
	        		    files.append(GLib.Path.build_filename(folder, info.get_name()));
	        	    }
	        	}
	        }
	    } catch (GLib.Error e) {
	        print("Error listing %s\n", folder);
	    }

	    if (reverse_sort) {
	        folders.reverse();
	        files.reverse();
	    }
    }

    public Gdk.Pixbuf get_pixbuf_from_path(string path, int size = 48) {
        Gtk.IconTheme icon_theme = Gtk.IconTheme.get_default();
        GLib.File file = GLib.File.new_for_path(path);
		GLib.FileInfo info = file.query_info("standard::icon", 0);
		GLib.Icon icon = info.get_icon();

        string[] icon_names = icon.to_string().split(" ");
        if ("image-x-generic" in icon_names) {
            return new Gdk.Pixbuf.from_file_at_size(path, size, size);
        } else {
            Gtk.IconInfo icon_info = icon_theme.choose_icon(icon_names, size, Gtk.IconLookupFlags.GENERIC_FALLBACK);
            return icon_info.load_icon();
        }
    }
}
