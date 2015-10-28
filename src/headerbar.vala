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

        public signal void view_mode_changed(Loxu.ViewMode mode);
        public signal void icon_size_changed(int size);
        public signal void sort_mode_changed(Loxu.SortMode mode);
        public signal void reverse_changed(bool reverse);

        private Gtk.Box box;
        private Gtk.ToggleButton grid_button;
        private Gtk.ToggleButton list_button;

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

            Gtk.Image grid_image = new Gtk.Image.from_icon_name("view-grid-symbolic", Gtk.IconSize.BUTTON);

            this.grid_button = new Gtk.ToggleButton();
            this.grid_button.set_tooltip_text("Grid");
            this.grid_button.set_active(true);
            this.grid_button.add(grid_image);
            this.grid_button.toggled.connect(this.view_mode_toggled);
            box.pack_start(this.grid_button, true, true, 0);

            Gtk.Image list_image = new Gtk.Image.from_icon_name("view-list-symbolic", Gtk.IconSize.BUTTON);

            this.list_button = new Gtk.ToggleButton();
            this.list_button.set_tooltip_text("List");
            this.list_button.add(list_image);
            this.list_button.toggled.connect(this.view_mode_toggled);
            box.pack_start(this.list_button, true, true, 0);

            Gtk.Scale scale = new Gtk.Scale.with_range(Gtk.Orientation.HORIZONTAL, 1, 5, 1);
            scale.set_draw_value(false);
            scale.set_has_origin(false);
            scale.set_round_digits(0);
            scale.set_restrict_to_fill_level(false);
            scale.set_value(3);

            for (int i=1; i<=5; i++) {
                scale.add_mark(i, Gtk.PositionType.BOTTOM, null);
            }

            scale.value_changed.connect(() => {
                this.icon_size_changed((int)scale.get_value() * 24);
            });

            this.box.pack_start(scale, false, false, 0);

            this.box.pack_start(new Gtk.Separator(Gtk.Orientation.HORIZONTAL), false, false, 10);

            Gtk.Label label = new Gtk.Label("Sort");
            label.set_sensitive(false);
            label.set_xalign(0);
            this.box.pack_start(label, false, false, 0);

            Gtk.RadioButton name_radio_button = new Gtk.RadioButton.with_label(null, "Name");
            this.box.pack_start(name_radio_button, false, false, 0);

            name_radio_button.toggled.connect(() => {
                if (name_radio_button.get_active()) {
                    this.sort_mode_changed(Loxu.SortMode.NAME);
                }
            });

            Gtk.RadioButton size_radio_button = new Gtk.RadioButton.with_label_from_widget(name_radio_button, "Size");
            this.box.pack_start(size_radio_button, false, false, 0);

            size_radio_button.toggled.connect(() => {
                if (size_radio_button.get_active()) {
                    this.sort_mode_changed(Loxu.SortMode.SIZE);
                }
            });

            Gtk.CheckButton sort_reverse = new Gtk.CheckButton.with_label("Reverse");
            this.box.pack_start(sort_reverse, false, false, 0);

            this.box.pack_start(new Gtk.Separator(Gtk.Orientation.HORIZONTAL), false, false, 10);

            Gtk.CheckButton show_hidden = new Gtk.CheckButton.with_label("Show hidden files");
            this.box.pack_start(show_hidden, false, false, 0);
        }

        private void view_mode_toggled(Gtk.ToggleButton button) {
            if (button.get_active()) {
                if (button == this.grid_button) {
                    this.list_button.set_active(false);
                    this.view_mode_changed(Loxu.ViewMode.ICON);
                } else if (button == this.list_button) {
                    this.grid_button.set_active(false);
                    this.view_mode_changed(Loxu.ViewMode.LIST);
                }
            }
        }
    }

    public class OptionsPopover: Gtk.Popover {

        public OptionsPopover() {
        }
    }

    public class HeaderBar: Gtk.HeaderBar {

        public signal void location_changed(string path);
        public signal void icon_size_changed(int size);
        public signal void view_mode_changed(Loxu.ViewMode mode);

        public string folder;

        public Gtk.Button back_button;
        public Gtk.Button forward_button;
        public Gtk.Button up_button;
        public Loxu.EntryLocation entry;
        public OptionsPopover options_popover;
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
            this.entry.change_location.connect(this.change_location_cb);
            this.pack_start(this.entry);

            Gtk.ToggleButton options_button = new Gtk.ToggleButton();
            options_button.set_image(Utils.get_image_from_name("view-more-symbolic"));
            this.pack_end(options_button);

            this.options_popover = new OptionsPopover();
            this.options_popover.set_relative_to(options_button);
            this.options_popover.hide();

            this.options_popover.hide.connect(() => {
                options_button.set_active(false);
            });

            Gtk.ToggleButton view_button = new Gtk.ToggleButton();
            view_button.set_image(Utils.get_image_from_name("view-grid-symbolic"));
            view_button.toggled.connect(this.show_view_popover);
            this.pack_end(view_button);

            this.view_popover = new ViewPopover();
            this.view_popover.set_relative_to(view_button);
            this.view_popover.hide();

            this.view_popover.hide.connect(() => {
                view_button.set_active(false);
            });

            this.view_popover.icon_size_changed.connect((size) => {
                this.icon_size_changed(size);
            });

            this.view_popover.view_mode_changed.connect((mode) => {
                this.view_mode_changed(mode);
            });

            this.set_folder(path, false);
            this.set_show_close_button(true);
        }

        public void set_folder(string? path = null, bool show_entry = false) {
            this.folder = (path != null)? path: Utils.get_home_dir();
            this.entry.set_folder(this.folder);
            this.entry.set_mode(show_entry? Loxu.EntryMode.ENTRY: Loxu.EntryMode.BUTTONS);

            this.up_button.set_sensitive(this.folder != "/");
        }

        private void change_location_cb(Loxu.EntryLocation entry, string path) {
            this.set_folder(path);
            this.location_changed(path);
            //this.entry.set_mode(Loxu.EntryMode.BUTTONS);
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

        private void show_options_popover(Gtk.ToggleButton button) {
            if (button.get_active()) {
                this.options_popover.show_all();
            } else if (!button.get_active() || !this.options_popover.get_visible()) {
                this.options_popover.hide();
            }
        }
    }
}
