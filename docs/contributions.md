# Jordan's Contributions

All commits by Jordan Nnabugwu on the `bt_speaker` project.

---

## Foundation (2026-06-09)

| Hash | Commit |
| --- | --- |
| `cb7d5fc` | Initial project setup |
| `e9e4f39` | Restructured into a Melos monorepo (pi_app, phone_app, bt_speaker_core) |
| `4904843` | Second scaffolding commit |
| `8575cff` | Added `bt_speaker_core` shared models (`BeatData`, `NowPlaying`, `EqSettings`, `LedCommand`) and project spec |
| `9aa9cbf` | Dart format pass |

## Pi App — WebSocket & Connection Layer (2026-06-18)

| Hash | Commit |
| --- | --- |
| `164bb57` | WebSocket server foundation for pi_app — `HttpServer` + upgrade, broadcast event stream, typed `WsEvent` sealed classes |
| `754560a` | Added `ConnectionBloc` and made `WebSocketServer` port configurable (enables `port: 0` in tests) |
| `3b83d30` | Dart format pass |
| `d941f89` | Melos CI script updates |
| `96541f6` | Added `VisualizerBloc` and `LedBloc` with full test coverage |

## Pi App — BLoC Layer Complete (2026-06-20)

| Hash | Commit |
| --- | --- |
| `99f0ed9` | Added `NowPlayingBloc` and `EqBloc`; wired all five blocs in `AppRoot` via `MultiBlocProvider` |
| `46b1352` | CI fix — guard `flutter test` step with `if [ -d "test" ]` so packages without a test directory don't fail |
| `f77c073` | Updated `README.md` with hardware specs, architecture overview, and tech stack |

## Pi App — Visualizer UI (2026-06-22)

| Hash | Commit |
| --- | --- |
| `ca1a06c` | Added full Pi app UI: `VisualizerPainter` (FFT bar `CustomPainter`), `VisualizerCanvas`, `ConnectionBanner`, `NowPlayingBar`, `HomeScreen`; replaced `Text('BT Speaker Pi')` placeholder in `main.dart`; 44/44 tests passing |
| `49c3a05` | Format pass across all new widget and test files |

---

## Summary by Area

| Area | Files Changed | Tests Added |
| --- | --- | --- |
| Monorepo & shared models | 8 | — |
| WebSocket server + ConnectionBloc | 12 | 8 |
| VisualizerBloc + LedBloc | 8 | 6 |
| NowPlayingBloc + EqBloc + AppRoot | 10 | 8 |
| Visualizer UI (painter, canvas, banner, bar, screen) | 11 | 22 |
| CI, README, formatting | 4 | — |
