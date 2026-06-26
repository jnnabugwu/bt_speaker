#!/usr/bin/env python3
"""WS2812B LED daemon — reads JSON commands from stdin, drives a 16-LED ring via SPI."""

import json
import math
import sys
import threading
import time

import spidev

NUM_LEDS = 16
SPI_HZ = 2_400_000
RESET_BYTES = [0x00] * 50


def _encode_byte(b: int) -> list[int]:
    """Encode one WS2812B data byte into 3 SPI bytes (3 SPI bits per WS bit)."""
    result = 0
    for i in range(7, -1, -1):
        result = (result << 3) | (0b110 if (b >> i) & 1 else 0b100)
    return [(result >> 16) & 0xFF, (result >> 8) & 0xFF, result & 0xFF]


def _pixel(r: int, g: int, b: int) -> list[int]:
    """Encode one RGB pixel as 9 SPI bytes in WS2812B GRB order."""
    return _encode_byte(g) + _encode_byte(r) + _encode_byte(b)


def _send_frame(spi: spidev.SpiDev, pixels: list[tuple[int, int, int]]) -> None:
    data: list[int] = []
    for r, g, b in pixels:
        data.extend(_pixel(r, g, b))
    data.extend(RESET_BYTES)
    spi.xfer2(data)


def _scale(value: int, brightness: int) -> int:
    return int(value * brightness / 255)


def _mode_loop(spi: spidev.SpiDev, state: dict, lock: threading.Lock) -> None:
    t = 0
    while True:
        with lock:
            cmd = dict(state["cmd"])

        mode = cmd.get("mode", "off")
        r = cmd.get("r", 0)
        g = cmd.get("g", 0)
        b = cmd.get("b", 0)
        brightness = cmd.get("brightness", 255)

        if mode == "off":
            _send_frame(spi, [(0, 0, 0)] * NUM_LEDS)
            time.sleep(0.1)

        elif mode == "static" or mode == "beat_sync":
            sr = _scale(r, brightness)
            sg = _scale(g, brightness)
            sb = _scale(b, brightness)
            _send_frame(spi, [(sr, sg, sb)] * NUM_LEDS)
            time.sleep(0.1)

        elif mode == "breathe":
            # Sine envelope: period ~2 s at 30 fps (60 frames)
            breath = (math.sin(t * 2 * math.pi / 60) + 1) / 2
            combined = int(brightness * breath)
            br = _scale(r, combined)
            bg = _scale(g, combined)
            bb = _scale(b, combined)
            _send_frame(spi, [(br, bg, bb)] * NUM_LEDS)
            t = (t + 1) % 60
            time.sleep(1 / 30)

        else:
            # Unknown mode — turn off
            _send_frame(spi, [(0, 0, 0)] * NUM_LEDS)
            time.sleep(0.1)


def main() -> None:
    spi = spidev.SpiDev()
    spi.open(0, 0)
    spi.max_speed_hz = SPI_HZ
    spi.mode = 0b00

    state: dict = {"cmd": {"mode": "off", "r": 0, "g": 0, "b": 0, "brightness": 255}}
    lock = threading.Lock()

    thread = threading.Thread(target=_mode_loop, args=(spi, state, lock), daemon=True)
    thread.start()

    for line in sys.stdin:
        line = line.strip()
        if not line:
            continue
        try:
            cmd = json.loads(line)
            with lock:
                state["cmd"] = cmd
        except json.JSONDecodeError:
            pass


if __name__ == "__main__":
    main()
