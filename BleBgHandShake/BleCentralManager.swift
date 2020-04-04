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

        self.centralManager.scanForPeripherals(withServices: [CBUUID.batteryService],
                                               options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
    }

    func stopScan() {
        print("stopScan")
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
        print("willRestoreState")

    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("didDiscover")

    }
}

extension CBUUID {
    static var batteryService: CBUUID {
        return CBUUID.init(string: "180F")
    }
}
