#!/usr/bin/env python3

import subprocess
import gi

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, Gdk


class BrightnessSlider(Gtk.Window):
    def __init__(self):
        super().__init__(type=Gtk.WindowType.TOPLEVEL)

        self.set_decorated(False)
        self.set_keep_above(True)
        self.set_resizable(False)
        self.set_default_size(320, 55)
        self.set_title("Brightness")

        # Close with Escape
        self.connect("key-press-event", self.on_key_press)

        # Close GTK when the window is destroyed
        self.connect("destroy", Gtk.main_quit)

        # Get the actual current brightness percentage
        brightness = self.get_brightness()

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

        self.slider.set_value(brightness)
        self.slider.set_draw_value(False)
        self.slider.set_hexpand(True)

        self.slider.connect(
            "value-changed",
            self.on_brightness_changed
        )

        # Percentage label
        self.label = Gtk.Label()
        self.label.set_text(f"{brightness}%")
        self.label.set_width_chars(4)

        box.pack_start(
            self.slider,
            True,
            True,
            0
        )

        box.pack_start(
            self.label,
            False,
            False,
            0
        )

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

        # Make sure the window receives keyboard input
        self.set_can_focus(True)
        self.grab_focus()

        # Open near the mouse for now
        self.set_position(Gtk.WindowPosition.MOUSE)

    def get_brightness(self):
        try:
            result = subprocess.run(
                ["brightnessctl", "-m"],
                capture_output=True,
                text=True
            )

            output = result.stdout.strip()

            # Your system outputs:
            #
            # intel_backlight,backlight,24960,26%,96000
            #
            # Fields:
            # 0 = device
            # 1 = type
            # 2 = current raw brightness
            # 3 = current percentage
            # 4 = maximum raw brightness

            fields = output.split(",")

            percentage = fields[3].replace("%", "").strip()

            return max(
                0,
                min(100, int(percentage))
            )

        except Exception:
            return 50

    def on_brightness_changed(self, slider):
        value = round(slider.get_value())

        # Update percentage text
        self.label.set_text(f"{value}%")

        # Change actual brightness
        subprocess.run(
            [
                "brightnessctl",
                "set",
                f"{value}%"
            ],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )

    def on_key_press(self, window, event):
        # Escape closes the popup
        if event.keyval == Gdk.KEY_Escape:
            self.destroy()
            return True

        return False


def main():
    window = BrightnessSlider()
    window.show_all()

    Gtk.main()


if __name__ == "__main__":
    main()
