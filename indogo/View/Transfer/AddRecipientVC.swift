//
//  AddRecipientVC.swift
//  indogo
//
//  Created by mac on 2020/8/29.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import KingfisherWebP

class AddRecipientVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

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
    
    @IBOutlet weak var bankListTableView: UITableView!
    var showBankList:[BankObj] = []
    var tempRecipientObj:RecipientObj =  RecipientObj()
    
    @IBOutlet weak var bankImg: UIImageView!
    @IBOutlet weak var purposeListTableView: UITableView!
    var choseRelationIdx = -1
    
    //MARK: - Tableview Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == bankListTableView {
            return showBankList.count
        } else if tableView == purposeListTableView{
            return AppDelegate.shared().relationObj.count
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
            let cellData = showBankList[indexPath.row]
            bankCodeTextfield.text = cellData.bank_name
            //bankImg
            tempBankCode = cellData.bank_code
            //bankCodeTextfield.resignFirstResponder()
            accountTextfield.becomeFirstResponder()
            changeBankImg(BankName: cellData.bank_name!)
            purposeBgV.isHidden = false
        } else {
            choseRelationIdx = indexPath.row
            let cellData = AppDelegate.shared().relationObj[indexPath.row]
            purposeTextfield.text = cellData.name
            //purposeTextfield.resignFirstResponder()
            purposeListTableView.isHidden = true
            checkBtnState()
        }
        
    }
    
    //MARK: - Utility
    func changeBankImg(BankName name:String) {
        let serchBankobj = UtilityTool().searchBankObj(BankName: name)
        let imgurl = serchBankobj.bank_photo!
        let urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
        bankImg.kf.setImage(with: urlhaed)
    }
    
    func checkBtnState() {
        if bankCodeTextfield.text! != "", accountTextfield.text! != "", purposeTextfield.text! != "" {
            nextBtn.isEnabled = true
            nextBtn.addGradienOfIndoGo()
            nextBtn.setTitleColor(.white, for: .normal)
        } else {
            nextBtn.isEnabled = false
            nextBtn.removeGradienLayer()
            nextBtn.setTitleColor(Color_Main_Red, for: .normal)
        }
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
        
        bankListTableView.reloadData()
    }
    
    //MARK: - Text Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        closeAll()
        return false
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideTextBtn.isHidden = false
        if textField == bankCodeTextfield {
            bankListTableView.isHidden = false
            purposeListTableView.isHidden = true
        } else if textField == purposeTextfield {
            bankListTableView.isHidden = true
            purposeListTableView.isHidden = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        hideTextBtn.isHidden = true
        bankListTableView.isHidden = true
        purposeListTableView.isHidden = true
        checkBtnState()
        changeBankImg(BankName: bankCodeTextfield.text!)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard let text = textField.text else{
            return true
        }
        
        if textField == accountTextfield {
            if !string.checkAlphabetDigit() {
                return false
            }
        }
        
        if textField == bankCodeTextfield {
            if !string.checkAlphabetDigit() {
                return false
            }
        }
        
        let textLength = text.count + string.count - range.length
        if textLength>20 {
            return false
        }
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        reloadDataAndTable(Str: newString)
        checkBtnState()
        return true

    }
    
    //MARK: - Purpose
    func embededPurpose() {
        let controller = TransferPurposeEmbededVC(nibName: "TransferPurposeEmbededVC", bundle: nil)
        controller.parentAddVC = self
        controller.loadFrom = 1
        //add as a childviewcontroller
        addChild(controller)

         // Add the child's View as a subview
         self.view.addSubview(controller.view)
         controller.view.frame = view.bounds
         controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

         // tell the childviewcontroller it's contained in it's parent
        controller.didMove(toParent: self)
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
                    self.tempRecipientObj.bank_name = self.bankCodeTextfield.text!
                    self.tempRecipientObj.bank_acc = self.accountTextfield.text!
                    self.tempRecipientObj.bank_code = serchBankobj.bank_code!
                    self.tempRecipientObj.recipient_id = AppDelegate.shared().tempRecipientObj.recipient_id
                    self.tempRecipientObj.recipient_name = AppDelegate.shared().tempRecipientObj.recipient_name
                    
                    if self.canSelectForTransfer {
                        AppDelegate.shared().transactionObj.recipientObj = self.tempRecipientObj
                        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "AddRecipientPurposeVC") as? AddRecipientPurposeVC
                        self.navigationController?.pushViewController(nextVC!, animated: true)
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
        addRecipient()
    }
    
    @IBAction func hideTextAction(_ sender: Any) {
        closeAll()
    }
    
    @IBAction func showPurposeAction(_ sender: Any) {
        closeAll()
        bankListTableView.isHidden = true
        purposeListTableView.isHidden = false
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
        
        purposeTextfield.isEnabled = false
        
        showBankList = AppDelegate.shared().bankList
        bankListTableView.separatorStyle = .none
        bankListTableView.delegate = self
        bankListTableView.dataSource = self
        bankListTableView.isHidden = true
        bankListTableView.backgroundColor = .white
        
        purposeListTableView.separatorStyle = .none
        purposeListTableView.delegate = self
        purposeListTableView.dataSource = self
        purposeListTableView.isHidden = true
        purposeListTableView.backgroundColor = .white
        
        bankCodeTextfield.keyboardType = .default
        bankCodeTextfield.autocorrectionType = .no
        accountTextfield.keyboardType = .numberPad
        accountTextfield.delegate = self
        bankCodeTextfield.delegate = self
        purposeTextfield.delegate = self
        
        purposeBgV.isHidden = true
        
        accountTextfield.autocapitalizationType = .allCharacters
        bankCodeTextfield.autocapitalizationType = .allCharacters
        
        backL.text = ""
        
        bankCodeTextfield.becomeFirstResponder()
        bankCodeTextfield.placeholder = NSLocalizedString("Point Transfer Add Recipient Code PlaceHolder", comment: "")
        accountTextfield.placeholder = NSLocalizedString("Point Transfer Add Recipient Accounnt PlaceHolder", comment: "")
        purposeTextfield.placeholder = NSLocalizedString("Purpose Select Title", comment: "")
        purposeListTableView.register(RelationTVC.self, forCellReuseIdentifier: "RelationTVC")
        
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
