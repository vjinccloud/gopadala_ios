//
//  ForgotPassChangeVC.swift
//  indogo
//
//  Created by mac on 2020/7/18.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ForgotPassChangeVC: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var warnL: UILabel!
    @IBOutlet weak var warn2L: UILabel!
    @IBOutlet weak var passBtn: UIButton!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var showPassBtn: UIButton!
    @IBOutlet weak var repassBtn: UIButton!
    @IBOutlet weak var repassTextField: UITextField!
    @IBOutlet weak var showRePassBtn: UIButton!
    @IBOutlet weak var barV: UIView!
    
    @IBOutlet weak var nextBtn: UIButton!
    
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
    
    //MARK: - Utility
    func checkState() {
        if passTextField.text!.count>0, repassTextField.text!.count>0 {
            nextBtn.isEnabled = true
            nextBtn.backgroundColor = Color_Main_Red
        } else {
            nextBtn.isEnabled = false
            nextBtn.backgroundColor = .clear
        }
    }
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        
        if passTextField.text != repassTextField.text {
            AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("Register Error Pass Not match", comment: ""))
            return
        }
        
        if passTextField.text!.count < 4 {
            AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("Register Error Pass", comment: ""))
            return
        }
        
        let parameters:Parameters = ["arc_no":AppDelegate.shared().forgotPassTempMemID, "password":UtilityTool().sha256(Code: passTextField.text!), "sms_code":AppDelegate.shared().forgotPassTempEnterCode, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        Dlog("parameters=\(parameters)")
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_PassUpdate;
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
                    //回輸入密碼頁
                    guard let viewControllers = self.navigationController?.viewControllers else {
                        return
                    }
                    
                    var isBack = false
                    for firstViewController in viewControllers {
                        if firstViewController is LoginStep2VC {
                            isBack = true
                            self.navigationController?.popToViewController(firstViewController, animated: true)
                            return
                        }
                    }
                    
                    if !isBack {
                        self.navigationController?.popToRootViewController(animated: true)
                    }
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
    }
    
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
    
    @IBAction func showRePassAction(_ sender: Any) {
        repassTextField.isSecureTextEntry.toggle()
        
        if repassTextField.isSecureTextEntry {
            showRePassBtn.setBackgroundImage(UIImage.init(named: "noview_b"), for: .normal)
        } else {
            showRePassBtn.setBackgroundImage(UIImage.init(named: "view_w"), for: .normal)
        }
    }
    
    //MARK: - Text Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        if textField == passTextField {
            passBtn.backgroundColor = Color_Main_LightGray
            warnL.isHidden = false
        } else if textField == repassTextField {
            repassBtn.backgroundColor = Color_Main_LightGray
            warn2L.isHidden = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == passTextField {
            passBtn.backgroundColor = .white
            warnL.isHidden = true
        } else if textField == repassTextField {
            repassBtn.backgroundColor = .white
            warn2L.isHidden = true
        }
        checkState()
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        
        backL.text = NSLocalizedString("TFFRHP Change Title", comment: "")
        passBtn.layer.cornerRadius = passBtn.frame.size.height/2
        repassBtn.layer.cornerRadius = repassBtn.frame.size.height/2
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        
        passTextField.placeholder = NSLocalizedString("passcode", comment: "")
        repassTextField.placeholder = NSLocalizedString("TFFRHP Change placehold2", comment: "")
        
        nextBtn.setTitle(NSLocalizedString("send", comment: ""), for: .normal)
        nextBtn.backgroundColor = .clear
        nextBtn.layer.borderColor = Color_Main_Red.cgColor
        nextBtn.layer.borderWidth = 0.5
        
        nextBtn.isEnabled = false
        passTextField.isSecureTextEntry = true
        repassTextField.isSecureTextEntry = true
        
        passTextField.delegate = self
        repassTextField.delegate = self
        
        warnL.text = NSLocalizedString("TFFRHP Change warn", comment: "")
        warn2L.text = NSLocalizedString("TFFRHP Change warn2", comment: "")
        warnL.isHidden = true
        warn2L.isHidden = true
        barV.addGradienOfIndoGo()
        nextBtn.addGradienOfIndoGo()
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
