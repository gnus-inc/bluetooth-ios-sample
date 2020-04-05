//
//  CBUUID+.swift
//  BleBgHandShake
//
//  Created by Yusuke Takano on 2020/04/05.
//  Copyright © 2020 Yusuke Takano. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBUUID {
    static var batteryService: CBUUID {
        return CBUUID.init(string: "180F")
    }

    static var myService: CBUUID {
        return CBUUID(string: "1199")
    }

    static var myCharacteristic: CBUUID {
        return CBUUID(string: "8822")
    }
}
