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

    public class ViewPopover: Gtk.Popover {

        public signal void icon_size_changed(int size);

        private Gtk.Box box;

        public ViewPopover() {
            this.box = new Gtk.Box(Gtk.Orientation.VERTICAL, 0);
            this.box.set_border_width(9);
            this.box.set_size_request(160, 1);
            this.box.set_vexpand(false);
            this.box.set_can_focus(false);
            this.add(this.box);

            Gtk.Box box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            box.get_style_context().add_class("linked");
            box.set_margin_bottom(6);
            this.box.pack_start(box, false, false, 0);

            GLib.Icon grid_icon = GLib.Icon.new_for_string("view-grid-symbolic");

            Gtk.ModelButton grid_button = new Gtk.ModelButton();
            grid_button.text = "Grid";
            grid_button.iconic = true;
            grid_button.centered = true;
            grid_button.icon = grid_icon;
            box.pack_start(grid_button, true, true, 0);

            GLib.Icon list_icon = GLib.Icon.new_for_string("view-list-symbolic");

            Gtk.ModelButton list_button = new Gtk.ModelButton();
            list_button.text = "List";
            list_button.iconic = true;
            list_button.centered = true;
            list_button.icon = list_icon;
            box.pack_start(list_button, true, true, 0);

            Gtk.Scale scale = new Gtk.Scale.with_range(Gtk.Orientation.HORIZONTAL, 1, 5, 1);
            scale.set_draw_value(false);
            scale.set_has_origin(false);
            scale.set_round_digits(0);
            scale.set_restrict_to_fill_level(false);
            scale.set_value(2);

            for (int i=1; i<=5; i++) {
                scale.add_mark(i, Gtk.PositionType.BOTTOM, null);
            }

            scale.value_changed.connect(() => {
                this.icon_size_changed((int)scale.get_value() * 24);
            });

            this.box.pack_start(scale, false, false, 0);
        }
    }

    public class HeaderBar: Gtk.HeaderBar {

        public signal void location_changed(string path);
        public signal void icon_size_changed(int size);

        public string folder;

        public Gtk.Button back_button;
        public Gtk.Button forward_button;
        public Gtk.Button up_button;
        public Loxu.EntryLocation entry;
        public Gtk.ToggleButton menu_button;
        public ViewPopover view_popover;

        public HeaderBar(string? path = null) {
            Gtk.Box box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
            box.get_style_context().add_class("raised");
            box.get_style_context().add_class("linked");
            this.pack_start(box);

            this.back_button = new Gtk.Button();
            this.back_button.get_style_context().add_class("image-button");
            this.back_button.set_image(Utils.get_image_from_name("go-previous-symbolic"));
            this.back_button.set_valign(Gtk.Align.CENTER);
            this.back_button.set_sensitive(false);
            box.add(this.back_button);

            this.forward_button = new Gtk.Button();
            this.forward_button.get_style_context().add_class("image-button");
            this.forward_button.set_image(new Gtk.Image());
            this.forward_button.set_image(Utils.get_image_from_name("go-next-symbolic"));
            this.forward_button.set_valign(Gtk.Align.CENTER);
            this.forward_button.set_sensitive(false);
            box.add(this.forward_button);

            this.up_button = new Gtk.Button();
            this.up_button.get_style_context().add_class("image-button");
            this.up_button.set_image(new Gtk.Image());
            this.up_button.set_image(Utils.get_image_from_name("go-up-symbolic"));
            this.up_button.set_valign(Gtk.Align.CENTER);
            this.up_button.clicked.connect(this.go_up);
            box.add(this.up_button);

            this.entry = new Loxu.EntryLocation();
            //this.entry.change_location.connect(this.change_location_cb);
            this.pack_start(this.entry);

            this.menu_button = new Gtk.ToggleButton();
            this.menu_button.set_image(Utils.get_image_from_name("view-grid-symbolic"));
            this.menu_button.toggled.connect(this.show_view_popover);
            this.pack_end(this.menu_button);

            this.view_popover = new ViewPopover();
            this.view_popover.set_relative_to(this.menu_button);

            this.view_popover.hide.connect(() => {
                this.menu_button.set_active(false);
            });

            this.view_popover.icon_size_changed.connect((size) => {
                this.icon_size_changed(size);
            });

            this.view_popover.hide();

            this.set_folder(path, false);
            this.set_show_close_button(true);
        }

        public void set_folder(string? path = null, bool show_entry = false) {
            this.folder = (path != null)? path: Utils.get_home_dir();
            this.entry.set_folder(this.folder);
            this.entry.set_mode(show_entry? Loxu.EntryMode.ENTRY: Loxu.EntryMode.BUTTONS);

            this.up_button.set_sensitive(this.folder != "/");
        }

        private void change_location_cb(Loxu.EntryLocation entry) {
            this.entry.set_mode(Loxu.EntryMode.BUTTONS);
        }

        private void go_up(Gtk.Button button) {
            string path = GLib.Path.get_dirname(this.folder);
            this.set_folder(path);
            this.location_changed(path);
        }

        private void show_view_popover(Gtk.ToggleButton button) {
            if (button.get_active()) {
                this.view_popover.show_all();
            } else if (!button.get_active() || !this.view_popover.get_visible()) {
                this.view_popover.hide();
            }
        }
    }
}
