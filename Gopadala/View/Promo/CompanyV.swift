//
//  CompanyV.swift
//  indogo
//
//  Created by Wang Jen Chung on 2022/10/17.
//  Copyright © 2022 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit

class CompanyV: UIView, WKNavigationDelegate {
    
    var companyL:UILabel!
    var serialNoL:UILabel!
    var dateL:UILabel!
    var promiseL:UILabel!
    var addressL:UILabel!
    
    var transferValue:UILabel!
    var bankNameL:UILabel!
    var phoneL:UILabel!
    var phoneimage:UIImageView!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func initFirst() {
        let imgV = UIImageView.init(frame: self.bounds)
        imgV.image = UIImage.init(named: "companyPink")
        imgV.contentMode = .scaleAspectFill
        self.addSubview(imgV)
        getInfo()
        
        let startY:CGFloat = AppTopBarHeight
        let scrollV:UIScrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: startY, width: self.frame.width, height: self.frame.height - AppBottomBarHeight - startY))
        self.addSubview(scrollV)
        var scrollY:CGFloat = 20
        let upHeight:CGFloat = 250
        let downHeight:CGFloat = 190
        let boxWid:CGFloat = self.frame.width - 20
        
        let hei:CGFloat = boxWid * 1320 / 2236 - 15
        let warnWebV = WKWebView(frame: CGRect(x: 10, y: 0, width: boxWid, height: hei))
        warnWebV.navigationDelegate = self
        
        if let url = URL(string: "https://prod.gopadala.com.tw/anti_fraud.php") {
            let request = URLRequest(url: url)
            warnWebV.load(request)
        }
        
        scrollV.addSubview(warnWebV)
        scrollY = hei + 10
        
        let upV = UIView.init(frame: CGRect.init(x: 10, y: 0, width: boxWid, height: upHeight))
        upV.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.7)
        upV.layer.cornerRadius = 10
        upV.clipsToBounds = true
        
        let upLogo = UIImageView.init(frame: CGRect.init(x: 50, y: 15, width: boxWid-100, height: 50))
        upLogo.image = UIImage.init(named: "Logo")
        upLogo.contentMode = .scaleAspectFit
        upV.addSubview(upLogo)
        
        companyL = UILabel.init(frame: CGRect.init(x: 30, y: 50, width: boxWid-60, height: 50))
        companyL.font = UIFont.systemFont(ofSize: 20)
        companyL.textColor = Color_Gradient_Right
        companyL.numberOfLines = 2
        companyL.textAlignment = .center
        companyL.text = "Digital Idea Multi-media, co.ltd\n數位至匯股份有限公司"
        upV.addSubview(companyL)
        
        serialNoL = UILabel.init(frame: CGRect.init(x: 30, y: 103, width: boxWid-60, height: 20))
        serialNoL.font = UIFont.systemFont(ofSize: 14)
        serialNoL.textColor = .black
        serialNoL.textAlignment = .center
        serialNoL.text = "Nomor Lisensi：12345678"
        upV.addSubview(serialNoL)
        
        dateL = UILabel.init(frame: CGRect.init(x: 30, y: 120, width: boxWid-60, height: 20))
        dateL.font = UIFont.systemFont(ofSize: 14)
        dateL.textColor = .black
        dateL.textAlignment = .center
        dateL.text = "Belaku s/d：29 Desember 2029"
        upV.addSubview(dateL)
        
        promiseL = UILabel.init(frame: CGRect.init(x: 30, y: 145, width: boxWid-60, height: 20))
        promiseL.font = UIFont.systemFont(ofSize: 14)
        promiseL.textColor = .black
        promiseL.textAlignment = .center
        promiseL.text = "Bank Penjamin：bank bank"
        upV.addSubview(promiseL)
        
        let img = UIImageView.init(frame: CGRect.init(x: 15, y: 180, width: 20, height: 20))
        img.image = UIImage.init(named: "location_on")
        img.contentMode = .scaleAspectFit
        upV.addSubview(img)
        
        addressL = UILabel.init(frame: CGRect.init(x: 40, y: 170, width: boxWid-80, height: 40))
        addressL.font = UIFont.systemFont(ofSize: 14)
        addressL.textColor = .black
        addressL.adjustsFontSizeToFitWidth = true
        addressL.textAlignment = .center
        addressL.numberOfLines = 2
        addressL.text = "4F.,No. 501, Sec. 6 Nanjing E. Rd., Neihu Dist., Taipei City 114057, Taiwan (R.O.C.)"
        upV.addSubview(addressL)
        
        phoneL = UILabel.init(frame: CGRect.init(x: 40, y: 215, width: boxWid-80, height: 20))
        phoneL.font = UIFont.systemFont(ofSize: 14)
        phoneL.textColor = .black
        phoneL.textAlignment = .center
        phoneL.text = ""
        upV.addSubview(phoneL)
        
        phoneimage = UIImageView.init(frame: CGRect.init(x: 15, y: 212.5, width: 25, height: 25))
        phoneimage.center = CGPoint.init(x: phoneL.frame.origin.x - 20, y: phoneL.center.y)
        phoneimage.image = UIImage.init(named: "black_phone")
        phoneimage.contentMode = .scaleAspectFit
        upV.addSubview(phoneimage)
        
        let downV = UIView.init(frame: CGRect.init(x: 10, y: scrollY, width: boxWid, height: downHeight))
        downV.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.7)
        downV.layer.cornerRadius = 10
        downV.clipsToBounds = true
        scrollV.addSubview(downV)
        
        let introL = UILabel.init(frame: CGRect.init(x: 30, y: 8, width: boxWid-60, height: 20))
        introL.font = UIFont.boldSystemFont(ofSize: 14)
        introL.textColor = .black
        introL.textAlignment = .center
        introL.text = "Current Exchange Rate" //"Kurs Saat Ini"
        downV.addSubview(introL)
        
        let arrowL = UILabel.init(frame: CGRect.init(x: 30, y: 35, width: boxWid-60, height: 20))
        arrowL.font = UIFont.boldSystemFont(ofSize: 14)
        arrowL.textColor = Color_Gradient_Right
        arrowL.textAlignment = .center
        arrowL.text = "→"
        downV.addSubview(arrowL)
        
        let taiflagImgV = UIImageView.init(frame: CGRect.init(x: boxWid/2 - 35, y: 35, width: 20, height: 20))
        taiflagImgV.image = UIImage.init(named: "taiwan")
        taiflagImgV.contentMode = .scaleAspectFit
        downV.addSubview(taiflagImgV)
        
        let indoflagImgV = UIImageView.init(frame: CGRect.init(x: boxWid/2 + 15, y: 35, width: 20, height: 20))
        indoflagImgV.image = UIImage.init(named: "philippines")
        indoflagImgV.contentMode = .scaleAspectFit
        downV.addSubview(indoflagImgV)
        
        transferValue = UILabel.init(frame: CGRect.init(x: 30, y: 60, width: boxWid-60, height: 50))
        transferValue.font = UIFont.boldSystemFont(ofSize: 45)
        transferValue.textColor = Color_Gradient_Right
        transferValue.textAlignment = .center
        transferValue.text = ""
        downV.addSubview(transferValue)
        
        let lineV = UIView.init(frame: CGRect.init(x: 15, y: 110, width: boxWid-30, height: 0.5))
        lineV.backgroundColor = .black
        downV.addSubview(lineV)
        
        bankNameL = UILabel.init(frame: CGRect.init(x: 10, y: lineV.frame.origin.y, width: boxWid-20, height: downV.frame.height - lineV.frame.origin.y))
        bankNameL.font = UIFont.systemFont(ofSize: 14)
        bankNameL.textColor = .black
        bankNameL.numberOfLines = 0
        bankNameL.textAlignment = .center
        bankNameL.adjustsFontSizeToFitWidth = true
        bankNameL.text = ""
        downV.addSubview(bankNameL)
        
        scrollY += downHeight + 10
        
        upV.frame = CGRect.init(x: 10, y: scrollY, width: self.frame.width-20, height: upHeight)
        scrollV.addSubview(upV)
        scrollY += upHeight + 15
        
        let nextBtn = UIButton.init(frame: CGRect.init(x: self.frame.width/2-100, y: scrollY, width: 180, height: 45))
        scrollV.addSubview(nextBtn)
        nextBtn.layer.cornerRadius = 10
        nextBtn.backgroundColor = .clear
        nextBtn.layer.backgroundColor = UIColor.white.cgColor
        nextBtn.setTitleColor(Color_Gradient_Left, for: .normal)
        nextBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        nextBtn.setTitle(NSLocalizedString("pic take", comment: ""), for: .normal)
        nextBtn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        scrollY += 55
        
        let imgStr:[String] = ["711","fanilymart","okmart","hilife"]
        let flagWid:CGFloat = 25
        for i in 0..<imgStr.count {
            let imgV = UIImageView.init(frame: CGRect.init(x: self.frame.width/2 - 2*flagWid - 9 + CGFloat(i)*(flagWid+6), y: scrollY, width: flagWid, height: flagWid))
            scrollV.addSubview(imgV)
            imgV.image = UIImage.init(named: imgStr[i])
        }
        
        scrollV.contentSize = CGSize.init(width: self.frame.width, height: scrollY)
    }
    
    @objc func nextAction() {
        removeNow()
    }
    
    func initAll() {
        if AppDelegate.shared().getInfoStrAry.count >= 10 {
            companyL.text = AppDelegate.shared().getInfoStrAry[0]
            serialNoL.text = "Business Permit No.：" + AppDelegate.shared().getInfoStrAry[2]
            dateL.text = AppDelegate.shared().getInfoStrAry[3]
            promiseL.text = "Performance Guarantee：" + AppDelegate.shared().getInfoStrAry[4]
            addressL.text = AppDelegate.shared().getInfoStrAry[8]
            transferValue.text = AppDelegate.shared().getInfoStrAry[5]
            phoneL.text = AppDelegate.shared().getInfoStrAry[1]
            
            let x = phoneL.center.x
            phoneL.sizeToFit()
            phoneL.center = CGPoint.init(x: x, y: phoneL.center.y)
            phoneimage.center = CGPoint.init(x: phoneL.frame.origin.x - 20, y: phoneL.center.y)
            bankNameL.text = "The exchange rate of USD to NTD referred to \(AppDelegate.shared().getInfoStrAry[6])\nThe exchange rate of USD to PESO referred to \(AppDelegate.shared().getInfoStrAry[7])"
            
            //companyL.text = AppDelegate.shared().getInfoStrAry[7]
            //companyL.text = AppDelegate.shared().getInfoStrAry[8]
            //companyL.text = AppDelegate.shared().getInfoStrAry[9]
        }
        
    }
    
    func removeNow() {
        AppDelegate.shared().showFloatingBtn()
        AppDelegate.shared().hideCompany()
    }

    //MARK: - API
    func getInfo() {
        let timeStamp = "\(Date().timeIntervalSince1970)"
        let straes = timeStamp.AES128encrypt(aes_key: AES28Key)
        //Dlog("aes encrypt = \(straes)")
        
        let parameters:Parameters = ["token":straes, "timestamp":timeStamp]
        let headers: HTTPHeaders = [:]
        
        Dlog("parameters=\(parameters)")
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_GetInfo;
        AppDelegate.shared().alamofireManagerWithTimeout.requestWithoutCache(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in
                AppDelegate.shared().removeLoadingView()
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling on \(todoEndpoint)")
                    print(response.result.error!)
                    //AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("API Timeout", comment: ""))
                    return
                }
                
                let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                Dlog("getInfo responseStr = \(responseStr ?? "")")
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    self.initAll()
                } else if result == ResponseState.failed {
                    //AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
  
  // MARK: - WKNavigationDelegate
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
      guard let url = navigationAction.request.url else {
          decisionHandler(.allow)
          return
      }
      let scheme = url.scheme?.lowercased() ?? ""
      // Only intercept user-tapped HTTP/HTTPS links; allow initial load and programmatic navigations.
      if (scheme == "http" || scheme == "https"),
         navigationAction.navigationType == .linkActivated {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
          decisionHandler(.cancel)
          return
      }
      decisionHandler(.allow)
  }
}
