//
//  BleCentralManager.swift
//  BleBgHandShake
//
//  Created by Yusuke Takano on 2020/04/05.
//  Copyright © 2020 Yusuke Takano. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BleCentralManagerDelegate: class {

    func didChangedScanState(started: Bool)

}

class BleCentralManager: NSObject {

    private (set) static var shared: BleCentralManager!

    var centralManager: CBCentralManager!
    var service: CBMutableService?
    var characteristic: CBMutableCharacteristic?

    var connectingPeripherals: [CBPeripheral] = []

    var delegates: [BleCentralManagerDelegate] = []

    var isAvailable: Bool {
        return self.centralManager.state == .poweredOn
    }

    var isScanning: Bool {
        return self.centralManager.isScanning
    }

    private override init() {
        super.init()

        let options: [String : Any] = [
            CBCentralManagerOptionRestoreIdentifierKey: "BleBGHandShakeKey",
            CBCentralManagerOptionShowPowerAlertKey: true
        ]
        self.centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
    }

    static func instatiate() {
        shared = BleCentralManager()
    }

    func addDelegate(_ delegate: BleCentralManagerDelegate) {
        self.delegates.append(delegate)
    }

    func startScan() {
        print("startScan")
        guard isAvailable else {
            print("Scan Not available ")
            self.delegates.forEach { $0.didChangedScanState(started: false)}
            return
        }

        guard !self.isScanning else {
            print("Already scanning")
            return
        }

        // Should not specified ServiceUUID If in foreground to execute active scan
        let services: [CBUUID]? = nil
        // Have to be specified ServiceUUID when in background state
//        let services: [CBUUID] = [CBUUID.myService]

        self.centralManager.scanForPeripherals(withServices: services,
                                               options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }

    func stopScan() {
        print("stopScan")
        guard isAvailable else {
            return
        }

        guard self.isScanning else {
            print("Already stopped")
            return
        }
        self.centralManager!.stopScan()
    }

    private func setup() {
    }

    private func reset() {
        stopScan()
        self.delegates.forEach{$0.didChangedScanState(started: false)}
    }

}

extension BleCentralManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centralManagerDidUpdateState: \(central.state)")

        switch central.state {
        case .poweredOn     : setup()
        case .poweredOff    : reset()
        case .resetting     : reset()
        case .unsupported   : reset()
        case .unauthorized  : reset()
        case .unknown       : reset()
        default             : reset()
        }

    }

    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        print("willRestoreState: \(dict)")
        self.connectingPeripherals = dict["kCBRestoredPeripherals"] as? [CBPeripheral] ?? []

        self.delegates.forEach{$0.didChangedScanState(started: self.isScanning)}
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

        // Do filtering by RSSI level here if you need limit nearby devices
//        if RSSI < -50 {
//            return
//        }

        print("didDiscover: \(advertisementData), rssi: \(RSSI)")
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
        self.connectingPeripherals.append(peripheral)
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("didConnect: \(String(describing: peripheral.name))")

        // filter by local name if needed e.g.
//        if let name = peripheral.name, name == "iPhone" {
//            self.centralManager.cancelPeripheralConnection(peripheral)
//        }

        peripheral.discoverServices([CBUUID(string: "1199")])
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("didFailToConnect: \(String(describing: peripheral.name))")
        if let index = self.connectingPeripherals.firstIndex(of: peripheral) {
            self.connectingPeripherals.remove(at: index)
        }
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("didDisconnec: \(String(describing: peripheral.name))")
        if let index = self.connectingPeripherals.firstIndex(of: peripheral) {
            self.connectingPeripherals.remove(at: index)
        }
    }
}

extension BleCentralManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("didDiscoverService: \(String(describing: peripheral.services))")

        if let sevices = peripheral.services {
            if sevices.contains(where: {$0.uuid == CBUUID.myService}) {
                print("FOUND MY SERVICE!")
                // Will be continued some processes..
                return
            }
        }

        // Disconnect uninterested devices
        self.centralManager.cancelPeripheralConnection(peripheral)
    }

}
