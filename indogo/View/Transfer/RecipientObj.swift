//
//  RecipientObj.swift
//  indogo
//
//  Created by mac on 2020/8/29.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

//recipient_id(30)recipient_name(30)bank_acc(30)bank_name(30)is_hidden
class RecipientObj: NSObject {
    var recipient_id:String! = ""
    var recipient_name:String! = ""
    var bank_acc:String! = ""
    var bank_code:String! = ""
    var bank_name:String! = ""
    var is_hidden:String! = ""
    
    public func setValueByOrder(Order orderNum:Int, Value valueStr:String) {
        if orderNum == 0 {
            recipient_id = valueStr
        } else if orderNum == 1 {
            recipient_name = valueStr
        } else if orderNum == 2 {
            bank_acc = valueStr
        } else if orderNum == 3 {
            bank_name = valueStr
        } else if orderNum == 4 {
            is_hidden = valueStr
        }
    }
    
    public func printSelf() {
        Dlog("recipient_id(\(recipient_id ?? "")), recipient_name(\(recipient_name ?? "")), bank_acc(\(bank_acc ?? "")), bank_name(\(bank_name ?? "")), is_hidden(\(is_hidden ?? ""))")
    }
}
