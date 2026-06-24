# BT Speaker — Claude Code Guide

## Project Overview

Flutter-embedded monorepo: a Pi display app + phone companion app that communicate over WebSocket. The Pi shows a live audio visualizer; the phone sends EQ settings, LED commands, and now-playing metadata.

## Monorepo Structure

```
apps/
  pi_app/          — Flutter app running on Pi via flutter-pi (no standard Flutter deployment)
  phone_app/       — Flutter companion app (iOS/Android)
packages/
  bt_speaker_core/ — Shared models: BeatData, NowPlaying, EqSettings, LedCommand
```

Uses **Melos 7.x** — follow 7.x workspace requirements (pubspec workspace resolution). Do not use legacy bootstrap flags.

## Raspberry Pi Target

- **Hardware:** Raspberry Pi Zero 2 W (quad-core ARM Cortex-A53)
- **Architecture:** armv7 (32-bit) — never assume aarch64
- **Runtime:** flutter-pi (DRM/KMS, no X server, no standard Flutter embedder)
- **Flutter version:** 3.41.9 stable
- **Build command:** `flutterpi_tool build --arch=arm --cpu=generic --release`
- **Pi hostname:** Base27, IP: 192.168.1.70, user: jnnabugwu

## WebSocket Protocol

- Pi runs a **WebSocket server** on port 8080
- Phone is the **client** — all messages flow phone → Pi (unidirectional in Phase 1)
- Message types (keyed on `'type'` field): `beat`, `eq`, `led`, `now_playing`
- All models have `toJson()` / `fromJson()` in `bt_speaker_core`
- Pi rejects a second client with HTTP 503

## Critical Naming Hazard

`flutter/material.dart` re-exports `ConnectionState` from `dart:async`. Any file that defines or imports a custom `ConnectionState` alongside material must use:

```dart
import 'package:flutter/material.dart' hide ConnectionState;
```

This applies in both pi_app and phone_app. Already applied in `connection_banner.dart`.

## Code Conventions

- **State management:** `flutter_bloc` — BLoC-per-feature pattern
- **File layout:** `lib/features/<feature>/bloc/` and `lib/features/<feature>/widgets/`
- **Part files:** events and states use `part of` the bloc file
- **Doc comments:** all public members need `///` doc comments (`very_good_analysis`)
- **Const:** use `const` constructors everywhere possible
- **No comments** explaining what code does — only WHY (non-obvious constraints/workarounds)

## Testing

- Test framework: `flutter_test` + `bloc_test` + `MockBloc`/`whenListen`/`isA<>()` pattern
- Tests use real `WebSocketServer(port: 0)` (OS-assigned port) for integration tests
- Widget tests use `MockBloc` — wrap in `BlocProvider<T>.value`
- After writing async/widget tests, verify timing: `server.start()` must be unawaited and tests need `Future.delayed` coordination to avoid hangs
- Run full suite before declaring done: `flutter test` in each app directory

## CI

GitHub Actions matrix across all three packages. Test step guards with `if [ -d "test" ]` to skip packages without a test directory (phone_app has none yet). See `.github/workflows/ci.yaml`.

## Phase Roadmap

1. ✅ Pi app BLoC layer (ConnectionBloc, VisualizerBloc, LedBloc, NowPlayingBloc, EqBloc)
2. ✅ Pi app UI (VisualizerPainter, HomeScreen, ConnectionBanner, NowPlayingBar)
3. 🔲 Deploy to Pi — verify HDMI render
4. 🔲 Phone app — WebSocket client, EQ screen, LED screen (plan exists)
5. 🔲 Wire WS2812B LED ring (GPIO 10, SPI)
6. 🔲 Beat/FFT audio pipeline + NowPlaying music integration (Phase 2)
7. 🔲 MAX98357A I2S amp (Phase 2)
