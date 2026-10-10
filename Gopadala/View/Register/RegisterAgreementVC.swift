//
//  RegisterAgreementVC.swift
//  indogo
//
//  Created by mac on 2020/7/18.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit

class RegisterAgreementVC: UIViewController, UIScrollViewDelegate, WKNavigationDelegate {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var agreementBackV: UIView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var barV: UIView!
    var hasScroll = false
    var hasEnd = false
    var touchOrder = 0
    var tempARC = ""
    var loadOnce = false
    
    //MARK: - API
    public func getAgreement() {
        let parameters:Parameters = ["doc_name":"會員服務條款", "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_GetDoc;
        
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
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "會員服務條款")
                if result == ResponseState.ok {
                    self.nextBtn.isEnabled = true
                    self.webView.navigationDelegate = self
                    self.webView.loadHTMLString(AppDelegate.shared().tempAgreementHtmlContent, baseURL: nil)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("WebView 已加載完成")
        
        self.webView.scrollView.delegate = self
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if !hasScroll {
            touchOrder = 1
            hasScroll = true
            nextBtn.layer.borderColor = Color_Purple.cgColor
            nextBtn.layer.borderWidth = 1
            nextBtn.setTitleColor(Color_Purple, for: .normal)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let scrollViewHeight = scrollView.frame.size.height
        let scrollContentSizeHeight = scrollView.contentSize.height
        let scrollOffset = scrollView.contentOffset.y
        
        if scrollOffset + scrollViewHeight >= scrollContentSizeHeight {
            if !hasEnd {
                hasEnd = true
                nextBtn.addGradienOfIndoGo()
                nextBtn.layer.borderWidth = 0
                nextBtn.setTitleColor(.white, for: .normal)
                nextBtn.isEnabled = true
            }
        }
    }
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        if touchOrder == 0 {
            hasScroll = true
            touchOrder = 1
            nextBtn.layer.borderColor = Color_Purple.cgColor
            nextBtn.layer.borderWidth = 1
            nextBtn.setTitleColor(Color_Purple, for: .normal)
            
            webView.scrollView.setContentOffset(CGPoint.init(x: 0, y: webView.scrollView.contentSize.height/2), animated: true)
            
            return
        } else if touchOrder == 1 {
            touchOrder = 2
            webView.scrollView.setContentOffset(CGPoint.init(x: 0, y: webView.scrollView.contentSize.height - webView.frame.height), animated: true)
            hasEnd = true
            nextBtn.addGradienOfIndoGo()
            nextBtn.layer.borderWidth = 0
            nextBtn.setTitleColor(.white, for: .normal)
            nextBtn.isEnabled = true
            return
        }
        
        //原本是RegisterIntroVC
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "RegisterPurpleMain") as? RegisterPurpleMain
        nextVC?.tempARC = tempARC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        AppDelegate.shared().showTopButton()
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()
        AppDelegate.shared().hideTopButton()

        // Do any additional setup after loading the view.
        backL.text = NSLocalizedString("", comment: "")
        agreementBackV.layer.cornerRadius = 20
        agreementBackV.clipsToBounds = true
        
        //nextBtn.isEnabled = false
        nextBtn.layer.cornerRadius = nextBtn.frame.height/2
        cancelBtn.isHidden = true
        cancelBtn.layer.cornerRadius = nextBtn.frame.height/2
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = Color_Main_Red.cgColor
        nextBtn.backgroundColor = .clear
        nextBtn.layer.borderColor = Color_Main_LightGray.cgColor
        nextBtn.layer.borderWidth = 1
        nextBtn.setTitleColor(Color_Main_LightGray, for: .normal)
        nextBtn.isEnabled = false
        nextBtn.setTitle(NSLocalizedString("agree", comment: ""), for: .normal)
        cancelBtn.setTitle(NSLocalizedString("cancel", comment: ""), for: .normal)
        
        barV.backgroundColor = Color_Main_Red
        
        getAgreement()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if loadOnce {
            return
        }
        barV.addGradienOfIndoGo()
        loadOnce = true
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
