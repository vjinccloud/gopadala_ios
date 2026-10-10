//
//  PaymentTypeObj.swift
//  Gopadala
//
//  Created by Wang Jen Chung on 2024/3/9.
//  Copyright © 2024 DIM. All rights reserved.
//

import UIKit

class PaymentTypeObj: NSObject {
    var paymenet_code:String! = ""
    var payment_name:String! = ""
    var payment_code_2:String! = ""
    var payment_name_2:String! = ""
    
    public func setValueByOrder(Order orderNum:Int, Value valueStr:String) {
        if orderNum == 0 {
            paymenet_code = valueStr
        } else if orderNum == 1 {
            payment_name = valueStr
        } else if orderNum == 2 {
            payment_code_2 = valueStr
        } else if orderNum == 3 {
            payment_name_2 = valueStr
        }
    }
    
    public func printSelf() {
        Dlog("paymenet_code(\(paymenet_code ?? "")), payment_code_2(\(payment_code_2 ?? "")), payment_name(\(payment_name ?? ""))")
    }
}
