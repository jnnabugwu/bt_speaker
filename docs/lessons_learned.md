# Lessons Learned — Pi Setup

Issues hit during initial Pi app deployment, what was tried, and what actually fixed it.

---

## 1. `tvservice` not available on 64-bit Raspberry Pi OS

**Symptom:** `-bash: tvservice: command not found`

**Why:** `tvservice` was removed from Raspberry Pi OS Bookworm (64-bit). It only worked with the legacy firmware video driver.

**What we tried:** Running `tvservice -s` as documented in many flutter-pi guides.

**Fix:** Use `kmsprint` instead (install with `sudo apt install -y kmsprint`). Also confirmed working display via `ls /dev/dri/` showing `card0` and `renderD128`.

---

## 2. Do NOT install Flutter SDK on the Pi

**Symptom:** `cannot execute binary file` when running `flutter precache --linux` on the Pi.

**Why:** Flutter's Dart SDK binary is compiled for x86_64. It can't run on the Pi's ARM architecture.

**What we tried:** Cloning Flutter from GitHub to `/opt/flutter` and running `flutter precache --linux`.

**Fix:** Flutter SDK lives on the Mac only. The Pi only needs `flutter-pi` (a C binary compiled on the Pi) to run the pre-built bundle. Delete any Flutter clone on the Pi with `sudo rm -rf /opt/flutter`.

---

## 3. Chained cmake command fails if `build/` already exists

**Symptom:** `mkdir: cannot create directory 'build': File exists` → `CMake Error: source directory does not appear to contain CMakeLists.txt`

**Why:** The chained command `mkdir build && cd build` stops at `mkdir` when the directory already exists, so `cd build` never runs. `cmake ..` then runs from the wrong directory.

**What we tried:** Running `cd ~/flutter-pi && mkdir build && cd build && cmake ..` as a one-liner.

**Fix:** Run the steps separately:
```bash
cd ~/flutter-pi/build
cmake .. && make -j$(nproc) && sudo make install
```

---

## 4. `icudtl file not found` when running flutter-pi

**Symptom:** `filesystem_layout.c: icudtl file not found!`

**Why:** `flutter build bundle` only produces the Dart/Flutter assets. It does not include `icudtl.dat` or `libflutter_engine.so`, which flutter-pi needs at runtime.

**What we tried:** `flutter build bundle` then rsyncing `build/flutter_assets/` to the Pi.

**Fix:** Use `flutterpi_tool build` instead. It downloads the matching engine, icudtl.dat, and packages everything into `build/flutter-pi/<arch>/`.

---

## 5. `fvm flutterpi_tool` is not a valid FVM command

**Symptom:** `Could not find an option named "--arch"` with FVM's help output printed.

**Why:** FVM only has its own subcommands (`flutter`, `dart`, `exec`, etc.). Running `fvm flutterpi_tool` is parsed as an unknown FVM command, not passed through to flutterpi_tool.

**What we tried:** `fvm flutterpi_tool build --arch=arm64`

**Fix:** Use `fvm exec` to run any arbitrary command through FVM's managed Flutter environment:
```bash
fvm exec flutterpi_tool build --arch arm
```

---

## 6. Downgrading to Flutter 3.27.0 breaks the monorepo

**Symptom:** `Because bt_speaker_workspace depends on melos >=7.0.0-dev.9 which requires SDK version >=3.8.0 <4.0.0, version solving failed.`

**Why:** Flutter 3.27.0 ships with Dart 3.6.0. Melos 7.x requires Dart >=3.8.0. The two are incompatible.

**What we tried:** Pinning Flutter 3.27.0 via FVM after reading that it fixes the `icudtl` error, then changing all `sdk: ^3.11.5` constraints to `^3.6.0`.

**Fix:** Stay on Flutter 3.41.9. The `icudtl` issue was actually caused by using `flutter build bundle` instead of `flutterpi_tool build` (see issue #4), not a Flutter version problem.

---

## 7. Wrong rsync directory — bundle is not in `flutter_assets/`

**Symptom:** `icudtl file not found` even after switching to `flutterpi_tool build`.

**Why:** We rsynced `build/flutter_assets/` but `flutterpi_tool build` puts the complete bundle (engine + icudtl.dat + assets) in `build/flutter-pi/<arch>/`, not in `flutter_assets/`.

**What we tried:** `rsync -avz build/flutter_assets/ ...`

**Fix:**
```bash
rsync -avz build/flutter-pi/armv7-generic/ jnnabugwu@Base27.local:~/bt_speaker/bundle/
```

---

## 8. `Exec format error` — wrong architecture target

**Symptom:** `-bash: ~/bt_speaker/bundle/flutter-pi: cannot execute binary file: Exec format error`

**Why:** The Pi Zero 2 W has a 64-bit processor but runs a **32-bit armv7l OS**. Building with `--arch arm64` produces an aarch64 (64-bit) binary that can't run on a 32-bit OS.

**How we diagnosed it:**
```bash
uname -m                              # returned armv7l (32-bit)
file ~/bt_speaker/bundle/flutter-pi  # returned ELF 64-bit ARM aarch64
```

**Fix:** Always build with `--arch arm` for this Pi:
```bash
fvm exec flutterpi_tool build --arch arm
# output lands in build/flutter-pi/armv7-generic/
```

---

## Key Takeaways

| Rule | Reason |
|---|---|
| Never install Flutter SDK on the Pi | Dart binaries are x86_64 only |
| Always use `flutterpi_tool build`, never `flutter build bundle` | Only flutterpi_tool packages the engine + icudtl.dat |
| Always use `--arch arm` for this Pi | OS is 32-bit armv7l despite 64-bit hardware |
| Rsync `build/flutter-pi/armv7-generic/`, not `build/flutter_assets/` | Full bundle lives in the flutter-pi output dir |
| Use `fvm exec <tool>` not `fvm <tool>` | FVM only proxies `flutter` and `dart` directly |
