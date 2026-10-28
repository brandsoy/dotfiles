# proximity-lock

Locks the Mac when the iPhone is no longer nearby.

The daemon continuously scans BLE for Apple Continuity advertisements and
fingerprints the iPhone by the iOS 17+ "Nearby" advert (manufacturer data
`4C 00`, TLV type `0x10`, len 7): 5 stable bytes that identify the phone while
the BLE address and the surrounding bytes rotate for privacy. When the
fingerprint has not been seen for a grace period (default 30s), it runs
`pmset displaysleepnow` to blank and lock the screen.

For a real lock rather than just a display sleep, "Require password
immediately" must be set in System Settings -> Lock Screen -> require
password after display is turned off (the macOS default is immediate).

The old AirDrop beacon (TLV type `0x05`) is no longer emitted by current iOS,
which is why this tool tracks the Nearby advert instead.

## Behavior

- Absence is only counted once the daemon is running: the clock is armed at
  launch. If the phone is absent at startup (e.g. Mac boots while you are
  out), the Mac locks `grace` seconds after launch.
- The lock is issued once per absence. It is not re-issued while the phone
  stays away, and the phone returning resets the state (logged as
  `back in range`). Coming back does not unlock the Mac; you still
  authenticate normally.
- Toggling Bluetooth off on the phone, or powering the phone off, looks the
  same as leaving the room: the Mac locks. This is by design ("iPhone no
  longer present"), but is worth knowing.
- The grace period exists so short trips with the phone (kitchen, bathroom)
  do not lock the Mac. Tune it for the apartment size.
- Watch mode needs the fingerprint file `~/.local/state/proximity-lock/phone`
  (one hex fragment). Without it, the daemon exits with
  `no fingerprint learned yet`.
- Log lines (ISO 8601 timestamps) go to `~/Library/Logs/proximity-lock.log`
  when launched by the agent:
  `watching <fragment> grace <N>s`, `phone <fragment> absent <N>s -> locking`,
  `phone <fragment> back in range`.

## Install

```sh
cd ~/dotfiles/scripts/macos/proximity-lock
swiftc -O proximity-lock.swift \
    -Xlinker -sectcreate -Xlinker __TEXT -Xlinker __info_plist -Xlinker Info.plist \
    -o ~/.local/bin/proximity-lock
~/.local/bin/proximity-lock --selftest

# Keep the iPhone within about a meter of the Mac for the learn scan:
~/.local/bin/proximity-lock --learn 30

cp com.mattis.proximity-lock.plist ~/Library/LaunchAgents/
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.mattis.proximity-lock.plist
```

The embedded `Info.plist` (`NSBluetoothAlwaysUsageDescription`) is required so
macOS attributes the Bluetooth permission prompt to this binary; approve it
once when asked (System Settings -> Privacy & Security -> Bluetooth lists
`proximity-lock` afterwards). The agent runs at login and restarts if it dies
(`RunAtLoad` + `KeepAlive`).

## Usage

```sh
proximity-lock --learn [seconds]   # Scan; list phone fingerprints by peak RSSI;
                                   # save the strongest to the state file.
proximity-lock --dump [seconds]     # Print raw Apple advert blobs by peak RSSI
                                   # (calibration aid: what is actually in the air).
proximity-lock [--grace N]         # Watch mode (the daemon).
proximity-lock --selftest          # Parser assertions; exits 0.
```

Defaults: learn/dump window 30s, grace 30s.

## Tuning

- Grace period: edit `--grace` in `~/Library/LaunchAgents/com.mattis.proximity-lock.plist`,
  then `launchctl kickstart -k gui/$(id -u)/com.mattis.proximity-lock`.
- Wrong phone picked by `--learn` (e.g. an iPad was closer): edit
  `~/.local/state/proximity-lock/phone` and put the fragment from the learn
  table there. Read-only for the daemon.
- New phone, or the phone starts being "absent" while sitting on the desk:
  re-run `--learn` (the fingerprint is expected to be stable, but re-learn
  after changing phones).

## Troubleshooting

- **Nothing in the log / agent not scanning.** Check
  `launchctl print gui/$(id -u)/com.mattis.proximity-lock` shows `state = running`,
  and that `proximity-lock` is enabled in Privacy & Security -> Bluetooth.
  After editing the source and rebuilding, the new binary needs its Bluetooth
  permission re-approved once.
- **`--learn` reports no adverts at all.** The Bluetooth permission prompt is
  probably still pending; approve it and retry.
- **`--learn` sees Apple traffic but no Nearby adverts.** The phone must be
  nearby with Bluetooth on. (Nearby adverts come from iPhones on modern iOS;
  the learn table lists whatever is in range with peak RSSI.)
- **Locks while you are at the desk.** The fingerprint rotated or was re-learned
  wrongly; re-run `--learn 30` with the phone close.
- **Never locks.** Walk away with the phone and watch
  `tail -f ~/Library/Logs/proximity-lock.log` for the `absent ... -> locking`
  line. Note a lock requires "Require password immediately" to prompt for login.

## Uninstall

```sh
launchctl bootout gui/$(id -u)/com.mattis.proximity-lock
rm ~/Library/LaunchAgents/com.mattis.proximity-lock.plist \
   ~/.local/bin/proximity-lock ~/.local/state/proximity-lock/phone
```

## Files

- `proximity-lock.swift` -- the whole tool (daemon, learn, dump, selftest)
- `Info.plist` -- embedded into the binary at build time for the Bluetooth prompt
- `com.mattis.proximity-lock.plist` -- LaunchAgent (grace is set here)
- Runtime state: `~/.local/state/proximity-lock/phone`, log:
  `~/Library/Logs/proximity-lock.log`
