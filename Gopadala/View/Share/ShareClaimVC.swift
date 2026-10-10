//
//  ShareClaimVC.swift
//  indogo
//
//  Created by Wang Jen Chung on 2023/4/16.
//  Copyright © 2023 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class ShareClaimVC: UIViewController {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var barV: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    var loadOnce = false
    
    @IBOutlet weak var boxV: UIView!
    @IBOutlet weak var numL: UILabel!
    
    @IBOutlet weak var expireDateL: UILabel!
    @IBOutlet weak var vidotV: UIView!
    @IBOutlet weak var v2dotV: UIView!
    @IBOutlet weak var v3dotV: UIView!
    
    @IBOutlet weak var deadLineL: UILabel!
    @IBOutlet weak var nextBtnbottomLength: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        barV.addGradienOfIndoGo()
        backL.text = "Redeem Points"
        nextBtn.addGradienOfIndoGo()
        nextBtn.setTitle("NEXT", for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        
        vidotV.layer.cornerRadius = vidotV.frame.height/2
        v2dotV.layer.cornerRadius = v2dotV.frame.height/2
        v3dotV.layer.cornerRadius = v3dotV.frame.height/2
        
        boxV.layer.backgroundColor = UIColor.white.cgColor
        boxV.layer.cornerRadius = 15
        boxV.layer.borderColor = Color_Main_LightGray.cgColor
        boxV.layer.borderWidth = 1
        
        if !AppDelegate.shared().deviceSmall {
            nextBtnbottomLength.constant = 120
        }
        
        callMemberData()
        getPointHistory()
    }
    
    func initData() {
        numL.text = AppDelegate.shared().memberData["verify_point"]!
    }
    
    //MARK: - API
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
                    self.initData()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func getPointHistory() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_PointHistoryList;
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
                Dlog("todoEndpoint = \(todoEndpoint),responseStr = \(responseStr ?? "")")
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                
                if result == ResponseState.ok {
                    let num = AppDelegate.shared().historyListObj.count
                    if num == 0 {
                        self.deadLineL.text = ""
                        return
                    }
                    
                    let obj = AppDelegate.shared().historyListObj[0]
                    self.deadLineL.text = "\(obj.expirDate ?? "")"
                    Dlog("obj.expirDate = \(obj.expirDate)")
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
            }
    }
    
    func checkMember() {
        
        let parameters:Parameters = ["arc_no":AppDelegate.shared().getRemeberedAarcNo(), "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
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
                
                if result == ResponseState.ok {
                    let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "ShareGetPointIntroVC") as? ShareGetPointIntroVC
                    self.navigationController?.pushViewController(nextVC!, animated: true)
                } else if result == ResponseState.member_not_exist {
                    
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //MARK: - Btn Action
    @IBAction func nextAction(_ sender: Any) {
        checkMember()
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
