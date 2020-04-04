//
//  Data+.swift
//  BleBgHandShake
//
//  Created by Yusuke Takano on 2020/04/04.
//  Copyright © 2020 Yusuke Takano. All rights reserved.
//

import Foundation

extension Data {

    init<T>(from value: T) {
        var v = value
        self.init(buffer: UnsafeBufferPointer(start: &v, count: 1))
    }

    func to<T>(type: T.Type) -> T {
        return withUnsafeBytes { $0.pointee }
    }
}
