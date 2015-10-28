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

    public class NotebookTab: Gtk.Box {

        public string folder;

        public Gtk.Label label;
        public Gtk.Button close_button;

        public NotebookTab(string folder) {
            this.folder = folder;

            this.set_hexpand(true);

            this.label = new Gtk.Label(Utils.get_path_name(this.folder));
            this.label.set_justify(Gtk.Justification.CENTER);
            this.pack_start(this.label, true, true, 0);

            this.close_button = new Gtk.Button();
            this.close_button.set_image(Utils.get_image_from_name("window-close-symbolic"));
            this.pack_end(this.close_button, false, false, 0);

            this.show_all();
        }
    }

    public class Notebook: Gtk.Notebook {

        public signal void location_changed(string path);

        public Loxu.ViewMode view_mode = Loxu.ViewMode.ICON;

        public Notebook() {
        }

        public void add_tab(string path) {
            NotebookTab tab = new NotebookTab(path);

            Loxu.View view = new Loxu.View(path);
            view.set_view_mode(this.view_mode);
            view.location_changed.connect(this.location_changed_cb);

            this.append_page(view, tab);
            this.set_tab_reorderable(tab, true);
            this.switch_page.connect(this.page_switched);

            this.check_show_tabs();
            this.show_all();
        }

        private void page_switched(Gtk.Notebook notebook, Gtk.Widget widget, uint page_num) {
            Loxu.View view = (widget as Loxu.View);
            this.location_changed(view.folder);
        }

        private void location_changed_cb(Loxu.View view, string path) {
            this.location_changed(path);
        }

        public void check_show_tabs() {
            this.set_show_tabs(this.get_n_pages() > 1);  // FIXME: Check the user configuration too
        }

        public void set_current_folder(string path) {
            Gtk.Widget v = this.get_children().nth_data(this.get_current_page());
            Loxu.View view = (v as Loxu.View);
            view.set_folder(path);
        }

        public void set_icon_size(int size) {
            foreach (Gtk.Widget widget in this.get_children()) {
                Loxu.View view = (widget as Loxu.View);
                view.set_icon_size(size);
            }
        }

        public void set_view_mode(Loxu.ViewMode mode) {
            this.view_mode = mode;
            foreach (Gtk.Widget widget in this.get_children()) {
                Loxu.View view = (widget as Loxu.View);
                view.set_view_mode(this.view_mode);
            }
        }
    }
}
