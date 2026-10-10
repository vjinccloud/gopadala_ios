//
//  AddRecipientNewObj.swift
//  Gopadala
//
//  Created by Wang Jen Chung on 2024/3/8.
//  Copyright © 2024 DIM. All rights reserved.
//

import UIKit

class AddRecipientNewObj: NSObject {
    var rowTypeAry:[AddRecipientRowType] = []
    var rowSubTypeAry:[AddRecipientRowSubType] = []
    var rowNameAry:[String] = []
    var placeHolderAry:[String] = []
    var apiRow:[String] = []
    
    func initProperty() {
        if AppDelegate.shared().tansferMethod == .Bank {
            rowTypeAry = [.select, .txt, .txt, .txt, .txt, .select, .select, .txt]
            rowSubTypeAry = [.s_bank, .t_txt, .t_txt, .t_txt, .t_phone, .s_relation, .s_branch, .t_banknum]
            rowNameAry = ["Bank name", "First name", "Middle name", "Last name", "Phone Number", "Relationship with recipient", "Branch Area", "Bank account number"]
            placeHolderAry = ["","","","", "Enter 11 digit PH number (091xxxxxxx)", "", "", "Enter bank account or e-wallet number"]
            apiRow = ["bank_code", "first_name","middle_name","last_name","phone_no","relationships_id","branch_area_id","bank_acc"]
        } else if AppDelegate.shared().tansferMethod == .Cash {
            rowTypeAry = [.select, .txt, .txt, .txt, .txt, .day, .select]
            rowSubTypeAry = [.s_cashOption, .t_txt, .t_txt, .t_txt, .t_phone, .d_birth, .s_relation]
            rowNameAry = ["Cash Pick-up Option", "First name", "Middle name", "Last name", "Recipient phone number", "Recipient's Birthday", "Relationship with recipient"]
            placeHolderAry = ["Select from the list", "", "", "", "Enter 11 digit PH number (091xxxxxxx)", "YYYY/MM/DD", ""]
            apiRow = ["cash_pickup_id", "first_name","middle_name","last_name","phone_no","birthday","relationships_id"]
        } else if AppDelegate.shared().tansferMethod == .SSS {
            rowTypeAry = [.txt, .txt, .txt, .txt, .txt, .txt, .day, .select]
            rowSubTypeAry = [.t_num, .t_txt, .t_txt, .t_txt, .t_phone, .t_num, .d_birth, .s_relation]
            rowNameAry = ["SSS Number", "First name", "Middle name", "Last name", "Recipient phone number", "ID number", "Recipient's Birthday", "Relationship with recipient"]
            placeHolderAry = ["Enter 10 digit SSS number", "", "", "", "Enter 11 digit PH number (091xxxxxxx)","", "YYYY/MM/DD", ""]
            apiRow = ["sss_number", "first_name","middle_name","last_name","phone_no","passport_id","birthday","relationships_id"]
        } else if AppDelegate.shared().tansferMethod == .Pag {
            rowTypeAry = [.txt, .txt, .txt, .txt, .txt, .txt, .day, .select]
            rowSubTypeAry = [.t_num, .t_txt, .t_txt, .t_txt, .t_phone, .t_num, .d_birth, .s_relation]
            rowNameAry = ["Pag-Ibig Number", "First name", "Middle name", "Last name", "Recipient phone number", "ID number", "Recipient's Birthday", "Relationship with recipient"]
            placeHolderAry = ["Enter 12 digit Pag-Ibig number", "", "", "", "Enter 11 digit PH number (091xxxxxxx)","", "YYYY/MM/DD", ""]
            apiRow = ["pag_ibig_number", "first_name","middle_name","last_name","phone_no","passport_id","birthday","relationships_id"]
        } else if AppDelegate.shared().tansferMethod == .Health {
            rowTypeAry = [.txt, .txt, .txt, .txt, .txt, .txt, .day, .select]
            rowSubTypeAry = [.t_num, .t_txt, .t_txt, .t_txt, .t_phone, .t_num, .d_birth, .s_relation]
            rowNameAry = ["PhilHealth Number", "First name", "Middle name", "Last name", "Recipient phone number", "ID number", "Recipient's Birthday", "Relationship with recipient"]
            placeHolderAry = ["Enter 12 digit PhilHealth number", "", "", "", "Enter 11 digit PH number (091xxxxxxx)","", "YYYY/MM/DD", ""]
            apiRow = ["philhealth_number", "first_name","middle_name","last_name","phone_no","passport_id","birthday","relationships_id"]
        }
        
        //check
        Dlog("a. \(rowTypeAry.count) b. \(rowSubTypeAry.count) c. \(rowNameAry.count) d. \(placeHolderAry.count)")
    }
    
    func initTransferProperty() {
        if AppDelegate.shared().tansferMethod == .SSS {
            rowTypeAry = [.select,.select,.txt,.day,.day,.txt,.txt,.total]
            rowSubTypeAry = [.s_payType, .s_contribution, .t_php, .d_from, .d_to, .t_ntd, .t_ntd, .none]
            rowNameAry = ["Payment Type", "PHP amount - Contribution", "PHP amount - Short term loan", "From", "To", "Amount in NTD", "Charge fee in NTD", "Total NTD amount"]
            placeHolderAry = ["Select from the list","Select from the list","Select from the list", "YYYY/MM", "YYYY/MM", "Automatically convert to NTD", "", "Amount in NTD + Charge fee"]
        } else if AppDelegate.shared().tansferMethod == .Pag {
            rowTypeAry = [.select, .txt, .day, .day, .txt, .txt, .total]
            rowSubTypeAry = [.s_payType, .t_php, .d_from, .d_to, .t_ntd, .t_ntd, .none]
            rowNameAry = ["Payment Type", "PHP amount", "From", "To", "Amount in NTD", "Charge fee in NTD", "Total NTD amount"]
            placeHolderAry = ["Select from the list", "Input the PHP amount", "YYYY/MM", "YYYY/MM", "Automatically convert to NTD", "", "Amount in NTD + Charge fee"]
        } else if AppDelegate.shared().tansferMethod == .Health {
            rowTypeAry = [.select, .day, .day, .txt, .txt, .total]
            rowSubTypeAry = [.s_phpAmount, .d_from, .d_to, .t_ntd, .t_ntd, .none]
            rowNameAry = ["PHP amount", "From", "To", "Amount in NTD", "Charge fee in NTD", "Total NTD amount"]
            placeHolderAry = ["Select from the list", "YYYY/MM", "YYYY/MM", "Automatically convert to NTD", "", "Amount in NTD + Charge fee"]
        }
        
        //check
        Dlog("a. \(rowTypeAry.count) b. \(rowSubTypeAry.count) c. \(rowNameAry.count) d. \(placeHolderAry.count)")
    }
}
