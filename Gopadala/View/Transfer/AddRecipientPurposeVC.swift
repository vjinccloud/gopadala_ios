//
//  AddRecipientPurposeVC.swift
//  indogo
//
//  Created by Wang Jen Chung on 2022/11/9.
//  Copyright © 2022 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import KingfisherWebP

class AddRecipientPurposeVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backL: UILabel!
    
    @IBOutlet weak var hideTextBtn: UIButton!
    @IBOutlet weak var codeBgV: UIView!
    @IBOutlet weak var accountBgV: UIView!
    @IBOutlet weak var accountTextfield: UITextField!
    
    @IBOutlet weak var purposeBgV: UIView!
    @IBOutlet weak var purposeTextfield: UITextField!
    
    @IBOutlet weak var bankCodeTextfield: UITextField!
    var canSelectForTransfer = false
    @IBOutlet weak var nextBtn: UIButton!
    var tempBankCode = ""
    
    var showBankList:[BankObj] = []
    var tempRecipientObj:RecipientObj =  RecipientObj()
    
    @IBOutlet weak var bankImg: UIImageView!
    @IBOutlet weak var purposeListTableView: UITableView!
    var choseRelationIdx = -1
    
    //MARK: - Tableview Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppDelegate.shared().purposeObj.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let cellData = AppDelegate.shared().purposeObj[indexPath.row]
        cell.textLabel?.text = cellData.name
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        choseRelationIdx = indexPath.row
        let cellData = AppDelegate.shared().purposeObj[indexPath.row]
        purposeTextfield.text = cellData.name
        purposeTextfield.resignFirstResponder()
        checkBtnState()
        
    }
    
    //MARK: - Utility
    func changeBankImg(BankName name:String) {
        let serchBankobj = UtilityTool().searchBankObj(BankName: name)
        let imgurl = serchBankobj.bank_photo!
        let urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        bankImg.kf.setImage(with: urlhaed)
    }
    
    func checkBtnState() {
        if accountTextfield.text! == ""  {
            nextBtn.isEnabled = false
        } else {
            nextBtn.isEnabled = true
        }
        
        nextBtn.removeGradienLayer()
        nextBtn.addGradienOfIndoGo()
        nextBtn.setTitleColor(.white, for: .normal)
    }
    
    func closeAll() {
        closeText()
        purposeTextfield.resignFirstResponder()
    }
    
    func closeText() {
        bankCodeTextfield.resignFirstResponder()
        accountTextfield.resignFirstResponder()
    }
    
    func reloadDataAndTable(Str str:String) {
        if str == "" {
            showBankList = AppDelegate.shared().bankList
        } else {
            showBankList = []
            
            for i in 0..<AppDelegate.shared().bankList.count {
                let obj = AppDelegate.shared().bankList[i]
                
                if obj.bank_name.lowercased().contains(str.lowercased()) {
                    showBankList.append(obj)
                }
            }
        }
    }
    
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
    func addRecipient() {
        //找出 bank code
        let serchBankobj = UtilityTool().searchBankObj(BankName: bankCodeTextfield.text!)
        if serchBankobj.bank_code == "" {
            return
        }
        
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "bank_code":serchBankobj.bank_code!, "bank_acc":accountTextfield.text!, "relationships_id":AppDelegate.shared().relationObj[choseRelationIdx].idx!, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        closeAll()
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
                    self.tempRecipientObj.bank_acc = self.accountTextfield.text!
                    self.tempRecipientObj.bank_code = serchBankobj.bank_code!
                    self.tempRecipientObj.recipient_id = AppDelegate.shared().tempRecipientObj.recipient_id
                    self.tempRecipientObj.recipient_name = AppDelegate.shared().tempRecipientObj.recipient_name
                    
                    if self.canSelectForTransfer {
                        AppDelegate.shared().transactionObj.recipientObj = self.tempRecipientObj
                        
                        //self.embededPurpose()
                    } else {
                        self.navigationController?.popViewController(animated: true)
                    }
                    
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //MARK: - Button-Action
    @IBAction func nextAction(_ sender: Any) {
        var storyboardId = "TransactionInfoConfirmVC"
        if AppDelegate.shared().deviceSmall {
            storyboardId = "TransactionInfoConfirmVCSmall"
        }
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: storyboardId) as? TransactionInfoConfirmVC
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    @IBAction func hideTextAction(_ sender: Any) {
        closeAll()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func generateToolBar() ->UIToolbar {
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(doneAction))
        
        let toolBar:UIToolbar = UIToolbar()
        toolBar.items = [flexibleSpace,done]
        toolBar.sizeToFit()
        
        return toolBar
    }
    
    @objc func doneAction() {
        closeText()
    }
    
    //MARK: - Text Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        closeAll()
        return false
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideTextBtn.isHidden = false
        if textField == purposeTextfield {
            purposeListTableView.isHidden = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        hideTextBtn.isHidden = true
        purposeListTableView.isHidden = true
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //self.setupHideKeyboardOnTap()
        //bankCodeTextfield.inputAccessoryView = generateToolBar()
        //accountTextfield.inputAccessoryView = generateToolBar()
        bankCodeTextfield.returnKeyType = .done
        accountTextfield.returnKeyType = .done
        purposeTextfield.returnKeyType = .done
        
        showBankList = AppDelegate.shared().bankList
        
        purposeListTableView.separatorStyle = .none
        purposeListTableView.delegate = self
        purposeListTableView.dataSource = self
        purposeListTableView.isHidden = true
        purposeListTableView.backgroundColor = .white
        
        bankCodeTextfield.keyboardType = .default
        bankCodeTextfield.autocorrectionType = .no
        accountTextfield.keyboardType = .numberPad
        accountTextfield.isEnabled = false
        bankCodeTextfield.isEnabled = false
        purposeTextfield.delegate = self
        
        purposeBgV.isHidden = true
        
        accountTextfield.autocapitalizationType = .allCharacters
        bankCodeTextfield.autocapitalizationType = .allCharacters
        
        backL.text = ""
        
        bankCodeTextfield.becomeFirstResponder()
        bankCodeTextfield.placeholder = NSLocalizedString("Point Transfer Add Recipient Code PlaceHolder", comment: "")
        accountTextfield.placeholder = NSLocalizedString("Point Transfer Add Recipient Accounnt PlaceHolder", comment: "")
        purposeTextfield.placeholder = NSLocalizedString("Purpose placeholder", comment: "")
        purposeListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        codeBgV.layer.cornerRadius = codeBgV.frame.size.height/2
        accountBgV.layer.cornerRadius = accountBgV.frame.size.height/2
        purposeBgV.layer.cornerRadius = purposeBgV.frame.size.height/2
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.setTitle(NSLocalizedString("Point Transfer Add Recipient Next", comment: ""), for: .normal)
        nextBtn.backgroundColor = .clear
        nextBtn.layer.borderWidth = 0.5
        nextBtn.layer.borderColor = Color_Main_Red.cgColor
        nextBtn.isEnabled = false
        
        hideTextBtn.isHidden = true
        accountTextfield.text = AppDelegate.shared().tempRecipientObj.recipient_name
        bankCodeTextfield.text = AppDelegate.shared().transactionObj.recipientObj.bank_name
        tempBankCode = AppDelegate.shared().transactionObj.recipientObj.bank_code
        changeBankImg(BankName: AppDelegate.shared().transactionObj.recipientObj.bank_name)
        purposeBgV.isHidden = false
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
