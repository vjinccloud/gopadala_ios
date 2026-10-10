//
//  ForgotPassEnterCodeVC.swift
//  indogo
//
//  Created by mac on 2020/7/17.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import SwiftyJSON
import AVFoundation
import Alamofire

class ForgotPassEnterCodeVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var topL: UILabel!
    @IBOutlet weak var sendAgainBtn: UIButton!
    @IBOutlet weak var allCodeTextField: UITextField!
    @IBOutlet weak var codeT1: UITextField!
    @IBOutlet weak var codeT2: UITextField!
    @IBOutlet weak var codeT3: UITextField!
    @IBOutlet weak var codeT4: UITextField!
    @IBOutlet weak var barV: UIView!
    var timer:Timer!
    private var buttonEnabledDate: Date?
    var nextIndex = 0
    var loadOnce = false
    
    //MARK: - Timer
    @objc func timeToReSend() {
        let currentDate = Date()
        if currentDate >= self.buttonEnabledDate! {
            timer.invalidate()
            self.sendAgainBtn.isEnabled = true
            self.sendAgainBtn.setTitle("Resend SMS Code", for: .normal)
        } else {
            let remainingSeconds = Int(self.buttonEnabledDate!.timeIntervalSince(currentDate))
            self.sendAgainBtn.setTitle("Remaining time \(remainingSeconds) second", for: .normal)
        }
    }
    
    //MARK: - API
    func sendSMS() {
        let parameters:Parameters = ["arc_no":AppDelegate.shared().forgotPassTempMemID, "phone_no":AppDelegate.shared().forgotPassTempPhone, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        Dlog("parameters=\(parameters)")
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_SendSMS;
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
                    self.sendAgainBtn.isEnabled = false
                    self.buttonEnabledDate = Date().addingTimeInterval(30)
                    self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.timeToReSend), userInfo: nil, repeats: true)
                    
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func sendUpdatePhoneSMS() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "phone_no":AppDelegate.shared().forgotPassTempPhone, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        Dlog("parameters=\(parameters)")
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_SendUpdatePhoneSMS;
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
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func verifyPoint() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "verify_code":allCodeTextField.text!, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        Dlog("parameters=\(parameters)")
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_VerifyPoint
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
                    guard let viewControllers = self.navigationController?.viewControllers else {
                        return
                    }
                    
                    for firstViewController in viewControllers {
                        if firstViewController is ShareMainVC {
                            self.navigationController?.popToViewController(firstViewController, animated: true)
                            break
                        }
                    }
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func checkUpdatePhoneSMS() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "sms_code":allCodeTextField.text!, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        Dlog("parameters=\(parameters)")
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_VerifyUpdatePhoneSMS;
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
                    self.navigationController?.popToRootViewController(animated: true)
                    /*
                    guard let viewControllers = self.navigationController?.viewControllers else {
                        return
                    }
                    
                    for firstViewController in viewControllers {
                        if firstViewController is MemberMainVC {
                            self.navigationController?.popToViewController(firstViewController, animated: true)
                            break
                        }
                    }*/
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //MARK: - Button-Action
    @IBAction func sendAgain(_ sender: Any) {
        if nextIndex == 2 {
            sendUpdatePhoneSMS()
        } else {
            sendSMS()
        }
    }
    
    @IBAction func nextAction(_ sender: Any) {
        if allCodeTextField.text == "" || allCodeTextField.text?.count != 4 {
            AppDelegate.shared().showAlertWithWindow(self, Message: "Please Enter Number")
            return
        }
        
        if nextIndex == 2 {
            checkUpdatePhoneSMS()
            return
        }
        Dlog("AppDelegate.shared().forgotPassTempSMS = \(AppDelegate.shared().forgotPassTempSMS)")
        AppDelegate.shared().forgotPassTempEnterCode = allCodeTextField.text!
        
        /*
        if AppDelegate.shared().forgotPassTempSMS != allCodeTextField.text! {
            AppDelegate.shared().showAlertWithWindow(self, Message: "SMS Code Wrong")
            return
        }*/
        
        /*
        if codeT1.text == "" || codeT2.text == "" || codeT3.text == "" || codeT4.text == "" {
            AppDelegate.shared().showAlertWithWindow(self, Message: "Please Enter Number")
            return
        }
        
        //組合
        AppDelegate.shared().forgotPassTempEnterCode = codeT1.text! + codeT2.text! + codeT3.text! + codeT4.text!
        */
        
        if nextIndex == 0 {
            let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPassChangeVC") as? ForgotPassChangeVC
            self.navigationController?.pushViewController(nextVC!, animated: true)
        } else if nextIndex == 1 {
            //202304 改成直接回首頁(MemberMain)
            self.navigationController?.popToRootViewController(animated: true)
            /*
            let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "MemberEditVC") as? MemberEditVC
            self.navigationController?.pushViewController(nextVC!, animated: true)
             */
        } else if nextIndex == 2 {
            self.navigationController?.popToRootViewController(animated: true)
        } else if nextIndex == 3 {
            verifyPoint()
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Text Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = Color_Main_Red
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = Color_Main_DarkGray
    }
    
    /*
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else{
            return true
        }
        let textLength = text.count + string.count - range.length
        if string.count == 1 {
            if textField == codeT1 {
                codeT1.text = string
                codeT1.resignFirstResponder()
                codeT2.becomeFirstResponder()
            } else if textField == codeT2 {
                codeT2.text = string
                codeT2.resignFirstResponder()
                codeT3.becomeFirstResponder()
            } else if textField == codeT3 {
                codeT3.text = string
                codeT3.resignFirstResponder()
                codeT4.becomeFirstResponder()
            } else if textField == codeT4 {
                codeT4.text = string
                codeT4.resignFirstResponder()
            }
            return false
        } else {
        }
    
        return textLength <= 1
    }
    */
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        
        backL.text = NSLocalizedString("back", comment: "")
        nextBtn.setTitle(NSLocalizedString("ok", comment: ""), for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.height/2
        sendAgainBtn.setTitle(NSLocalizedString("TFFRHP Enter Send Again", comment: ""), for: .normal)
        sendAgainBtn.layer.cornerRadius = sendAgainBtn.frame.height/2
        sendAgainBtn.layer.borderWidth = 0.5
        sendAgainBtn.layer.borderColor = UIColor.darkGray.cgColor
        titleL.text = NSLocalizedString("TFFRHP Enter Title", comment: "")
        topL.text = NSLocalizedString("TFFRHP Enter Top", comment: "") + AppDelegate.shared().forgotPassTempPhone
        
        allCodeTextField.backgroundColor = .white
        allCodeTextField.keyboardType = .numberPad
        
        barV.backgroundColor = Color_Main_Red
        
        self.sendAgainBtn.isEnabled = false
        self.buttonEnabledDate = Date().addingTimeInterval(30)
        self.timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.timeToReSend), userInfo: nil, repeats: true)
        
        barV.installLayoutAwareIndoGoGradient()
        nextBtn.installLayoutAwareIndoGoGradient()
    
        /*
        codeT1.backgroundColor = Color_Main_DarkGray
        codeT1.keyboardType = .numberPad
        codeT1.textColor = .white
        codeT1.delegate = self
        codeT2.backgroundColor = Color_Main_DarkGray
        codeT2.keyboardType = .numberPad
        codeT2.delegate = self
        codeT3.backgroundColor = Color_Main_DarkGray
        codeT3.keyboardType = .numberPad
        codeT3.delegate = self
        codeT4.backgroundColor = Color_Main_DarkGray
        codeT4.keyboardType = .numberPad
        codeT4.delegate = self
        */
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        barV.updateLayoutAwareIndoGoGradientFrame()
        nextBtn.updateLayoutAwareIndoGoGradientFrame()
        nextBtn.layer.cornerRadius = nextBtn.bounds.height / 2
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
