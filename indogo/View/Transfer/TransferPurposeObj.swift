//
//  TransferPurposeObj.swift
//  indogo
//
//  Created by Wang Jen Chung on 2022/3/8.
//  Copyright © 2022 DIM. All rights reserved.
//

import UIKit

//跟關係可共用結構
class TransferPurposeObj: NSObject {
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
