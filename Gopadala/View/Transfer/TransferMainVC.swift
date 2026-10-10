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

class TransferMainVC: UIViewController, UITextFieldDelegate, CustomAlertDelegate, UIGestureRecognizerDelegate {
    
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
    @IBOutlet weak var leftBtn: UIButton!
    
    @IBOutlet weak var midV: UIView!
    @IBOutlet weak var midVL: UIView!
    @IBOutlet weak var midVR: UIView!
    @IBOutlet weak var midLImg: UIImageView!
    @IBOutlet weak var midRImg: UIImageView!
    @IBOutlet weak var midLL: UILabel!
    @IBOutlet weak var midRL: UILabel!
    @IBOutlet weak var otherMethodV: UIView!
    @IBOutlet weak var boxHeight: NSLayoutConstraint!
    @IBOutlet weak var otherChoseBox: UIView!
    @IBOutlet weak var otherChoseL: UILabel!
    
    @IBOutlet weak var otherBoxV1: UIView!
    @IBOutlet weak var otherBoxV2: UIView!
    @IBOutlet weak var otherBoxV3: UIView!
    @IBOutlet weak var otherBoxV4: UIView!
    
    @IBOutlet weak var otherTransferV: TransferMainOtherV!
    
    @IBOutlet weak var promteShowL: UILabel!
    @IBOutlet weak var topbox_barLength: NSLayoutConstraint!
    @IBOutlet weak var topbox_barbackV: UIView!
    @IBOutlet weak var topbox_barV: UIView!
    @IBOutlet weak var topbox_titleL: UILabel!
    @IBOutlet weak var topbox_MoneyL: UILabel!
    @IBOutlet weak var topboxHeight: NSLayoutConstraint!
    var loadOnce = false
    var kursValue:Double = 0
    var calculateStyle = 0 //0是以台幣為主計算，1是以印尼幣為主
    var coinTransferPercent = 1
    var serviceCharge = 0
    var decresedCharge = 0
    var decresedChargeUnit = 50
    var totalChage = 0
    var statusNow = 0
    var discountCodeValue = 0
    private var isManualRefreshing = false
    private let manualRefreshTriggerDistance: CGFloat = 90
    private lazy var manualRefreshIndicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            indicator = UIActivityIndicatorView(style: .large)
        } else {
            indicator = UIActivityIndicatorView(style: .whiteLarge)
        }
        indicator.color = .black
        indicator.hidesWhenStopped = true
        indicator.isHidden = true
        return indicator
    }()
    private var manualRefreshIndicatorTopConstraint: NSLayoutConstraint?
    private var manualRefreshIndicatorBaseOffset: CGFloat = 8
    private var currentPullDistance: CGFloat = 0
    
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
        if AppDelegate.shared().tansferMethod == .Bank {
            serviceCharge = Int(AppDelegate.shared().memberData["service_charge"]!)!
        } else if AppDelegate.shared().tansferMethod == .Cash {
            serviceCharge = Int(AppDelegate.shared().memberData["service_charge_NTP"]!)!
        } else if AppDelegate.shared().tansferMethod == .SSS {
            serviceCharge = Int(AppDelegate.shared().memberData["service_charge_SSS"]!)!
        } else if AppDelegate.shared().tansferMethod == .Pag {
            serviceCharge = Int(AppDelegate.shared().memberData["service_charge_PGB"]!)!
        } else if AppDelegate.shared().tansferMethod == .Health {
            serviceCharge = Int(AppDelegate.shared().memberData["service_charge_PHN"]!)!
        }
        
        //downTextField.text = "\(kursValue ?? 1)"
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
        let totalDiscount:Int = decresedCharge + discountCodeValue
        
        if totalDiscount == 0 {
            pointLeftL.text = "\(totalDiscount)"
        } else {
            pointLeftL.text = "-\(totalDiscount)"
        }
        /*
        if decresedCharge == 0 {
            pointLeftL.text = "\(decresedCharge)"
        } else {
            pointLeftL.text = "-\(decresedCharge)"
        }*/
        
        totalChage = upValue! + serviceCharge - decresedCharge - discountCodeValue
        totalNTDL.text = "\(totalChage)".stringToIntDecimalString()
        
        Dlog("totalChage = \(totalChage)")
    }
    
    //MARK: - Button Action
    private func updateUsePointButtonAppearance() {
        let isUsingPoints = decresedCharge > 0
        let availablePoints = Int(AppDelegate.shared().memberData["remit_point"]!) ?? 0
        leftTotalPL.text = "\(availablePoints - decresedCharge)"
        leftBgV.backgroundColor = isUsingPoints ? Color_Main_Red : .clear
        leftTotalPL.textColor = isUsingPoints ? .white : Color_Main_Red
        leftDownL.textColor = isUsingPoints ? .white : Color_Main_Red
    }

    @IBAction func leftBtnDownAction(_ sender: Any) {
        updateUsePointButtonAppearance()
    }
    
    @IBAction func leftBtnOutsideAction(_ sender: Any) {
        updateUsePointButtonAppearance()
    }
    
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
        checkAndCalculateValue(UseStyle: 4, NweString: "")
        updateUsePointButtonAppearance()
    }

    @IBAction func rightBtnAction(_ sender: Any) {
        
        if upTextField.text == "1" {
            return
        }
        
        //不強制解包，避免欄位含小數(匯率)或非數字時 crash
        let upText = upTextField.text!.replacingOccurrences(of: ",", with: "")
        let downText = downTextField.text!.replacingOccurrences(of: ",", with: "")
        guard let upValue = Int(upText), upValue > 0, (Double(downText) ?? 0) > 0 else {
            return
        }

        AppDelegate.shared().transactionObj = TransactionObj()
        AppDelegate.shared().transactionObj.ntdValue = upValue
        //印尼盾必須再用台幣換算印尼盾(要對齊)
        let downValue = Int(ceil(Double(AppDelegate.shared().transactionObj.ntdValue) * kursValue))
        AppDelegate.shared().transactionObj.targetValue = downValue
        AppDelegate.shared().transactionObj.feeValue = serviceCharge
        AppDelegate.shared().transactionObj.usePoint = decresedCharge + discountCodeValue
        AppDelegate.shared().transactionObj.totalNtdValue = totalChage
        
        //送出前要查詢是否超過金額
        //202304 改成先檢查會員資料
        //checkMemberData()
        //202306 改成先MR
        if AppDelegate.shared().tansferMethod == .Bank {
            checkAmount()
        } else {
            checkAmountOther()
        }
    }
    
    @IBAction func midLeftAction(_ sender: Any) {
        if AppDelegate.shared().discountForTransfer == "" {
            promteShowL.isHidden = true
        } else {
            promteShowL.isHidden = false
        }
        
        if AppDelegate.shared().discountForTransfer != "" {
            discountCodeValue = Int(AppDelegate.shared().discountForTransfer) ?? 0
            leftBgV.isUserInteractionEnabled = false
            leftBtn.isUserInteractionEnabled = false
        } else {
            discountCodeValue = 0
            leftBgV.isUserInteractionEnabled = true
            leftBtn.isUserInteractionEnabled = true
        }
        
        AppDelegate.shared().transferChoseLeft = true
        AppDelegate.shared().tansferMethod = .Bank
        otherTransferV.isHidden = true
        setMethodUI()
        decresedCharge = 0
        updateUsePointButtonAppearance()
        setUpKursValue()
        upTextField.text = "1"
        checkAndCalculateValue(UseStyle: 0, NweString: "")
        downTextField.text = String.init(format: "%.3f", kursValue)
    }
    
    @IBAction func midRightAction(_ sender: Any) {
        promteShowL.isHidden = true
        discountCodeValue = 0
        leftBgV.isUserInteractionEnabled = true
        leftBtn.isUserInteractionEnabled = true
        
        AppDelegate.shared().transferChoseLeft = false
        otherTransferV.isHidden = true
        setMethodUI()
        otherChoseBox.isHidden = false
        decresedCharge = 0
        updateUsePointButtonAppearance()
        setUpKursValue()
        checkAndCalculateValue(UseStyle: 0, NweString: "")
    }
    
    @objc func methodGesture(_ sender: UITapGestureRecognizer) {
        guard let subV = sender.view else { return }
        let tag = subV.tag
        
        if tag == 1 {
            AppDelegate.shared().showAlertWithWindow(self, Message: "Coming soon")
            return
        }
        if tag == 0 {
            AppDelegate.shared().tansferMethod = .Cash
            otherChoseL.text = "Cash Pick-up"
        } else if tag == 1 {
            AppDelegate.shared().tansferMethod = .SSS
            otherChoseL.text = "SSS"
        } else if tag == 2 {
            AppDelegate.shared().tansferMethod = .Pag
            otherChoseL.text = "Pag-Ibig"
        } else if tag == 3 {
            AppDelegate.shared().tansferMethod = .Health
            otherChoseL.text = "PhilHealth"
        }
        
        otherChoseBox.isHidden = true
        
        if tag == 0 {
            checkAndCalculateValue(UseStyle: 0, NweString: "")
            //僅在初始狀態(金額=1)顯示匯率；已輸入金額時保留換算後的整數，
            //避免小數匯率蓋掉欄位導致後續 Int 轉換 crash
            if upTextField.text == "1" {
                downTextField.text = "\(kursValue ?? 1)"
            }
        } else {
            otherTransferV.initUI()
            otherTransferV.isHidden = false
        }
        
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
    
    public func callMemberData(completion: (() -> Void)? = nil) {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        if !isManualRefreshing {
            AppDelegate.shared().addLoadingView()
        }
        
        let todoEndpoint: String = API_CheckLogin;
        
        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        
        AppDelegate.shared().alamofireManagerWithTimeout.requestWithoutCache(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { [weak self] response in
                defer {
                    completion?()
                }
                
                let shouldHideLoading = !(self?.isManualRefreshing ?? false)
                if shouldHideLoading {
                    AppDelegate.shared().removeLoadingView()
                }
                
                guard let self = self else { return }
                
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
                    customAlert.initDataCheckAlert(Title: "NOTICE", Content: AppDelegate.shared().apiBackContentStr, NextBtn1Str: "ok")
                    self.view.addSubview(customAlert)
                    customAlert.customDelegate = self
                } else if result == ResponseState.dataCheckStatus3 {
                    self.statusNow = 3
                    let customAlert = CustomAlertView.init(frame: self.view.bounds)
                    //customAlert.initDataCheckAlert(Title: "Pemberitahuan", Content: "Masa berlaku ARC Anda sudah berakhir", NextBtn1Str: "perbaharui arc")
                    customAlert.initDataCheckAlert(Title: "NOTICE", Content: AppDelegate.shared().apiBackContentStr, NextBtn1Str: "ok")
                    customAlert.customDelegate = self
                    self.view.addSubview(customAlert)
                } else if result == ResponseState.dataCheckStatus2 {
                    self.statusNow = 2
                    let customAlert = CustomAlertView.init(frame: self.view.bounds)
                    //customAlert.initDataCheckAlert(Title: "Pemberitahuan", Content: "Silakan unggah kembali foto ARC Belakang, ARC Depan, Foto Selfie", NextBtn1Str: "perbaharui arc")
                    customAlert.initDataCheckAlert(Title: "NOTICE", Content: AppDelegate.shared().apiBackContentStr, NextBtn1Str: "ok")
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
        
        var parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "amount_ntd":charge, "use_remit_point":use_remit_point, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        
        var todoEndpoint: String = API_MemberRecipents;
        if AppDelegate.shared().discountForTransfer != "" {
            todoEndpoint = API_MemberRecipentsV2
            parameters["discount_code"] = AppDelegate.shared().discountCode
            parameters["discount_amt"] = AppDelegate.shared().discountForTransfer
        }
        
        if !AppDelegate.shared().transferChoseLeft {
            todoEndpoint = API_MemberRecipentsOther_Transfer
            /*
            if AppDelegate.shared().discountForTransfer != "" {
                todoEndpoint = API_MemberRecipentsOther_TransferV2
                parameters["discount_code"] = AppDelegate.shared().discountCode
                parameters["discount_amt"] = AppDelegate.shared().discountForTransfer
            }*/
            
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
        closeAll()
        AppDelegate.shared().addLoadingView()
        
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
                    customAlert.initAmountAlert(Title: "NOTICE")
                    self.view.addSubview(customAlert)
                    self.checkAndCalculateValue(UseStyle: 0, NweString: "")
                }
        }
    }
    
    public func checkAmountOther() {
        
        var use_remit_point = 0
        if decresedCharge > 0 {
            use_remit_point = 1
        }
        
        //檢查金額要扣掉手續費
        let charge = Int(upTextField.text!.replacingOccurrences(of: ",", with: ""))!
        //AppDelegate.shared().transactionObj.totalNtdValue
        
        var parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "amount_ntd":charge, "use_remit_point":use_remit_point, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        
        var todoEndpoint: String = API_MemberCheckAmountOther
        if AppDelegate.shared().discountForTransfer != "" {
            todoEndpoint = API_MemberRecipentsOther_TransferV2
            parameters["discount_code"] = AppDelegate.shared().discountCode
            parameters["discount_amt"] = AppDelegate.shared().discountForTransfer
        }
        
        if !AppDelegate.shared().transferChoseLeft {
            todoEndpoint = API_MemberRecipentsOther_Transfer
            /*
            if AppDelegate.shared().discountForTransfer != "" {
                todoEndpoint = API_MemberRecipentsOther_TransferV2
                parameters["discount_code"] = AppDelegate.shared().discountCode
                parameters["discount_amt"] = AppDelegate.shared().discountForTransfer
            }*/
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
        closeAll()
        AppDelegate.shared().addLoadingView()
        
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
                    customAlert.initAmountAlert(Title: "NOTICE")
                    self.view.addSubview(customAlert)
                    self.checkAndCalculateValue(UseStyle: 0, NweString: "")
                }
        }
    }
    
    func plotQuotaState() {
        //topbox_titleL.text = AppDelegate.shared().memberData["member_name"] ?? ""
        topbox_MoneyL.text = String.stringToOnlyIntString(Number: AppDelegate.shared().transferQuotaLeft) + " NTD"
        
        if AppDelegate.shared().transferQuotaLeft == 0 || AppDelegate.shared().transferQuotaTotal == 0 {
            topbox_barLength.constant = 1
        } else {
            topbox_barLength.constant = topbox_barbackV.frame.width * (Double(AppDelegate.shared().transferQuotaLeft)/Double(AppDelegate.shared().transferQuotaTotal))
        }
    }
    
    public func getQuota(completion: (() -> Void)? = nil) {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken]
        let headers: HTTPHeaders = [:]
        if !isManualRefreshing {
            AppDelegate.shared().addLoadingView()
        }
        
        let todoEndpoint: String = API_GetQuota;
        
        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        
        AppDelegate.shared().alamofireManagerWithTimeout.requestWithoutCache(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { [weak self] response in
                guard let self = self else {
                    completion?()
                    return
                }
                
                defer {
                    completion?()
                }
                
                let shouldHideLoading = !self.isManualRefreshing
                if shouldHideLoading {
                    AppDelegate.shared().removeLoadingView()
                }
                
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
                    self.plotQuotaState()
                    //self.getRecipents()
                } else if result == ResponseState.failed {
                    //AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
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
        
        AppDelegate.shared().setTransferDefault()
        otherTransferV.isHidden = true
        otherTransferV.parentVC = self
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
        
        topbox_barbackV.layer.cornerRadius = topbox_barbackV.frame.size.height/2
        topbox_barbackV.layer.borderWidth = 1
        topbox_barbackV.layer.borderColor = Color_Main_LightGray.cgColor
        topbox_barV.layer.cornerRadius = topbox_barV.frame.size.height/2
        topbox_barV.layer.backgroundColor = Color_Main_Red.cgColor
        
        topbox_titleL.text = NSLocalizedString("Transfer Main Top Box Title", comment: "")
        upNameL.text = NSLocalizedString("Transfer Main Box Up Title", comment: "")
        downNameL.text = NSLocalizedString("Transfer Main Box Down Title", comment: "")
        kirimL.text = NSLocalizedString("Transfer Main Charge Title", comment: "")
        pointL.text = NSLocalizedString("Transfer Main Use Point Title", comment: "")
        totalNTDTitleL.text = NSLocalizedString("Transfer Main Total Money", comment: "")
        leftDownL.text = NSLocalizedString("Transfer Main Total Point Title", comment: "")
        rightTitleL.text = NSLocalizedString("send", comment: "")
        leftDownL.adjustsFontSizeToFitWidth = true
        
        if AppDelegate.shared().discountForTransfer != "" {
            discountCodeValue = Int(AppDelegate.shared().discountForTransfer) ?? 0
            leftBgV.isUserInteractionEnabled = false
            leftBtn.isUserInteractionEnabled = false
        } else {
            discountCodeValue = 0
            leftBgV.isUserInteractionEnabled = true
            leftBtn.isUserInteractionEnabled = true
        }
        
        updateUsePointButtonAppearance()
        checkAndCalculateValue(UseStyle:0, NweString: "")
        downTextField.text = String.init(format: "%.3f", kursValue)
        
        AppDelegate.shared().getPurposeList()
        AppDelegate.shared().getRelationList()
        
        otherBoxV1.layer.cornerRadius = 5
        otherBoxV1.layer.borderWidth = 0.5
        otherBoxV1.layer.borderColor = Color_Main_LightGray.cgColor
        
        otherBoxV2.layer.cornerRadius = 5
        otherBoxV2.layer.borderWidth = 0.5
        otherBoxV2.layer.borderColor = Color_Main_LightGray.cgColor
        
        otherBoxV3.layer.cornerRadius = 5
        otherBoxV3.layer.borderWidth = 0.5
        otherBoxV3.layer.borderColor = Color_Main_LightGray.cgColor
        
        otherBoxV4.layer.cornerRadius = 5
        otherBoxV4.layer.borderWidth = 0.5
        otherBoxV4.layer.borderColor = Color_Main_LightGray.cgColor
        
        promteShowL.textAlignment = .center
        promteShowL.text = "PROMO"
        promteShowL.backgroundColor = .clear
        promteShowL.layer.backgroundColor = Color_Main_Red.cgColor
        promteShowL.layer.cornerRadius = promteShowL.frame.size.height/2
        
        otherBoxV1.tag = 0
        otherBoxV2.tag = 1
        otherBoxV3.tag = 2
        otherBoxV4.tag = 3
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(methodGesture))
        otherBoxV1.addGestureRecognizer(tapGesture)
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(methodGesture))
        otherBoxV2.addGestureRecognizer(tapGesture2)
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(methodGesture))
        otherBoxV3.addGestureRecognizer(tapGesture3)
        let tapGesture4 = UITapGestureRecognizer(target: self, action: #selector(methodGesture))
        otherBoxV4.addGestureRecognizer(tapGesture4)
        
        setupManualRefreshGesture()
        
        if AppDelegate.shared().discountForTransfer == "" {
            promteShowL.isHidden = true
        } else {
            promteShowL.isHidden = false
        }
    }
    
    private func setupManualRefreshGesture() {
        manualRefreshIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(manualRefreshIndicator)
        if #available(iOS 11.0, *) {
            manualRefreshIndicatorBaseOffset = 8
            manualRefreshIndicatorTopConstraint = manualRefreshIndicator.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: manualRefreshIndicatorBaseOffset)
        } else {
            manualRefreshIndicatorBaseOffset = 28
            manualRefreshIndicatorTopConstraint = manualRefreshIndicator.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor, constant: manualRefreshIndicatorBaseOffset)
        }
        NSLayoutConstraint.activate([
            manualRefreshIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            manualRefreshIndicatorTopConstraint!
        ])
        view.bringSubviewToFront(manualRefreshIndicator)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleFullScreenPan(_:)))
        panGesture.delegate = self
        panGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(panGesture)
    }
    
    private func showIndicatorIfNeeded() {
        if manualRefreshIndicator.isHidden {
            manualRefreshIndicator.isHidden = false
        }
        if !manualRefreshIndicator.isAnimating {
            manualRefreshIndicator.startAnimating()
        }
    }
    
    private func updateIndicatorPosition(for pullDistance: CGFloat) {
        guard let topConstraint = manualRefreshIndicatorTopConstraint else { return }
        let effectiveDistance = min(pullDistance, manualRefreshTriggerDistance * 1.3)
        topConstraint.constant = manualRefreshIndicatorBaseOffset + effectiveDistance * 0.5
        UIView.performWithoutAnimation {
            self.view.layoutIfNeeded()
        }
    }
    
    private func resetIndicator(animated: Bool) {
        guard let topConstraint = manualRefreshIndicatorTopConstraint else { return }
        let animations = {
            topConstraint.constant = self.manualRefreshIndicatorBaseOffset
            self.view.layoutIfNeeded()
        }
        let completion = {
            self.manualRefreshIndicator.stopAnimating()
            self.manualRefreshIndicator.isHidden = true
        }
        
        if animated {
            UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .curveEaseOut], animations: animations) { _ in
                completion()
            }
        } else {
            animations()
            completion()
        }
    }
    
    private func snapIndicatorToBase() {
        guard let topConstraint = manualRefreshIndicatorTopConstraint else { return }
        topConstraint.constant = manualRefreshIndicatorBaseOffset
        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState, .curveEaseOut], animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    @objc private func handleFullScreenPan(_ gesture: UIPanGestureRecognizer) {
        if isManualRefreshing {
            return
        }
        
        let translation = gesture.translation(in: view)
        let pullDistance = max(0, translation.y)
        
        switch gesture.state {
        case .began:
            currentPullDistance = 0
            if pullDistance == 0 {
                resetIndicator(animated: false)
            }
        case .changed:
            currentPullDistance = pullDistance
            if pullDistance > 0 {
                showIndicatorIfNeeded()
                updateIndicatorPosition(for: pullDistance)
            } else {
                resetIndicator(animated: false)
            }
        case .ended, .cancelled, .failed:
            gesture.setTranslation(.zero, in: view)
            if currentPullDistance >= manualRefreshTriggerDistance {
                beginManualRefresh()
            } else {
                resetIndicator(animated: true)
            }
            currentPullDistance = 0
        default:
            break
        }
    }
    
    private func beginManualRefresh() {
        guard !isManualRefreshing else { return }
        isManualRefreshing = true
        manualRefreshIndicator.isHidden = false
        manualRefreshIndicator.startAnimating()
        snapIndicatorToBase()
        refreshTransferData { [weak self] in
            guard let self = self else { return }
            self.isManualRefreshing = false
            self.resetIndicator(animated: true)
            let newValue = (Int(AppDelegate.shared().memberData["remit_point"]!) ?? 0) - decresedCharge
            leftTotalPL.text = "\(newValue)"
            checkAndCalculateValue(UseStyle: 0, NweString: "")
            // Reset to initial look after refresh, but never overwrite user typing.
            if !downTextField.isFirstResponder {
                downTextField.text = String(format: "%.3f", self.kursValue)
            }
        }
    }
    
    private func refreshTransferData(completion: (() -> Void)? = nil) {
        setUpKursValue()
        let group = DispatchGroup()
        self.upTextField.text = "1"
        decresedCharge = 0
        updateUsePointButtonAppearance()
        group.enter()
        callMemberData {
            group.leave()
        }
        
        group.enter()
        getQuota {
            group.leave()
        }
        
        AppDelegate.shared().showTopButton()
        
        group.notify(queue: .main) {
            completion?()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        plotQuotaState()
        
        if loadOnce {
            //這邊每次都要重新設定
            setUpKursValue()
            callMemberData()
            getQuota()
            AppDelegate.shared().showTopButton()
            return
        }
        
        loadOnce = true
        rightBgV.addGradienOfIndoGo()
        callMemberData()
        getQuota()
        //頂部兩個按鈕
        AppDelegate.shared().topMargin = self.view.safeAreaInsets.top
        AppDelegate.shared().addTopButton()
        
        AppDelegate.shared().nowBottomMenuType = .transaction
        AppDelegate.shared().bottomMenu.paintMenu()
        
        setMethodUI()
    }
    
    func setMethodUI() {
        if AppDelegate.shared().transferChoseLeft {
            midVL.backgroundColor = .white
            midVR.backgroundColor = .clear
            midLL.textColor = Color_Purple
            midRL.textColor = Color_Main_DarkGray
            midLImg.image = UIImage.init(named: "Bank_E-Wallet_ON")
            midRImg.image = UIImage.init(named: "Other Methods_OFF")
            
            otherMethodV.isHidden = true
            //boxHeight.constant = 15
            topboxHeight.constant = 5
            otherChoseBox.isHidden = true
        } else {
            midVL.backgroundColor = .clear
            midVR.backgroundColor = .white
            midLL.textColor = Color_Main_DarkGray
            midRL.textColor = Color_Purple
            midLImg.image = UIImage.init(named: "Bank_E-Wallet_OFF")
            midRImg.image = UIImage.init(named: "Other Methods_ON")
            
            otherMethodV.isHidden = false
            //boxHeight.constant = 60
            topboxHeight.constant = 50
        }
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
