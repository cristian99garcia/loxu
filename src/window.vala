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

    public class Window: Gtk.ApplicationWindow {

        public Loxu.HeaderBar headerbar;
        public Loxu.Notebook notebook;
        public Gtk.PlacesSidebar sidebar;

        public Window(string[] paths) {
            this.set_size_request(620, 400);

            this.headerbar = new Loxu.HeaderBar();

            this.headerbar.location_changed.connect((path) => {
                this.notebook.set_current_folder(path);
            });

            this.headerbar.icon_size_changed.connect((size) => {
                this.notebook.set_icon_size(size);
            });

            this.headerbar.view_mode_changed.connect((mode) => {
                this.notebook.set_view_mode(mode);
            });

            this.set_titlebar(this.headerbar);

            Gtk.Paned paned = new Gtk.Paned(Gtk.Orientation.HORIZONTAL);
            paned.set_wide_handle(false);
            this.add(paned);

            this.sidebar = new Gtk.PlacesSidebar();
            this.sidebar.set_show_trash(false);
            this.sidebar.set_local_only(true);
            sidebar.open_location.connect(this.open_location_sidebar);
            paned.add1(this.sidebar);

            this.notebook = new Loxu.Notebook();
            this.notebook.location_changed.connect(this.location_changed_notebook);
            paned.add2(this.notebook);

            this.add_tabs(paths);
            this.show_all();
        }

        public void add_tabs(string[] p) {
            string[] paths;
            if (p.length == 0) {
                paths = { Utils.get_home_dir() };
            } else {
                paths = p;
            }

            foreach (string path in paths) {
                this.notebook.add_tab(path);
            }
        }

        private void location_changed_notebook(Loxu.Notebook notebook, string path) {
            this.headerbar.set_folder(path);
        }

        private void open_location_sidebar(Gtk.PlacesSidebar sidebar, GLib.File file, Gtk.PlacesOpenFlags flag) {
            string path = file.get_path();
            switch (flag) {
                case Gtk.PlacesOpenFlags.NORMAL:
                    this.notebook.set_current_folder(path);
                    this.headerbar.set_folder(path);
                    break;

                case Gtk.PlacesOpenFlags.NEW_TAB:
                    this.notebook.add_tab(path);
                    break;

                case Gtk.PlacesOpenFlags.NEW_WINDOW:
                    break;
            }
        }
    }
}
