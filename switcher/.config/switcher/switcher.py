import json
from watchdog.events import FileSystemEventHandler
from watchdog.observers import Observer
from gi.repository import Gtk
import gi
import subprocess
import time
gi.require_version('Gtk', '4.0')

config_path = "/home/d/.config/switcher/switcherrc"


def debug(var):
    subprocess.check_output(['notify-send', f'{var}{time.time()}'])


class Handler(FileSystemEventHandler):
    def __init__(self, apps_box) -> None:
        super().__init__()
        self.apps_box = apps_box
        self.apps = []

        self.config = {}
        self.load_config()

    def on_any_event(self, event):
        if event.is_directory:
            return None

        elif event.event_type == 'modified':
            self.load_config()

    def load_config(self):
        try:
            modified_config = json.load(open(config_path))
            if modified_config != self.config:
                self.on_config_changed(modified_config)
        except:
            pass

    def on_config_changed(self, modified_config):
        if self.config:
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

            # app style
            if idx == self.config['index']:
                app.set_opacity(1)
            else:
                app.set_opacity(0.5)

            # append to apps_box
            self.apps_box.append(app)
            self.apps.append(app)
        pass


class Watcher:
    def __init__(self, apps_box):
        self.observer = Observer()
        self.apps_box = apps_box

    def run(self):
        event_handler = Handler(self.apps_box)
        self.observer.schedule(
            event_handler, config_path, recursive=True)
        self.observer.start()


class MainWindow(Gtk.ApplicationWindow):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        apps_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL)
        self.set_child(apps_box)

        eck = Gtk.EventControllerKey.new()
        eck.connect("key-released", self.on_key_released)
        self.add_controller(eck)

        watcher = Watcher(apps_box)
        watcher.run()

    def focus_current(self):
        config = json.load(open(config_path))
        subprocess.check_output(
            ['hyprctl', 'dispatch', 'focuswindow', f'address:{config["windows"][config["index"]]["address"]}'])

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

    def on_activate(self, app):
        self.win = MainWindow(application=app)
        self.win.set_resizable(False)
        self.win.present()


app = WindowSwitcher(application_id="com.switcher.hypr")
app.run()
