//
//  LoginStep2VC.swift
//  indogo
//
//  Created by Wang Jen Chung on 2022/10/31.
//  Copyright © 2022 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import FirebaseMessaging
import FirebaseCore
import FirebaseAnalytics

class LoginStep2VC: UIViewController, UITextFieldDelegate, CustomAlertDelegate {
    
    @IBOutlet weak var barV: GradianBarView!
    @IBOutlet weak var newLoginhintL: UILabel!
    
    @IBOutlet weak var passBtn: UIButton!
    @IBOutlet weak var passTextField: UITextField!
    
    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var lupaBtn: UIButton!
    
    @IBOutlet weak var showPassBtn: UIButton!
    @IBOutlet weak var topScrollView: UIScrollView!
    
    var loadOnce:Bool = false
    var rememberMeState = true
    var nextAction:EnterPassNextAction = .Login
    
    //MARK: - Button-Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func showPassAction(_ sender: Any) {
        passTextField.isSecureTextEntry.toggle()
        
        if passTextField.isSecureTextEntry {
            showPassBtn.setBackgroundImage(UIImage.init(named: "noview_b"), for: .normal)
        } else {
            showPassBtn.setBackgroundImage(UIImage.init(named: "view_w"), for: .normal)
        }
    }
    
    @IBAction func loginAction(_ sender: Any) {
        
        if passTextField.text?.count == 0 {
            //AppDelegate.shared().showAlertWithWindow(self, Message: "請輸入密碼")
            return
        }
        
        if nextAction == .Login {
            loginNext()
        } else if nextAction == .Transfer {
            //要照 TransactionInfoConfirmVC 的下一步 callMemberData() 開始
            callMemberData()
        }
    }
    
    @IBAction func forgotPassAction(_ sender: Any) {
        Analytics.logEvent("iOS_ForgotPass", parameters: nil)
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPassMainVC") as? ForgotPassMainVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    func customAlertnextAction(Ref obj: CustomAlertView) {
        obj.removeFromSuperview()
        
        //進入註冊
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterAgreementVC") as? RegisterAgreementVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    func customAlertnextActionSecond(Ref obj: CustomAlertView) {
        
    }
    
    //MARK: - API
    func checkTokenLogin() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_CheckLogin;
        
        Dlog("checkTokenLogin todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        
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
                Dlog("checkTokenLogin responseStr = \(responseStr ?? "")")
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    AppDelegate.shared().nowBottomMenuType = AppDelegate.shared().defautBottomMenuType
                    AppDelegate.shared().changeRootOfFunc(Type: .transaction)
                    /*
                    //檢查版本
                    let appVersionFromBackend = Float(AppDelegate.shared().memberData["app_version"]!)
                    let appVersionInApp = Float((Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)!)
                    Dlog("appVersionFromBackend = \(appVersionFromBackend ?? 0), appVersionInApp = \(appVersionInApp ?? 0)")
                    if appVersionFromBackend! > appVersionInApp! {
                        DispatchQueue.main.async{
                            let alert = UIAlertController(title: "", message: NSLocalizedString("Please Update App", comment: ""), preferredStyle: .alert)
                            let action1 = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler:{(_)-> Void in
                                let urlString:String = AppDelegate.shared().memberData["app_market"]!
                                
                                if let phoneCallURL = URL(string: urlString) {
                                    if (UIApplication.shared.canOpenURL(phoneCallURL)) {
                                        UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
                                    }
                                    exit(0)
                                }
                            })
                            alert.addAction(action1)
                            let window = UIApplication.shared.keyWindow
                            window?.rootViewController!.present(alert ,animated: true,completion: nil)
                        }
                        return
                    }
                    */
                    //傳輸token
                    self.sendToken()
                    //讀取未讀通知數量
                    AppDelegate.shared().getNotice()
                    
                } else if result == ResponseState.failed {
                    AppDelegate.shared().userLogout()
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func loginNext() {
        let accountStr = AppDelegate.shared().tempArcForLogin
        let parameters:Parameters = ["login_id":accountStr, "login_password": UtilityTool().sha256(Code: passTextField.text!), "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        //let parameters:Parameters = ["login_id":accountTextfield.text!, "login_password": UtilityTool().sha256(Code: passTextField.text!)]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_Login;
        
        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        URLCache.shared.removeAllCachedResponses()
        
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
                Dlog("login responseStr = \(responseStr ?? "")")
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    /*
                    //檢查版本(之後要改成新欄位)
                    let appVersionFromBackend = Float(AppDelegate.shared().memberData["app_version"]!)
                    let appVersionInApp = Float((Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)!)
                    Dlog("appVersionFromBackend = \(appVersionFromBackend ?? 0), appVersionInApp = \(appVersionInApp ?? 0)")
                    if appVersionFromBackend! > appVersionInApp! {
                        DispatchQueue.main.async{
                            let alert = UIAlertController(title: "", message: NSLocalizedString("Please Update App", comment: ""), preferredStyle: .alert)
                            let action1 = UIAlertAction(title: NSLocalizedString("ok", comment: ""), style: .default, handler:{(_)-> Void in
                                let urlString:String = AppDelegate.shared().memberData["app_market"]!
                                
                                if let phoneCallURL = URL(string: urlString) {
                                    if (UIApplication.shared.canOpenURL(phoneCallURL)) {
                                        UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
                                    }
                                    exit(0)
                                }
                            })
                            alert.addAction(action1)
                            let window = UIApplication.shared.keyWindow
                            window?.rootViewController!.present(alert ,animated: true,completion: nil)
                        }
                        return
                    }*/
                    
                    //傳輸token
                    self.sendToken()
                    //會員資料編輯要顯示的
                    AppDelegate.shared().rememberAarcNo(Account: accountStr)
                    //讀取未讀通知數量
                    AppDelegate.shared().getNotice()
                    if self.rememberMeState {
                        AppDelegate.shared().rememberAccount(Account: accountStr, Pass: self.passTextField.text!)
                    } else {
                        AppDelegate.shared().removeSavedAccount()
                    }
                    
                    AppDelegate.shared().nowBottomMenuType = AppDelegate.shared().defautBottomMenuType
                    AppDelegate.shared().changeRootOfFunc(Type: .transaction)
                    //AppDelegate.shared().showAlertWithWindow(self, Message: "Hi, \(AppDelegate.shared().memberData["member_name"] ?? "") 登入成功")
                    URLCache.shared.removeAllCachedResponses()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func sendToken() {
        if FirebaseToken == "" {
            return
        }
        
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken,"device_token":FirebaseToken, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        let todoEndpoint: String = API_PhoneTokenSet;
        
        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        
        AppDelegate.shared().alamofireManagerWithTimeout.requestWithoutCache(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling on \(todoEndpoint)")
                    print(response.result.error!)
                    AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("API Timeout", comment: ""))
                    return
                }
                let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                Dlog("responseStr = \(responseStr ?? "")")
        }
    }
    
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
                    self.recalculateTargetMoneyAndGoNext()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func recalculateTargetMoneyAndGoNext() {
        let obj = AppDelegate.shared().transactionObj
        let kursValue = Double(AppDelegate.shared().memberData["kurs_value"]!)!
        AppDelegate.shared().transactionObj.targetValue = Int(ceil(Double(obj.ntdValue) * kursValue))
        
        //改成直接到結果頁
        createTransaction()
    }
    
    public func createTransaction() {
        let obj = AppDelegate.shared().transactionObj
        let recipient_id = AppDelegate.shared().transactionObj.recipientObj.recipient_id!
        
        var parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "amount_ntd":obj.ntdValue,"kurs_lm_time":AppDelegate.shared().memberData["kurs_lm_time"]!, "service_charge":obj.feeValue, "total_payment":obj.totalNtdValue, "transfer_idr":
            obj.targetValue, "recipient_id":recipient_id, "pin_code_mode":PinCodeMode, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString(), "login_password": UtilityTool().sha256(Code: passTextField.text!)]
        
        if obj.usePoint == 0 {
            parameters["use_remit_point"] = 0
        } else {
            parameters["use_remit_point"] = 1
            parameters["use_points"] = obj.usePoint
        }
        
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_TransactionCreate;
        
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
                    self.getNextStep()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func getNextStep() {
        let transferStateObj = TransferStateObj()
        let serchBankobj = UtilityTool().searchBankObj(BankName: AppDelegate.shared().transactionObj.recipientObj.bank_name!)
        
        transferStateObj.bank_code = serchBankobj.bank_code
        transferStateObj.to_acc = AppDelegate.shared().transactionObj.recipientObj.bank_acc
        transferStateObj.total = "\(AppDelegate.shared().transactionObj.totalNtdValue)"
        transferStateObj.transfer_amount_idr = "\(AppDelegate.shared().transactionObj.targetValue)"
            transferStateObj.recipient_name =  AppDelegate.shared().transactionObj.recipientObj.recipient_name
        
        //新的首頁
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "TransactionNewMainVC") as? TransactionNewMainVC
        //let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "TransactionResultVC") as? TransactionResultVC
        nextVC?.payment_info = AppDelegate.shared().tempTransactionResultObj.payment_info
        nextVC?.transferStateObj = transferStateObj
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        barV.addGradienOfIndoGo()
        newLoginhintL.text = NSLocalizedString("New Login Hint", comment: "")
        
        passBtn.layer.cornerRadius = passBtn.frame.height/2
        loginBtn.layer.cornerRadius = loginBtn.frame.height/2
        loginBtn.addGradienOfIndoGo()
        
        lupaBtn.layer.cornerRadius = lupaBtn.frame.height/2
        lupaBtn.layer.borderColor = UIColor.white.cgColor
        lupaBtn.layer.borderWidth = 0.5
        
        passTextField.keyboardType = .asciiCapable
        passTextField.delegate = self
        passTextField.placeholder = NSLocalizedString("New Login Pass PlaceHolder" , comment: "")
        
        loginBtn.setTitle(NSLocalizedString("login", comment: ""), for: .normal)
        lupaBtn.setTitle(NSLocalizedString("", comment: ""), for: .normal)
        
        let attributes = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let underlineAttributedString = NSAttributedString(string: NSLocalizedString("recover passcode", comment: ""), attributes: attributes)
        lupaBtn.setAttributedTitle(underlineAttributedString, for: .normal)
        //let bnumber = Bundle.main.buildNumber
        
        passTextField.isSecureTextEntry = true
        passTextField.text = AppDelegate.shared().getRemeberedPassword()
        
        if passTextField.text!.count > 0 {
            passBtn.backgroundColor = Color_Main_LightGray
        }
        loginBtn.addGradienOfIndoGo()
        rememberMeState = AppDelegate.shared().tempRemeberState
        
        if DevMode {
            passTextField.text = "123456"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if loadOnce {
            return
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else{
            return true
        }
        
        if !string.checkAlphabetDigit() {
            return false
        }
        
        let textLength = text.count + string.count - range.length
        if textLength>20 {
            return false
        }
        
        return true
    }
}
