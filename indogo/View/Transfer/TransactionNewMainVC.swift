//
//  TransactionNewMainVC.swift
//  indogo
//
//  Created by mac on 2021/6/4.
//  Copyright © 2021 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import WebKit

enum TansactionNewMainType {
    case seven
    case ok
    case family
    case hilife
    case bank
}

class TransactionNewMainVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var paymentInfoL: UILabel!
    @IBOutlet weak var totalTWDL: UILabel!
    @IBOutlet weak var myTable: UITableView!
    @IBOutlet weak var payIntroL: UILabel!
    
    let pngAry:[String] = ["new711","newfamily","newok","newhilife","newbank"]
    let nameAry:[String] = [NSLocalizedString("Transfer New Main 711", comment: ""),NSLocalizedString("Transfer New Main family", comment: ""),NSLocalizedString("Transfer New Main ok", comment: ""),NSLocalizedString("Transfer New Main hilife", comment: ""),NSLocalizedString("Transfer New Main bank", comment: "")]
    
    var loadOnce = false
    var transferStateObj:TransferStateObj!
    var orderCheckStateObj:TransferOrderCheckObj!
    var payment_info:String = ""
    var chosedStyle:StoreType!
    
    var transactionNewTypeAry:[TansactionNewMainType] = [.seven,.family,.ok,.hilife,.bank]
    
    //MARK: - API
    public func getBarCode() {
        
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "payment_info":payment_info, "mode":2, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        AppDelegate.shared().addLoadingView()
        
        var todoEndpoint: String = API_BarCode_711;
        
        if chosedStyle == StoreType.sevenEleven {
            todoEndpoint = API_BarCode_711
        } else if chosedStyle == StoreType.familymart {
            todoEndpoint = API_BarCode_fami
        } else if chosedStyle == StoreType.ok {
            todoEndpoint = API_BarCode_ok
        } else if chosedStyle == StoreType.hiLife {
            todoEndpoint = API_BarCode_hilife
        }
        
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
                Dlog("responseStr(\(todoEndpoint) = \(responseStr ?? "")")
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "TransactionPayVC") as? TransactionPayVC
                    nextVC?.payment_info = self.payment_info
                    nextVC?.transferStateObj = self.transferStateObj
                    nextVC?.orderCheckStateObj = self.orderCheckStateObj
                    nextVC?.chosedStyle = self.chosedStyle
                    self.navigationController?.pushViewController(nextVC!, animated: true)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    public func getBankCode() {
        
        let parameters:Parameters = ["app_token":AppDelegate.shared().sessionToken, "payment_info":payment_info, "mode":2, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_GetBankCode;
        
        Dlog("todoEndpoint=\(todoEndpoint)\nparameters=\(parameters)")
        
        AppDelegate.shared().alamofireManagerWithTimeout.requestWithoutCache(todoEndpoint,method: .post,parameters: parameters,encoding: JSONEncoding.default, headers:headers)
            .responseJSON { response in
                AppDelegate.shared().removeLoadingView()
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling on \(todoEndpoint)")
                    print(response.result.error!)
                    return
                }
                
                do {
                    
                    let json = try JSON(data: response.data!)
                    Dlog("todoEndpoint=\(todoEndpoint)\njson=\(json)")
                    
                    if json["status"] != JSON.null {
                        if json["status"].intValue == 1 {
                            let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "TransactionBankVC") as? TransactionBankVC
                            nextVC?.payment_info = self.payment_info
                            nextVC?.transferStateObj = self.transferStateObj
                            nextVC?.bankInfoJSON = json["data"]
                            self.navigationController?.pushViewController(nextVC!, animated: true)
                        } else {
                            AppDelegate.shared().showAlertWithWindow(self, Message: json["errMsg"].stringValue)
                            return
                        }
                    } else {
                        
                    }
                    
                    
                } catch {
                    AppDelegate.shared().showAlertWithWindow(self, Message: Lang_APIDecodeFail)
                }
        }
    }
    
    //MARK: - Button-Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 5
     }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 92
    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PayNewMainTableViewCell", for: indexPath) as! PayNewMainTableViewCell
        cell.logoImg.image = UIImage.init(named: pngAry[indexPath.row])
        cell.payTitleL.text = nameAry[indexPath.row]
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
     }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let types = transactionNewTypeAry[indexPath.row]
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "TransactionResultVC") as? TransactionResultVC
        nextVC?.payment_info = payment_info
        switch types {
        case .seven:
            chosedStyle = .sevenEleven
            getBarCode()
            return
        case .ok:
            nextVC?.showPhoto(Type: .ok)
        case .family:
            chosedStyle = .familymart
            getBarCode()
            return
        case .hilife:
            chosedStyle = .hiLife
            getBarCode()
            return
        case .bank:
            goBank()
            return
        }
        
        nextVC?.transferStateObj = transferStateObj
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    func goBank() {
        getBankCode()
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        AppDelegate.shared().hideTopButton()
        backL.text = NSLocalizedString("Transfer PayStep Title", comment: "")
        payIntroL.text = NSLocalizedString("Transfer PayStep Intro", comment: "")
        paymentInfoL.text = payment_info.separateSpecialForIndoGo()
        totalTWDL.text = "Total TWD \(transferStateObj.total.stringToIntDecimalString())"
        
        let nib = UINib(nibName: "PayNewMainTableViewCell", bundle: nil)
        myTable.register(nib, forCellReuseIdentifier: "PayNewMainTableViewCell")
        myTable.bounces = false
        myTable.delegate = self
        myTable.dataSource = self
        myTable.backgroundColor = .clear
        myTable.separatorStyle = .none
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if loadOnce {
            return
        }
        
        loadOnce = true
        //reloadData()
        
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
