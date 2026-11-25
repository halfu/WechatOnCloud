#!/usr/bin/env python3
import ctypes
import os
import subprocess
import time

DISPLAY = os.environ.get("DISPLAY", ":1").encode()
CHECK_INTERVAL = 1.5
STUCK_THRESHOLD = 3  # 3 * 1.5s = 4.5s motionless while grabbed with Button1 pressed

x11 = ctypes.cdll.LoadLibrary("libX11.so.6")
x11.XOpenDisplay.restype = ctypes.c_void_p

def log(msg):
    ts = time.strftime("%Y-%m-%d %H:%M:%S")
    print(f"[woc-pointer-watchdog {ts}] {msg}", flush=True)

def main():
    dpy = None
    while not dpy:
        dpy = x11.XOpenDisplay(DISPLAY)
        if not dpy:
            time.sleep(2)
    root = x11.XDefaultRootWindow(ctypes.c_void_p(dpy))

    stuck_count = 0
    last_pos = None

    while True:
        time.sleep(CHECK_INTERVAL)
        try:
            pg = x11.XGrabPointer(ctypes.c_void_p(dpy), root, 0, 0, 1, 1, 0, 0, 0)
            if pg == 0:
                x11.XUngrabPointer(ctypes.c_void_p(dpy), 0)
                x11.XFlush(ctypes.c_void_p(dpy))
                stuck_count = 0
                last_pos = None
                continue

            r_ret, c_ret = ctypes.c_ulong(), ctypes.c_ulong()
            rx, ry, wx, wy = ctypes.c_int(), ctypes.c_int(), ctypes.c_int(), ctypes.c_int()
            mask = ctypes.c_uint()
            x11.XQueryPointer(
                ctypes.c_void_p(dpy), root,
                ctypes.byref(r_ret), ctypes.byref(c_ret),
                ctypes.byref(rx), ctypes.byref(ry),
                ctypes.byref(wx), ctypes.byref(wy),
                ctypes.byref(mask),
            )
            pos = (rx.value, ry.value)
            btn1_held = bool(mask.value & 0x100)

            if (btn1_held or pg == 4) and (last_pos is None or pos == last_pos):
                stuck_count += 1
            else:
                stuck_count = 0
            last_pos = pos

            if stuck_count >= STUCK_THRESHOLD:
                log(f"Detected frozen pointer grab (pg={pg}, mask={hex(mask.value)}, pos={pos}) for {stuck_count * CHECK_INTERVAL:.1f}s -> recovering openbox")
                subprocess.run(["pkill", "-9", "-u", "abc", "-x", "openbox"], check=False)
                time.sleep(1.2)
                subprocess.run(["xdotool", "mouseup", "1"], env={**os.environ, "DISPLAY": DISPLAY.decode()}, check=False)
                stuck_count = 0
                last_pos = None
        except Exception as e:
            log(f"Error: {e}")
            time.sleep(2)

if __name__ == "__main__":
    main()
