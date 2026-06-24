# Pi Setup & Test Command Reference

**Pi user:** `jnnabugwu` | **Hostname:** `Base27`

---

## SSH

```bash
# Connect
ssh jnnabugwu@Base27.local

# Copy SSH key so you don't need a password
ssh-copy-id jnnabugwu@Base27.local

# Find IP if mDNS isn't working
arp -a | grep -i base27
```

### Keep app running if SSH drops

```bash
# Install once
sudo apt install -y tmux

tmux new -s pi_app          # start session
# Ctrl+B then D             # detach
tmux attach -t pi_app       # reattach
```

---

## Verify HDMI / DRM

```bash
vcgencmd measure_temp       # Pi alive check
ls /dev/dri/                # expect card0 and renderD128
kmsprint                    # shows HDMI mode + resolution (tvservice not available on 64-bit OS)
```

If `card0` is missing, add to `/boot/firmware/config.txt` then reboot:

```
dtoverlay=vc4-kms-v3d
```

Fix DRM permissions if flutter-pi can't open the device:

```bash
groups jnnabugwu            # should include video and render
sudo usermod -aG video,render jnnabugwu && sudo reboot
```

## Build and Install flutter-pi (on the Pi)

```bash
sudo apt install -y cmake libgl1-mesa-dev libgles2-mesa-dev \
  libegl1-mesa-dev libdrm-dev libgbm-dev ttf-mscorefonts-installer \
  fontconfig libsystemd-dev libinput-dev libudev-dev libxkbcommon-dev

git clone https://github.com/ardera/flutter-pi.git ~/flutter-pi
cd ~/flutter-pi/build
cmake .. && make -j$(nproc) && sudo make install

flutter-pi --help           # verify install
```

> Note: `mkdir build` will fail if it already exists — just `cd ~/flutter-pi/build` directly.

---

## Deploy Pi App (run from Mac)

Flutter SDK stays on your Mac. Use `flutterpi_tool` to build a self-contained bundle.

> **Pi Zero 2 W runs 32-bit armv7l OS** — always use `--arch arm`, not `--arch arm64`.

```bash
# Install tool once
fvm dart pub global activate flutterpi_tool

# Build from apps/pi_app
cd apps/pi_app
fvm exec flutterpi_tool build --arch arm

# Push the armv7 bundle to the Pi
rsync -avz build/flutter-pi/armv7-generic/ jnnabugwu@Base27.local:~/bt_speaker/bundle/
```

---

## Run the Pi App

```bash
# On the Pi (inside tmux session)
chmod +x ~/bt_speaker/bundle/flutter-pi
~/bt_speaker/bundle/flutter-pi ~/bt_speaker/bundle/
```

Expected on screen: black background, "Waiting for connection…" banner, empty visualizer.

---

## Get Pi IP for Phone App

```bash
# On the Pi
hostname -I
```

Enter `ws://<ip>:8080` in the phone app connection screen.

Verify server is up from Mac:

```bash
curl http://Base27.local:8080    # expect HTTP 426, not a timeout
```

---

## Run Tests (Mac)

```bash
# All packages
melos run test:all

# Pi app only
cd apps/pi_app && flutter test --coverage
```

---

## Connection Test Checklist

- [ ] `ssh jnnabugwu@Base27.local` connects
- [ ] `ls /dev/dri/` shows `card0`
- [ ] flutter-pi launches, display shows "Waiting for connection…"
- [ ] `curl http://Base27.local:8080` returns HTTP 426
- [ ] Phone app connects → banner shows "Connected"
- [ ] Beat event → visualizer bars animate
- [ ] EQ slider change → EqBloc updates
- [ ] LED color change → LedBloc updates
- [ ] Now Playing update → NowPlayingBar updates
- [ ] Phone disconnect → banner reverts to "Waiting…"
- [ ] Phone reconnect → banner returns to "Connected"

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| Black screen / no UI | `sudo usermod -aG video,render jnnabugwu && sudo reboot` |
| mDNS not resolving | Use IP from `hostname -I` instead of `Base27.local` |
| Port 8080 unreachable | `sudo ufw status` — disable or allow 8080 |
| App crashes on launch | Re-run `fvm exec flutterpi_tool build --arch arm` and re-rsync |
| `Exec format error` | Wrong arch — Pi is 32-bit armv7l, use `--arch arm` not `--arch arm64` |
| `icudtl file not found` | Bundle missing engine artifacts — use `flutterpi_tool build` not `flutter build bundle` |
| HDMI no signal | Add `dtoverlay=vc4-kms-v3d` to `/boot/firmware/config.txt`, reboot |
