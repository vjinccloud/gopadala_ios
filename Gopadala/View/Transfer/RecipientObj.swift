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
    var isOther = false
    var recipient_id:String! = ""
    var recipient_name:String! = ""
    var last_name = ""
    var first_name = ""
    var middle_name = ""
    var phone_no = ""
    var cash_pickup_id = ""
    var cash_pickup_name = ""
    var cash_pickup_photo = ""
    var sss_number = ""
    var pag_ibig_number = ""
    var philhealth_number = ""
    var passport_id = ""
    var bank_acc:String! = ""
    var bank_code:String! = ""
    var bank_name:String! = ""
    var is_hidden:String! = ""
    var branch_area_id:String! = ""
    
    public func setValueByOrder(Order orderNum:Int, Value valueStr:String) {
        isOther = false
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
        } else if orderNum == 5 {
            last_name = valueStr
        } else if orderNum == 6 {
            first_name = valueStr
        } else if orderNum == 7 {
            middle_name = valueStr
        } else if orderNum == 8 {
            phone_no = valueStr
        } else if orderNum == 9 {
            branch_area_id = valueStr
        }
    }
    
    public func setValueOtherByOrder(Order orderNum:Int, Value valueStr:String) {
        isOther = true
        if orderNum == 0 {
            recipient_id = valueStr
        } else if orderNum == 1 {
            recipient_name = valueStr
        } else if orderNum == 2 {
            last_name = valueStr
        } else if orderNum == 3 {
            first_name = valueStr
        } else if orderNum == 4 {
            middle_name = valueStr
        } else if orderNum == 5 {
            phone_no = valueStr
        } else if orderNum == 6 {
            cash_pickup_id = valueStr
        } else if orderNum == 7 {
            cash_pickup_name = valueStr
        } else if orderNum == 8 {
            cash_pickup_photo = valueStr
        } else if orderNum == 9 {
            sss_number = valueStr
        } else if orderNum == 10 {
            pag_ibig_number = valueStr
        } else if orderNum == 11 {
            philhealth_number = valueStr
        } else if orderNum == 12 {
            passport_id = valueStr
        }
    }
    
    public func printSelf() {
        Dlog("recipient_id(\(recipient_id ?? "")), recipient_name(\(recipient_name ?? "")), bank_acc(\(bank_acc ?? "")), bank_name(\(bank_name ?? "")), cash_pickup_photo(\(cash_pickup_photo ?? ""))")
    }
}
