# BT Speaker — Project Spec

## Overview

Two Flutter apps working together:

- **Pi app** — runs on the Raspberry Pi Zero WH display. Always on.
  Shows the visualizer and reacts to beat data from the phone.
- **Phone app** — runs on iOS/Android. Remote control for everything.
  Captures mic audio, sends beat data to Pi, controls EQ and LEDs.

---

## Pi App — Requirements

### Connection

- [ ] Starts a WebSocket server on port 8080 on boot
- [ ] Accepts one phone client connection at a time
- [ ] Shows a "Waiting for connection..." state when no phone is connected
- [ ] Shows a "Connected" state when phone joins
- [ ] Handles phone disconnect gracefully — returns to waiting state without crashing

### Visualizer

- [ ] Renders a fullscreen audio visualizer using CustomPainter
- [ ] Reacts to FFT bar data received from the phone via WebSocket
- [ ] Supports at least two visualizer modes: bar graph and radial/bloom
- [ ] Visualizer is animated — bars move smoothly, not jumpy
- [ ] Background is dark (black or near-black) so LEDs and bars pop
- [ ] Shows current track title and artist when Now Playing data is received
- [ ] Shows album art when provided (as base64 image payload)

### LED Control

- [ ] Drives WS2812B LED ring on GPIO10 via Python subprocess
- [ ] Supports 4 LED modes: static, beat-sync, breathe, off
- [ ] In beat-sync mode: LED brightness maps to beat intensity from phone
- [ ] In static mode: holds the last color sent from phone
- [ ] In breathe mode: slow pulse independent of beat data
- [ ] LED updates do not block the UI thread

### Display

- [ ] App runs fullscreen — no title bar, no navigation bar, no cursor
- [ ] No Flutter debug banner in release mode
- [ ] Renders correctly on 800x480 display resolution
- [ ] Does not show any system UI overlays

### Reliability

- [ ] App auto-launches on Pi boot via systemd service
- [ ] If app crashes, systemd restarts it within 5 seconds
- [ ] App does not require SSH or keyboard to operate after setup

---

## Phone App — Requirements

### Connection Screen

- [ ] Text field to enter Pi IP address
- [ ] Connect button that initiates WebSocket connection
- [ ] Shows connecting / connected / failed states clearly
- [ ] Remembers last used IP address (persisted via Hive)
- [ ] Disconnect button available from any screen

### Visualizer Screen

- [ ] Captures mic audio using the `record` package
- [ ] Runs FFT analysis in a Dart Isolate — not on the main thread
- [ ] Renders the same visualizer locally on the phone screen
- [ ] Sends FFT bar data + BPM + intensity to Pi via WebSocket
- [ ] Visualizer runs at 60fps on the phone
- [ ] Handles mic permission denied gracefully with a clear message

### Controls Screen

- [ ] Bass slider (0–100)
- [ ] Mid slider (0–100)
- [ ] Treble slider (0–100)
- [ ] EQ slider changes are debounced — no more than one write per 300ms
- [ ] LED color picker (full color wheel)
- [ ] LED brightness slider (0–100)
- [ ] LED mode selector: static / beat-sync / breathe / off
- [ ] At least 3 saveable EQ presets (name + bass/mid/treble values)
- [ ] Presets persisted locally via Hive
- [ ] Haptic feedback when a preset is applied

### Now Playing Screen

- [ ] Shows current track title, artist, album name
- [ ] Shows album art
- [ ] Shows playback progress bar
- [ ] Data pulled from Spotify SDK or Apple MusicKit
- [ ] Sends track metadata to Pi via WebSocket so Pi display updates
- [ ] Graceful empty state when no music is playing

### Device Screen

- [ ] Shows Pi connection status (connected / disconnected)
- [ ] Shows Pi IP address currently in use
- [ ] Button to disconnect and re-enter IP
- [ ] Shows LED ring status (last known mode and color)
- [ ] Shows app version

### Navigation

- [ ] Bottom navigation bar with 4 tabs: Visualizer / Controls / Now Playing / Device
- [ ] go_router handles all routing
- [ ] Deep link support: `btspeaker://connect?ip=192.168.x.x`

---

## WebSocket Payload Contracts

### Phone → Pi (beat data, sent every FFT cycle)

```json
{
  "type": "beat",
  "bpm": 128,
  "intensity": 0.87,
  "fft_bars": [0.2, 0.8, 0.6, 0.4, 0.9, 0.3, 0.7, 0.5,
               0.1, 0.6, 0.4, 0.7, 0.3, 0.9, 0.5, 0.2]
}
```

### Phone → Pi (LED command)

```json
{
  "type": "led",
  "mode": "beat_sync",
  "r": 255,
  "g": 0,
  "b": 128,
  "brightness": 200
}
```

### Phone → Pi (Now Playing)

```json
{
  "type": "now_playing",
  "title": "Blinding Lights",
  "artist": "The Weeknd",
  "album": "After Hours",
  "album_art_base64": "...",
  "progress_ms": 45000,
  "duration_ms": 200000
}
```

### Phone → Pi (EQ — stored for Phase 2 amp)

```json
{
  "type": "eq",
  "bass": 75,
  "mid": 50,
  "treble": 60
}
```

---

## BLoC Requirements

### Pi App

| BLoC | Responsibility |
| --- | --- |
| `ConnectionBloc` | WebSocket server state — waiting / connected / error |
| `VisualizerBloc` | Receives beat payloads, drives CustomPainter state |
| `LedBloc` | Receives LED commands, triggers Python subprocess |
| `NowPlayingBloc` | Receives track metadata, updates display |

### Phone App

| BLoC | Responsibility |
| --- | --- |
| `ConnectionBloc` | WebSocket client state — idle / connecting / connected / error |
| `AudioBloc` | Mic stream → Isolate FFT → beat data emission |
| `EqualizerBloc` | Slider state, preset save/load, debounced writes |
| `LedBloc` | Color picker state, mode selection, sends LED commands |
| `NowPlayingBloc` | Spotify/MusicKit integration, track metadata |

---

## Architecture Requirements

### Both Apps

- [ ] Clean Architecture — data / domain / presentation layers
- [ ] Repository pattern — all data sources behind abstract interfaces
- [ ] BLoC for all state management — no setState in feature code
- [ ] go_router for navigation
- [ ] No business logic in widgets

### Phone App Only

- [ ] iOS → TestFlight
- [ ] Android → Firebase App Distribution
- [ ] `very_good_analysis` lint rules
- [ ] Unit tests for all BLoCs
- [ ] Widget tests for critical UI interactions

---

## Performance Benchmarks

### Pi App

| Metric | Target | Minimum Acceptable |
| --- | --- | --- |
| Visualizer frame rate | 30fps | 24fps |
| WebSocket message processing | < 16ms | < 33ms |
| App boot to visualizer visible | < 10 seconds | < 20 seconds |
| LED update latency (receive → GPIO) | < 50ms | < 100ms |
| Memory usage | < 150MB | < 200MB |
| CPU usage (idle, no phone connected) | < 20% | < 35% |
| CPU usage (active, receiving beat data) | < 60% | < 75% |

> Note: The Pi Zero WH is a single-core 1GHz ARM11. These targets are achievable but require keeping the Flutter widget tree lean and doing heavy work (LED GPIO, WebSocket parsing) off the UI thread.

### Phone App

| Metric | Target | Minimum Acceptable |
| --- | --- | --- |
| Visualizer frame rate | 60fps | 48fps |
| FFT processing latency | < 8ms per cycle | < 16ms |
| WebSocket send latency | < 5ms | < 10ms |
| App cold start to visualizer | < 2 seconds | < 3 seconds |
| Memory usage | < 120MB | < 180MB |
| Battery drain per hour (visualizer active) | < 8% | < 12% |

### WebSocket Communication

| Metric | Target | Minimum Acceptable |
| --- | --- | --- |
| Beat data round trip (phone → Pi) | < 20ms | < 50ms |
| LED command latency | < 30ms | < 75ms |
| Reconnection time after dropout | < 3 seconds | < 8 seconds |
| Message loss rate on local network | 0% | < 1% |

---

## Definition of Done

The project is complete when:

- [ ] Pi boots and Flutter visualizer appears on display within 20 seconds with no keyboard or SSH required
- [ ] Phone app connects to Pi, visualizer on Pi reacts to music within 3 seconds of connecting
- [ ] LED ring pulses visibly in sync with the beat
- [ ] EQ presets save and reload correctly across app restarts
- [ ] Phone app ships to TestFlight via CodeMagic on push to main
- [ ] A 60-second demo video recorded showing all features working
- [ ] GitHub repo README explains the architecture and how to run it

---

## Out of Scope (Phase 2)

- MAX98357A amp audio output (requires hardware not yet purchased)
- Melos monorepo tooling setup
- OTA firmware update for the Pi
- Multi-device support (more than one phone controlling the Pi)
- User accounts or cloud sync of presets
- Spotify playback control (read-only metadata only in Phase 1)
- AWS/GraphQL listening history feature
- CodeMagic CI/CD pipeline
