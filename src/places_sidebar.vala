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

    public class Sidebar: Gtk.PlacesSidebar {

        public signal void folder_changed2(string path, Gtk.PlacesOpenFlags flag);

        public Sidebar() {
            this.set_size_request(100, 1);

            //this.open_location.connect(this.open_location_cb);
        }

        //private void open_location_cb(Gtk.PlacesSidebar self, GLib.File file, Gtk.PlacesOpenFlags flag) {
        //    this.folder_changed(file.get_path(), flag);
        //}
    }
}
