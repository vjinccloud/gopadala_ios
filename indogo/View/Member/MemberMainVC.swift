//
//  MemberMainVC.swift
//  indogo
//
//  Created by mac on 2020/8/10.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MemberMainVC: UIViewController {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var memberImgV: UIImageView!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var phoneL: UILabel!
    @IBOutlet weak var pointL: UILabel!
    @IBOutlet weak var reciterL: UILabel!
    @IBOutlet weak var transactionL: UILabel!
    @IBOutlet weak var callL: UILabel!
    @IBOutlet weak var aboutL: UILabel!
    @IBOutlet weak var termsL: UILabel!
    @IBOutlet weak var faqL: UILabel!
    @IBOutlet weak var logoutL: UILabel!
    @IBOutlet weak var changePhoneL: UILabel!
    @IBOutlet weak var foiL: UILabel!
    @IBOutlet weak var eRecieptL: UILabel!
    @IBOutlet weak var deleteL: UILabel!
    
    var showDeleteContainer:UIView!
    var loadOnce = false
    
    //MARK: - API
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
                    AppDelegate.shared().pointRootShowHistory = true
                    AppDelegate.shared().changeRootOfFunc(Type: .sharing)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func deleteApply() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken,"arc_no":AppDelegate.shared().getRemeberedAarcNo(), "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_MemberDelete;
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
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //MARK: - Button-Action
    @IBAction func editAction(_ sender: Any) {
        //202304 改成先做，後面再驗證
        /*
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "MemberChangeDataIntroVC") as? MemberChangeDataIntroVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
        */
        
        //改成先警語
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "MemberEditVC") as? MemberEditVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func changePhoneAction(_ sender: Any) {
        AppDelegate.shared().forgotPassTempMemID = AppDelegate.shared().getRemeberedAarcNo()
        AppDelegate.shared().forgotPassTempPhone = AppDelegate.shared().memberData["app_phone_no"] ?? ""
        
        let nextVC = UIStoryboard(name: "Register", bundle: nil).instantiateViewController(withIdentifier: "MemberChangePhoneIntroVC") as? MemberChangePhoneIntroVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func pointAction(_ sender: Any) {
        getPointHistory()
    }
    
    @IBAction func reciteAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "RecipientListVC") as? RecipientListVC
        nextVC!.canSelectForTransfer = false
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func tansactionAction(_ sender: Any) {
        AppDelegate.shared().changeRootOfFunc(Type: .transState)
    }
    
    @IBAction func callAction(_ sender: Any) {
        let phone = "0287928773"
        let cleanPhoneNumber = phone.components(separatedBy: CharacterSet.decimalDigits.inverted).joined(separator: "")
        let urlString:String = "tel://\(cleanPhoneNumber)"

        if let phoneCallURL = URL(string: urlString) {
            if (UIApplication.shared.canOpenURL(phoneCallURL)) {
                UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
        /*
        let url = URL(string: "telprompt:0287928773")
        if UIApplication.shared.canOpenURL(url!) {
            //UIApplication.shared.open(url!)
            UIApplication.shared.open(url!, options: [:], completionHandler:
                 nil)
        }*/
    }
    
    @IBAction func foiAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "SpecialPageVC") as? SpecialPageVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func aboutAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "PureWebVC") as? PureWebVC
        let urlStr = "https://prod.indogo.com.tw/tomcat_images/ABOUT_US-01.html"
        //"https://prod.indogo.link/tomcat_images/ABOUT_US-01.html"
        nextVC?.setTitleAndCallURL(URL: urlStr, Title: NSLocalizedString("Profile Main About", comment: ""))
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func termsAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "MemberUseAgreementVC") as? MemberUseAgreementVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func faqAction(_ sender: Any) {
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "PureWebVC") as? PureWebVC
        nextVC?.setTitleAndCallURL(URL: "https://prod.indogo.com.tw/tomcat_images/REMIT_INFO.html", Title: NSLocalizedString("Profile Main Faq", comment: ""))
        self.navigationController?.pushViewController(nextVC!, animated: true)
        
    }
    
    @IBAction func logoutAction(_ sender: Any) {
        AppDelegate.shared().userLogout()
        AppDelegate.shared().changeRootOfFunc(Type: .main)
    }
    
    @IBAction func eRecieptAction(_ sender: Any) {
        let urlPath = "https://invoice.indogo.com.tw/alist?arc=\(AppDelegate.shared().getRemeberedAccount())&pass=\(String(describing: AppDelegate.shared().getRemeberedAccount().base64EncodedString()!))"
        Dlog("url = \(urlPath)")
        /*
        let urlString:String = urlPath

        if let phoneCallURL = URL(string: urlString) {
            if (UIApplication.shared.canOpenURL(phoneCallURL)) {
                UIApplication.shared.open(phoneCallURL, options: [:], completionHandler: nil)
            }
        }
        
        return
         */
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "PureWebVC") as? PureWebVC
        nextVC?.setTitleAndCallURL(URL: urlPath, Title: NSLocalizedString("Profile Main About", comment: ""))
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameL.text = AppDelegate.shared().memberData["member_name"]
        phoneL.text = AppDelegate.shared().memberData["app_phone_no"]
        backL.text = NSLocalizedString("Profile Main Title", comment: "")
        changePhoneL.text = NSLocalizedString("Profile Main ChangePhone", comment: "")
        pointL.text = NSLocalizedString("Profile Main Point", comment: "")
        reciterL.text = NSLocalizedString("Profile Main Reciter", comment: "")
        transactionL.text = NSLocalizedString("Profile Main Transaction", comment: "")
        callL.text = NSLocalizedString("Profile Main Call", comment: "")
        aboutL.text = NSLocalizedString("Profile Main About", comment: "")
        termsL.text = NSLocalizedString("Profile Main Terms", comment: "")
        faqL.text = NSLocalizedString("Profile Main Faq", comment: "")
        logoutL.text = NSLocalizedString("Profile Main Logout", comment: "")
        foiL.text = NSLocalizedString("debate title", comment: "")
        memberImgV.contentMode = .scaleAspectFill
        memberImgV.layer.cornerRadius = memberImgV.frame.size.height/2
        memberImgV.clipsToBounds = true
        
        memberImgV.isHidden = true
        
        eRecieptL.text = NSLocalizedString("ereciept", comment: "")
        
        deleteL.translatesAutoresizingMaskIntoConstraints = false
        deleteL.adjustsFontSizeToFitWidth = true
        
        // 創建帶有屬性的文字
        let attributedText = NSMutableAttributedString(string: "Jika Anda ingin menghapus akun silahkan tekan disini")
        
        // 設置「tekan disini」的底線和顏色
        attributedText.addAttribute(.foregroundColor, value: Color_Purple, range: NSRange(location: 40, length: 12)) // 36 是「tekan disini」的開始索引，11 是它的長度
        attributedText.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 40, length: 12))
        attributedText.addAttribute(.underlineColor, value: Color_Purple, range: NSRange(location: 40, length: 12)) // 設置底線顏色為黑色
                
        // 設置 UILabel 的屬性文字
        deleteL.attributedText = attributedText
        
        // 設置 UILabel 可以點擊
        deleteL.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(labelTapped))
        deleteL.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func labelTapped() {
        // 在這裡處理點擊事件，您可以導航到相關頁面或執行其他操作
        showDeleteAlertView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        memberImgV.image = AppDelegate.shared().getIconImage()
        
        if loadOnce {
            AppDelegate.shared().showTopButton()
            return
        }
        
        loadOnce = true
        
        //頂部兩個按鈕
        AppDelegate.shared().topMargin = self.view.safeAreaInsets.top
        AppDelegate.shared().addTopButton()
        
        AppDelegate.shared().nowBottomMenuType = .profile
        AppDelegate.shared().bottomMenu.paintMenu()
        
    }
    
    //自定義 alert
    func showDeleteAlertView() {
        let title = "Yakin mau hapus akun Anda?"
        let msg = "Tekan HAPUS untuk pengajuan penghapusan akun Anda\n\nAkun yang telah dihapus tidak dapat digunakan kembali"
        let confirmstr = "BATAL"
        let cancelstr = "HAPUS"
        let window = UIApplication.shared.keyWindow
        
        showDeleteContainer = UIView(frame: CGRect.init(x: 0, y: 0, width: window!.bounds.width, height: window!.bounds.height))
        window!.addSubview(showDeleteContainer);
        showDeleteContainer.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
        
        let titelL = UILabel.init(frame: CGRect.init(x: 25, y: 20, width: window!.bounds.width - 100, height: 50))
        titelL.text = title
        titelL.font = UIFont.boldSystemFont(ofSize: 16)
        titelL.textAlignment = .center
        titelL.numberOfLines = 0
        
        //決定字串高度
        let strL = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: window!.bounds.width - 100, height: 10))
        strL.text = msg
        strL.font = UIFont.systemFont(ofSize: 14)
        let height = strL.requiredHeight
        let boxHeight = 180 + height
        
        let alertViewBg = UIView.init(frame: CGRect.init(x: 35, y: window!.bounds.height/2 - 20 - boxHeight/2, width: window!.bounds.width - 70, height: boxHeight))
        showDeleteContainer.addSubview(alertViewBg)
        
        alertViewBg.addSubview(titelL)
        
        alertViewBg.backgroundColor = .white
        alertViewBg.layer.cornerRadius = 10
        alertViewBg.clipsToBounds = true
        
        //字
        strL.frame = CGRect.init(x: 25, y: 60+20, width: alertViewBg.frame.size.width - 50, height: height)
        strL.textAlignment = .center
        strL.numberOfLines = 0
        alertViewBg.addSubview(strL)
        
        //按鈕
        let btn = UIButton.init(frame: CGRect.init(x: alertViewBg.frame.size.width * 0.1, y: boxHeight - 60, width: alertViewBg.frame.size.width * 0.4, height: 35))
        btn.layer.cornerRadius = btn.frame.size.height/2
        btn.layer.borderColor = Color_Main_Red.cgColor
        btn.layer.borderWidth = 0.5
        btn.addTarget(self, action: #selector(removeDeleteAlert), for: .touchUpInside)
        btn.setTitle(confirmstr, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.addGradienOfIndoGo()
        alertViewBg.addSubview(btn)
        btn.center = CGPoint.init(x: alertViewBg.frame.size.width * 0.25, y: btn.center.y)
        
        let cancelbtn = UIButton.init(frame: CGRect.init(x: alertViewBg.frame.size.width * 0.6, y: boxHeight - 60, width: alertViewBg.frame.size.width * 0.4, height: 35))
        cancelbtn.layer.cornerRadius = btn.frame.size.height/2
        cancelbtn.layer.borderColor = Color_Purple.cgColor
        cancelbtn.layer.borderWidth = 1
        cancelbtn.setTitleColor(Color_Purple, for: .normal)
        cancelbtn.addTarget(self, action: #selector(sendDeleteAction), for: .touchUpInside)
        cancelbtn.setTitle(cancelstr, for: .normal)
        alertViewBg.addSubview(cancelbtn)
        cancelbtn.center = CGPoint.init(x: alertViewBg.frame.size.width * 0.75, y: btn.center.y)
    }
    
    @objc func sendDeleteAction() {
        showDeleteContainer.removeFromSuperview()
        deleteApply()
    }
    
    @objc func removeDeleteAlert() {
        showDeleteContainer.removeFromSuperview()
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
