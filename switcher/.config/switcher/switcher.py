from gi.repository import Gtk
import json
import subprocess
import gi
import threading
import time
import os

gi.require_version('Gtk', '4.0')

config_path = "/home/d/.config/switcher/switcherrc"


def debug(val):
    subprocess.check_output(['notify-send', f'{val}'])


class Handler:
    def __init__(self, apps_box):
        self.apps_box = apps_box
        self.apps = []

        self.config = {}
        self.last_modified_time = 0  # Added this line
        self.load_config()

    def load_config(self):
        try:
            modified_config = json.load(open(config_path))
            if modified_config != self.config:
                self.on_config_changed(modified_config)
        except Exception as e:
            print(f"Error loading config: {e}")

    def on_config_changed(self, modified_config):
        if self.config and ' '.join(self.config['icons']) == modified_config['icons']:
            self.config['index'] = modified_config['index']
            self.on_index_changed()
        else:
            self.config = modified_config
            self.config['icons'] = self.config['icons'].split(' ')
            self.on_windows_changed()

    def on_index_changed(self):
        for idx, app in enumerate(self.apps):
            if idx == self.config['index']:
                app.set_opacity(1)
            else:
                app.set_opacity(0.5)

    def on_windows_changed(self):
        for app in self.apps:
            self.apps_box.remove(app)
        self.apps = []

        for idx, window in enumerate(self.config['windows']):
            # app box
            app = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
            app.set_spacing(20)
            app.set_margin_top(20)
            app.set_margin_bottom(20)
            app.set_margin_start(20)
            app.set_margin_end(20)

            # app icon
            icon = Gtk.Image()
            icon.set_from_file(self.config['icons'][idx])
            app.append(icon)

            # app title
            label = Gtk.Label()
            title = window['title']
            if len(title) > 12:
                title = title[:12] + '...'
            label.set_text(title)
            app.append(label)

            # workspace
            workspace = Gtk.Label()
            workspace.set_text(f'({window["workspace"]["id"]})')
            app.append(workspace)

            # app style
            if idx == self.config['index']:
                app.set_opacity(1)
            else:
                app.set_opacity(0.5)

            # append to apps_box
            self.apps_box.append(app)
            self.apps.append(app)


class PollingWatcher:
    def __init__(self, handler):
        self.handler = handler
        self.stop_event = threading.Event()

    def poll_file_changes(self):
        while not self.stop_event.is_set():
            try:
                modified_time = os.path.getmtime(config_path)
                if modified_time != self.handler.last_modified_time:
                    self.handler.load_config()
                    self.handler.last_modified_time = modified_time
            except Exception as e:
                print(f"Error polling file changes: {e}")

            time.sleep(0.1)  # Poll every 0.3 second

    def start(self):
        threading.Thread(target=self.poll_file_changes).start()

    def stop(self):
        self.stop_event.set()


class MainWindow(Gtk.ApplicationWindow):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        eck = Gtk.EventControllerKey.new()
        eck.connect("key-pressed", self.on_key_pressed)
        eck.connect("key-released", self.on_key_released)
        self.add_controller(eck)

    def focus_current(self):
        config = json.load(open(config_path))
        index = config['index']
        windows = config['windows']
        try:
            window = windows[index]
            subprocess.check_output(
                ['hyprctl', 'dispatch', 'focuswindow', f'address:{window["address"]}'])
        except Exception as e:
            print(f"Error focusing current window: {e}")

    def on_key_pressed(self, controller, keyval, keycode, state):
        if keycode == 36:
            self.focus_current()
            self.close()

    def on_key_released(self, controller, keyval, keycode, state):
        if keycode == 133:
            subprocess.check_output(
                ['hyprctl', 'dispatch', 'movetoworkspacesilent', '10,com.switcher.hypr'])
            self.focus_current()
        pass


class WindowSwitcher(Gtk.Application):
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self.connect('activate', self.on_activate)
        self.handler = None
        self.polling_watcher = None

    def on_activate(self, app):
        self.win = MainWindow(application=app)
        self.win.set_resizable(False)
        self.win.present()

        apps_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        apps_box.set_size_request(100, 100)
        self.win.set_child(apps_box)

        self.handler = Handler(apps_box)
        self.polling_watcher = PollingWatcher(self.handler)
        self.polling_watcher.start()

    def on_shutdown(self, *args):
        if self.polling_watcher:
            self.polling_watcher.stop()


if __name__ == "__main__":
    app = WindowSwitcher(application_id="com.switcher.hypr")
    app.connect("shutdown", app.on_shutdown)
    app.run()
    Gtk.main()
