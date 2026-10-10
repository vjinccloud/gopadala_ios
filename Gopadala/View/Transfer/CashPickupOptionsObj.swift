//
//  CashPickupOptionsObj.swift
//  Gopadala
//
//  Created by Wang Jen Chung on 2024/3/9.
//  Copyright © 2024 DIM. All rights reserved.
//

import UIKit

class CashPickupOptionsObj: NSObject {
    var idx:String! = ""
    var name:String! = ""
    var photo:String! = ""
    
    public func setValueByOrder(Order orderNum:Int, Value valueStr:String) {
        if orderNum == 0 {
            idx = valueStr
        } else if orderNum == 1 {
            name = valueStr
        } else if orderNum == 2 {
            photo = valueStr
        }
    }
    
    public func printSelf() {
        Dlog("recipient_id(\(idx ?? "")), recipient_name(\(name ?? "")), photo(\(photo ?? ""))")
    }
}
