//
//  TransactionInfoConfirmVC.swift
//  indogo
//
//  Created by mac on 2020/9/3.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import KingfisherWebP

class TransactionInfoConfirmVC: UIViewController {

    @IBOutlet weak var backL: UILabel!
    
    @IBOutlet weak var backgV: UIView!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var iconImgV: UIImageView!
    @IBOutlet weak var accountL: UILabel!
    @IBOutlet weak var twdL: UILabel!
    @IBOutlet weak var twdVL: UILabel!
    @IBOutlet weak var feeL: UILabel!
    @IBOutlet weak var feeVL: UILabel!
    @IBOutlet weak var usePointL: UILabel!
    @IBOutlet weak var usePointVL: UILabel!
    @IBOutlet weak var totalL: UILabel!
    @IBOutlet weak var totalVL: UILabel!
    
    @IBOutlet weak var recipientIcon: UIImageView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var recipient_titleL: UILabel!
    @IBOutlet weak var recipient_phoneL: UILabel!
    
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
                    self.recalculateTargetMoneyAndGoNext()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    public func createTransaction() {
        let obj = AppDelegate.shared().transactionObj
        let recipient_id = AppDelegate.shared().transactionObj.recipientObj.recipient_id!
        
        var parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "amount_ntd":obj.ntdValue,"kurs_lm_time":AppDelegate.shared().memberData["kurs_lm_time"]!, "service_charge":obj.feeValue, "purposes_id": obj.purposes_id, "total_payment":obj.totalNtdValue, "transfer_idr":
            obj.targetValue, "recipient_id":recipient_id, "pin_code_mode":PinCodeMode, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        
        if obj.usePoint == 0 {
            parameters["use_remit_point"] = 0
        } else {
            parameters["use_remit_point"] = 1
            parameters["use_points"] = obj.usePoint
        }
        
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        var todoEndpoint: String = API_TransactionCreate;
        if AppDelegate.shared().discountForTransfer != "" {
            todoEndpoint = API_TransactionCreateV2
            parameters["discount_code"] = AppDelegate.shared().discountCode
            parameters["discount_amt"] = AppDelegate.shared().discountForTransfer
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
                Dlog("responseStr = \(responseStr ?? "")")
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    self.getNextStep()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    public func createTransactionOther() {
        let obj = AppDelegate.shared().transactionObj
        let recipient_id = AppDelegate.shared().transactionObj.recipientObj.recipient_id!
        
        var parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "amount_ntd":obj.ntdValue,"kurs_lm_time":AppDelegate.shared().memberData["kurs_lm_time"]!, "service_charge":obj.feeValue, "total_payment":obj.totalNtdValue, "transfer_idr":
            obj.targetValue, "recipient_id":recipient_id, "purposes_id": obj.purposes_id, "pin_code_mode":1, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        
        if obj.usePoint == 0 {
            parameters["use_remit_point"] = 0
        } else {
            parameters["use_remit_point"] = 1
            parameters["use_points"] = obj.usePoint
        }
        
        if AppDelegate.shared().tansferMethod == .Cash {
            parameters["service_code"] = "NTP"
        } else if AppDelegate.shared().tansferMethod == .Pag {
            parameters["service_code"] = "PGB"
            parameters["payment_code"] = obj.other_payment_code
            parameters["paymenet_code_2"] = obj.other_payment_code2
            parameters["PGB_ym_start"] = obj.other_ym_start
            parameters["PGB_ym_end"] = obj.other_ym_end
            parameters["transfer_idr_PGB"] = obj.other_transfer_idr
            parameters["transfer_idr"] = obj.targetValue
            
        } else if AppDelegate.shared().tansferMethod == .SSS {
            parameters["service_code"] = "SSS"
            if !obj.isSSSContribution {
                parameters["transfer_idr_SSS"] = obj.other_transfer_idr
            } else {
                parameters["transfer_idr_SSS"] = obj.other_transfer_idr
            }
            
            parameters["payment_code"] = obj.other_payment_code
            parameters["paymenet_code_2"] = obj.other_payment_code2
            parameters["SSS_ym_start"] = obj.other_ym_start
            parameters["SSS_ym_end"] = obj.other_ym_end
        } else if AppDelegate.shared().tansferMethod == .Health {
            parameters["service_code"] = "PHN"
            parameters["PHN_ym_start"] = obj.other_ym_start
            parameters["PHN_ym_end"] = obj.other_ym_end
            parameters["PHN_months"] = obj.other_PHN_months
            parameters["transfer_idr"] = obj.other_transfer_idr
            parameters["payment_code"] = obj.other_payment_code
            parameters["paymenet_code_2"] = obj.other_payment_code2
        }
        
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        var todoEndpoint: String = API_TransactionCreate_Other;
        /*
        if AppDelegate.shared().discountForTransfer != "" {
            todoEndpoint = API_TransactionCreate_OtherV2
            parameters["discount_code"] = AppDelegate.shared().discountCode
            parameters["discount_amt"] = AppDelegate.shared().discountForTransfer
        }*/
        
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
                    self.getNextStep()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func getNextStep() {
        let transferStateObj = TransferStateObj()
        let serchBankobj = UtilityTool().searchBankObj(BankName: AppDelegate.shared().transactionObj.recipientObj.bank_name!)
        
        transferStateObj.bank_code = serchBankobj.bank_code
        transferStateObj.to_acc = AppDelegate.shared().transactionObj.recipientObj.bank_acc
        transferStateObj.total = "\(AppDelegate.shared().transactionObj.totalNtdValue)"
        transferStateObj.transfer_amount_idr = "\(AppDelegate.shared().transactionObj.targetValue)"
            transferStateObj.recipient_name =  AppDelegate.shared().transactionObj.recipientObj.recipient_name
        
        //新的首頁
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "TransactionNewMainVC") as? TransactionNewMainVC
        //let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "TransactionResultVC") as? TransactionResultVC
        nextVC?.payment_info = AppDelegate.shared().tempTransactionResultObj.payment_info
        nextVC?.transferStateObj = transferStateObj
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        //202211改成增加一頁輸入密碼
        //又取消
        /*
        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginStep2VC") as? LoginStep2VC
        nextVC?.nextAction = .Transfer
        self.navigationController?.pushViewController(nextVC!, animated: true)
        */
        //再計算一次匯率
        callMemberData()
    }
    
    @IBAction func backAction(_ sender: Any) {
        //一律回想選擇畫面
        guard let viewControllers = self.navigationController?.viewControllers else {
            return
        }
        
        for firstViewController in viewControllers {
            if firstViewController is RecipientListVC {
                self.navigationController?.popToViewController(firstViewController, animated: true)
                break
            }
        }
        
        //self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - View-Life
    func recalculateTargetMoneyAndGoNext() {
        //202304 改成不重新計算
        /*
        let obj = AppDelegate.shared().transactionObj
        let kursValue = Double(AppDelegate.shared().memberData["kurs_value"]!)!
        AppDelegate.shared().transactionObj.targetValue = Int(ceil(Double(obj.ntdValue) * kursValue))
        */
        
        if AppDelegate.shared().tansferMethod == .Bank {
            createTransaction()
        } else {
            createTransactionOther()
        }
        
        /*
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "TransactionAgreeMentVC") as? TransactionAgreeMentVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
         */
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let obj = AppDelegate.shared().transactionObj
        
        // Do any additional setup after loading the view.
        backL.text = "Confirm Recipients"
        nameL.text = obj.recipientObj.recipient_name
        twdL.text = NSLocalizedString("Transfer Confirm TWD Title", comment: "")
        feeL.text = NSLocalizedString("Transfer Confirm Fee Title", comment: "")
        usePointL.text = NSLocalizedString("Transfer Confirm UsePoint Title", comment: "")
        totalL.text = NSLocalizedString("Transfer Confirm Total Title", comment: "")
        nameL.adjustsFontSizeToFitWidth = true
        nameL.textAlignment = .center
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.setTitle("SEND", for: .normal)
        nextBtn.addGradienOfIndoGo()
        backgV.layer.cornerRadius = 5
        
        var idstr = ""
        recipient_titleL.text = ""
        recipient_phoneL.text = obj.recipientObj.phone_no
        if AppDelegate.shared().tansferMethod == .Bank {
            idstr = obj.recipientObj.bank_acc
            recipient_titleL.text = obj.recipientObj.bank_acc
            var serchBankobj = UtilityTool().searchBankObj(BankName: obj.recipientObj.bank_name!)
            if obj.recipientObj.bank_name == "" {
                serchBankobj = UtilityTool().searchBankObj(BankCode: obj.recipientObj.bank_code!)
            } else {
                serchBankobj = UtilityTool().searchBankObj(BankName: obj.recipientObj.bank_name!)
            }
            
            let imgurl = serchBankobj.bank_photo!
            let urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
            iconImgV.kf.setImage(with: urlhaed)
            
        } else if AppDelegate.shared().tansferMethod == .Cash {
            idstr = obj.recipientObj.cash_pickup_name
            recipient_titleL.text = obj.recipientObj.passport_id
            //iconImgV.image = UIImage.init(named: "Cash Pick-up.png")
            recipientIcon.isHidden = true
            let url = AppDelegate.shared().getCashOptionPhoto(Brand: obj.recipientObj.cash_pickup_id)
            if url.hasPrefix("http") {
                let urlhaed = URL(string: url.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
                iconImgV.kf.setImage(with: urlhaed)
            } else {
                iconImgV.image = UIImage.init(named: "Cash Pick-up.png")
            }
        } else if AppDelegate.shared().tansferMethod == .SSS {
            idstr = obj.recipientObj.sss_number
            recipient_titleL.text = obj.recipientObj.passport_id
            iconImgV.image = UIImage.init(named: "SSS.png")
        } else if AppDelegate.shared().tansferMethod == .Pag {
            idstr = obj.recipientObj.pag_ibig_number
            recipient_titleL.text = obj.recipientObj.passport_id
            iconImgV.image = UIImage.init(named: "Pag-Ibig.png")
        } else if AppDelegate.shared().tansferMethod == .Health {
            idstr = obj.recipientObj.philhealth_number
            recipient_titleL.text = obj.recipientObj.passport_id
            iconImgV.image = UIImage.init(named: "PhilHealth.png")
        }
        
        accountL.text = idstr
        
        var valueStr = "\(obj.ntdValue)".stringToIntDecimalString()
        twdVL.text = "NTD \(valueStr)"
        feeVL.text = "\(obj.feeValue)"
        if obj.usePoint > 0 {
            usePointVL.text = "-\(obj.usePoint)"
        } else {
            usePointVL.text = "\(obj.usePoint)"
        }
        
        valueStr = "\(obj.totalNtdValue)".stringToIntDecimalString()
        totalVL.text = "\(valueStr)"
        
        //重抓一次匯率，再計算一次
        //callMemberData(Continue: false)
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
