//
//  RegisterPurpleInputVC.swift
//  indogo
//
//  Created by Wang Jen Chung on 2022/11/2.
//  Copyright © 2022 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class RegisterPurpleInputVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var barV: UIView!
    
    @IBOutlet weak var topScrollView: UIScrollView!
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var accountBtn: UIButton!
    @IBOutlet weak var accountTextfield: UITextField!
    
    @IBOutlet weak var errorL: UILabel!
    @IBOutlet weak var phoneView: UIView!
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var phoneTextfield: UITextField!
    var nowTextIdx = 0
    var dateStart:Date = Date()
    var dateEnd:Date = Date()
    
    var startDatePicker:UIDatePicker!
    var endDatePicker:UIDatePicker!
    
    @IBOutlet weak var passView: UIView!
    @IBOutlet weak var passBtn: UIButton!
    @IBOutlet weak var passTextField: UITextField!
    @IBOutlet weak var showPassBtn: UIButton!
    
    @IBOutlet weak var rePassView: UIView!
    @IBOutlet weak var rePassBtn: UIButton!
    @IBOutlet weak var rePassTextField: UITextField!
    @IBOutlet weak var showRePassBtn: UIButton!
    
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var arcCodeL: UILabel!
    
    @IBOutlet weak var titelL: UILabel!
    @IBOutlet weak var titleBtn: UIButton!
    @IBOutlet weak var date1IntroL: UILabel!
    @IBOutlet weak var date2IntroL: UILabel!
    
    @IBOutlet weak var date1Textfield: UITextField!
    @IBOutlet weak var date2Textfield: UITextField!
    @IBOutlet weak var date1Btn: UIButton!
    @IBOutlet weak var date2Btn: UIButton!
    
    var presetArc = ""
    var hasSharedCode = false
    var loadOnce = false
    var canPress = true
    
    func addDatePicker() {
        
        let dateNow = Date()
        
        if date1Textfield != nil {
            date1Textfield.tag = 0
            let datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 200))
            datePicker.datePickerMode = .date
            
            //datePicker.locale = NSLocale(localeIdentifier: "zh_TW") as Locale
            
            dateStart = dateNow.addDays(Days: 0, Month: 0, Year: -17)
            datePicker.date = dateStart
            datePicker.minimumDate = dateNow.addDays(Days: 0, Month: 0, Year: -65)
            datePicker.maximumDate = dateNow.addDays(Days: 0, Month: 0, Year: -17)
            date1Textfield.inputView = datePicker
            let doneButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(self.datePickerStartDone))
            let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44))
            toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
            date1Textfield.inputAccessoryView = toolBar
            startDatePicker = datePicker
            startDatePicker.tag = 0
            if #available(iOS 14, *) {
                datePicker.preferredDatePickerStyle = .wheels
            }
        }
        
        if date2Textfield != nil {
            date2Textfield.tag = 1
            let datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 200))
            datePicker.datePickerMode = .date
            dateEnd = dateNow
            datePicker.date = dateEnd
            datePicker.minimumDate = dateNow
            datePicker.maximumDate = dateNow.addDays(Days: 0, Month: 0, Year: 5)
            
            date2Textfield.inputView = datePicker
            let doneButton = UIBarButtonItem.init(title: NSLocalizedString("ok", comment: ""), style: .done, target: self, action: #selector(self.datePickerEndDone))
            let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44))
            toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
            date2Textfield.inputAccessoryView = toolBar
            endDatePicker = datePicker
            endDatePicker.tag = 1
            if #available(iOS 14, *) {
                datePicker.preferredDatePickerStyle = .wheels
            }
        }
    }
    
    @objc func datePickerStartDone() {
        date1Textfield.resignFirstResponder()
        let date = startDatePicker.date
        dateStart = date
        date1Textfield.text = date.toString()
    }
    
    @objc func datePickerEndDone() {
        date2Textfield.resignFirstResponder()
        let date = endDatePicker.date
        dateEnd = date
        date2Textfield.text = date.toString()
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        errorView.isHidden = true
        barV.addGradienOfIndoGo()
        backL.text = NSLocalizedString("back", comment: "")
        accountBtn.layer.cornerRadius = accountBtn.frame.size.height/2
        phoneBtn.layer.cornerRadius = phoneBtn.frame.size.height/2
        passBtn.layer.cornerRadius = passBtn.frame.size.height/2
        rePassBtn.layer.cornerRadius = rePassBtn.frame.size.height/2
        registerBtn.layer.cornerRadius = registerBtn.frame.size.height/2
        titleBtn.layer.cornerRadius = titleBtn.frame.size.height/2
        date1Btn.layer.cornerRadius = date1Btn.frame.size.height/2
        date2Btn.layer.cornerRadius = date2Btn.frame.size.height/2
        
        titelL.text = NSLocalizedString("account", comment: "")
        date1IntroL.text = NSLocalizedString("Register AddDate Title", comment: "")
        date2IntroL.text = NSLocalizedString("Register AddDate Title2", comment: "")
        
        passTextField.placeholder = NSLocalizedString("passcode", comment: "")
        rePassTextField.placeholder = NSLocalizedString("TFFRHP Change placehold2", comment: "")
        registerBtn.setTitle(NSLocalizedString("ok", comment: ""), for: .normal)
        
        passTextField.isSecureTextEntry = true
        rePassTextField.isSecureTextEntry = true
        
        accountTextfield.autocapitalizationType = .allCharacters
        
        //setShareCode(Code: "FD30471099")
        //showShareCodeInputview()
        
        accountTextfield.keyboardType = .asciiCapable
        passTextField.keyboardType = .asciiCapable
        rePassTextField.keyboardType = .asciiCapable
        
        accountTextfield.delegate = self
        phoneTextfield.delegate = self
        passTextField.delegate = self
        rePassTextField.delegate = self
        
        accountTextfield.placeholder = NSLocalizedString("Register Input Name", comment: "")
        phoneTextfield.placeholder = NSLocalizedString("Register Input Phone", comment: "")
        passTextField.placeholder = NSLocalizedString("Register Input Pass", comment: "")
        rePassTextField.placeholder = NSLocalizedString("Register Input rePass", comment: "")
        
        registerBtn.layer.borderColor = Color_Purple.cgColor
        registerBtn.layer.borderWidth = 0.5
        
        //inputArcView.isHidden = true
        checkNextBtnState(CheckText: false)
        #if targetEnvironment(simulator)
        //模擬器直接秀下一步
        self.simulatorNextAction()
        #else
        //--should--
        if DevMode {
            self.simulatorNextAction()
        }
        #endif
        
        if self.view.frame.size.width<380 {
            Dlog("special handling")
            //arcTextfield.font = UIFont.systemFont(ofSize: 12)
        }
        
        if AppDelegate.shared().hasArcResultAndGotoRegister {
            setArcCodeString(Code: AppDelegate.shared().arcScanReulstForRegister)
        }
        
        addDatePicker()
        date1Textfield.text = dateStart.toString()
        date2Textfield.text = dateEnd.toString()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if loadOnce {
            return
        }
        
        loadOnce = true
        
        if presetArc != "" {
            arcCodeL.text = presetArc
        }
    }
    
    func setArcText(Text text:String) {
        arcCodeL.text = text
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else{
            return true
        }
        
        if textField == passTextField || textField == rePassTextField {
            if !string.checkAlphabetDigit() {
                return false
            }
        }
        
        
        let textLength = text.count + string.count - range.length
        if textLength>20 {
            return false
        }
        
        return true

    }
    
    //MARK: - API
    func registerStep1() {
        
        let obj = AppDelegate.shared().tempRegisterObj
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_RegisterStep1;
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            multipartFormData.append(obj.account!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "name")
            multipartFormData.append(obj.phoneNum!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "phone")
            multipartFormData.append(obj.arcNum!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "arc_no")
            multipartFormData.append(UtilityTool().sha256(Code: obj.passwaord!).data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "password")
            multipartFormData.append(obj.shareCode.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "share_member_id")
            multipartFormData.append(obj.arcDay.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "arc_expire_date")
            multipartFormData.append(obj.birthday.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "birthday")
            
        }, usingThreshold: UInt64.init(), to: todoEndpoint, method: .post, headers: headers) { (result) in
            
            switch result {
            case .success(let upload, _, _):
                upload.response { response in
                    
                    AppDelegate.shared().removeLoadingView()
                    
                    guard response.error == nil else {
                        // got an error in getting the data, need to handle it
                        print("error calling on \(todoEndpoint), response = \(response)")
                        print(response.error!)
                        return
                    }
                    
                    //下一步，簡訊
                    let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                    Dlog("responseStr = \(responseStr ?? "")")
                    let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                    
                    if result == ResponseState.ok {
                        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterEnterSMSCodeVC") as? RegisterEnterSMSCodeVC
                        nextVC?.registerFromIndex = 1
                        self.navigationController?.pushViewController(nextVC!, animated: true)
                    } else if result == ResponseState.failed {
                        AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
            }
        }
    }
    
    func registerStep1NextAction() {
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterIDTakePhotoVC") as? RegisterIDTakePhotoVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        
        AppDelegate.shared().tempRegisterObj = RegisterDataObj()
        //AppDelegate.shared().tempRegisterObj.meImg = meImg
        AppDelegate.shared().tempRegisterObj.account = accountTextfield.text
        AppDelegate.shared().tempRegisterObj.phoneNum = phoneTextfield.text
        AppDelegate.shared().tempRegisterObj.passwaord = passTextField.text
        AppDelegate.shared().tempRegisterObj.arcNum = arcCodeL.text
        if hasSharedCode {
            AppDelegate.shared().tempRegisterObj.shareCode =  arcCodeL.text!
        } else {
            AppDelegate.shared().tempRegisterObj.shareCode = ""
        }
        
        AppDelegate.shared().tempRegisterObj.birthday = date1Textfield.text!
        AppDelegate.shared().tempRegisterObj.arcDay = date2Textfield.text!
        
        registerStep1()
        /*
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterAddDateVC") as? RegisterAddDateVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
        */
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
        rePassTextField.isSecureTextEntry.toggle()
        
        if rePassTextField.isSecureTextEntry {
            showRePassBtn.setBackgroundImage(UIImage.init(named: "noview_b"), for: .normal)
        } else {
            showRePassBtn.setBackgroundImage(UIImage.init(named: "view_w"), for: .normal)
        }
    }
    
    //MARK: - Text Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        nowTextIdx = textField.tag
        Dlog("nowTextIdx = \(nowTextIdx)")
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkNextBtnState(CheckText: true)
    }
    
    //MARK: - Utility
    func checkTextFormat() -> Bool {
        if accountTextfield.text?.count == 0 || phoneTextfield.text?.count == 0 || passTextField.text?.count == 0 || rePassTextField.text?.count == 0 || arcCodeL.text?.count == 0 {
            errorL.text = NSLocalizedString("Register Error Empty", comment: "")
            errorView.isHidden = false
            return false
        }
        
        //Tel
        var pass = true
        if !(phoneTextfield.text?.hasPrefix("09"))! {
            pass = false
        }
        
        if phoneTextfield.text?.count != 10 {
            pass = false
        }
        
        if !pass {
            errorL.text = NSLocalizedString("Register Error Tel", comment: "")
            errorView.isHidden = false
            return false
        }
        
        //ARC
        pass = true
        let text = arcCodeL.text!
        
        if text.count != 10 {
            pass = false
        }
        
        let singleWord = text.getSubString(Start: 1, EndNotInclude: 2).lowercased()
        Dlog("singleWord = \(singleWord)")
        if singleWord == "c" || singleWord == "d" || singleWord == "8" || singleWord == "9" {
            pass = true
        } else {
            pass = false
        }
        
        if pass {
            let range = NSRange(location: 0, length: 1)
            let regex = try! NSRegularExpression(pattern: "[A-Z]")
            pass = regex.firstMatch(in: text, options: [], range: range) != nil
        }
        
        if pass {
            let words = text.getSubString(Start: 2, EndNotInclude: 10)
            Dlog("words = \(words)")
            let pred = NSPredicate(format:"SELF MATCHES %@", "^[0-9]\\d*$")
            pass = pred.evaluate(with: words)
        }
        
        if !pass {
            errorL.text = NSLocalizedString("Register Error ARC", comment: "")
            errorView.isHidden = false
            
            return false
        }
        
        //密碼
        pass = true
        if passTextField.text!.count < 4 {
            pass = false
        }
        
        if !pass {
            errorL.text = NSLocalizedString("Register Error Pass", comment: "")
            errorView.isHidden = false
            return false
        }
        
        pass = true
        
        if passTextField.text != rePassTextField.text {
            pass = false
        }
        
        if !pass {
            errorL.text = NSLocalizedString("Register Error Pass Not match", comment: "")
            errorView.isHidden = false
            return false
        }
        
        errorView.isHidden = true
        return true
    }
    
    func checkNextBtnState(CheckText checkNow:Bool) {
        var pass = true
        
        if accountTextfield.text?.count == 0 || phoneTextfield.text?.count == 0 || passTextField.text?.count == 0 || rePassTextField.text?.count == 0 || arcCodeL.text?.count == 0 {
            pass = false
        } else if passTextField.text != rePassTextField.text {
            pass = false
        } /*else if !hasMeCode {
            pass = false
        }*/
        
        if checkNow {
            let passText = checkTextFormat()
            if !passText {
                pass = false
            }
        }
        
        if pass {
            registerBtn.addGradienOfIndoGo()
            registerBtn.isEnabled = true
        } else {
            registerBtn.backgroundColor = .clear
            registerBtn.isEnabled = false
        }
    }
    
    public func setArcCodeString(Code code:String) {
        arcCodeL.text = code
        checkNextBtnState(CheckText: true)
    }
    
    //測試用(僅在模擬器發生)
    func simulatorNextAction() {
        
        accountTextfield.text = "ask"
        phoneTextfield.text = "0935499332"
        passTextField.text = "a12345"
        rePassTextField.text = "a12345"
        setArcCodeString(Code: "XC00000092") //XX00000037
        
        checkNextBtnState(CheckText: true)
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
