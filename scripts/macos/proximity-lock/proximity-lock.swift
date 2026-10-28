// proximity-lock -- lock the Mac when your iPhone's BLE advertisement disappears.
//
// iPhones continuously send Apple Continuity BLE advertisements. The iOS 17+
// "Nearby" advert (manufacturer data 4C 00, TLV type 0x10, len 7) carries a
// stable 5-byte fragment that identifies the phone; the first and last value
// bytes rotate for privacy. The BLE address rotates too, but that fragment
// does not, so it fingerprints the phone. (The old AirDrop type 0x05 advert
// is no longer emitted by current iOS.) When the fragment has not been seen
// for --grace seconds, run `pmset displaysleepnow` (a real lock needs
// System Settings -> Lock Screen -> "Require password immediately").
//
// Usage:
//   proximity-lock --learn [seconds]   Scan, list phone fingerprints by peak
//                                      RSSI, save the strongest to the state
//                                      file. Keep the phone close while it runs.
//   proximity-lock --dump [seconds]     Scan and print raw Apple advert blobs by
//                                      peak RSSI (calibration aid).
//   proximity-lock [--grace N]          Watch mode (the daemon).
//   proximity-lock --selftest
//
// State file: ~/.local/state/proximity-lock/phone (one hex fragment; edit to
// override what --learn picked).
//
// Build: swiftc -O proximity-lock.swift \
//            -Xlinker -sectcreate -Xlinker __TEXT -Xlinker __info_plist -Xlinker Info.plist \
//            -o ~/.local/bin/proximity-lock
// On first run macOS asks for Bluetooth access; grant it under
// System Settings -> Privacy & Security -> Bluetooth.

import CoreBluetooth
import Foundation

let home = FileManager.default.homeDirectoryForCurrentUser
let stateFile = home
    .appendingPathComponent(".local/state/proximity-lock/phone")

func log(_ message: String) {
    let stamp = ISO8601DateFormatter().string(from: Date())
    print("\(stamp) \(message)")
}

// Apple Continuity manufacturer blob: 4C 00 followed by TLVs (type, len, value).
// iOS 17+ "Nearby" TLV (type 0x10, len 7): rotating flag byte, 5 stable bytes
// identifying the phone, rotating auth byte.
func phoneFragment(_ data: Data?) -> String? {
    guard let data, data.count >= 4 else { return nil }
    let b = [UInt8](data)
    guard b[0] == 0x4C, b[1] == 0x00 else { return nil }
    var i = 2
    while i + 2 <= b.count {
        let type = b[i]
        let len = Int(b[i + 1])
        let end = i + 2 + len
        guard end <= b.count else { return nil }
        if type == 0x10, len == 7 {
            return b[(i + 3)..<(i + 8)].map { String(format: "%02x", $0) }.joined()
        }
        i = end
    }
    return nil
}

func lockScreen() {
    let pmset = Process()
    pmset.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
    pmset.arguments = ["displaysleepnow"]
    do {
        try pmset.run()
    } catch {
        log("ERROR: pmset displaysleepnow failed: \(error)")
    }
}

final class Scanner: NSObject, CBCentralManagerDelegate {
    let queue = DispatchQueue(label: "proximity-lock")
    var manager: CBCentralManager!
    var target: String?
    var grace: TimeInterval = 30
    var learnSeconds: TimeInterval = 0
    var learnDump = false
    var lastSeen: [String: Date] = [:]
    var peak: [String: Int] = [:]
    var locked = false
    var appleAdverts = 0
    var types: [Int: Int] = [:]
    var blobs: [String: (count: Int, peak: Int)] = [:]

    func start() {
        manager = CBCentralManager(delegate: self, queue: queue)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        guard central.state == .poweredOn else {
            log("bluetooth not available (state \(central.state.rawValue))")
            return
        }
        central.scanForPeripherals(
            withServices: nil,
            options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        if learnSeconds > 0 {
            log("learning for \(Int(learnSeconds))s...")
            queue.asyncAfter(deadline: .now() + learnSeconds) { self.finishLearn() }
        } else {
            // Arm the absence clock at launch so a present phone never trips an
            // instant lock; absence counts from here if it is gone on boot.
            if let target = target { lastSeen[target] = Date() }
            log("watching \(target ?? "?") grace \(Int(grace))s")
            tick()
        }
    }

    func centralManager(
        _ central: CBCentralManager,
        didDiscover peripheral: CBPeripheral,
        advertisementData: [String: Any],
        rssi RSSI: NSNumber
    ) {
        if let data = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data {
            let b = [UInt8](data)
            if b.count >= 2, b[0] == 0x4C, b[1] == 0x00 {
                appleAdverts += 1
                var i = 2
                while i + 2 <= b.count {
                    types[Int(b[i]), default: 0] += 1
                    let end = i + 2 + Int(b[i + 1])
                    guard end <= b.count else { break }
                    i = end
                }
                let hexBlob = b.map { String(format: "%02x", $0) }.joined()
                blobs[hexBlob, default: (0, -127)].count += 1
                blobs[hexBlob]!.peak = max(blobs[hexBlob]!.peak, RSSI.intValue)
            }
        }
        guard let fragment = phoneFragment(
            advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data)
        else { return }
        lastSeen[fragment] = Date()
        peak[fragment, default: -127] = max(peak[fragment] ?? -127, RSSI.intValue)
        if fragment == target, locked {
            locked = false
            log("phone \(fragment) back in range")
        }
    }

    private func tick() {
        queue.asyncAfter(deadline: .now() + 2) { self.tick() }
        guard let target else { return }
        let absent = Date().timeIntervalSince(lastSeen[target] ?? .distantPast)
        if absent > grace, !locked {
            locked = true
            log("phone \(target) absent \(Int(absent))s -> locking")
            lockScreen()
        }
    }

    private func finishLearn() {
        let ranked = peak.sorted { $0.value > $1.value }
        if learnDump {
            for (blob, stats) in blobs.sorted(by: { $0.value.peak > $1.value.peak }) {
                print(String(format: "%4d dBm x%3d  %@", stats.peak, stats.count, blob))
            }
            exit(0)
        }
        guard !ranked.isEmpty else {
            if appleAdverts == 0 {
                log("no BLE adverts of any kind arrived -- approve the Bluetooth permission prompt (System Settings -> Privacy & Security -> Bluetooth), then retry")
            } else {
                let tally = types.sorted { $0.value > $1.value }
                    .map { String(format: "type %#02x x%d", $0.key, $0.value) }
                    .joined(separator: ", ")
                log("Apple BLE traffic seen but no Nearby (type 0x10) adverts; TLV types: \(tally)")
                log("phone must be nearby with Bluetooth on")
            }
            exit(1)
        }
        print("peak RSSI  fingerprint (iOS Nearby advert, 5 stable bytes)")
        for (fragment, rssi) in ranked {
            print(String(format: "%6d dBm  %@", rssi, fragment))
        }
        let best = ranked[0].key
        try? FileManager.default.createDirectory(
            at: stateFile.deletingLastPathComponent(),
            withIntermediateDirectories: true)
        try? Data(best.utf8).write(to: stateFile)
        log("saved \(best) to \(stateFile.path) -- edit the file to pick another")
        exit(0)
    }
}

func selftest() {
    func hex(_ s: String) -> Data {
        let chars = Array(s)
        return Data(stride(from: 0, to: chars.count - 1, by: 2).compactMap {
            UInt8(String(chars[$0...$0 + 1]), radix: 16)
        })
    }
    assert(phoneFragment(hex("4c001007301f2b5941f558")) == "1f2b5941f5")
    // Multiple TLVs in one blob; a short TLV before the Nearby one.
    assert(phoneFragment(hex("4c001202000010073c1fb49ad38838")) == "1fb49ad388")
    assert(phoneFragment(hex("4c0005050102aabbcc")) == nil) // AirDrop TLV: no longer used
    assert(phoneFragment(hex("02010664ef")) == nil) // not Apple
    assert(phoneFragment(hex("4c001007301f2b5941f5")) == nil) // truncated value
    assert(phoneFragment(nil) == nil)
    print("selftest OK")
    exit(0)
}

let args = CommandLine.arguments
setbuf(stdout, nil) // launchd pipes are block-buffered; log lines must appear live
if args.contains("--selftest") { selftest() }

let scanner = Scanner()
if args.contains("--learn") {
    let i = args.firstIndex(of: "--learn")!
    scanner.learnSeconds = TimeInterval(args[i + 1]) ?? 30
} else if args.contains("--dump") {
    let i = args.firstIndex(of: "--dump")!
    scanner.learnSeconds = TimeInterval(args[i + 1]) ?? 30
    scanner.learnDump = true
} else {
    if let i = args.firstIndex(of: "--grace") {
        scanner.grace = TimeInterval(args[i + 1]) ?? 30
    }
    scanner.target = try? String(
        contentsOf: stateFile, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
    guard let target = scanner.target, !target.isEmpty else {
        log("no fingerprint learned yet; run with --learn first")
        exit(1)
    }
}
scanner.start()
dispatchMain()
