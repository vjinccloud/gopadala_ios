//
//  MemberChangeDataIntroVC.swift
//  indogo
//
//  Created by Wang Jen Chung on 2022/3/7.
//  Copyright © 2022 DIM. All rights reserved.
//

import UIKit
import SwiftyJSON
import AVFoundation
import Alamofire

class MemberChangeDataIntroVC: UIViewController {
    
    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var topL: UILabel!
    @IBOutlet weak var top2L: UILabel!
    @IBOutlet weak var phoneL: UILabel!
    @IBOutlet weak var sendAgainBtn: UIButton!
    @IBOutlet weak var barV: UIView!
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backL.text = NSLocalizedString("back", comment: "")
        nextBtn.setTitle(NSLocalizedString("ok", comment: ""), for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.height/2
        sendAgainBtn.setTitle(NSLocalizedString("Change Data Intro Btn Title", comment: ""), for: .normal)
        sendAgainBtn.layer.cornerRadius = sendAgainBtn.frame.height/2
        sendAgainBtn.layer.borderWidth = 0.5
        sendAgainBtn.layer.borderColor = Color_Purple.cgColor
        titleL.text = NSLocalizedString("Change Data Intro Title", comment: "")
        topL.text = NSLocalizedString("Change Data Intro Line1", comment: "")
        
        AppDelegate.shared().forgotPassTempMemID = AppDelegate.shared().getRemeberedAarcNo()
        AppDelegate.shared().forgotPassTempPhone = AppDelegate.shared().memberData["app_phone_no"] ?? ""
        phoneL.text = AppDelegate.shared().forgotPassTempPhone
        
        top2L.text = NSLocalizedString("Change Data Intro Line2", comment: "")
        barV.addGradienOfIndoGo()
        nextBtn.addGradienOfIndoGo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
        AppDelegate.shared().hideTopButton()
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
                    let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ForgotPassEnterCodeVC") as? ForgotPassEnterCodeVC
                    nextVC?.nextIndex = 1
                    self.navigationController?.pushViewController(nextVC!, animated: true)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
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
