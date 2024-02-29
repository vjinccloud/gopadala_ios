//
//  TransactionObj.swift
//  indogo
//
//  Created by mac on 2020/9/3.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class TransactionObj: NSObject {
    var ntdValue = 0
    var targetValue = 0
    var feeValue = 0
    var usePoint = 0
    var totalNtdValue = 0
    var recipientObj:RecipientObj = RecipientObj()
    var purposes_id = "0"
}
