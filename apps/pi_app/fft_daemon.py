#!/usr/bin/env python3
"""FFT daemon — reads ALSA loopback audio, emits BeatData JSON on stdout at 30 fps."""

import json
import sys
import time

import numpy as np
import sounddevice as sd

SAMPLE_RATE = 44_100
CHUNK = 1024
NUM_BARS = 16
TARGET_FPS = 30
DEVICE = "hw:Loopback,1,0"

# Log-spaced frequency bin edges from 60 Hz to 16 kHz
_FREQ_EDGES = np.logspace(np.log10(60), np.log10(16_000), NUM_BARS + 1)

# BPM estimation state
_onset_history: list[float] = []
_prev_magnitude: np.ndarray | None = None
_last_peak_time: float = 0.0
_bpm_estimate: int = 0


def _compute_bars(samples: np.ndarray) -> list[float]:
    windowed = samples * np.hanning(len(samples))
    spectrum = np.abs(np.fft.rfft(windowed))
    freqs = np.fft.rfftfreq(len(samples), d=1.0 / SAMPLE_RATE)

    bars: list[float] = []
    for i in range(NUM_BARS):
        lo, hi = _FREQ_EDGES[i], _FREQ_EDGES[i + 1]
        mask = (freqs >= lo) & (freqs < hi)
        bars.append(float(np.mean(spectrum[mask])) if mask.any() else 0.0)

    peak = max(bars) if bars else 1.0
    if peak > 0:
        bars = [b / peak for b in bars]
    return bars


def _compute_intensity(samples: np.ndarray) -> float:
    rms = float(np.sqrt(np.mean(samples ** 2)))
    # Normalise roughly to 0–1 assuming 16-bit audio in float32 (-1..1)
    return min(rms * 10.0, 1.0)


def _update_bpm(magnitude: np.ndarray, now: float) -> int:
    global _prev_magnitude, _last_peak_time, _bpm_estimate, _onset_history

    if _prev_magnitude is not None:
        flux = float(np.sum(np.maximum(magnitude - _prev_magnitude, 0)))
        _onset_history.append(flux)
        if len(_onset_history) > 60:
            _onset_history.pop(0)

        threshold = np.mean(_onset_history) * 1.5 if _onset_history else 0
        if flux > threshold and (now - _last_peak_time) > 0.3:
            if _last_peak_time > 0:
                interval = now - _last_peak_time
                _bpm_estimate = int(60.0 / interval)
                _bpm_estimate = max(40, min(_bpm_estimate, 220))
            _last_peak_time = now

    _prev_magnitude = magnitude.copy()
    return _bpm_estimate


def main() -> None:
    interval = 1.0 / TARGET_FPS

    with sd.InputStream(
        device=DEVICE,
        channels=1,
        samplerate=SAMPLE_RATE,
        blocksize=CHUNK,
        dtype="float32",
    ) as stream:
        while True:
            t0 = time.monotonic()
            data, _ = stream.read(CHUNK)
            samples = data[:, 0]

            bars = _compute_bars(samples)
            intensity = _compute_intensity(samples)
            magnitude = np.abs(np.fft.rfft(samples * np.hanning(len(samples))))
            bpm = _update_bpm(magnitude, t0)

            payload = {
                "type": "beat",
                "bpm": bpm,
                "intensity": round(intensity, 4),
                "fft_bars": [round(b, 4) for b in bars],
            }
            sys.stdout.write(json.dumps(payload) + "\n")
            sys.stdout.flush()

            elapsed = time.monotonic() - t0
            if elapsed < interval:
                time.sleep(interval - elapsed)


if __name__ == "__main__":
    main()
