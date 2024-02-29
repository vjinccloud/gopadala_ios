//
//  TransferMainVC.swift
//  indogo
//
//  Created by mac on 2020/9/2.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import KingfisherWebP

class TransferMainVC: UIViewController, UITextFieldDelegate, CustomAlertDelegate {
    
    @IBOutlet weak var boxV: UIView!
    @IBOutlet weak var upNameL: UILabel!
    @IBOutlet weak var upTextLineV: UIView!
    @IBOutlet weak var downNameL: UILabel!
    @IBOutlet weak var downTextLineV: UIView!
    @IBOutlet weak var upTextField: UITextField!
    @IBOutlet weak var downTextField: UITextField!
    @IBOutlet weak var kirimL: UILabel!
    @IBOutlet weak var valueL: UILabel!
    @IBOutlet weak var pointL: UILabel!
    @IBOutlet weak var pointLeftL: UILabel!
    @IBOutlet weak var totalNTDTitleL: UILabel!
    @IBOutlet weak var totalNTDL: UILabel!
    @IBOutlet weak var leftBgV: UIView!
    @IBOutlet weak var leftPL: UILabel!
    @IBOutlet weak var leftTotalPL: UILabel!
    @IBOutlet weak var leftDownL: UILabel!
    @IBOutlet weak var rightBgV: UIView!
    @IBOutlet weak var rightTitleL: UILabel!
    
    var loadOnce = false
    var kursValue:Double = 0
    var calculateStyle = 0 //0是以台幣為主計算，1是以印尼幣為主
    var coinTransferPercent = 1
    var serviceCharge = 0
    var decresedCharge = 0
    var decresedChargeUnit = 50
    var totalChage = 0
    var statusNow = 0
    
    func customAlertnextAction(Ref obj: CustomAlertView) {
        obj.removeFromSuperview()
        
        if statusNow == 1 || statusNow == 3 {
            let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "MemberEditVC") as? MemberEditVC
            self.navigationController?.pushViewController(nextVC!, animated: true)
        } else if statusNow == 2 {
            //checkAmount()
            self.goRecipientList()
        }
    }
    
    func customAlertnextActionSecond(Ref obj: CustomAlertView) {
        
    }
    
    //MARK: - Utility
    func setUpKursValue() {
        kursValue = Double(AppDelegate.shared().memberData["kurs_value"]!)!
        serviceCharge = Int(AppDelegate.shared().memberData["service_charge"]!)!
    }
    
    func justCalculateValue(UseStyle style:Int, NweString newString:String) {
        
        var upValue = Int(newString.replacingOccurrences(of: ",", with: ""))
        var downValue = Int(newString.replacingOccurrences(of: ",", with: ""))
         
        if style == 0 {
            if upTextField.text == "" {
                upTextField.text = "1"
                upValue = 1
            }
            downValue = Int(ceil(Double(upValue!) * kursValue))
            if downValue! < 1 {
                downValue! = 1
            }
        } else if style == 1 {
            if downTextField.text == "" {
                downTextField.text = "1"
                downValue = 1
            }
            upValue = Int(ceil(Double(downValue!) / kursValue))
            if upValue! < 1 {
                upValue! = 1
            }
        }
        
        if upTextField.isFirstResponder == false {
            upTextField.text = "\(upValue ?? 1)".stringToIntDecimalString()
        }
        
        if downTextField.isFirstResponder == false {
            downTextField.text = "\(downValue ?? 1)".stringToIntDecimalString()
        }
    }
    
    func checkAndCalculateValue(UseStyle style:Int, NweString newString:String) {
        setUpKursValue()

        /*
        let value = Double(AppDelegate.shared().memberData["remit_point"]!)!
        if value < 200 {
            serviceCharge = Int(value)
        }*/
        
        var string = newString
        
        var upValue = Int(upTextField.text!.replacingOccurrences(of: ",", with: ""))
        var downValue = Int(downTextField.text!.replacingOccurrences(of: ",", with: ""))
         
        if style == 0 {
            if upTextField.text == "" {
                upTextField.text = "1"
                upValue = 1
            }
            downValue = Int(ceil(Double(upValue!) * kursValue))
            if downValue! < 1 {
                downValue! = 1
            }
        } else if style == 1 {
            if downTextField.text == "" {
                downTextField.text = "1"
                downValue = 1
            }
            upValue = Int(ceil(Double(downValue!) / kursValue))
            if upValue! < 1 {
                upValue! = 1
            }
        } else if style == 2 {
            if string == "" {
                string = "1"
                //upTextField.text = "1"
            }
            
            upValue = Int(string)
            downValue = Int(ceil(Double(upValue!) * kursValue))
            downTextField.text = "\(downValue ?? 1)".stringToIntDecimalString()
        } else if style == 3 {
            if string == "" {
                string = "1"
                //downTextField.text = "1"
            }
            
            downValue = Int(string)
            upValue = Int(ceil(Double(downValue!) / kursValue))
            if upValue! < 1 {
                upValue! = 1
            }
            upTextField.text = "\(upValue ?? 1)".stringToIntDecimalString()
        }
        
        if style < 2 {
            if upTextField.isFirstResponder == false {
                upTextField.text = "\(upValue ?? 1)".stringToIntDecimalString()
            }
            
            if downTextField.isFirstResponder == false {
                downTextField.text = "\(downValue ?? 1)".stringToIntDecimalString()
            }
        }
        
        valueL.text = "\(serviceCharge)"
        if decresedCharge == 0 {
            pointLeftL.text = "\(decresedCharge)"
        } else {
            pointLeftL.text = "-\(decresedCharge)"
        }
        
        totalChage = upValue! + serviceCharge - decresedCharge
        totalNTDL.text = "\(totalChage)".stringToIntDecimalString()
        
        Dlog("totalChage = \(totalChage)")
    }
    
    //MARK: - Button Action
    @IBAction func leftBtnAction(_ sender: Any) {
        let value = Int(AppDelegate.shared().memberData["remit_point"]!)!
        
        if decresedCharge == serviceCharge || decresedCharge == value {
            decresedCharge = 0
        } else {
            
            //暫時改成 0 或 全部
            decresedCharge = serviceCharge
            if decresedCharge > value {
                decresedCharge = 0
            }
            
            if decresedCharge > serviceCharge {
                decresedCharge = serviceCharge
            }
            
            //之後恢復
            /*
            decresedCharge += decresedChargeUnit
            if decresedCharge > value {
                decresedCharge = 0
            }
            
            if decresedCharge > serviceCharge {
                decresedCharge = serviceCharge
            }
            */
        }
        
        checkAndCalculateValue(UseStyle: 0, NweString: "")
    }

    @IBAction func rightBtnAction(_ sender: Any) {
        
        if upTextField.text!.replacingOccurrences(of: ",", with: "") == "" || downTextField.text!.replacingOccurrences(of: ",", with: "") == "" || Int(upTextField.text!.replacingOccurrences(of: ",", with: ""))! == 0 || Int(downTextField.text!.replacingOccurrences(of: ",", with: ""))! == 0 {
            return
        }
        
        AppDelegate.shared().transactionObj = TransactionObj()
        AppDelegate.shared().transactionObj.ntdValue = Int(upTextField.text!.replacingOccurrences(of: ",", with: ""))!
        //印尼盾必須再用台幣換算印尼盾(要對齊)
        let downValue = Int(ceil(Double(AppDelegate.shared().transactionObj.ntdValue) * kursValue))
        AppDelegate.shared().transactionObj.targetValue = downValue
        AppDelegate.shared().transactionObj.feeValue = serviceCharge
        AppDelegate.shared().transactionObj.usePoint = decresedCharge
        AppDelegate.shared().transactionObj.totalNtdValue = totalChage
        
        //送出前要查詢是否超過金額
        //202304 改成先檢查會員資料
        //checkMemberData()
        //202306 改成先MR
        checkAmount()
    }
    
    //MARK: - API
    public func callMemberData() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_CheckLogin;
        
        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        
        AppDelegate.shared().alamofireManagerWithTimeout.requestWithoutCache(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in
                AppDelegate.shared().removeLoadingView()
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling on \(todoEndpoint)")
                    print(response.result.error!)
                    AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("API Timeout", comment: ""))
                    return
                }
                
                let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                Dlog("responseStr = \(responseStr ?? "")")
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    self.setUpKursValue()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    public func checkMemberData() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        
        let headers: HTTPHeaders = [:]
        closeAll()
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_DataCheck;
        
        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        
        AppDelegate.shared().alamofireManagerWithTimeout.requestWithoutCache(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in
                AppDelegate.shared().removeLoadingView()
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling on \(todoEndpoint)")
                    print(response.result.error!)
                    AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("API Timeout", comment: ""))
                    return
                }
                //AppDelegate.shared().apiBackContentStr
                let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                Dlog("checkAmount responseStr = \(responseStr ?? "")")
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    //self.checkAmount()
                    self.goRecipientList()
                } else if result == ResponseState.error {
                    let msg = NSLocalizedString("Transfer Result Exceed", comment: "") + " " + AppDelegate.shared().apiBackContentStr.stringToIntDecimalString()
                    AppDelegate.shared().showAlertWithWindow(self, Message:msg)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                } else if result == ResponseState.dataCheckStatus1 {
                    self.statusNow = 1
                    let customAlert = CustomAlertView.init(frame: self.view.bounds)
                    //customAlert.initDataCheckAlert(Title: "Pemberitahuan", Content: "Masa berlaku ARC Anda kurang dari 10 hari", NextBtn1Str: "perbaharui arc")
                    customAlert.initDataCheckAlert(Title: "Pemberitahuan", Content: AppDelegate.shared().apiBackContentStr, NextBtn1Str: "ok")
                    self.view.addSubview(customAlert)
                    customAlert.customDelegate = self
                } else if result == ResponseState.dataCheckStatus3 {
                    self.statusNow = 3
                    let customAlert = CustomAlertView.init(frame: self.view.bounds)
                    //customAlert.initDataCheckAlert(Title: "Pemberitahuan", Content: "Masa berlaku ARC Anda sudah berakhir", NextBtn1Str: "perbaharui arc")
                    customAlert.initDataCheckAlert(Title: "Pemberitahuan", Content: AppDelegate.shared().apiBackContentStr, NextBtn1Str: "ok")
                    customAlert.customDelegate = self
                    self.view.addSubview(customAlert)
                } else if result == ResponseState.dataCheckStatus2 {
                    self.statusNow = 2
                    let customAlert = CustomAlertView.init(frame: self.view.bounds)
                    //customAlert.initDataCheckAlert(Title: "Pemberitahuan", Content: "Silakan unggah kembali foto ARC Belakang, ARC Depan, Foto Selfie", NextBtn1Str: "perbaharui arc")
                    customAlert.initDataCheckAlert(Title: "Pemberitahuan", Content: AppDelegate.shared().apiBackContentStr, NextBtn1Str: "ok")
                    customAlert.customDelegate = self
                    self.view.addSubview(customAlert)
                }
        }
    }
    
    public func checkAmount() {
        
        var use_remit_point = 0
        if decresedCharge > 0 {
            use_remit_point = 1
        }
        
        //檢查金額要扣掉手續費
        let charge = Int(upTextField.text!.replacingOccurrences(of: ",", with: ""))!
        //AppDelegate.shared().transactionObj.totalNtdValue
        
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "amount_ntd":charge, "use_remit_point":use_remit_point, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        
        let headers: HTTPHeaders = [:]
        closeAll()
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_MemberRecipents;
        
        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        
        AppDelegate.shared().alamofireManagerWithTimeout.requestWithoutCache(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in
                AppDelegate.shared().removeLoadingView()
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling on \(todoEndpoint)")
                    print(response.result.error!)
                    AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("API Timeout", comment: ""))
                    return
                }
                //AppDelegate.shared().apiBackContentStr
                let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                Dlog("checkAmount responseStr = \(responseStr ?? "")")
                
                AppDelegate.shared().recipientListObjs = []
                AppDelegate.shared().recipientShownListObjs = []
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                
                if result == ResponseState.ok {
                    self.checkMemberData()
                } else if result == ResponseState.error {
                    let msg = NSLocalizedString("Transfer Result Exceed", comment: "") + " " + AppDelegate.shared().apiBackContentStr.stringToIntDecimalString()
                    AppDelegate.shared().showAlertWithWindow(self, Message:msg)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                } else if result == ResponseState.maxExceed {
                    Dlog("AppDelegate.shared().tempTransferLeftAmount = \(AppDelegate.shared().tempTransferLeftAmount)")
                    self.upTextField.text = "\(AppDelegate.shared().tempTransferLeftAmount)"
                    self.justCalculateValue(UseStyle: 0, NweString: "\(AppDelegate.shared().tempTransferLeftAmount)")
                    let customAlert = CustomAlertView.init(frame: self.view.bounds)
                    customAlert.initAmountAlert(Title: "Mohon Maaf")
                    self.view.addSubview(customAlert)
                    self.checkAndCalculateValue(UseStyle: 0, NweString: "")
                }
        }
    }
    
    func goRecipientList() {
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "RecipientListVC") as? RecipientListVC
        nextVC!.canSelectForTransfer = true
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    //MARK: - Text Delegate
    func closeAll() {
        closeText()
    }
    
    func closeText() {
        upTextField.resignFirstResponder()
        downTextField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == upTextField {
            upTextField.text = upTextField.text!.replacingOccurrences(of: ",", with: "")
            upTextField.selectAll(nil)
        } else if textField == downTextField {
            downTextField.text = downTextField.text!.replacingOccurrences(of: ",", with: "")
            downTextField.selectAll(nil)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        var mode = 0
        if textField == upTextField {
            mode = 0
        } else if textField == downTextField {
            mode = 1
        }
        checkAndCalculateValue(UseStyle: mode, NweString: "")
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if ((string == "0" || string == "") && (textField.text! as NSString).range(of: ".").location < range.location) {
            return true
        }
        
        var isEmpty = false
        var newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if newString == "" {
            isEmpty = true
            newString = "1"
        }
        if textField == upTextField {
            justCalculateValue(UseStyle: 0, NweString: newString)
        } else if textField == downTextField {
            justCalculateValue(UseStyle: 1, NweString: newString)
        }
        
        if isEmpty {
            Dlog("isEmpty 1")
            if textField == upTextField {
                upTextField.text = "1"
                upTextField.selectAll(nil)
                return false
            } else if textField == downTextField {
                downTextField.text = "1"
                downTextField.selectAll(nil)
                return false
            }
        }

        /*
        // First check whether the replacement string's numeric...
        let cs = NSCharacterSet(charactersIn: "0123456789.").inverted
        let filtered = string.components(separatedBy: cs)
        let component = filtered.joined(separator: "")
        let isNumeric = string == component

        // Then if the replacement string's numeric, or if it's
        // a backspace, or if it's a decimal point and the text
        // field doesn't already contain a decimal point,
        // reformat the new complete number using
        if isNumeric {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 10
            // Combine the new text with the old; then remove any
            // commas from the textField before formatting
            let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            let numberWithOutCommas = newString.replacingOccurrences(of: ",", with: "")
            let number = formatter.number(from: numberWithOutCommas)
            if number != nil {
                var formattedString = formatter.string(from: number!)
                // If the last entry was a decimal or a zero after a decimal,
                // re-add it here because the formatter will naturally remove
                // it.
                if string == "." && range.location == textField.text?.count {
                    formattedString = formattedString?.appending(".")
                }
                textField.text = formattedString
            } else {
                textField.text = nil
            }
        }
        return false
        */
        
        return true

    }
    
    /*
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if newString.contains(".") || newString.contains("-") {
            //let str = newString.replacingOccurrences(of: "..", with: ".")
            //textField.text = str
            return false
        }
        
        if textField==upTextField {
            if newString.count == 10 {
                return false
            }
            checkAndCalculateValue(UseStyle: 2, NweString: newString)
        } else if textField==downTextField {
            if newString.count == 10 {
                return false
            }
            checkAndCalculateValue(UseStyle: 3, NweString: newString)
        }
        
        return true
    }*/
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Dlog("regionCode = \(Locale.current.regionCode)")

        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        
        upTextLineV.isHidden = true
        downTextLineV.isHidden = true
        boxV.layer.borderWidth = 1
        boxV.layer.borderColor = UIColor.lightGray.cgColor
        
        leftBgV.layer.cornerRadius = leftBgV.frame.size.height/2
        leftBgV.layer.borderWidth = 1
        leftBgV.layer.borderColor = Color_Main_Red.cgColor
        leftPL.backgroundColor = .clear
        leftPL.layer.backgroundColor = Color_Main_Red.cgColor
        leftPL.layer.cornerRadius = leftPL.frame.size.height/2
        
        rightBgV.layer.cornerRadius = rightBgV.frame.size.height/2
        
        upTextField.keyboardType = .numberPad
        downTextField.keyboardType = .numberPad
        upTextField.delegate = self
        downTextField.delegate = self
        
        upNameL.text = NSLocalizedString("Transfer Main Box Up Title", comment: "")
        downNameL.text = NSLocalizedString("Transfer Main Box Down Title", comment: "")
        kirimL.text = NSLocalizedString("Transfer Main Charge Title", comment: "")
        pointL.text = NSLocalizedString("Transfer Main Use Point Title", comment: "")
        totalNTDTitleL.text = NSLocalizedString("Transfer Main Total Money", comment: "")
        leftDownL.text = NSLocalizedString("Transfer Main Total Point Title", comment: "")
        rightTitleL.text = NSLocalizedString("send", comment: "")
        
        leftTotalPL.text = AppDelegate.shared().memberData["remit_point"]!
        checkAndCalculateValue(UseStyle:0, NweString: "")
        
        AppDelegate.shared().getPurposeList()
        AppDelegate.shared().getRelationList()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if loadOnce {
            //這邊每次都要重新設定
            setUpKursValue()
            callMemberData()
            AppDelegate.shared().showTopButton()
            return
        }
        
        loadOnce = true
        rightBgV.addGradienOfIndoGo()
        callMemberData()
        //頂部兩個按鈕
        AppDelegate.shared().topMargin = self.view.safeAreaInsets.top
        AppDelegate.shared().addTopButton()
        
        AppDelegate.shared().nowBottomMenuType = .transaction
        AppDelegate.shared().bottomMenu.paintMenu()
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
