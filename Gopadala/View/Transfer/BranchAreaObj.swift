//
//  BranchAreaObj.swift
//  Gopadala
//
//  Created by Wang Jen Chung on 2024/3/9.
//  Copyright © 2024 DIM. All rights reserved.
//

import UIKit

class BranchAreaObj: NSObject {
    var idx:String! = ""
    var name:String! = ""
    
    public func setValueByOrder(Order orderNum:Int, Value valueStr:String) {
        if orderNum == 0 {
            idx = valueStr
        } else if orderNum == 1 {
            name = valueStr
        }
    }
    
    public func printSelf() {
        Dlog("recipient_id(\(idx ?? "")), recipient_name(\(name ?? ""))")
    }
}
