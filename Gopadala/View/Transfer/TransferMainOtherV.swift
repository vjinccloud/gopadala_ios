//
//  TransferMainOtherV.swift
//  Gopadala
//
//  Created by Wang Jen Chung on 2024/3/9.
//  Copyright © 2024 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import KingfisherWebP

class TransferMainOtherV: UIView, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var topScrollV: UIScrollView!
    
    var pickerV:UIPickerView!
    var tempTag = 0
    var tempRecipientObj:RecipientObj =  RecipientObj()
    var stuffObj = AddRecipientNewObj()
    var allElement:[AddRecipientNewElement] = []
    var selectId:[String] = []
    var fromPicker:UIDatePicker!
    var toDatePicker:UIDatePicker!
    var chosedFromDate:Date!
    var chosedToDate:Date!
    
    var parentVC:TransferMainVC!
    var totalIdx = 0
    var amountIdx = 0
    var chargeIdx = 0
    var serviceCharge = 0
    var transfer_amount_idr = 0
    var transfer_idr = 0
    var amount_ntd = 0
    var startMonthStr = ""
    var endMonthStr = ""
    var payment_code = ""
    var payment_code2 = ""
    var php_months = 0
    var isSSSContribution = false
    var tagOfPagAmount = 0
    
    //MARK: - Init
    func initUI() {
        var startY:CGFloat = 20
        
        AppDelegate.shared().paymentTypeObj = []
        AppDelegate.shared().sSSContributionObj = []
        AppDelegate.shared().pHNContributionObj = []
        
        if AppDelegate.shared().tansferMethod == .SSS {
            serviceCharge = Int(AppDelegate.shared().memberData["service_charge_SSS"]!)!
        } else if AppDelegate.shared().tansferMethod == .Pag {
            serviceCharge = Int(AppDelegate.shared().memberData["service_charge_PGB"]!)!
        } else if AppDelegate.shared().tansferMethod == .Health {
            serviceCharge = Int(AppDelegate.shared().memberData["service_charge_PHN"]!)!
        }
        
        topScrollV.subviews.forEach({ $0.removeFromSuperview() })
        stuffObj = AddRecipientNewObj()
        stuffObj.initTransferProperty()
        
        allElement = []
        for i in 0..<stuffObj.rowTypeAry.count {
            let obj = AddRecipientNewElement.init(frame: CGRect.init(x: 25, y: startY, width: topScrollV.frame.width-50, height: 70))
            obj.initAll(labelStr: stuffObj.rowNameAry[i], name: "", placeHold: stuffObj.placeHolderAry[i], type: stuffObj.rowTypeAry[i], sub: stuffObj.rowSubTypeAry[i], tag: i)
            obj.textField.tag = i
            if stuffObj.rowTypeAry[i] == .select, stuffObj.rowSubTypeAry[i] != .s_bank {
                initPickerView(touchAt: obj.textField)
            } else if stuffObj.rowTypeAry[i] == .day {
                addDatePicker(subtype: stuffObj.rowSubTypeAry[i], txtF: obj.textField)
            }
            
            if stuffObj.rowSubTypeAry[i] == .s_branch {
                obj.titleL.alpha = 0.5
                obj.txtBgV.alpha = 0.5
            }
            
            if AppDelegate.shared().tansferMethod == .SSS {
                if stuffObj.rowSubTypeAry[i] == .s_contribution || stuffObj.rowSubTypeAry[i] == .t_php {
                    obj.titleL.alpha = 0.5
                    obj.txtBgV.alpha = 0.5
                }
            }
            
            if AppDelegate.shared().tansferMethod == .Pag {
                if stuffObj.rowSubTypeAry[i] == .t_php {
                    tagOfPagAmount = i
                }
            }
            
            if stuffObj.rowTypeAry[i] != .total {
                obj.textField.delegate = self
            }
            
            if stuffObj.rowTypeAry[i] == .total || stuffObj.rowSubTypeAry[i] == .t_ntd {
                obj.textField.isEnabled = false
            }
            
            if stuffObj.rowTypeAry[i] == .total {
                totalIdx = i
            }
            
            if AppDelegate.shared().tansferMethod == .Health, stuffObj.rowSubTypeAry[i] == .d_to {
                obj.textField.isEnabled = false
            }
            
            if stuffObj.rowSubTypeAry[i] == .t_ntd {
                if stuffObj.rowNameAry[i].hasPrefix("Amount") {
                    amountIdx = i
                } else if stuffObj.rowNameAry[i].hasPrefix("Charge") {
                    chargeIdx = i
                    obj.textField.text = "\(serviceCharge)"
                }
            }
            
            obj.parentV = self
            
            topScrollV.addSubview(obj)
            allElement.append(obj)
            selectId.append("")
            
            startY += obj.frame.height
        }
        
        startY += 20
        let btn = UIButton.init(frame: CGRect.init(x: 0, y: startY, width: topScrollV.frame.width/2, height: 35))
        btn.setTitle("SUBMIT", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        btn.backgroundColor = .clear
        btn.layer.backgroundColor = Color_Gradient_Left.cgColor
        btn.layer.cornerRadius = 10
        btn.center = CGPoint.init(x: topScrollV.frame.width/2, y: startY + btn.frame.height/2)
        btn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        topScrollV.addSubview(btn)
        
        startY += btn.frame.height + 30
        
        if startY <= topScrollV.frame.height {
            startY = topScrollV.frame.height + 30
        }
        
        topScrollV.contentSize = CGSize.init(width: topScrollV.frame.width, height: startY)
    }

    func monthsBetweenDates(from dateString1: String, to dateString2: String) -> Int? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM"
        
        guard let date1 = dateFormatter.date(from: dateString1),
              let date2 = dateFormatter.date(from: dateString2) else {
            return nil // 不能解析日期
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.month], from: date1, to: date2)
        return components.month! + 1
    }
    
    func addMonthsToDateString(dateString: String, monthsToAdd: Int) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM"
        
        guard let date = dateFormatter.date(from: dateString) else {
            return nil // 不能解析日期
        }
        
        let calendar = Calendar.current
        if let newDate = calendar.date(byAdding: .month, value: monthsToAdd-1, to: date) {
            return dateFormatter.string(from: newDate)
        } else {
            return nil // 日期操作失敗
        }
    }

    func calculateAmount() {
        
        var totalMonths = 0
        var amount = 0
        startMonthStr = ""
        endMonthStr = ""
        var isSSS_Short = false
        
        for i in 0..<stuffObj.rowSubTypeAry.count {
            
            if AppDelegate.shared().tansferMethod == .SSS {
                if stuffObj.rowSubTypeAry[i] == .s_contribution, allElement[i].titleL.alpha == 1, allElement[i].textField.text != "" {
                    amount = Int(allElement[i].textField.text!)!
                } else if stuffObj.rowSubTypeAry[i] == .t_php, allElement[i].titleL.alpha == 1, allElement[i].textField.text != "" {
                    amount = Int(allElement[i].textField.text!)!
                    isSSS_Short = true
                }
            } else if AppDelegate.shared().tansferMethod == .Pag {
                if stuffObj.rowSubTypeAry[i] == .t_php, allElement[i].titleL.alpha == 1, allElement[i].textField.text != "" {
                    amount = Int(allElement[i].textField.text!)!
                }
            } else if AppDelegate.shared().tansferMethod == .Health {
                if stuffObj.rowSubTypeAry[i] == .s_phpAmount, allElement[i].titleL.alpha == 1, allElement[i].textField.text != "" {
                    amount = Int(allElement[i].textField.text!)!
                }
            }
            
            if stuffObj.rowSubTypeAry[i] == .d_from {
                startMonthStr = allElement[i].textField.text!
            } else if stuffObj.rowSubTypeAry[i] == .d_to {
                endMonthStr = allElement[i].textField.text!
            }
        }
        
        isSSSContribution = !isSSS_Short
        totalMonths = monthsBetweenDates(from: startMonthStr, to: endMonthStr) ?? 0
        Dlog("amount = \(amount), totalMonths = \(totalMonths)")
        transfer_idr = amount
        
        if totalMonths == 0 || amount == 0 {
            amount_ntd = 0
            transfer_amount_idr = 0
            allElement[amountIdx].textField.text = "0"
            allElement[totalIdx].textField.text = "0"
        } else {
            
            if AppDelegate.shared().tansferMethod == .Health {
                transfer_amount_idr = amount
            } else if AppDelegate.shared().tansferMethod == .Pag {
                transfer_amount_idr = amount * totalMonths
                transfer_idr = amount
            } else if AppDelegate.shared().tansferMethod == .SSS, isSSS_Short {
                Dlog("isSSS_Short")
                transfer_amount_idr = amount * totalMonths
                transfer_idr = amount
            } else {
                transfer_amount_idr = amount * totalMonths
            }
            amount_ntd = Int(ceil(Double(transfer_amount_idr) / parentVC.kursValue))
            allElement[amountIdx].textField.text = "\(amount_ntd)"
            allElement[totalIdx].textField.text = "\(amount_ntd+serviceCharge)"
        }
        
        Dlog("transfer_amount_idr = \(transfer_amount_idr), transfer_idr = \(transfer_idr), amount_ntd = \(amount_ntd)")
    }
    
    func callSelect(tag: Int) {
        let subtype = stuffObj.rowSubTypeAry[tag]
        tempTag = tag
        allElement[tag].textField.becomeFirstResponder()
    }
    
    //MARK: - Check
    func checkCanGoOn() -> Bool {
        
        for i in 0..<stuffObj.rowTypeAry.count {
            let type = stuffObj.rowTypeAry[i]
            
            if type == .total {
                continue
            }
        }
        
        if AppDelegate.shared().tansferMethod == .SSS || AppDelegate.shared().tansferMethod == .Pag {
            if !checkDate() {
                return false
            }
        }
        
        return true
    }
    
    //MARK: - UITextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let pointInTable = textField.superview?.convert(textField.frame.origin, to: topScrollV)
        
        if let point = pointInTable {
            let y = point.y - 60
            topScrollV.setContentOffset(CGPoint(x: 0, y: y), animated: true)
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let tag = textField.tag
        tempTag = tag
        let subtype = stuffObj.rowSubTypeAry[tag]
        
        if subtype == .s_payType {
            
            if AppDelegate.shared().paymentTypeObj.count == 0 {
                getPaymentType()
                return false
            }
        } else if subtype == .s_contribution || subtype == .s_contribution_loan {
            
            if allElement[tag].txtBgV.alpha == 0.5 {
                return false
            }
            
            if AppDelegate.shared().tansferMethod == .SSS {
                if AppDelegate.shared().sSSContributionObj.count == 0 {
                    getCashOption()
                    return false
                }
            } else if AppDelegate.shared().tansferMethod == .Health {
                if AppDelegate.shared().pHNContributionObj.count == 0 {
                    getCashOption()
                    return false
                }
            }
            
        } else if subtype == .s_phpAmount {
            if AppDelegate.shared().pHNContributionObj.count == 0 {
                getCashOption()
                return false
            }
        }
        
        return true
    }
    
    func checkPagAmount(tagOfAmount:Int) {
        let tag = tagOfAmount
        let text = allElement[tag].textField.text!
        var value = 0
        if text != "", text.checkNumber() {
            value = Int(text) ?? 0
        }
        
        if stuffObj.rowSubTypeAry[tag] == .t_php {
            for i in 0..<stuffObj.rowSubTypeAry.count {
                if stuffObj.rowSubTypeAry[i] == .s_payType, selectId[i] != "" {
                    if allElement[i].textField.text! == "Contribution", value < 200 {
                        AppDelegate.shared().showAlert(self.parentVC, title: "", msg: "Amount must be at least 200 PHP")
                        allElement[tag].textField.text = "200"
                    } else if allElement[i].textField.text! == "Pag-IBIG MP2", value < 500 {
                        AppDelegate.shared().showAlert(self.parentVC, title: "", msg: "Amount must be at least 500 PHP")
                        allElement[tag].textField.text = "500"
                    }
                }
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        let tag = textField.tag
        if AppDelegate.shared().tansferMethod == .Pag {
            checkPagAmount(tagOfAmount: tag)
        }
        calculateAmount()
    }
    
    func addDatePicker(subtype:AddRecipientRowSubType, txtF:UITextField) {
        let datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: parentVC.view.bounds.size.width, height: 200))
        
        if subtype == .d_to || subtype == .d_from {
            //datePicker.date = chosedFromDate
            datePicker.datePickerMode = .date
        } else if subtype == .d_birth {
            datePicker.datePickerMode = .date
            //datePicker.date = chosedToDate
        }
        
        txtF.inputView = datePicker
        let doneButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(datePickerDone(_:)))
        doneButton.tag = txtF.tag
        
        let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: parentVC.view.bounds.size.width, height: 44))
        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
        txtF.inputAccessoryView = toolBar
        
        
        if subtype == .d_birth || subtype == .d_from {
            fromPicker = datePicker
        } else if subtype == .d_to {
            toDatePicker = datePicker
        }
        
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
    }
    
    @objc func datePickerDone(_ sender:UIBarButtonItem) {
        let subtype = stuffObj.rowSubTypeAry[sender.tag]
        var date = Date()
        if subtype == .d_birth || subtype == .d_from {
            date = fromPicker.date
            chosedFromDate = date
            
            if AppDelegate.shared().tansferMethod == .Health {
                for i in 0..<stuffObj.rowSubTypeAry.count {
                    if stuffObj.rowSubTypeAry[i] == .d_to {
                        let monthstr = addMonthsToDateString(dateString: giveDateString(date: date, subtype: subtype), monthsToAdd: php_months)
                        allElement[i].textField.text = monthstr
                    }
                }
            }
            
        } else if subtype == .d_to {
            date = toDatePicker.date
            chosedToDate = date
            
            
        }
        allElement[sender.tag].textField.text = giveDateString(date: date, subtype: subtype)
        allElement[sender.tag].textField.resignFirstResponder()
    }
    
    func checkDate() -> Bool {
        if chosedFromDate == nil || chosedToDate == nil {
            AppDelegate.shared().showAlertWithWindow(parentVC, Message: "Date inputs is invalid")
            return false
        }
        
        if chosedToDate.compareOneDay(AnotherDay: chosedFromDate) == 2 {
            AppDelegate.shared().showAlertWithWindow(parentVC, Message: "Date inputs is invalid")
            return false
        }
        
        return true
    }
    
    func giveDateString(date:Date, subtype:AddRecipientRowSubType) -> String {
        var str = ""
        if subtype == .d_birth {
            str = date.toString(format: "yyyy-MM-dd")
        } else if subtype == .d_from || subtype == .d_to {
            str = date.toString(format: "yyyy/MM")
        }
        
        return str
    }
    
    //MARK: - API
    public func getPaymentType() {
        var parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        if AppDelegate.shared().tansferMethod == .Pag {
            parameters["service_code"] = "PGB"
        } else if AppDelegate.shared().tansferMethod == .SSS {
            parameters["service_code"] = "SSS"
        } else if AppDelegate.shared().tansferMethod == .Health {
            parameters["service_code"] = "PHN"
        }
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_PaymentTypeList;
        
        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        
        AppDelegate.shared().alamofireManagerWithTimeout.requestWithoutCache(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in
                AppDelegate.shared().removeLoadingView()
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling on \(todoEndpoint)")
                    print(response.result.error!)
                    AppDelegate.shared().showAlertWithWindow(self.parentVC, Message: NSLocalizedString("API Timeout", comment: ""))
                    return
                }
                
                let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                Dlog("responseStr = \(responseStr ?? "")")
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    self.allElement[self.tempTag].textField.becomeFirstResponder()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self.parentVC, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    public func getCashOption() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        var todoEndpoint: String = API_CashPickupOptionList;
        
        if AppDelegate.shared().tansferMethod == .Cash {
            todoEndpoint = API_CashPickupOptionList
        } else if AppDelegate.shared().tansferMethod == .SSS {
            todoEndpoint = API_SSSContributionList
        } else if AppDelegate.shared().tansferMethod == .Health {
            todoEndpoint = API_PHNContributionList
        }
        
        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        
        AppDelegate.shared().alamofireManagerWithTimeout.requestWithoutCache(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in
                AppDelegate.shared().removeLoadingView()
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling on \(todoEndpoint)")
                    print(response.result.error!)
                    AppDelegate.shared().showAlertWithWindow(self.parentVC, Message: NSLocalizedString("API Timeout", comment: ""))
                    return
                }
                
                let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                Dlog("responseStr = \(responseStr ?? "")")
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    self.allElement[self.tempTag].textField.becomeFirstResponder()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self.parentVC, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func initPickerView(touchAt sender:UITextField){
        if pickerV == nil {
            pickerV = UIPickerView()
            pickerV.delegate = self
            pickerV.dataSource = self
        }
        
        // 依照點選不同的textField取出對應的pickView並給予tag
        // 到時候再依 tag 來撈出相對應資料
        
        let tag = sender.tag
        
        // 設定pickerView上方的toolbar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        // 讓toolbar自動調整合適於pickerView尺吋
        toolBar.sizeToFit()
        
        // 設定toolbar內的button
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(clickCancelButton(_:)))
        cancelButton.tag = tag
        // 中間空白的部份
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Chose", style: .plain, target: self, action: #selector(clickDoneButton(_:)))
        doneButton.tag = tag
        
        toolBar.setItems([cancelButton, spaceItem, doneButton], animated: false)
        
        // 設定toobar可以使用
        toolBar.isUserInteractionEnabled = true
        // 將pickerField輸入view改為pickerView
        sender.inputView = pickerV
        sender.tintColor = .clear
        // 將toolbar設定在pickerField裡面
        sender.inputAccessoryView = toolBar
    }
    
    //MARK: - Button-Action
    @objc func nextAction() {
        if !checkCanGoOn() {
            return
        }
        Dlog("nextAction")
        
        AppDelegate.shared().transactionObj = TransactionObj()
        AppDelegate.shared().transactionObj.ntdValue = amount_ntd
        AppDelegate.shared().transactionObj.other_PHN_months = php_months
        AppDelegate.shared().transactionObj.isSSSContribution = isSSSContribution
        AppDelegate.shared().transactionObj.other_ym_start = startMonthStr
        AppDelegate.shared().transactionObj.other_ym_end = endMonthStr
        AppDelegate.shared().transactionObj.other_payment_code = payment_code
        AppDelegate.shared().transactionObj.other_payment_code2 = payment_code2
        AppDelegate.shared().transactionObj.other_transfer_idr = transfer_idr
        
        if AppDelegate.shared().tansferMethod == .SSS {
            AppDelegate.shared().transactionObj.targetValue = transfer_amount_idr
            //AppDelegate.shared().transactionObj.other_transfer_idr = 0
            
        } else if AppDelegate.shared().tansferMethod == .Pag {
            AppDelegate.shared().transactionObj.targetValue = transfer_amount_idr
        } else {
            AppDelegate.shared().transactionObj.targetValue = 0
        }
        
        AppDelegate.shared().transactionObj.other_amount_ntd = amount_ntd
        
        AppDelegate.shared().transactionObj.other_transfer_amount_idr = transfer_amount_idr
        
        AppDelegate.shared().transactionObj.feeValue = serviceCharge
        AppDelegate.shared().transactionObj.usePoint = 0
        AppDelegate.shared().transactionObj.totalNtdValue = amount_ntd + serviceCharge
        
        //送出前要查詢是否超過金額
        //202304 改成先檢查會員資料
        //checkMemberData()
        //202306 改成先MR
        checkAmountOther()
        
    }
    
    public func checkAmountOther() {
        
        let use_remit_point = 0
        
        var parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "amount_ntd":amount_ntd, "use_remit_point":use_remit_point, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        
        var todoEndpoint: String = API_MemberCheckAmountOther;
        if !AppDelegate.shared().transferChoseLeft {
            todoEndpoint = API_MemberRecipentsOther_Transfer
            var idstr = ""
            if AppDelegate.shared().tansferMethod == .Cash {
                idstr = "NTP"
            } else if AppDelegate.shared().tansferMethod == .SSS {
                idstr = "SSS"
            } else if AppDelegate.shared().tansferMethod == .Pag {
                idstr = "PGB"
            } else if AppDelegate.shared().tansferMethod == .Health {
                idstr = "PHN"
            }
            parameters["recipient_type_id"] = idstr
        }
        
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        
        AppDelegate.shared().alamofireManagerWithTimeout.requestWithoutCache(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in
                AppDelegate.shared().removeLoadingView()
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling on \(todoEndpoint)")
                    print(response.result.error!)
                    AppDelegate.shared().showAlertWithWindow(self.parentVC, Message: NSLocalizedString("API Timeout", comment: ""))
                    return
                }
                //AppDelegate.shared().apiBackContentStr
                let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                Dlog("checkAmount responseStr = \(responseStr ?? "")")
                
                AppDelegate.shared().recipientListObjs = []
                AppDelegate.shared().recipientShownListObjs = []
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                
                if result == ResponseState.ok {
                    self.parentVC.checkMemberData()
                } else if result == ResponseState.error {
                    let msg = NSLocalizedString("Transfer Result Exceed", comment: "") + " " + AppDelegate.shared().apiBackContentStr.stringToIntDecimalString()
                    AppDelegate.shared().showAlertWithWindow(self.parentVC, Message:msg)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self.parentVC, Message: AppDelegate.shared().apiBackContentStr)
                } else if result == ResponseState.maxExceed {
                    Dlog("AppDelegate.shared().tempTransferLeftAmount = \(AppDelegate.shared().tempTransferLeftAmount)")
                    
                    let customAlert = CustomAlertView.init(frame: self.parentVC.view.bounds)
                    customAlert.initAmountAlert(Title: "NOTICE")
                    self.parentVC.view.addSubview(customAlert)
                    
                }
        }
    }
    
    //MARK: - Picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let subtype = stuffObj.rowSubTypeAry[tempTag]
        
        if subtype == .s_relation {
            return AppDelegate.shared().relationObj.count
        } else if subtype == .s_branch {
            return AppDelegate.shared().branchAreaObj.count
        } else if subtype == .s_cashOption {
            return AppDelegate.shared().cashOptionObj.count
        } else if subtype == .s_payType {
            return AppDelegate.shared().paymentTypeObj.count
        } else if subtype == .s_contribution || subtype == .s_contribution_loan {
            if AppDelegate.shared().tansferMethod == .SSS {
                return AppDelegate.shared().sSSContributionObj.count
            } else if AppDelegate.shared().tansferMethod == .Health {
                return AppDelegate.shared().pHNContributionObj.count
            }
        } else if subtype == .s_phpAmount {
            return AppDelegate.shared().pHNContributionObj.count
        }
        return 3
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let subtype = stuffObj.rowSubTypeAry[tempTag]
        
        if subtype == .s_relation {
            return AppDelegate.shared().relationObj[row].name
        } else if subtype == .s_branch {
            return AppDelegate.shared().branchAreaObj[row].name
        } else if subtype == .s_cashOption {
            return AppDelegate.shared().cashOptionObj[row].name
        } else if subtype == .s_payType {
            return AppDelegate.shared().paymentTypeObj[row].payment_name
        } else if subtype == .s_contribution || subtype == .s_contribution_loan {
            if AppDelegate.shared().tansferMethod == .SSS {
                return AppDelegate.shared().sSSContributionObj[row].amt
            } else if AppDelegate.shared().tansferMethod == .Health {
                return AppDelegate.shared().pHNContributionObj[row].amt
            }
        } else if subtype == .s_phpAmount {
            return AppDelegate.shared().pHNContributionObj[row].amt
        }
        return "\(row)"
    }
    
    @objc func clickCancelButton(_ sender:UIBarButtonItem) {
        let tag = sender.tag
        allElement[tag].textField.resignFirstResponder()
    }
    
    @objc func clickDoneButton(_ sender:UIBarButtonItem) {
        let idx = pickerV.selectedRow(inComponent: 0)
        let tag = sender.tag
        allElement[tag].textField.resignFirstResponder()
        
        let subtype = stuffObj.rowSubTypeAry[tempTag]
        
        if subtype == .s_relation {
            allElement[tag].textField.text = AppDelegate.shared().relationObj[idx].name
            selectId[tag] = AppDelegate.shared().relationObj[idx].idx!
        } else if subtype == .s_branch {
            allElement[tag].textField.text = AppDelegate.shared().branchAreaObj[idx].name
            selectId[tag] = AppDelegate.shared().branchAreaObj[idx].idx!
        } else if subtype == .s_cashOption {
            allElement[tag].textField.text = AppDelegate.shared().cashOptionObj[idx].name
            selectId[tag] = AppDelegate.shared().cashOptionObj[idx].idx!
        } else if subtype == .s_payType {
            allElement[tag].textField.text = AppDelegate.shared().paymentTypeObj[idx].payment_name
            selectId[tag] = AppDelegate.shared().paymentTypeObj[idx].paymenet_code!
            payment_code = AppDelegate.shared().paymentTypeObj[idx].paymenet_code!
            payment_code2 = AppDelegate.shared().paymentTypeObj[idx].payment_code_2!
            
            if AppDelegate.shared().tansferMethod == .SSS {
                if allElement[tag].textField.text!.hasPrefix("Contribution") {
                    for i in 0..<stuffObj.rowSubTypeAry.count {
                        if stuffObj.rowSubTypeAry[i] == .s_contribution {
                            allElement[i].titleL.alpha = 1
                            allElement[i].txtBgV.alpha = 1
                        } else if stuffObj.rowSubTypeAry[i] == .t_php {
                            allElement[i].titleL.alpha = 0.5
                            allElement[i].txtBgV.alpha = 0.5
                        }
                    }
                } else if allElement[tag].textField.text!.hasPrefix("Short") {
                    for i in 0..<stuffObj.rowSubTypeAry.count {
                        if stuffObj.rowSubTypeAry[i] == .s_contribution {
                            allElement[i].titleL.alpha = 0.5
                            allElement[i].txtBgV.alpha = 0.5
                        } else if stuffObj.rowSubTypeAry[i] == .t_php {
                            allElement[i].titleL.alpha = 1
                            allElement[i].txtBgV.alpha = 1
                        }
                    }
                } else {
                    for i in 0..<stuffObj.rowSubTypeAry.count {
                        if stuffObj.rowSubTypeAry[i] == .s_contribution {
                            allElement[i].titleL.alpha = 1
                            allElement[i].txtBgV.alpha = 1
                        } else if stuffObj.rowSubTypeAry[i] == .t_php {
                            allElement[i].titleL.alpha = 0.5
                            allElement[i].txtBgV.alpha = 0.5
                        }
                    }
                }
            } else if AppDelegate.shared().tansferMethod == .Pag {
                checkPagAmount(tagOfAmount: tagOfPagAmount)
            }
            
        } else if subtype == .s_contribution || subtype == .s_contribution_loan {
            if AppDelegate.shared().tansferMethod == .SSS {
                allElement[tag].textField.text = AppDelegate.shared().sSSContributionObj[idx].amt
                selectId[tag] = AppDelegate.shared().sSSContributionObj[idx].amt!
            } else if AppDelegate.shared().tansferMethod == .Health {
                allElement[tag].textField.text = AppDelegate.shared().pHNContributionObj[idx].amt
                selectId[tag] = AppDelegate.shared().pHNContributionObj[idx].amt!
            }
        } else if subtype == .s_phpAmount {
            allElement[tag].textField.text = AppDelegate.shared().pHNContributionObj[idx].amt
            selectId[tag] = AppDelegate.shared().pHNContributionObj[idx].amt!
            php_months = Int(AppDelegate.shared().pHNContributionObj[idx].months!)!
            
            var monthstr = ""
            for i in 0..<stuffObj.rowSubTypeAry.count {
                if stuffObj.rowSubTypeAry[i] == .d_from {
                    monthstr = allElement[i].textField.text!
                    break
                }
            }
            
            if monthstr != "" {
                for i in 0..<stuffObj.rowSubTypeAry.count {
                    if stuffObj.rowSubTypeAry[i] == .d_to {
                        let monthstr = addMonthsToDateString(dateString:monthstr, monthsToAdd: php_months)
                        allElement[i].textField.text = monthstr
                    }
                }
            }
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
