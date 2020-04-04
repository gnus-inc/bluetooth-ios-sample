//
//  MainViewController.swift
//  BleBgHandShake
//
//  Created by Yusuke Takano on 2020/04/04.
//  Copyright © 2020 Yusuke Takano. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    @IBOutlet weak var advertisementSegmentedControl: UISegmentedControl!

    @IBOutlet weak var scanSegmentedControl: UISegmentedControl!

    var isAdvertisementOn: Bool {
        get {
            return advertisementSegmentedControl.selectedSegmentIndex == 1
        }
        set {
            advertisementSegmentedControl.selectedSegmentIndex = newValue ? 1 : 0
        }
    }

    var isScanOn: Bool {
        get {
            return scanSegmentedControl.selectedSegmentIndex == 1
        }
        set {
            scanSegmentedControl.selectedSegmentIndex = newValue ? 1 : 0
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        BlePeripheralManager.shared.addDelegate(self)
        isAdvertisementOn = BlePeripheralManager.shared.isAdvertiseing
        BleCentralManager.shared.addDelegate(self)
        isScanOn = BleCentralManager.shared.isScanning
    }

    @IBAction func didValueChangedAdvertisement(_ sender: Any) {
        if isAdvertisementOn {
            BlePeripheralManager.shared.startAdvertise()
        } else {
            BlePeripheralManager.shared.stopAdvertise()
        }
    }


    @IBAction func didValueChangedScan(_ sender: Any) {
        if isScanOn {
            BleCentralManager.shared.startScan()
        } else {
            BleCentralManager.shared.stopScan()
        }

    }

}

extension MainViewController: BlePeripheralManagerDelegate {
    func didChangedAdvertismentState(started: Bool) {
        if isAdvertisementOn != started {
            isAdvertisementOn = started
        }
    }
}

extension MainViewController: BleCentralManagerDelegate {
    func didChangedScanState(started: Bool) {
        if isScanOn != started {
            isScanOn = started
        }
    }
}
