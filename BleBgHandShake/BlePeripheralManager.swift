//
//  BlePeripheralManager.swift
//  BleBgHandShake
//
//  Created by Yusuke Takano on 2020/04/04.
//  Copyright © 2020 Yusuke Takano. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BlePeripheralManagerDelegate: class {

    func didChangedAdvertismentState(started: Bool)

}

class BlePeripheralManager: NSObject {

    private (set) static var shared: BlePeripheralManager!

    var peripheralManager: CBPeripheralManager!
    var service: CBMutableService?
    var characteristic: CBMutableCharacteristic?

    var delegates: [BlePeripheralManagerDelegate] = []

    var isAvailable: Bool {
        return self.peripheralManager.state == .poweredOn
    }

    var isAdvertiseing: Bool {
        return self.peripheralManager.isAdvertising
    }

    private override init() {
        super.init()

        let options: Dictionary = [
            CBPeripheralManagerOptionRestoreIdentifierKey: "BleBGHandShakeKey",
        ]

        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: options)
        if #available(iOS 13.0, *) {
            let isSupportExtendedScanAndConnect = CBCentralManager.supports(CBCentralManager.Feature.extendedScanAndConnect)
            print("isSupportExtendedScanAndConnect? \(isSupportExtendedScanAndConnect)")
        }


    }

    static func instatiate() {
        shared = BlePeripheralManager()
    }

    func addDelegate(_ delegate: BlePeripheralManagerDelegate) {
        self.delegates.append(delegate)
    }

    func startAdvertise() {
        print("startAdvertise")
        guard !self.isAdvertiseing else {
            print("Already advertising")
            return
        }
        let data = [CBAdvertisementDataLocalNameKey: "BleBgHandShake"]
        self.peripheralManager!.startAdvertising(data)
    }

    func stopAdvertise() {
        print("stopAdvertise")
        guard self.isAdvertiseing else {
            print("Already stopped")
            return
        }
        self.peripheralManager!.stopAdvertising()
    }

    private func setup() {
        self.service = CBMutableService(type: CBUUID(string: "1199"),
                                        primary: true)
        self.characteristic = CBMutableCharacteristic(type: CBUUID(string: "8822"),
                                                      properties: [.read],
                                                      value: Data(from: 0xF0F0),
                                                      permissions: [.readable])
        self.service!.characteristics = [self.characteristic!]
        self.peripheralManager.add(self.service!)
    }

    private func reset() {
        stopAdvertise()
        if let service = self.service {
            self.peripheralManager.remove(service)
            self.service = nil
            self.characteristic = nil
        }
        self.delegates.forEach{$0.didChangedAdvertismentState(started: false)}
    }

}

extension BlePeripheralManager: CBPeripheralManagerDelegate {

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("peripheralManagerDidUpdateState: \(peripheral.state)")

        switch peripheral.state {
        case .poweredOn     : setup()
        case .poweredOff    : reset()
        case .resetting     : reset()
        case .unsupported   : reset()
        case .unauthorized  : reset()
        case .unknown       : reset()
        default             : reset()
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        print("willRestoreState: \(dict)")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        print("didAdd \(service)")
        if error != nil {
            print("didAdd error: \(error!.localizedDescription)")
            return
        }
    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("didStartAdvertising")
        if error != nil {
            print("didStartAdvertising error: \(error!.localizedDescription)")
            self.delegates.forEach { $0.didChangedAdvertismentState(started: false)}
            return
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("didSubscribeTo: \(characteristic)")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("didUnsubscribeFrom: \(characteristic)")
    }

    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        print("isReady toUpdateSubscribers: \(peripheral)")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("didReceiveRead: \(request)")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("didReceiveWrite: \(requests)")
    }

}
