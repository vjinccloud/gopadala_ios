//
//  RecipientListVC.swift
//  indogo
//
//  Created by mac on 2020/8/28.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import KingfisherWebP

class RecipientListVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var searchBgV: UIView!
    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var searchTextfield: UITextField!
    @IBOutlet weak var myTable: UITableView!
    var canSelectForTransfer = false
    var showDataList:[RecipientObj] = []
    //因為怕會重複一直進入而產生無法返回的迴圈
    var hasGotoAddRecipient = false
    var embededPurpooseView:UIView!
    
    //MARK: - Purpose
    func embededPurpose() {
        let controller = TransferPurposeEmbededVC(nibName: "TransferPurposeEmbededVC", bundle: nil)
        controller.parentVC = self
        //add as a childviewcontroller
        addChild(controller)

         // Add the child's View as a subview
         self.view.addSubview(controller.view)
         controller.view.frame = view.bounds
         controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

         // tell the childviewcontroller it's contained in it's parent
        controller.didMove(toParent: self)
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return showDataList.count
     }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecipientTableViewCell", for: indexPath) as! RecipientTableViewCell
        let cellData = showDataList[indexPath.row]
        let serchBankobj = UtilityTool().searchBankObj(BankName: cellData.bank_name!)
        
        let imgurl = serchBankobj.bank_photo!
        print("bank_photo = \(imgurl)")
        let urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        cell.logoImgV.kf.setImage(with: urlhaed)
        
        cell.nameL.text = cellData.recipient_name
        cell.bankL.text = cellData.bank_name
        cell.accL.text = cellData.bank_acc
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
     }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            hideRecipient(Recipient: showDataList[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !canSelectForTransfer {
            return
        }
        
        AppDelegate.shared().transactionObj.recipientObj = showDataList[indexPath.row]
        embededPurpose()
        
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
    
    //MARK: - API
    public func hideRecipient(Recipient obj:RecipientObj) {
        let serchBankobj = UtilityTool().searchBankObj(BankName: obj.bank_name!)
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "bank_code":serchBankobj.bank_code!, "bank_acc":obj.bank_acc!, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        closeAll()
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_MemberHideRecipent;
        
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
                    self.getRecipents()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    public func getRecipents() {
        var parameters:Parameters = [:]
        if canSelectForTransfer {
            
            var use_remit_point = 0
            if AppDelegate.shared().transactionObj.usePoint > 0 {
                use_remit_point = 1
            }
            
            parameters = ["token":AppDelegate.shared().sessionToken, "amount_ntd":AppDelegate.shared().transactionObj.ntdValue, "use_remit_point":use_remit_point, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        } else {
            parameters = ["token":AppDelegate.shared().sessionToken, "amount_ntd":0, "use_remit_point":0, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        }
        
        let headers: HTTPHeaders = [:]
        closeAll()
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_MemberRecipents;
        
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
                
                AppDelegate.shared().recipientListObjs = []
                AppDelegate.shared().recipientShownListObjs = []
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    self.reloadDataAndTable(Str: self.searchTextfield.text!)
                    if AppDelegate.shared().recipientShownListObjs.count == 0, self.hasGotoAddRecipient == false {
                        self.hasGotoAddRecipient = true
                        self.goAddRecipient()
                    }
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func goAddRecipient() {
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "AddRecipientVC") as? AddRecipientVC
        nextVC!.canSelectForTransfer = canSelectForTransfer
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    //MARK: - Button-Action
    @IBAction func addRecipientAction(_ sender: Any) {
        goAddRecipient()
    }
    
    @IBAction func searchAction(_ sender: Any) {
        closeAll()
        reloadDataAndTable(Str: searchTextfield.text!)
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Text Delegate
    func closeAll() {
        closeText()
    }
    
    func closeText() {
        searchTextfield.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        closeAll()
        reloadDataAndTable(Str: textField.text!)
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else{
            return true
        }
        
        if !string.checkAlphabetDigitAndSpace() {
            return false
        }
        
        let textLength = text.count + string.count - range.length
        if textLength>20 {
            return false
        }
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        reloadDataAndTable(Str: newString)
        return true

    }
    
    //MARK: - Utility
    func reloadDataAndTable(Str str:String) {
        //根據search字串過濾
        showDataList = []
        if str == "" {
            showDataList = AppDelegate.shared().recipientShownListObjs
        } else {
            let searchStr = str.lowercased()
            for i in 0..<AppDelegate.shared().recipientShownListObjs.count {
                let obj = AppDelegate.shared().recipientShownListObjs[i]
                if obj.recipient_name.lowercased().contains(searchStr) || obj.bank_acc.lowercased().contains(searchStr) || obj.bank_name.lowercased().contains(searchStr) {
                    showDataList.append(obj)
                }
            }
        }
        
        self.myTable.delegate = self
        self.myTable.dataSource = self
        self.myTable.reloadData()
        
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupHideKeyboardOnTap()
        backL.text = ""
        let nib = UINib(nibName: "RecipientTableViewCell", bundle: nil)
        myTable.register(nib, forCellReuseIdentifier: "RecipientTableViewCell")
        myTable.bounces = false
        myTable.backgroundColor = .clear
        myTable.separatorStyle = .none
        
        searchTextfield.keyboardType = .default
        searchTextfield.returnKeyType = .search
        searchTextfield.autocapitalizationType = .allCharacters
        searchTextfield.delegate = self
        
        searchBgV.layer.cornerRadius = searchBgV.frame.size.height/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            
        AppDelegate.shared().hideTopButton()
        getRecipents()
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
