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

public class Application: Gtk.Application {

    string[] init_paths;

    public Application(string[] paths) {
		Object(application_id: "org.lestim.loxu", flags: GLib.ApplicationFlags.FLAGS_NONE);
        this.init_paths = paths;
    }

    protected override void activate() {
        this.new_window(this.init_paths);
    }

    public void new_window(string[]? paths = null) {
        Loxu.Window win = new Loxu.Window(paths);
        win.set_application(this);
        this.add_window(win);
    }
}

void main(string[] args) {
    string[] paths = {};
    bool add = false;

    foreach (string path in args) {
        if (add && path != null) {
            paths += path;
        }
        add = true;
    }

    Application application = new Application(paths);
    application.run();
}
