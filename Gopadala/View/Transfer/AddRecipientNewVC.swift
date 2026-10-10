//
//  AddRecipientNewVC.swift
//  Gopadala
//
//  Created by Wang Jen Chung on 2024/3/8.
//  Copyright © 2024 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import KingfisherWebP

class AddRecipientNewVC: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var hideTextBtn: UIButton!
    @IBOutlet weak var scrollTopDistance: NSLayoutConstraint!
    @IBOutlet weak var topScrollV: UIScrollView!
    
    @IBOutlet weak var midV: UIView!
    @IBOutlet weak var midVL: UIView!
    @IBOutlet weak var midVR: UIView!
    @IBOutlet weak var midLImg: UIImageView!
    @IBOutlet weak var midRImg: UIImageView!
    @IBOutlet weak var midLL: UILabel!
    @IBOutlet weak var midRL: UILabel!
    @IBOutlet weak var otherMethodV: UIView!
    @IBOutlet weak var otherChoseL: UILabel!
    
    @IBOutlet weak var bankListTableView: UITableView!
    var showBankList:[BankObj] = []
    var tempRecipientObj:RecipientObj =  RecipientObj()
    
    var needBranchArea = ""
    var tempTag = 0
    var selectCurrencyIdx = 0
    var pickerV:UIPickerView!
    var canSelectForTransfer = false
    var loadOnce = false
    var stuffObj = AddRecipientNewObj()
    var allElement:[AddRecipientNewElement] = []
    var selectId:[String] = []
    var fromPicker:UIDatePicker!
    var toDatePicker:UIDatePicker!
    var chosedFromDate:Date!
    var chosedToDate:Date!
    
    //MARK: - Init
    func initUI() {
        var startY:CGFloat = 20
        
        stuffObj.initProperty()
        
        allElement = []
        for i in 0..<stuffObj.rowTypeAry.count {
            let obj = AddRecipientNewElement.init(frame: CGRect.init(x: 25, y: startY, width: topScrollV.frame.width-50, height: 70))
            obj.initAll(labelStr: stuffObj.rowNameAry[i], name: "", placeHold: stuffObj.placeHolderAry[i], type: stuffObj.rowTypeAry[i], sub: stuffObj.rowSubTypeAry[i], tag: i)
            obj.textField.tag = i
            if stuffObj.rowTypeAry[i] == .select, stuffObj.rowSubTypeAry[i] != .s_bank {
                initPickerView(touchAt: obj.textField)
            } else if stuffObj.rowTypeAry[i] == .day {
                addDatePicker(subtype: stuffObj.rowSubTypeAry[i], txtF: obj.textField)
            }
            
            if stuffObj.rowSubTypeAry[i] == .s_branch {
                obj.titleL.alpha = 0.5
                obj.txtBgV.alpha = 0.5
            }
            
            if AppDelegate.shared().tansferMethod == .SSS {
                if stuffObj.rowSubTypeAry[i] == .s_contribution || stuffObj.rowSubTypeAry[i] == .s_contribution_loan {
                    obj.titleL.alpha = 0.5
                    obj.txtBgV.alpha = 0.5
                }
            }
            
            if stuffObj.rowTypeAry[i] != .total {
                obj.textField.delegate = self
            }
            obj.parentVC = self
            
            topScrollV.addSubview(obj)
            allElement.append(obj)
            selectId.append("")
            
            if stuffObj.rowSubTypeAry[i] == .s_bank {
                bankListTableView.tag = i
            }
            
            startY += obj.frame.height
        }
        
        startY += 20
        let btn = UIButton.init(frame: CGRect.init(x: 0, y: startY, width: topScrollV.frame.width/2, height: 35))
        btn.setTitle("SUBMIT", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        btn.backgroundColor = .clear
        btn.layer.backgroundColor = Color_Gradient_Left.cgColor
        btn.layer.cornerRadius = 10
        btn.center = CGPoint.init(x: topScrollV.frame.width/2, y: startY + btn.frame.height/2)
        btn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        topScrollV.addSubview(btn)
        
        startY += btn.frame.height + 30
        
        if startY <= topScrollV.frame.height {
            startY = topScrollV.frame.height + 30
        }
        
        topScrollV.contentSize = CGSize.init(width: topScrollV.frame.width, height: startY)
    }
    
    func callSelect(tag: Int) {
        let subtype = stuffObj.rowSubTypeAry[tag]
        tempTag = tag
        if subtype == .s_bank {
            bankListTableView.isHidden = false
        } else {
            allElement[tag].textField.becomeFirstResponder()
        }
    }
    
    //MARK: - Check
    func checkCanGoOn() -> Bool {
        
        for i in 0..<stuffObj.rowTypeAry.count {
            let type = stuffObj.rowTypeAry[i]
            
            if type == .total {
                continue
            }
            
            if allElement[i].textField.text == "", stuffObj.rowSubTypeAry[i] != .s_branch {
                var str = ""
                if type == .txt {
                    str = "Please input the \(allElement[i].labelName)"
                } else if type == .select || type == .day {
                    str = "Please select the \(allElement[i].labelName)"
                }
                AppDelegate.shared().showAlertView(Message: str, ConfrimStr: "OK")
                return false
            }
        }
        
        if AppDelegate.shared().tansferMethod == .Bank {
            for i in 0..<stuffObj.rowSubTypeAry.count {
                if stuffObj.rowSubTypeAry[i] == .s_branch {
                    if needBranchArea == "1", selectId[i] == "" {
                        AppDelegate.shared().showAlertView(Message: "Please select the \(allElement[i].labelName)", ConfrimStr: "OK")
                        return false
                    }
                    
                    break
                }
            }
        }
        
        return true
    }
    
    //MARK: - UITextField Delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let pointInTable = textField.superview?.convert(textField.frame.origin, to: topScrollV)
        
        if let point = pointInTable {
            let y = point.y - 60
            topScrollV.setContentOffset(CGPoint(x: 0, y: y), animated: true)
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let tag = textField.tag
        tempTag = tag
        let subtype = stuffObj.rowSubTypeAry[tag]
        
        if subtype == .s_bank {
            bankListTableView.isHidden = false
        } else if subtype == .s_branch {
            if needBranchArea != "1" {
                return false
            }
            
            if AppDelegate.shared().branchAreaObj.count == 0 {
                getBranchData()
                return false
            }
        } else if subtype == .s_cashOption {
            
            if AppDelegate.shared().cashOptionObj.count == 0 {
                getCashOption()
                return false
            }
        } else if subtype == .s_payType {
            
            if AppDelegate.shared().paymentTypeObj.count == 0 {
                getPaymentType()
                return false
            }
        } else if subtype == .s_contribution || subtype == .s_contribution_loan {
            
            if allElement[tag].txtBgV.alpha == 0.5 {
                return false
            }
            
            if AppDelegate.shared().tansferMethod == .SSS {
                if AppDelegate.shared().sSSContributionObj.count == 0 {
                    getCashOption()
                    return false
                }
            } else if AppDelegate.shared().tansferMethod == .Health {
                if AppDelegate.shared().pHNContributionObj.count == 0 {
                    getCashOption()
                    return false
                }
            }
            
        }
        
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func addDatePicker(subtype:AddRecipientRowSubType, txtF:UITextField) {
        let datePicker = UIDatePicker.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 200))
        
        if subtype == .d_to || subtype == .d_from {
            //datePicker.date = chosedFromDate
            datePicker.datePickerMode = .date
        } else if subtype == .d_birth {
            datePicker.datePickerMode = .date
            //datePicker.date = chosedToDate
        }
        
        txtF.inputView = datePicker
        let doneButton = UIBarButtonItem.init(title: "Done", style: .done, target: self, action: #selector(datePickerDone(_:)))
        doneButton.tag = txtF.tag
        
        let toolBar = UIToolbar.init(frame: CGRect(x: 0, y: 0, width: self.view.bounds.size.width, height: 44))
        toolBar.setItems([UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil), doneButton], animated: true)
        txtF.inputAccessoryView = toolBar
        
        
        if subtype == .d_birth || subtype == .d_from {
            fromPicker = datePicker
        } else if subtype == .d_to {
            toDatePicker = datePicker
        }
        
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
    }
    
    @objc func datePickerDone(_ sender:UIBarButtonItem) {
        let subtype = stuffObj.rowSubTypeAry[sender.tag]
        var date = Date()
        if subtype == .d_birth || subtype == .d_from {
            date = fromPicker.date
            chosedFromDate = date
        } else if subtype == .d_to {
            date = toDatePicker.date
            chosedToDate = date
        }
        
        allElement[sender.tag].textField.resignFirstResponder()
        allElement[sender.tag].textField.text = giveDateString(date: date, subtype: subtype)
    }
    
    func giveDateString(date:Date, subtype:AddRecipientRowSubType) -> String {
        var str = ""
        if subtype == .d_birth {
            str = date.toString(format: "yyyy-MM-dd")
        } else if subtype == .d_from || subtype == .d_to {
            str = date.toString(format: "yyyy/MM")
        }
        
        return str
    }
    
    //MARK: - API
    public func getBranchData() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_BankBranch;
        
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
                    self.allElement[self.tempTag].textField.becomeFirstResponder()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    public func getPaymentType() {
        var parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        if AppDelegate.shared().tansferMethod == .Pag {
            parameters["service_code"] = "PGB"
        } else if AppDelegate.shared().tansferMethod == .SSS {
            parameters["service_code"] = "SSS"
        } else if AppDelegate.shared().tansferMethod == .Health {
            parameters["service_code"] = "PHN"
        }
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_PaymentTypeList;
        
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
                    self.allElement[self.tempTag].textField.becomeFirstResponder()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    public func getCashOption() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        var todoEndpoint: String = API_CashPickupOptionList;
        
        if AppDelegate.shared().tansferMethod == .Cash {
            todoEndpoint = API_CashPickupOptionList
        } else if AppDelegate.shared().tansferMethod == .SSS {
            todoEndpoint = API_SSSContributionList
        } else if AppDelegate.shared().tansferMethod == .Health {
            todoEndpoint = API_PHNContributionList
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
                    self.allElement[self.tempTag].textField.becomeFirstResponder()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func addRecipient() {
        var bank_name = ""
        var bank_acc = ""
        var bank_code = ""
        var phone = ""
        var parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        for i in 0..<stuffObj.rowTypeAry.count {
            let type = stuffObj.rowTypeAry[i]
            let sub = stuffObj.rowSubTypeAry[i]
            let name = stuffObj.apiRow[i]
            
            if type == .total || (sub == .s_branch && needBranchArea == "0") {
                continue
            }
            
            if sub == .s_bank {
                bank_name = allElement[i].textField.text!
                bank_code = selectId[i]
            } else if sub == .t_banknum {
                bank_acc = allElement[i].textField.text!
            } else if sub == .t_phone {
                phone = allElement[i].textField.text!
            }
            
            if type == .select {
                parameters[name] = selectId[i]
            } else {
                parameters[name] = allElement[i].textField.text!
            }
        }
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_AddRecipient;
        
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
                    self.tempRecipientObj.bank_name = bank_name
                    self.tempRecipientObj.bank_acc = bank_acc
                    self.tempRecipientObj.bank_code = bank_code
                    self.tempRecipientObj.phone_no = phone
                    self.tempRecipientObj.recipient_id = AppDelegate.shared().tempRecipientObj.recipient_id
                    self.tempRecipientObj.recipient_name = AppDelegate.shared().tempRecipientObj.recipient_name
                    
                    if self.canSelectForTransfer {
                        AppDelegate.shared().transactionObj.recipientObj = self.tempRecipientObj
                        self.embededPurpose()
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func addRecipient_other() {
        var phone = ""
        var parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        for i in 0..<stuffObj.rowTypeAry.count {
            let type = stuffObj.rowTypeAry[i]
            let sub = stuffObj.rowSubTypeAry[i]
            let name = stuffObj.apiRow[i]
            
            if type == .total {
                continue
            }
            
            if sub == .t_phone {
                phone = allElement[i].textField.text!
            }
            
            if type == .select {
                parameters[name] = selectId[i]
            } else {
                parameters[name] = allElement[i].textField.text!
            }
        }
        
        if AppDelegate.shared().tansferMethod == .Cash {
            parameters["recipient_type_id"] = "NTP"
        } else if AppDelegate.shared().tansferMethod == .Pag {
            parameters["recipient_type_id"] = "PGB"
        } else if AppDelegate.shared().tansferMethod == .SSS {
            parameters["recipient_type_id"] = "SSS"
        } else if AppDelegate.shared().tansferMethod == .Health {
            parameters["recipient_type_id"] = "PHN"
            parameters["recipient_type_id"] = "PHN"
        }
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_AddRecipient_Other;
        
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
                    
                    self.tempRecipientObj.phone_no = phone
                    self.tempRecipientObj.recipient_id = AppDelegate.shared().tempRecipientObj.recipient_id
                    self.tempRecipientObj.recipient_name = AppDelegate.shared().tempRecipientObj.recipient_name
                    
                    if self.canSelectForTransfer {
                        AppDelegate.shared().transactionObj.recipientObj = self.tempRecipientObj
                        
                        if AppDelegate.shared().tansferMethod == .Cash {
                            AppDelegate.shared().transactionObj.recipientObj.cash_pickup_id = parameters["cash_pickup_id"] as! String
                            AppDelegate.shared().transactionObj.recipientObj.cash_pickup_name = "\(parameters["first_name"] as! String) \(parameters["middle_name"] as! String) \(parameters["last_name"] as! String)"
                        } else if AppDelegate.shared().tansferMethod == .Pag {
                            AppDelegate.shared().transactionObj.recipientObj.passport_id = parameters["passport_id"] as! String
                            AppDelegate.shared().transactionObj.recipientObj.pag_ibig_number = parameters["pag_ibig_number"] as! String
                        } else if AppDelegate.shared().tansferMethod == .SSS {
                            AppDelegate.shared().transactionObj.recipientObj.passport_id = parameters["passport_id"] as! String
                            AppDelegate.shared().transactionObj.recipientObj.sss_number = parameters["sss_number"] as! String
                        } else if AppDelegate.shared().tansferMethod == .Health {
                            AppDelegate.shared().transactionObj.recipientObj.passport_id = parameters["passport_id"] as! String
                            AppDelegate.shared().transactionObj.recipientObj.philhealth_number = parameters["philhealth_number"] as! String
                        }
                        
                        self.embededPurpose()
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //MARK: - Button-Action
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func hideTextAction(_ sender: Any) {
        //closeAll()
    }
    
    @objc func nextAction() {
        if !checkCanGoOn() {
            return
        }
        Dlog("nextAction")
        
        if AppDelegate.shared().tansferMethod == .Bank {
            addRecipient()
        } else {
            addRecipient_other()
        }
    }
    
    //MARK: - Tableview Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == bankListTableView {
            return showBankList.count
        } else {
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == bankListTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BankListTableViewCell", for: indexPath) as! BankListTableViewCell
            let cellData = showBankList[indexPath.row]
            let serchBankobj = UtilityTool().searchBankObj(BankName: cellData.bank_name!)
            
            let imgurl = serchBankobj.bank_photo!
            let urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
            cell.bankIconImgV.kf.setImage(with: urlhaed)
            cell.bankL.text = cellData.bank_name
            
            cell.backgroundColor = .white
            cell.selectionStyle = .none
            return cell
        } else {
            //let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let cell = tableView.dequeueReusableCell(withIdentifier: "RelationTVC", for: indexPath) as! RelationTVC
            let cellData = AppDelegate.shared().relationObj[indexPath.row]
            cell.textLabel?.text = cellData.name
            cell.textLabel?.highlightedTextColor = .white
            cell.backgroundColor = .white
            //cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == bankListTableView {
            let tag = bankListTableView.tag
            let cellData = showBankList[indexPath.row]
            allElement[tag].textField.text = cellData.bank_name
            //bankImg
            selectId[tag] = cellData.bank_code
            allElement[tag].textField.resignFirstResponder()
            bankListTableView.isHidden = true
            needBranchArea = cellData.needBranchArea
            
            for i in 0..<stuffObj.rowSubTypeAry.count {
                if stuffObj.rowSubTypeAry[i] == .s_branch {
                    if needBranchArea != "1" {
                        allElement[i].textField.text = ""
                        selectId[i] = ""
                        allElement[i].titleL.alpha = 0.5
                        allElement[i].txtBgV.alpha = 0.5
                    } else {
                        allElement[i].titleL.alpha = 1
                        allElement[i].txtBgV.alpha = 1
                    }
                    
                    break
                }
            }
            
        } else {
            
        }
        
    }
    
    //MARK: - Purpose
    func addPurposeNextAction() {
        if self.children.count > 0{
            let viewControllers:[UIViewController] = self.children
            for viewContoller in viewControllers{
                viewContoller.willMove(toParent: nil)
                viewContoller.view.removeFromSuperview()
                viewContoller.removeFromParent()
            }
        }
        
        var storyboardId = "TransactionInfoConfirmVC"
        if AppDelegate.shared().deviceSmall {
            storyboardId = "TransactionInfoConfirmVCSmall"
        }
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: storyboardId) as? TransactionInfoConfirmVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    func embededPurpose() {
        let controller = TransferPurposeEmbededVC(nibName: "TransferPurposeEmbededVC", bundle: nil)
        controller.parentAddNewVC = self
        controller.loadFrom = 2
        //add as a childviewcontroller
        addChild(controller)

         // Add the child's View as a subview
         self.view.addSubview(controller.view)
         controller.view.frame = view.bounds
         controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

         // tell the childviewcontroller it's contained in it's parent
        controller.didMove(toParent: self)
    }
    
    //MARK: - Utility
    func setMethodUI() {
        if AppDelegate.shared().transferChoseLeft {
            midVL.backgroundColor = .white
            midVR.backgroundColor = .clear
            midLL.textColor = Color_Purple
            midRL.textColor = Color_Main_DarkGray
            midLImg.image = UIImage.init(named: "Bank_E-Wallet_ON")
            midRImg.image = UIImage.init(named: "Other Methods_OFF")
            
            otherMethodV.isHidden = true
            scrollTopDistance.constant = 0
        } else {
            midVL.backgroundColor = .clear
            midVR.backgroundColor = .white
            midLL.textColor = Color_Main_DarkGray
            midRL.textColor = Color_Purple
            midLImg.image = UIImage.init(named: "Bank_E-Wallet_OFF")
            midRImg.image = UIImage.init(named: "Other Methods_ON")
            otherMethodV.isHidden = false
            scrollTopDistance.constant = 45
            
            if AppDelegate.shared().tansferMethod == .Cash {
                otherChoseL.text = "Cash Pick-up"
            } else if AppDelegate.shared().tansferMethod == .SSS {
                otherChoseL.text = "SSS"
            } else if AppDelegate.shared().tansferMethod == .Pag {
                otherChoseL.text = "Pag-Ibig"
            } else if AppDelegate.shared().tansferMethod == .Health {
                otherChoseL.text = "PhilHealth"
            }
        }
    }
    
    func initPickerView(touchAt sender:UITextField){
        if pickerV == nil {
            pickerV = UIPickerView()
            pickerV.delegate = self
            pickerV.dataSource = self
        }
        
        // 依照點選不同的textField取出對應的pickView並給予tag
        // 到時候再依 tag 來撈出相對應資料
        
        let tag = sender.tag
        
        // 設定pickerView上方的toolbar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        // 讓toolbar自動調整合適於pickerView尺吋
        toolBar.sizeToFit()
        
        // 設定toolbar內的button
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(clickCancelButton(_:)))
        cancelButton.tag = tag
        // 中間空白的部份
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Chose", style: .plain, target: self, action: #selector(clickDoneButton(_:)))
        doneButton.tag = tag
        
        toolBar.setItems([cancelButton, spaceItem, doneButton], animated: false)
        
        // 設定toobar可以使用
        toolBar.isUserInteractionEnabled = true
        // 將pickerField輸入view改為pickerView
        sender.inputView = pickerV
        sender.tintColor = .clear
        // 將toolbar設定在pickerField裡面
        sender.inputAccessoryView = toolBar
    }
    
    //MARK: - Picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let subtype = stuffObj.rowSubTypeAry[tempTag]
        
        if subtype == .s_relation {
            return AppDelegate.shared().relationObj.count
        } else if subtype == .s_branch {
            return AppDelegate.shared().branchAreaObj.count
        } else if subtype == .s_cashOption {
            return AppDelegate.shared().cashOptionObj.count
        } else if subtype == .s_payType {
            return AppDelegate.shared().paymentTypeObj.count
        } else if subtype == .s_contribution || subtype == .s_contribution_loan {
            if AppDelegate.shared().tansferMethod == .SSS {
                return AppDelegate.shared().sSSContributionObj.count
            } else if AppDelegate.shared().tansferMethod == .Health {
                return AppDelegate.shared().pHNContributionObj.count
            }
        }
        return 3
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let subtype = stuffObj.rowSubTypeAry[tempTag]
        
        if subtype == .s_relation {
            return AppDelegate.shared().relationObj[row].name
        } else if subtype == .s_branch {
            return AppDelegate.shared().branchAreaObj[row].name
        } else if subtype == .s_cashOption {
            return AppDelegate.shared().cashOptionObj[row].name
        } else if subtype == .s_payType {
            return AppDelegate.shared().paymentTypeObj[row].payment_name
        } else if subtype == .s_contribution || subtype == .s_contribution_loan {
            if AppDelegate.shared().tansferMethod == .SSS {
                return AppDelegate.shared().sSSContributionObj[row].amt
            } else if AppDelegate.shared().tansferMethod == .Health {
                return AppDelegate.shared().pHNContributionObj[row].amt
            }
        }
        return "\(row)"
    }
    
    @objc func clickCancelButton(_ sender:UIBarButtonItem) {
        let tag = sender.tag
        allElement[tag].textField.resignFirstResponder()
    }
    
    @objc func clickDoneButton(_ sender:UIBarButtonItem) {
        let idx = pickerV.selectedRow(inComponent: 0)
        selectCurrencyIdx = idx
        let tag = sender.tag
        allElement[tag].textField.resignFirstResponder()
        
        let subtype = stuffObj.rowSubTypeAry[tempTag]
        
        if subtype == .s_relation {
            allElement[tag].textField.text = AppDelegate.shared().relationObj[idx].name
            selectId[tag] = AppDelegate.shared().relationObj[idx].idx!
        } else if subtype == .s_branch {
            allElement[tag].textField.text = AppDelegate.shared().branchAreaObj[idx].name
            selectId[tag] = AppDelegate.shared().branchAreaObj[idx].idx!
        } else if subtype == .s_cashOption {
            allElement[tag].textField.text = AppDelegate.shared().cashOptionObj[idx].name
            selectId[tag] = AppDelegate.shared().cashOptionObj[idx].idx!
        } else if subtype == .s_payType {
            allElement[tag].textField.text = AppDelegate.shared().paymentTypeObj[idx].payment_name
            selectId[tag] = AppDelegate.shared().paymentTypeObj[idx].paymenet_code!
            
            if AppDelegate.shared().tansferMethod == .SSS {
                if allElement[tag].textField.text!.hasPrefix("Contribution") {
                    for i in 0..<stuffObj.rowSubTypeAry.count {
                        if stuffObj.rowSubTypeAry[i] == .s_contribution {
                            allElement[i].titleL.alpha = 1
                            allElement[i].txtBgV.alpha = 1
                        } else if stuffObj.rowSubTypeAry[i] == .s_contribution_loan {
                            allElement[i].titleL.alpha = 0.5
                            allElement[i].txtBgV.alpha = 0.5
                        }
                    }
                } else if allElement[tag].textField.text!.hasPrefix("Short") {
                    for i in 0..<stuffObj.rowSubTypeAry.count {
                        if stuffObj.rowSubTypeAry[i] == .s_contribution {
                            allElement[i].titleL.alpha = 0.5
                            allElement[i].txtBgV.alpha = 0.5
                        } else if stuffObj.rowSubTypeAry[i] == .s_contribution_loan {
                            allElement[i].titleL.alpha = 1
                            allElement[i].txtBgV.alpha = 1
                        }
                    }
                } else {
                    for i in 0..<stuffObj.rowSubTypeAry.count {
                        if stuffObj.rowSubTypeAry[i] == .s_contribution {
                            allElement[i].titleL.alpha = 1
                            allElement[i].txtBgV.alpha = 1
                        } else if stuffObj.rowSubTypeAry[i] == .s_contribution_loan {
                            allElement[i].titleL.alpha = 0.5
                            allElement[i].txtBgV.alpha = 0.5
                        }
                    }
                }
            }
            
        } else if subtype == .s_contribution || subtype == .s_contribution_loan {
            if AppDelegate.shared().tansferMethod == .SSS {
                allElement[tag].textField.text = AppDelegate.shared().sSSContributionObj[idx].amt
                selectId[tag] = AppDelegate.shared().sSSContributionObj[idx].amt!
            } else if AppDelegate.shared().tansferMethod == .Health {
                allElement[tag].textField.text = AppDelegate.shared().pHNContributionObj[idx].amt
                selectId[tag] = AppDelegate.shared().pHNContributionObj[idx].amt!
            }
        }
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        setMethodUI()
        backL.text = ""
        showBankList = AppDelegate.shared().bankList
        bankListTableView.isHidden = true
        bankListTableView.delegate = self
        bankListTableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if loadOnce {
            return
        }
        
        loadOnce = true
        initUI()
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
