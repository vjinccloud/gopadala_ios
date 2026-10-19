//
//  RegisterAddDateVC.swift
//  indogo
//
//  Created by Wang Jen Chung on 2022/3/8.
//  Copyright © 2022 DIM. All rights reserved.
//

import UIKit
import SwiftyJSON
import AVFoundation
import Alamofire

class RegisterAddDateVC: UIViewController, UITextFieldDelegate {

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
    
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var arcCodeL: UILabel!
    
    var dateStart:Date = Date()
    var dateEnd:Date = Date()
    
    var startDatePicker:UIDatePicker!
    var endDatePicker:UIDatePicker!
    var nowTextIdx = 0
    
    func addDatePicker() {
        
        let dateNow = Date()
        
        if phoneTextfield != nil {
            let datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 200))
            datePicker.datePickerMode = .date
            
            //datePicker.locale = NSLocale(localeIdentifier: "zh_TW") as Locale
            
            dateStart = dateNow.addDays(Days: 0, Month: 0, Year: -17)
            datePicker.date = dateStart
            datePicker.minimumDate = dateNow.addDays(Days: 0, Month: 0, Year: -65)
            datePicker.maximumDate = dateNow.addDays(Days: 0, Month: 0, Year: -17)
            phoneTextfield.inputView = datePicker
            let doneButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(self.datePickerDone))
            let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44))
            toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
            phoneTextfield.inputAccessoryView = toolBar
            startDatePicker = datePicker
            if #available(iOS 14, *) {
                datePicker.preferredDatePickerStyle = .wheels
            }
        }
        
        if phoneNewTextfield != nil {
            let datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 200))
            datePicker.datePickerMode = .date
            dateEnd = dateNow
            datePicker.date = dateEnd
            datePicker.minimumDate = dateNow
            datePicker.maximumDate = dateNow.addDays(Days: 0, Month: 0, Year: 5)
            
            phoneNewTextfield.inputView = datePicker
            let doneButton = UIBarButtonItem.init(title: NSLocalizedString("ok", comment: ""), style: .done, target: self, action: #selector(self.datePickerDone))
            let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44))
            toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
            phoneNewTextfield.inputAccessoryView = toolBar
            endDatePicker = datePicker
            if #available(iOS 14, *) {
                datePicker.preferredDatePickerStyle = .wheels
            }
        }
    }
    
    @objc func datePickerDone() {
        phoneTextfield.resignFirstResponder()
        phoneNewTextfield.resignFirstResponder()
        
        if nowTextIdx == 0 {
            let date = startDatePicker.date
            dateStart = date
            phoneTextfield.text = date.toString()
        } else if nowTextIdx == 1 {
            let date = endDatePicker.date
            dateEnd = date
            phoneNewTextfield.text = date.toString()
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        nowTextIdx = textField.tag
        return true
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        arcCodeL.text = AppDelegate.shared().tempRegisterObj.arcNum
        self.setupHideKeyboardOnTap()
        
        backL.text = NSLocalizedString("back", comment: "")
        phoneTitle.text = NSLocalizedString("Register AddDate Title", comment: "")
        phoneNewTitle.text = NSLocalizedString("Register AddDate Title2", comment: "")
        
        phoneBtn.layer.cornerRadius = phoneBtn.frame.size.height/2
        phoneBtn.layer.borderColor =  UIColor.white.cgColor
        phoneBtn.layer.borderWidth = 0.5
        phoneTextfield.delegate = self
        phoneTextfield.tag = 0
        phoneTextfield.inputAccessoryView = generateToolBar()
        //phoneTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Register Input Phone", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        phoneNewBtn.layer.cornerRadius = phoneNewBtn.frame.size.height/2
        phoneNewBtn.layer.borderColor =  UIColor.white.cgColor
        phoneNewBtn.layer.borderWidth = 0.5
        phoneNewTextfield.delegate = self
        phoneNewTextfield.tag = 1
        phoneNewTextfield.inputAccessoryView = generateToolBar()
        //phoneNewTextfield.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("Register Input Phone", comment: ""), attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        registerBtn.setTitle(NSLocalizedString("ok", comment: ""), for: .normal)
        registerBtn.layer.cornerRadius = registerBtn.frame.size.height/2
        registerBtn.layer.borderColor = Color_Main_Red.cgColor
        registerBtn.layer.borderWidth = 0.5
        
        //dateStart = obj.getStartDate()
        //dateEnd = obj.getEndDate()
        addDatePicker()
        phoneTextfield.text = dateStart.toString()
        phoneNewTextfield.text = dateEnd.toString()
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
        phoneTextfield.resignFirstResponder()
        phoneNewTextfield.resignFirstResponder()
    }
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        
        AppDelegate.shared().tempRegisterObj.birthday = phoneTextfield.text!
        AppDelegate.shared().tempRegisterObj.arcDay = phoneNewTextfield.text!
        registerStep1()
        /*
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterIDTakePhotoVC") as? RegisterIDTakePhotoVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
         */
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
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
            multipartFormData.append(obj.arcIssueDay.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "arc_issue_date")
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
