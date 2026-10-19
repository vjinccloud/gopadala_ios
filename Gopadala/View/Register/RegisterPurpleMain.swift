//
//  RegisterPurpleMain.swift
//  indogo
//
//  Created by Wang Jen Chung on 2022/11/1.
//  Copyright © 2022 DIM. All rights reserved.
//

import UIKit
import SwiftyJSON
import AVFoundation
import Alamofire

class RegisterPurpleMain: UIViewController, UITextFieldDelegate, CustomAlertDelegate {
    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var topL: UILabel!
    @IBOutlet weak var introL: UILabel!
    @IBOutlet weak var barV: GradianBarView!
    
    @IBOutlet weak var accountBtn: UIButton!
    @IBOutlet weak var accountTextfield: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    var oldCenter:CGPoint!
    var tempARC = ""
    var loadOnce = false
    
    //MARK: - Utility
    func customAlertnextAction(Ref obj: CustomAlertView) {
        obj.removeFromSuperview()
    }
    
    func customAlertnextActionSecond(Ref obj: CustomAlertView) {
        
    }
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        AppDelegate.shared().tempArcForLogin = self.accountTextfield.text!
        if accountTextfield.text == "" {
            AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("Please Enter Number", comment: ""))
            return
        }
        scanNext(Code: accountTextfield.text!)
        /*
        //--should-- 改成直接去新的註冊輸入頁面
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPassIntroVC") as? ForgotPassIntroVC
        nextVC!.fromType = .register
        self.navigationController?.pushViewController(nextVC!, animated: true)
         */
    }
    
    func scanNext(Code code:String) {
        
        //檢查限制為 C,D,8,9 其餘跳出格式錯誤
        //"scan format wrong"
        var checkedWrong = true
        if code.count < 2 {
            checkedWrong = true
        } else {
            let singleWord = code.getSubString(Start: 1, EndNotInclude: 2).lowercased()
            Dlog("singleWord = \(singleWord)")
            if singleWord == "c" || singleWord == "d" || singleWord == "8" || singleWord == "9" {
                checkedWrong = false
            }
        }
        
        if checkedWrong {
            
            let window = UIApplication.shared.keyWindow
            let customAlert = CustomAlertView.init(frame: self.view.frame)
            customAlert.initSimpleAlert(Title: "", Content: NSLocalizedString("scan format wrong" , comment: ""), NextBtn1Str: NSLocalizedString("ok" , comment: ""))
            window!.addSubview(customAlert)
            customAlert.customDelegate = self
            return
        }
        
        let parameters:Parameters = ["arc_no":code, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        Dlog("parameters=\(parameters)")
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_CheckMemExist;
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
                AppDelegate.shared().forgotPassTempMemID = code
                if result == ResponseState.ok {
                    //202404改成RegisterPurpleInputVC是後面才有
                    let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterPurpleInputVC") as? RegisterPurpleInputVC
                    nextVC!.presetArc = code
                    self.navigationController?.pushViewController(nextVC!, animated: true)
                    
                } else if result == ResponseState.member_not_exist {
                    //202404改成RegisterPurpleInputVC是後面才有
                    let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterPurpleInputVC") as? RegisterPurpleInputVC
                    nextVC!.presetArc = code
                    self.navigationController?.pushViewController(nextVC!, animated: true)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        
        AppDelegate.shared().showTopButton()
    }
    
    @IBAction func scanArcAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPassIntroVC") as? ForgotPassIntroVC
        nextVC!.fromType = .register
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupHideKeyboardOnTap()
        // Do any additional setup after loading the view.
        backL.text = NSLocalizedString("back", comment: "")
        topL.text = NSLocalizedString("New RegisterMain Top", comment: "")
        introL.text = NSLocalizedString("New RegisterMain Warning", comment: "")
        
        AppDelegate.shared().hideTopButton()
        barV.addGradienOfIndoGo()
        accountTextfield.delegate = self
        accountTextfield.autocapitalizationType = .allCharacters
        accountTextfield.placeholder = NSLocalizedString("New Login Account PlaceHolder", comment: "")
        loginBtn.setTitle(NSLocalizedString("ok", comment: ""), for: .normal)
        accountBtn.layer.cornerRadius = accountBtn.frame.height/2
        loginBtn.layer.cornerRadius = loginBtn.frame.height/2
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        oldCenter = self.view.center
        accountTextfield.text = tempARC
        if loadOnce {
            return
        }
        loadOnce = true
        loginBtn.addGradienOfIndoGo()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.view.center = CGPoint.init(x: oldCenter.x, y: oldCenter.y-80)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.center = oldCenter
    }
    
    //手動輸入 ARC：限 10 碼、只收英數字、小寫自動轉大寫
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField == accountTextfield, let current = textField.text, let textRange = Range(range, in: current) else {
            return true
        }
        
        let upper = string.uppercased()
        let allowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        if upper.unicodeScalars.contains(where: { !allowed.contains($0) }) {
            return false
        }
        
        let newText = current.replacingCharacters(in: textRange, with: upper)
        if newText.count > 10 {
            return false
        }
        
        if upper == string {
            return true
        }
        
        //有小寫：自己換成大寫後寫回，並把游標放回輸入點後面
        textField.text = newText
        if let pos = textField.position(from: textField.beginningOfDocument, offset: range.location + upper.count) {
            textField.selectedTextRange = textField.textRange(from: pos, to: pos)
        }
        return false
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
