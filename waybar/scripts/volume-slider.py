#!/usr/bin/env python3

import subprocess
import gi

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, Gdk


class VolumeSlider(Gtk.Window):
    def __init__(self):
        super().__init__(type=Gtk.WindowType.TOPLEVEL)

        self.set_decorated(False)
        self.set_keep_above(True)
        self.set_resizable(False)
        self.set_default_size(320, 55)
        self.set_title("Volume")

        # Close with Escape
        self.connect("key-press-event", self.on_key_press)
        self.connect("destroy", Gtk.main_quit)

        # Get current volume
        volume = self.get_volume()

        # Main container
        box = Gtk.Box(
            orientation=Gtk.Orientation.HORIZONTAL,
            spacing=10
        )
        box.set_margin_start(12)
        box.set_margin_end(12)
        box.set_margin_top(10)
        box.set_margin_bottom(10)

        # Slider
        self.slider = Gtk.Scale.new_with_range(
            Gtk.Orientation.HORIZONTAL,
            0,
            100,
            1
        )

        self.slider.set_value(volume)
        self.slider.set_draw_value(False)
        self.slider.set_hexpand(True)

        # Update volume while dragging
        self.slider.connect("value-changed", self.on_volume_changed)

        # Percentage label
        self.label = Gtk.Label()
        self.label.set_text(f"{volume}%")
        self.label.set_width_chars(4)

        box.pack_start(self.slider, True, True, 0)
        box.pack_start(self.label, False, False, 0)

        self.add(box)

        # CSS
        css = Gtk.CssProvider()
        css.load_from_data(b"""
            window {
                background-color: #292d35;
                border: 2px solid #61afef;
                border-radius: 6px;
            }

            scale trough {
                min-height: 8px;
                border-radius: 5px;
                background-color: #3b4252;
            }

            scale highlight {
                min-height: 8px;
                border-radius: 5px;
                background-color: #56b6c2;
            }

            scale slider {
                min-width: 16px;
                min-height: 16px;
                border-radius: 50%;
                background-color: #39ff14;
            }

            label {
                color: #39ff14;
                font-family: "JetBrainsMono Nerd Font";
                font-size: 14px;
                font-weight: bold;
            }
        """)

        Gtk.StyleContext.add_provider_for_screen(
            Gdk.Screen.get_default(),
            css,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )

        # Focus the window so Escape works immediately
        self.set_can_focus(True)
        self.grab_focus()

        # Put popup near mouse cursor
        self.set_position(Gtk.WindowPosition.MOUSE)

    def get_volume(self):
        try:
            result = subprocess.run(
                [
                    "wpctl",
                    "get-volume",
                    "@DEFAULT_AUDIO_SINK@"
                ],
                capture_output=True,
                text=True
            )

            output = result.stdout.strip()

            # Example:
            # Volume: 0.72
            volume = float(output.split()[1])

            return round(volume * 100)

        except Exception:
            return 50

    def on_volume_changed(self, slider):
        value = slider.get_value()
        percentage = round(value)

        self.label.set_text(f"{percentage}%")

        subprocess.run(
            [
                "wpctl",
                "set-volume",
                "@DEFAULT_AUDIO_SINK@",
                f"{percentage}%"
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )

    def on_key_press(self, window, event):
        # Escape key
        if event.keyval == Gdk.KEY_Escape:
            self.destroy()
            return True

        return False


def main():
    window = VolumeSlider()
    window.show_all()
    Gtk.main()


if __name__ == "__main__":
    main()
