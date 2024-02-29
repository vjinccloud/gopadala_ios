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

class CompanyV: UIView {
    
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
        
        var startY:CGFloat = 20 + AppTopBarHeight
        let scrollV:UIScrollView = UIScrollView.init(frame: CGRect.init(x: 0, y: startY, width: self.frame.width, height: self.frame.height - AppBottomBarHeight - 80 - startY))
        self.addSubview(scrollV)
        var scrollY:CGFloat = 20
        let upHeight:CGFloat = 290
        let downHeight:CGFloat = 210
        let boxWid:CGFloat = self.frame.width - 20
        let upV = UIView.init(frame: CGRect.init(x: 10, y: scrollY, width: boxWid, height: upHeight))
        upV.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.7)
        upV.layer.cornerRadius = 10
        upV.clipsToBounds = true
        scrollV.addSubview(upV)
        
        let upLogo = UIImageView.init(frame: CGRect.init(x: 50, y: 35, width: boxWid-100, height: 50))
        upLogo.image = UIImage.init(named: "indogo_logo")
        upLogo.contentMode = .scaleAspectFit
        upV.addSubview(upLogo)
        
        companyL = UILabel.init(frame: CGRect.init(x: 30, y: 90, width: boxWid-60, height: 50))
        companyL.font = UIFont.systemFont(ofSize: 20)
        companyL.textColor = Color_Gradient_Left
        companyL.numberOfLines = 2
        companyL.textAlignment = .center
        companyL.text = "Digital Idea Multi-media, co.ltd\n數位至匯股份有限公司"
        upV.addSubview(companyL)
        
        serialNoL = UILabel.init(frame: CGRect.init(x: 30, y: 143, width: boxWid-60, height: 20))
        serialNoL.font = UIFont.systemFont(ofSize: 14)
        serialNoL.textColor = .black
        serialNoL.textAlignment = .center
        serialNoL.text = "Nomor Lisensi：12345678"
        upV.addSubview(serialNoL)
        
        dateL = UILabel.init(frame: CGRect.init(x: 30, y: 160, width: boxWid-60, height: 20))
        dateL.font = UIFont.systemFont(ofSize: 14)
        dateL.textColor = .black
        dateL.textAlignment = .center
        dateL.text = "Belaku s/d：29 Desember 2029"
        upV.addSubview(dateL)
        
        promiseL = UILabel.init(frame: CGRect.init(x: 30, y: 185, width: boxWid-60, height: 20))
        promiseL.font = UIFont.systemFont(ofSize: 14)
        promiseL.textColor = .black
        promiseL.textAlignment = .center
        promiseL.text = "Bank Penjamin：bank bank"
        upV.addSubview(promiseL)
        
        let img = UIImageView.init(frame: CGRect.init(x: 15, y: 220, width: 20, height: 20))
        img.image = UIImage.init(named: "location_on")
        img.contentMode = .scaleAspectFit
        upV.addSubview(img)
        
        addressL = UILabel.init(frame: CGRect.init(x: 40, y: 210, width: boxWid-80, height: 40))
        addressL.font = UIFont.systemFont(ofSize: 14)
        addressL.textColor = .black
        addressL.adjustsFontSizeToFitWidth = true
        addressL.textAlignment = .center
        addressL.numberOfLines = 2
        addressL.text = "4F.,No. 501, Sec. 6 Nanjing E. Rd., Neihu Dist., Taipei City 114057, Taiwan (R.O.C.)"
        upV.addSubview(addressL)
        
        phoneL = UILabel.init(frame: CGRect.init(x: 40, y: 255, width: boxWid-80, height: 20))
        phoneL.font = UIFont.systemFont(ofSize: 14)
        phoneL.textColor = .black
        phoneL.textAlignment = .center
        phoneL.text = ""
        upV.addSubview(phoneL)
        
        phoneimage = UIImageView.init(frame: CGRect.init(x: 15, y: 252.5, width: 25, height: 25))
        phoneimage.center = CGPoint.init(x: phoneL.frame.origin.x - 20, y: phoneL.center.y)
        phoneimage.image = UIImage.init(named: "black_phone")
        phoneimage.contentMode = .scaleAspectFit
        upV.addSubview(phoneimage)
        
        scrollY += upHeight + 15
        
        let downV = UIView.init(frame: CGRect.init(x: 10, y: scrollY, width: boxWid, height: downHeight))
        downV.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 0.7)
        downV.layer.cornerRadius = 10
        downV.clipsToBounds = true
        scrollV.addSubview(downV)
        
        let introL = UILabel.init(frame: CGRect.init(x: 30, y: 8, width: boxWid-60, height: 20))
        introL.font = UIFont.boldSystemFont(ofSize: 14)
        introL.textColor = .black
        introL.textAlignment = .center
        introL.text = "Kurs" //"Kurs Saat Ini"
        downV.addSubview(introL)
        
        let arrowL = UILabel.init(frame: CGRect.init(x: 30, y: 35, width: boxWid-60, height: 20))
        arrowL.font = UIFont.boldSystemFont(ofSize: 14)
        arrowL.textColor = Color_Gradient_Left
        arrowL.textAlignment = .center
        arrowL.text = "→"
        downV.addSubview(arrowL)
        
        let taiflagImgV = UIImageView.init(frame: CGRect.init(x: boxWid/2 - 35, y: 35, width: 20, height: 20))
        taiflagImgV.image = UIImage.init(named: "taiwan")
        taiflagImgV.contentMode = .scaleAspectFit
        downV.addSubview(taiflagImgV)
        
        let indoflagImgV = UIImageView.init(frame: CGRect.init(x: boxWid/2 + 15, y: 35, width: 20, height: 20))
        indoflagImgV.image = UIImage.init(named: "indonesia")
        indoflagImgV.contentMode = .scaleAspectFit
        downV.addSubview(indoflagImgV)
        
        transferValue = UILabel.init(frame: CGRect.init(x: 30, y: 60, width: boxWid-60, height: 70))
        transferValue.font = UIFont.boldSystemFont(ofSize: 60)
        transferValue.textColor = Color_Gradient_Left
        transferValue.textAlignment = .center
        transferValue.text = ""
        downV.addSubview(transferValue)
        
        let lineV = UIView.init(frame: CGRect.init(x: 15, y: 130, width: boxWid-30, height: 0.5))
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
        
        scrollY += downHeight + 85
        scrollV.contentSize = CGSize.init(width: self.frame.width, height: scrollY)
        
        startY = self.frame.height - AppBottomBarHeight - 50
        let imgStr:[String] = ["711","fanilymart","okmart","hilife"]
        let flagWid:CGFloat = 25
        for i in 0..<imgStr.count {
            let imgV = UIImageView.init(frame: CGRect.init(x: self.frame.width/2 - 2*flagWid - 9 + CGFloat(i)*(flagWid+6), y: startY, width: flagWid, height: flagWid))
            self.addSubview(imgV)
            imgV.image = UIImage.init(named: imgStr[i])
        }
        
        startY -= (10 + 50)
        
        let nextBtn = UIButton.init(frame: CGRect.init(x: self.frame.width/2-100, y: startY, width: 180, height: 45))
        self.addSubview(nextBtn)
        nextBtn.layer.cornerRadius = 10
        nextBtn.backgroundColor = .clear
        nextBtn.layer.backgroundColor = UIColor.white.cgColor
        nextBtn.setTitleColor(Color_Gradient_Left, for: .normal)
        nextBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        nextBtn.setTitle(NSLocalizedString("pic take", comment: ""), for: .normal)
        nextBtn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
    }
    
    @objc func nextAction() {
        removeNow()
    }
    
    func initAll() {
        if AppDelegate.shared().getInfoStrAry.count >= 10 {
            companyL.text = AppDelegate.shared().getInfoStrAry[0]
            serialNoL.text = "Nomor Lisensi：" + AppDelegate.shared().getInfoStrAry[2]
            dateL.text = AppDelegate.shared().getInfoStrAry[3]
            promiseL.text = "Bank Penjamin：" + AppDelegate.shared().getInfoStrAry[4]
            addressL.text = AppDelegate.shared().getInfoStrAry[8]
            transferValue.text = AppDelegate.shared().getInfoStrAry[5]
            phoneL.text = AppDelegate.shared().getInfoStrAry[1]
            
            let x = phoneL.center.x
            phoneL.sizeToFit()
            phoneL.center = CGPoint.init(x: x, y: phoneL.center.y)
            phoneimage.center = CGPoint.init(x: phoneL.frame.origin.x - 20, y: phoneL.center.y)
            bankNameL.text = "Nilai Tukar IDR Mengacu Pada\n Nilai Tukar TWD ke USD melalui \(AppDelegate.shared().getInfoStrAry[6])\nSedangkan Nilai Tukar USD ke IDR Melalui \(AppDelegate.shared().getInfoStrAry[7])"
            
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
}
