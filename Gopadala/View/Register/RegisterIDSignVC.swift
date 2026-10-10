//
//  RegisterIDSignVC.swift
//  indogo
//
//  Created by mac on 2020/8/4.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import AVFoundation

class RegisterIDSignVC: UIViewController {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var barV: UIView!
    
    @IBOutlet weak var firstPhotoTitleL: UILabel!
    @IBOutlet weak var secPhotoTitleL: UILabel!
    @IBOutlet weak var signTitleL: UILabel!
    
    @IBOutlet weak var firstImgV: UIImageView!
    @IBOutlet weak var secImgV: UIImageView!
    @IBOutlet weak var signImgV: UIImageView!
    @IBOutlet weak var firstHeadV: UIView!
    @IBOutlet weak var signHeadV: UIView!
    @IBOutlet weak var midV: UIView!
    
    var firstHasTaked = false
    var secHasTaked = false
    var signHasTaked = false
    
    var frontImage:UIImage!
    var backImage:UIImage!
    var signImage:UIImage!
    
    @IBOutlet weak var firstView: UIView!
    @IBOutlet weak var secView: UIView!
    @IBOutlet weak var signView: UIView!
    
    var loadOnce = false
    
    //MARK: - Button-Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextAction(_ sender: Any) {
        AppDelegate.shared().tempRegisterObj.faceImg = frontImage
        AppDelegate.shared().tempRegisterObj.passportImg = backImage
        AppDelegate.shared().tempRegisterObj.signImg = signImage
        
        let obj = AppDelegate.shared().tempRegisterObj
        
        let headers: HTTPHeaders = [
            "Content-type": "multipart/form-data"
        ]
        
        AppDelegate.shared().addLoadingView()
        
        //let todoEndpoint: String = API_Register;
        let todoEndpoint: String = API_RegisterStep2;
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            
            multipartFormData.append(obj.arcNum!.data(using: String.Encoding.utf8, allowLossyConversion: false)!, withName: "arc_no")
            
            multipartFormData.append(obj.frontImg.ImgPress(LimitInBytes: ImageLimitInBytes), withName: "arc", fileName: "arc.jpg", mimeType: "image/jpg")
            multipartFormData.append(obj.backImg.ImgPress(LimitInBytes: ImageLimitInBytes), withName: "arc_back", fileName: "arc_back.jpg", mimeType: "image/jpg")
            multipartFormData.append(obj.signImg.ImgPress(LimitInBytes: ImageLimitInBytes), withName: "sign", fileName: "sign.jpg", mimeType: "image/jpg")
            multipartFormData.append(obj.faceImg.ImgPress(LimitInBytes: ImageLimitInBytes), withName: "address", fileName: "address.jpg", mimeType: "image/jpg")
            //multipartFormData.append(obj.passportImg.ImgPress(LimitInBytes: ImageLimitInBytes), withName: "id_card", fileName: "id_card.jpg", mimeType: "image/jpg")
            multipartFormData.append(obj.faceImg.ImgPress(LimitInBytes: ImageLimitInBytes), withName: "self", fileName: "self.jpg", mimeType: "image/jpg")
            
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
                    
                    //下一步，改成直接回首頁(原先是進入簡訊)
                    let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                    Dlog("responseStr = \(responseStr ?? "")")
                    let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                    
                    if result == ResponseState.ok {
                        
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
                        
                        /*
                        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterEnterSMSCodeVC") as? RegisterEnterSMSCodeVC
                        nextVC?.registerFromIndex = 0
                        self.navigationController?.pushViewController(nextVC!, animated: true)
                         */
                    } else if result == ResponseState.failed {
                        AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
            }
        }
        
    }
    
    @IBAction func signAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterMakeSignVC") as? RegisterMakeSignVC
        nextVC?.takePhotoType = PhotoIDType.sign
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func takeFirstPhoto(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterIDWithSelfIntroVC") as? RegisterIDWithSelfIntroVC
        nextVC?.takePhotoType = .faceAndId
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func takeSecPhoto(_ sender: Any) {
        var storyboardId = "RegisterIDTakeIntroVC"
        if AppDelegate.shared().deviceSmall {
            storyboardId = "RegisterIDTakeIntroVCSmall"
        }
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: storyboardId) as? RegisterIDTakeIntroVC
        nextVC?.takePhotoType = PhotoIDType.passport
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    //MARK: - Utility
    func setTakedPic(Type type:PhotoIDType, Img img:UIImage) {
        if type == PhotoIDType.faceAndId {
            frontImage = img
            firstImgV.image = img
            firstHasTaked = true
        } else if type == PhotoIDType.passport {
            backImage = img
            secImgV.image = img
            secHasTaked = true
        } else if type == PhotoIDType.sign {
            signImage = img
            signImgV.image = UIImage.init(named: "note.png")
            signHasTaked = true
        }
        
        checkNextBtnState()
    }
    
    func checkNextBtnState() {
        var pass = true
        
        if !firstHasTaked /*|| !secHasTaked*/ || !signHasTaked {
            pass = false
        }
        
        
        if pass {
            nextBtn.backgroundColor = Color_Purple
            nextBtn.isEnabled = true
        } else {
            nextBtn.backgroundColor = .clear
            nextBtn.isEnabled = false
        }
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backL.text = NSLocalizedString("back", comment: "")
        midV.isHidden = true
        nextBtn.setTitle(NSLocalizedString("ok", comment: ""), for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.layer.backgroundColor = Color_Purple.cgColor
        nextBtn.setTitleColor(.white, for: .normal)
        nextBtn.layer.borderWidth = 0.5
        nextBtn.layer.borderColor = Color_Purple.cgColor
        
        firstPhotoTitleL.text = NSLocalizedString("Register ID Self First2", comment: "")
        secPhotoTitleL.text = NSLocalizedString("Register ID Self Sec", comment: "")
        signTitleL.text = NSLocalizedString("Register ID Self Sign", comment: "")
        
        firstView.layer.borderWidth = 0.5
        firstView.layer.borderColor = UIColor.white.cgColor
        firstView.layer.cornerRadius = 5
        firstView.clipsToBounds = true
        
        secView.layer.borderWidth = 0.5
        secView.layer.borderColor = UIColor.white.cgColor
        secView.layer.cornerRadius = 5
        secView.clipsToBounds = true
        
        signView.layer.borderWidth = 0.5
        signView.layer.borderColor = UIColor.white.cgColor
        signView.layer.cornerRadius = 5
        signView.clipsToBounds = true
        
        barV.backgroundColor = Color_Main_Red
        firstHeadV.backgroundColor = Color_Main_Red
        signHeadV.backgroundColor = Color_Main_Red
        
        checkNextBtnState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if loadOnce {
            return
        }
        loadOnce = true
        barV.addGradienOfIndoGo()
        firstHeadV.addGradienOfIndoGo()
        signHeadV.addGradienOfIndoGo()
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
