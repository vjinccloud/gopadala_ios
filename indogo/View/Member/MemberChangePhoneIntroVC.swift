//
//  MemberChangePhoneIntroVC.swift
//  indogo
//
//  Created by Wang Jen Chung on 2022/3/7.
//  Copyright © 2022 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MemberChangePhoneIntroVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var inputMoreSpaceView: UIView!
    @IBOutlet weak var backL: UILabel!
    
    @IBOutlet weak var topScrollView: UIScrollView!
    
    @IBOutlet weak var phoneTitle: UILabel!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var phoneTextfield: UITextField!
    
    @IBOutlet weak var phoneNewTitle: UILabel!
    @IBOutlet weak var phoneNewView: UIView!
    @IBOutlet weak var phoneNewBtn: UIButton!
    @IBOutlet weak var phoneNewTextfield: UITextField!
    
    @IBOutlet weak var phoneNewWarnL: UILabel!
    
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var arcCodeL: UILabel!
    
    @IBOutlet weak var barV: UIView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorL: UILabel!
    
    var hasSharedCode = false
    var hasMeCode = false
    var meImg:UIImage!
    
    //MARK: - API
    func sendSMS() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "phone_no":phoneNewTextfield.text!, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
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
                    AppDelegate.shared().forgotPassTempPhone = self.phoneNewTextfield.text!
                    let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPassEnterCodeVC") as? ForgotPassEnterCodeVC
                    nextVC?.nextIndex = 2
                    self.navigationController?.pushViewController(nextVC!, animated: true)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //MARK: - Text Bar
    func generateToolBar() ->UIToolbar {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextBarAction))
        
        let toolBar:UIToolbar = UIToolbar()
        toolBar.items = [flexibleSpace,done]
        toolBar.sizeToFit()
        
        return toolBar
    }
    
    @objc func nextBarAction() {
        if phoneTextfield.isFirstResponder {
            phoneNewTextfield.becomeFirstResponder()
        }
    }
    
    //MARK: - Text Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == phoneTextfield {
            phoneNewTextfield.becomeFirstResponder()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        inputMoreSpaceView.isHidden = false
        /*
        if textField == phoneTextfield {
            topScrollView.contentOffset = CGPoint.init(x: 0, y: phoneView.frame.origin.y)
            phoneBtn.backgroundColor = Color_Main_LightGray
            phoneTextfield.textColor = .black
        } else if textField == phoneNewTextfield {
            topScrollView.contentOffset = CGPoint.init(x: 0, y: phoneNewView.frame.origin.y)
            phoneNewBtn.backgroundColor = Color_Main_LightGray
            phoneNewTextfield.textColor = .black
        }*/
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        inputMoreSpaceView.isHidden = true
        
        /*
        if textField == phoneTextfield {
            if textField.text!.count == 0 {
                phoneBtn.backgroundColor = Color_Main_DarkGray
                phoneTextfield.textColor = .white
            } else {
                phoneBtn.backgroundColor = Color_Main_LightGray
                phoneTextfield.textColor = .black
            }
        } else if textField == phoneNewTextfield {
            if textField.text!.count == 0 {
                phoneNewBtn.backgroundColor = Color_Main_DarkGray
                phoneNewTextfield.textColor = .white
            } else {
                phoneNewBtn.backgroundColor = Color_Main_LightGray
                phoneNewTextfield.textColor = .black
            }
        }*/
        
        checkNextBtnState(CheckText: true)
    }
    
    func checkNextBtnState(CheckText checkNow:Bool) {
        var pass = true
        
        if phoneTextfield.text?.count != 10 || phoneNewTextfield.text?.count != 10 {
            pass = false
        } else if phoneTextfield.text != AppDelegate.shared().forgotPassTempPhone {
            pass = false
        } else if !phoneTextfield.text!.hasPrefix("09") || !phoneNewTextfield.text!.hasPrefix("09") {
            pass = false
        }
        
        if pass {
            registerBtn.setTitleColor(.white, for: .normal)
            registerBtn.addGradienOfIndoGo()
            registerBtn.isEnabled = true
            phoneNewWarnL.isHidden = true
        } else {
            registerBtn.removeGradienLayer()
            registerBtn.setTitleColor(.black, for: .normal)
            registerBtn.isEnabled = false
            phoneNewWarnL.isHidden = false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else{
            return true
        }
        
        let textLength = text.count + string.count - range.length
        if textLength>20 {
            return false
        }
        
        return true

    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        barV.addGradienOfIndoGo()
        
        backL.text = NSLocalizedString("Change Phone Bar Title", comment: "")
        phoneTitle.text = NSLocalizedString("Change Phone Title", comment: "")
        phoneNewTitle.text = NSLocalizedString("Change Phone Title2", comment: "")
        phoneNewWarnL.text = NSLocalizedString("Change Phone Warn", comment: "")
        phoneBtn.layer.cornerRadius = phoneBtn.frame.size.height/2
        phoneTextfield.delegate = self
        phoneTextfield.inputAccessoryView = generateToolBar()
        phoneTextfield.placeholder = NSLocalizedString("Register Input Phone", comment: "")
        
        phoneNewBtn.layer.cornerRadius = phoneNewBtn.frame.size.height/2
        phoneNewTextfield.delegate = self
        phoneNewTextfield.inputAccessoryView = generateToolBar()
        phoneNewTextfield.placeholder = NSLocalizedString("Register Input Phone", comment: "")
        
        phoneNewWarnL.isHidden = true
        
        registerBtn.setTitle(NSLocalizedString("send", comment: ""), for: .normal)
        registerBtn.layer.backgroundColor = UIColor.clear.cgColor
        registerBtn.layer.cornerRadius = registerBtn.frame.size.height/2
        registerBtn.layer.borderColor = Color_Main_Red.cgColor
        registerBtn.layer.borderWidth = 0.5
        checkNextBtnState(CheckText: false)
        phoneNewWarnL.isHidden = true
        
        phoneTextfield.text = AppDelegate.shared().forgotPassTempPhone
        phoneTextfield.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
        AppDelegate.shared().hideTopButton()
        AppDelegate.shared().forgotPassTempPhone = AppDelegate.shared().memberData["app_phone_no"] ?? ""
    }
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        sendSMS()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
