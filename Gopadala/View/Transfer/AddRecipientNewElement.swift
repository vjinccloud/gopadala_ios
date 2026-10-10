//
//  AddRecipientNewElement.swift
//  Gopadala
//
//  Created by Wang Jen Chung on 2024/3/8.
//  Copyright © 2024 DIM. All rights reserved.
//

import UIKit

class AddRecipientNewElement: UIView {
    var labelName:String = ""
    var callName:String = ""
    var unitType:AddRecipientRowType = .txt
    var subType:AddRecipientRowSubType = .none
    let textField = UITextField()
    var titleL:UILabel!
    let txtBgV = UIView()
    var needCheck = true
    var parentVC:AddRecipientNewVC!
    var parentV:TransferMainOtherV!
    var tagForAry:Int = 0
    
    func initAll(labelStr:String, name:String, placeHold:String, type:AddRecipientRowType, sub:AddRecipientRowSubType, tag:Int) {
        unitType = type
        callName = name
        subType = sub
        tagForAry = tag
        
        let label = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.width, height: 20))
        if unitType == .total {
            label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        } else {
            label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        }
        
        label.text = labelStr
        labelName = labelStr
        label.textColor = .darkGray
        addSubview(label)
        label.tag = tag
        titleL = label
        titleL.tag = tag
        
        txtBgV.frame = CGRect.init(x: 0, y: 25, width: self.frame.width, height: 30)
        self.addSubview(txtBgV)
        txtBgV.tag = tag
        textField.backgroundColor = .white
        
        // 設置文本字段
        var leftSpace:CGFloat = 0
        if unitType == .select {
            leftSpace = 100
        }
        
        txtBgV.addSubview(textField)
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.frame = CGRect.init(x: 20, y: 0, width: txtBgV.frame.width-40-leftSpace, height: 30)
        textField.autocapitalizationType = .none
        textField.placeholder = placeHold
        textField.font = UIFont.systemFont(ofSize: 13)
        textField.tag = tag
        textField.backgroundColor = .clear
        
        if sub == .t_ntd || sub == .t_php || sub == .t_banknum {
            textField.keyboardType = .numberPad
        } else if sub == .t_phone {
            textField.keyboardType = .phonePad
        } else {
            textField.keyboardType = .default
        }
        
        if unitType == .select {
            let label = UILabel.init(frame: CGRect.init(x: txtBgV.frame.width-leftSpace-12, y: 0, width: leftSpace, height: txtBgV.frame.height))
            label.font = UIFont.systemFont(ofSize: 13, weight: .medium)
            label.text = "Choose One"
            label.textColor = .darkGray
            txtBgV.addSubview(label)
            label.tag = tag
            
            let arrow = UIImageView.init(frame: CGRect.init(x: txtBgV.frame.width - 25, y: txtBgV.frame.height/2 - 3, width: 10, height: 6))
            
            arrow.image = UIImage.init(systemName: "chevron.down")!.withRenderingMode(.alwaysTemplate)
            arrow.tintColor = .black
            
            txtBgV.addSubview(arrow)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(callSelect))
            txtBgV.addGestureRecognizer(tapGesture)
        }
        
        txtBgV.backgroundColor = .white
        txtBgV.layer.cornerRadius = 8
        txtBgV.layer.borderWidth = 0.5
        txtBgV.layer.borderColor = Color_Main_DarkGray.cgColor
    }
    
    @objc func callSelect(_ sender: UITapGestureRecognizer) {
        if parentVC != nil {
            parentVC.callSelect(tag: tagForAry)
        } else if parentV != nil {
            parentV.callSelect(tag: tagForAry)
        }
    }
    
    func checkText() -> checkCode {
        return checkText(name: labelName, text: textField.text!, type: unitType, sub: subType)
    }
    
    func checkText(name:String, text:String, type:AddRecipientRowType, sub:AddRecipientRowSubType, needContent:Bool = true) -> checkCode {
        var result = checkCode()
        
        if needContent, text == "" {
            result.result = false
            result.message = "Please enter \"\(name)\""
            return result
        }
        
        /*
        if subType == .email {
            let ans = text.isValidEmail()
            if !ans {
                result.result = false
                result.message = "\(name)格式錯誤"
            }
        } else if unitType == .password {
            let ans = text.isPasswordValid()
            if !ans {
                result.result = false
                result.message = "\(name)格式錯誤"
            }
        }*/
        
        return result
    }
}
