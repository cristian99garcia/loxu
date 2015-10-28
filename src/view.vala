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

    public class IconView: Gtk.IconView {

        public signal void location_changed(string path);
        public signal void info_changed(string info);

        public string folder;
        public int icon_size = 48;
        public Loxu.ActivationMode activation_mode;
        public Gtk.ListStore model;

        public IconView(string? path = null) {
            this.model = new Gtk.ListStore(2, typeof(string), typeof(Gdk.Pixbuf));

            this.set_selection_mode(Gtk.SelectionMode.MULTIPLE);
            this.set_can_focus(true);
            this.set_model(model);
            this.set_text_column(0);
            this.set_pixbuf_column(1);
            this.set_item_padding(0);
            this.set_spacing(10);
            this.set_item_width(70);

            this.button_press_event.connect(this.button_press_event_cb);
        }

        public void set_folder(string path) {
            this.folder = path;
            this.update();
        }

        public string get_folder() {
            return this.folder;
        }

        public void set_icon_size(int size) {
            this.icon_size = size;

            switch (this.icon_size) {
                case 24:
                    this.set_item_width(30);
                    break;

                case 48:
                    this.set_item_width(50);
                    break;

                default:
                    this.set_item_width(70);
                    break;
            }
        }

        public int get_icon_size() {
            return this.icon_size;
        }

        public void set_activation_mode(Loxu.ActivationMode mode) {
            this.activation_mode = mode;
        }

        public int get_activation_mode() {
            return this.activation_mode;
        }

        private bool button_press_event_cb(Gtk.Widget self, Gdk.EventButton event) {
            int x = (int)event.x;
            int y = (int)event.y;
            Gdk.EventType activation = (this.activation_mode == Loxu.ActivationMode.SINGLE)? Gdk.EventType.BUTTON_PRESS: Gdk.EventType.2BUTTON_PRESS;

            if (event.type == activation) {
                Gtk.TreePath? path = this.get_path_at_pos(x, y);

                if (path != null) {
                    Gtk.TreeIter treeiter;
                    this.model.get_iter(out treeiter, path);
                    string directory = this.get_path_from_treeiter(treeiter);
                    this.location_changed(directory);
                }
            }
            return false;
        }

        private void update() {
            GLib.List<string> folders;
            GLib.List<string> files;
            Utils.list_directory(this.folder, out folders, out files);

            this.model.clear();

            foreach (string path in folders) {
                this.add_icon(path);
            }

            foreach (string path in files) {
                this.add_icon(path);
            }
        }

        private void add_icon(string path) {
            Gdk.Pixbuf? pixbuf = Utils.get_pixbuf_from_path(path, this.icon_size);
            if (pixbuf != null) {
		        Gtk.TreeIter iter;
			    this.model.append(out iter);
			    model.set(iter, 0, Utils.get_path_name(path), 1, pixbuf);
            } else {
                print(path + "\n");
            }
		}

		private string get_path_from_treeiter(Gtk.TreeIter treeiter) {
            string name;
            GLib.Value val;
            this.model.get_value(treeiter, 0, out val);
            name = val.get_string();
            if (name == Utils.get_home_dir_name()) {
                return Utils.get_home_dir();
            } else {
                return GLib.Path.build_filename(this.folder, name);
            }
		}
    }

    public class ListView: Gtk.TreeView {

        public signal void location_changed(string path);

        public string folder;
        public int icon_size;
        public Loxu.ActivationMode activation_mode;

        public Gtk.IconView view;
        public Gtk.ListStore model;

        public ListView() {
        }

        public void set_folder(string path) {
            this.folder = path;
            this.update();
        }

        public string get_folder() {
            return this.folder;
        }

        public void set_icon_size(int size) {
            this.icon_size = size;
        }

        public int get_icon_size() {
            return this.icon_size;
        }

        public void set_activation_mode(Loxu.ActivationMode mode) {
            this.activation_mode = mode;
        }

        public int get_activation_mode() {
            return this.activation_mode;
        }

        private void update() {
        }
    }

    public class View: Gtk.Box {

        public signal void location_changed(string path);

        public string folder;
        public int icon_size = 72;
        public Loxu.ActivationMode activation_mode = Loxu.ActivationMode.DOBLE;

        public Loxu.ViewMode view_mode;
        public Gtk.ScrolledWindow scroll_grid;
        public Gtk.ScrolledWindow scroll_list;
        public IconView icon_view;
        public ListView tree_view;

        public View(string? path = null, Loxu.ViewMode view_mode = Loxu.ViewMode.ICON) {
            this.folder = (path != null)? path: Utils.get_home_dir();
            this.view_mode = view_mode;

            this.icon_view = new IconView();
            this.icon_view.location_changed.connect(this.location_changed_cb);

            this.tree_view = new ListView();
            this.tree_view.location_changed.connect(this.location_changed_cb);

            this.scroll_grid = new Gtk.ScrolledWindow(null, null);
            this.scroll_grid.add(this.icon_view);
            this.pack_start(this.scroll_grid, true, true, 0);

            this.scroll_list = new Gtk.ScrolledWindow(null, null);
            this.scroll_list.add(this.tree_view);

            this.update();
        }

        private void update() {
            this.icon_view.set_activation_mode(this.activation_mode);
            this.icon_view.set_icon_size(this.icon_size);
            this.icon_view.set_folder(this.folder);

            this.tree_view.set_activation_mode(this.activation_mode);
            this.tree_view.set_icon_size(this.icon_size);
            this.tree_view.set_folder(this.folder);

            this.show_all();
        }

        private void location_changed_cb(Gtk.Widget view, string path) {
            this.set_folder(path);
            this.location_changed(path);
        }

        public void set_folder(string path) {
            this.folder = path;
            this.update();
        }

        public string get_folder() {
            return this.folder;
        }

        public void set_icon_size(int size) {
            this.icon_size = size;
            this.update();
        }

        public int get_icon_size() {
            return this.icon_size;
        }

        public void set_activation_mode(Loxu.ActivationMode mode) {
            this.activation_mode = mode;
        }

        public int get_activation_mode() {
            return this.activation_mode;
        }

        public void set_view_mode(Loxu.ViewMode mode) {
            if (this.view_mode == mode) {
                return;
            }

            this.view_mode = mode;

            if (this.view_mode == Loxu.ViewMode.ICON) {
                this.remove(this.scroll_list);
                this.pack_start(this.scroll_grid, true, true, 0);
            } else if (this.view_mode == Loxu.ViewMode.LIST) {
                this.remove(this.scroll_grid);
                this.pack_start(this.scroll_list, true, true, 0);
            }

            this.update();
        }

        public Loxu.ViewMode get_view_mode() {
            return this.view_mode;
        }
    }
}
