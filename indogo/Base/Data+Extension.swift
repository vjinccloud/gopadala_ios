//
//  Data+Extension.swift
//  indogo
//
//  Created by Wang Jen Chung on 2022/8/1.
//  Copyright © 2022 DIM. All rights reserved.
//

import UIKit

extension Data {
    var hexString: String {
        return self.reduce("", { $0 + String(format: "%02x", $1) })
    }
}
