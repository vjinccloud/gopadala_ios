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
    
    var other_transfer_amount_idr = 0
    var other_transfer_idr = 0
    var other_amount_ntd = 0
    var other_ym_start = ""
    var other_ym_end = ""
    var other_payment_code = ""
    var other_payment_code2 = ""
    var other_PHN_months = 0
    var isSSSContribution = false
}
