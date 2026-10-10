//
//  RegisterEnterSMSCodeVC.swift
//  indogo
//
//  Created by mac on 2020/8/7.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import SwiftyJSON
import AVFoundation
import Alamofire

class RegisterEnterSMSCodeVC: UIViewController, UITextFieldDelegate {

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
    @IBOutlet weak var wangingTitleL: UILabel!
    var registerFromIndex = 0
    @IBOutlet weak var barV: UIView!
    var canPress = false
    private var warningLinkRange: NSRange?
    private lazy var warningLabelTapGesture: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(didTapWarningLabel(_:)))
    }()
    var loadOnce = false
    
    //MARK: - API
    func sendSMS() {
        let parameters:Parameters = ["arc_no":AppDelegate.shared().tempRegisterObj.arcNum!, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        Dlog("parameters=\(parameters)")
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_ResendRegisterSMS;
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
    
    //MARK: - Button-Action
    @IBAction func sendAgain(_ sender: Any) {
        if !canPress {
            return
        }
        
        canPress = false
        Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(self.changeState), userInfo: nil, repeats: false)
        sendSMS()
    }
    
    @objc func changeState() {
        canPress = true
    }
    
    @IBAction func nextAction(_ sender: Any) {
        
        if allCodeTextField.text == "" || allCodeTextField.text?.count != 4 {
            AppDelegate.shared().showAlertWithWindow(self, Message: "Please Enter Number")
            return
        }
        
        AppDelegate.shared().forgotPassTempEnterCode = allCodeTextField.text!
        
        if AppDelegate.shared().forgotPassTempSMS != allCodeTextField.text! {
            AppDelegate.shared().showAlertWithWindow(self, Message: "SMS Code Wrong")
            return
        }
        
        /*
        if codeT1.text == "" || codeT2.text == "" || codeT3.text == "" || codeT4.text == "" {
            AppDelegate.shared().showAlertWithWindow(self, Message: "Please Enter Number")
            return
        }*/
        
        //組合code
        let code =  allCodeTextField.text!
        //codeT1.text! + codeT2.text! + codeT3.text! + codeT4.text!
        
        let parameters:Parameters = ["arc_no":AppDelegate.shared().tempRegisterObj.arcNum!, "sms_code":code, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        Dlog("parameters=\(parameters)")
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_VerifyRegisterSMS;
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
                    if self.registerFromIndex == 0 {
                        //回首頁，並帶入帳密
                        guard let viewControllers = self.navigationController?.viewControllers else {
                            return
                        }
                        
                        for firstViewController in viewControllers {
                            if firstViewController is ViewController {
                                let obj = AppDelegate.shared().tempRegisterObj
                                let vc = firstViewController as! ViewController
                                vc.accountTextfield.text = obj.arcNum
                                vc.passTextField.text = obj.passwaord
                                break
                            }
                        }
                        self.navigationController?.popToRootViewController(animated: true)
                    } else if self.registerFromIndex == 1 {
                        //註冊第一步完成
                        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterIDTakePhotoVC") as? RegisterIDTakePhotoVC
                        self.navigationController?.pushViewController(nextVC!, animated: true)
                    }
                    
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func registerStep1() {
        
        let obj = AppDelegate.shared().tempRegisterObj
        
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_Register;
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            multipartFormData.append(obj.account!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "name")
            multipartFormData.append(obj.phoneNum!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "phone")
            multipartFormData.append(obj.arcNum!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "arc_no")
            multipartFormData.append(UtilityTool().sha256(Code: obj.passwaord!).data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "password")
            multipartFormData.append(obj.shareCode.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "share_member_id")
            
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
        
        configureWarningLabel()
        
        allCodeTextField.backgroundColor = .white
        allCodeTextField.keyboardType = .numberPad
        barV.backgroundColor = Color_Main_Red
        
        barV.installLayoutAwareIndoGoGradient()
        nextBtn.installLayoutAwareIndoGoGradient()
        
        Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(self.changeState), userInfo: nil, repeats: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        barV.updateLayoutAwareIndoGoGradientFrame()
        nextBtn.updateLayoutAwareIndoGoGradientFrame()
        nextBtn.layer.cornerRadius = nextBtn.bounds.height / 2
    }
    
    private func configureWarningLabel() {
        let warningText = NSLocalizedString("TFFRHP Warning Title", comment: "")
        let attributedText = NSMutableAttributedString(string: warningText)
        let fullRange = NSRange(location: 0, length: attributedText.length)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = wangingTitleL.textAlignment
        paragraphStyle.lineBreakMode = wangingTitleL.lineBreakMode
        attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
        let linkKeyword = "here"
        let nsText = warningText as NSString
        let linkRange = nsText.range(of: linkKeyword, options: [.caseInsensitive])
        if linkRange.location != NSNotFound && linkRange.length > 0 {
            attributedText.addAttributes([
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .foregroundColor: Color_Main_Red
            ], range: linkRange)
            warningLinkRange = linkRange
        } else {
            warningLinkRange = nil
        }
        wangingTitleL.attributedText = attributedText
        wangingTitleL.isUserInteractionEnabled = true
        if wangingTitleL.gestureRecognizers?.contains(where: { $0 === warningLabelTapGesture }) != true {
            wangingTitleL.addGestureRecognizer(warningLabelTapGesture)
        }
    }
    
    @objc private func didTapWarningLabel(_ gesture: UITapGestureRecognizer) {
        let textLength = wangingTitleL.attributedText?.length ?? 0
        AppDelegate.shared().callMessenger(removeFloating: false)
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

private extension UITapGestureRecognizer {
    func didTapAttributedText(in label: UILabel, inRange targetRange: NSRange) -> Bool {
        guard let attributedText = label.attributedText else {
            return false
        }
        let textStorage = NSTextStorage(attributedString: attributedText)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: label.bounds.size)
        textContainer.lineFragmentPadding = 0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let xOffset: CGFloat
        switch label.textAlignment {
        case .left, .natural, .justified:
            xOffset = -textBoundingBox.origin.x
        case .right:
            xOffset = label.bounds.size.width - textBoundingBox.size.width - textBoundingBox.origin.x
        default:
            xOffset = (label.bounds.size.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x
        }
        let yOffset = (label.bounds.size.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        
        let textContainerOffset = CGPoint(x: xOffset, y: yOffset)
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
