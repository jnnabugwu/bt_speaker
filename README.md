# BT Speaker Studio

A Flutter-embedded project that turns a Raspberry Pi Zero 2 W into a Bluetooth speaker display. A companion phone app connects over WebSocket and controls an on-screen audio visualizer, real-time EQ settings, and a WS2812B LED ring that pulses to the beat.

---

## Hardware

| Component | Details |
| --- | --- |
| **Raspberry Pi Zero 2 W** | Quad-core ARM Cortex-A53 @ 1 GHz, 512 MB RAM. |
| **HDMI Display** | Drives the Flutter visualizer UI via flutter-pi (DRM/KMS, no X server) |
| **WS2812B 16-LED Ring** | Addressable RGB ring wired to GPIO 10 (SPI). Syncs to beat data |
| **MAX98357A I2S Amp** | *(Phase 2)* I2S DAC/amp for audio output |

---

## Architecture

The project is a Melos monorepo with three packages:

```text
apps/
  pi_app/          — Flutter app running on the Pi via flutter-pi
  phone_app/       — Flutter companion app (iOS/Android)
packages/
  bt_speaker_core/ — Shared data models (BeatData, NowPlaying, EqSettings, LedCommand)
```

**Communication layer:** The Pi runs a WebSocket server on port 8080. The phone app connects as a client and sends typed JSON messages. The Pi app parses them into typed events (`BeatEvent`, `LedEvent`, `EqEvent`, `NowPlayingEvent`) via a sealed class hierarchy.

**Pi app state management:** Each feature has its own BLoC that subscribes to the shared WebSocket event stream and exposes typed state to the UI:

- `ConnectionBloc` — connection status (`waiting` / `connected`)
- `VisualizerBloc` — live `BeatData` (FFT bars, BPM, intensity)
- `NowPlayingBloc` — current track metadata (title, artist, album art, progress)
- `EqBloc` — equalizer settings (bass, mid, treble)
- `LedBloc` — LED mode and color commands

**Rendering:** The visualizer uses a `CustomPainter` drawing FFT frequency bars directly to a `Canvas` at the WebSocket data rate (~30–60 Hz) with no intermediate animation controller, suited for the Pi Zero 2 W's quad-core ARM.

---

## Tech Stack

- **Flutter 3.x** + **flutter-pi** (embedded Linux, DRM/KMS)
- **flutter_bloc** — state management
- **Melos** — monorepo scripts (analyze, format, test)
- **dart_periphery** *(planned)* — GPIO/SPI for LED ring
- **CI:** GitHub Actions matrix across all three packages with coverage upload to Codecov
