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

    public enum EntryMode {
        BUTTONS,
        ENTRY
    }

    public class ButtonsBox: Gtk.Box {

        public signal void change_location(string path);

        public string folder;
        public Gee.HashMap<string, Gtk.ToggleButton> buttons;

        public ButtonsBox() {
            this.set_orientation(Gtk.Orientation.HORIZONTAL);
            this.set_hexpand(true);
            this.get_style_context().add_class("raised");
            this.get_style_context().add_class("linked");

            this.buttons = new Gee.HashMap<string, Gtk.ToggleButton>();
        }

        public void set_folder(string? p) {
            string path = (p != null)? p: Utils.get_home_dir();
            if (this.folder != null && this.folder.has_prefix(path)) {  // Python "startswith" function
                //this.active_button(this.buttons[folder]);
                //this.buttons[folder].set_active(true);
                this.folder = path;
                return;
            }

            this.folder = path;
            this.buttons = new Gee.HashMap<string, Gtk.ToggleButton>();  // Remove all previus data;

            foreach (Gtk.Widget w in this.get_children()) {
                this.remove(w);
            }

            string[] folders;
            bool home = this.folder.has_prefix(Utils.get_home_dir());
            string current_folder = "";

            if (!home) {
                folders = this.folder.split("/");
                folders += "/";
            } else {
                folders = { Utils.get_home_dir_name() };
                string next = this.folder.slice(Utils.get_home_dir().length, this.folder.length);
                foreach (string folder in next.split("/")) {
                    folders += ("/" + folder);
                }
            }

            Gtk.ToggleButton active_button = new Gtk.ToggleButton();

            foreach (string? f in folders) {
                if (f == null || f == "") {
                    continue;
                }

                string folder;
                Gtk.Label label = new Gtk.Label(f);

                Gtk.ToggleButton button = new Gtk.ToggleButton();
                button.set_data("label", label);
                button.toggled.connect(this.button_active);
                this.pack_start(button, false, false, 0);

                active_button = button;

                Gtk.Box box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
                button.add(box);

                if (f == "") {
                    continue;
                } else if (f == Utils.get_home_dir_name()) {
                    folder = Utils.get_home_dir();
                    box.pack_start(Utils.get_image_from_name("go-home-symbolic"), false, false, 1);
                    box.pack_start(label, false, false, 0);
                } else {
                    box.pack_start(label, false, false, 0);
                    folder = current_folder + "/" + f;
                }

                current_folder += (f == Utils.get_home_dir_name()? "": "/") + folder;
                button.set_data("folder", current_folder);
                this.buttons[current_folder] = button;
            }

            active_button.set_active(true);
            this.show_all();
        }

        private void button_active(Gtk.ToggleButton button) {
            //Gtk.Label label = button.get_data("label");
            if (button.get_active()) {
                //label.set_markup("<b>%s</b>".printf(label.get_label()));
            } else {
                //label.set_markup(label.get_label());
            }
            //this.change_location(button.get_data);
        }
    }

    public class EntryLocation: Gtk.Box {

        public signal void change_location(string path);

        public string folder;

        public Gtk.Entry entry;
        public ButtonsBox buttons_box;

        public EntryLocation(string? path = null) {
            this.entry = new Gtk.Entry();
            this.entry.activate.connect(this.activate_cb);
            this.entry.focus_out_event.connect(this.focus_out_cb);
            this.entry.key_release_event.connect(this.key_release_cb);
            this.entry.set_hexpand(true);

            this.buttons_box = new ButtonsBox();

            this.set_orientation(Gtk.Orientation.HORIZONTAL);
            this.set_folder(path);
        }

        private void activate_cb(Gtk.Entry entry) {
            this.change_location(this.entry.get_text());
        }

        private bool focus_out_cb(Gtk.Widget self, Gdk.EventFocus event) {
            if (this.get_parent() != null) {
                //this.show_title();
            }

            return false;
        }

        private bool key_release_cb(Gtk.Widget self, Gdk.EventKey event) {
            if ((int)event.keyval == Gdk.Key.Escape) {
                //this.show_title();
            }
            return false;
        }

        public void set_folder(string? path = null) {
            this.folder = (path != null)? path: Utils.get_home_dir();  // path only if isn't null
            //this.set_mode(EntryMode.BUTTONS);
        }

        public string get_folder() {
            return this.folder;
        }

        public void set_mode(EntryMode mode) {
            switch (mode) {
                case EntryMode.BUTTONS:
                    if (this.entry.get_parent() != null) {
                        this.remove(this.entry);
                    }

                    if (this.buttons_box.get_parent() == null) {
                        this.buttons_box.set_folder(this.folder);
                        this.pack_start(this.buttons_box, true, true, 0);
                    }
                    break;

                case EntryMode.ENTRY:
                    if (this.entry.get_parent() == null) {
                        this.entry.set_text(this.folder);
                        this.pack_start(this.entry, true, true, 0);
                    }

                    if (this.buttons_box.get_parent() != null) {
                        this.remove(this.buttons_box);
                    }
                    break;
            }
            this.show_all();
        }
    }
}
