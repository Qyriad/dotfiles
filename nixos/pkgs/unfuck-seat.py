#!@PYTHON@

import time

from evdev import uinput, ecodes as e

with uinput.UInput() as ui:
    ui.write(e.EV_KEY, e.KEY_SPACE, 1)
    ui.syn()

    time.sleep(0.1)

    ui.write(e.EV_KEY, e.KEY_SPACE, 0)
    ui.syn()
