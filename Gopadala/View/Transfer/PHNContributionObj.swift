//
//  PHNContributionObj.swift
//  Gopadala
//
//  Created by Wang Jen Chung on 2024/3/9.
//  Copyright © 2024 DIM. All rights reserved.
//

import UIKit

class PHNContributionObj: NSObject {
    var amt:String! = ""
    var months:String! = ""
    
    public func setValueByOrder(Order orderNum:Int, Value valueStr:String) {
        if orderNum == 0 {
            amt = valueStr
        } else if orderNum == 1 {
            months = valueStr
        }
    }
    
    public func printSelf() {
        Dlog("recipient_id(\(amt ?? "")), recipient_name(\(months ?? ""))")
    }
}

class SSSContributionObj: NSObject {
    var amt:String! = ""
    
    public func setValueByOrder(Order orderNum:Int, Value valueStr:String) {
        if orderNum == 0 {
            amt = valueStr
        }
    }
    
    public func printSelf() {
        Dlog("recipient_id(\(amt ?? ""))")
    }
}
