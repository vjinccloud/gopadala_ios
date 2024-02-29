//
//  TransferListVC.swift
//  indogo
//
//  Created by mac on 2020/8/30.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import KingfisherWebP

class TransferListVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var searchBgV: UIView!
    @IBOutlet weak var searchTextfield: UITextField!
    @IBOutlet weak var myTable: UITableView!
    
    @IBOutlet weak var leftV: UIView!
    @IBOutlet weak var leftL: UILabel!
    @IBOutlet weak var rightV: UIView!
    @IBOutlet weak var rightL: UILabel!
    
    @IBOutlet weak var leftImgV: UIImageView!
    @IBOutlet weak var rightImgV: UIImageView!
    @IBOutlet weak var leftBtn: UIButton!
    @IBOutlet weak var rightBtn: UIButton!
    
    var showDataList:[TransferStateObj] = []
    var showOrderCheckDataList:[TransferOrderCheckObj] = []
    var searchShowIndex:[Int] = []
    var cellBarColor:[UIColor] = []
    var loadOnce = false
    var dateEnd:Date!
    var tempDateEnd:Date!
    var dateStartStr = ""
    var dateEndStr = ""
    
    var pageNext:Int = 1
    var pageEnd = false
    var moreStart = false
    var lastReadDetailIdx = 0
    var choseState = 0
    
    //MARK: - Scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /*
        if  searchTextfield.text == "", pageEnd == false, moreStart == false, (myTable.contentOffset.y+10)>=(myTable.contentSize.height-myTable.frame.size.height) {
            //self.searchNews(Add: true)
            generateTimeString()
            getTransferList()
            moreStart = true
        }*/
    }
    
    //MARK: - Handle Time
    func generateTimeString(FromeStart isStart:Bool = false) {
        if isStart {
            AppDelegate.shared().transferStateListObjs = []
            AppDelegate.shared().transferOrderCheckListObjs = []
            lastReadDetailIdx = 0
            tempDateEnd = Date()
            dateEnd = tempDateEnd
            generateTimeString()
        }
        dateEndStr = dateEnd.toString() + " 23:59:59"
        tempDateEnd = dateEnd.addDays(Days: -90)
        dateStartStr = tempDateEnd.toString() + " 00:00:00"
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return searchShowIndex.count
     }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let realIdx = searchShowIndex[indexPath.row]
        let cellOrderCheckData = showOrderCheckDataList[realIdx]
        
        if cellOrderCheckData.order_status == "5" {
            return 215
        } else {
            return 320
        }
        
    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TransferStateType1TableViewCell", for: indexPath) as! TransferStateType1TableViewCell
        
        let realIdx = searchShowIndex[indexPath.row]
        let cellData = showDataList[realIdx]
        
        let payment_info = cellData.payment_info
        var cellOrderCheckData:TransferOrderCheckObj = TransferOrderCheckObj()
        //api可能會重複給訂單資料，所以用找到的第一個
        for i in 0..<showDataList.count {
            if showDataList[i].payment_info == payment_info {
                cellOrderCheckData = showOrderCheckDataList[i]
                break
            }
        }
        
        //let cellOrderCheckData = showOrderCheckDataList[realIdx]
       
        let serchBankobj = UtilityTool().searchBankObj(BankCode: cellData.bank_code!)
        
        cell.barTitleL.text = NSLocalizedString("Transfer State " + cellOrderCheckData.order_status, comment: "")
        cell.midL.text = NSLocalizedString("Transfer State Mid Text Title", comment: "")
        
        let colorIdx = Int(cellOrderCheckData.order_status)! - 1
        if colorIdx >= 0, colorIdx <= 4 {
            Dlog("cellBarColor\(colorIdx), \(cellOrderCheckData.order_status)")
            cell.barV.backgroundColor = cellBarColor[colorIdx]
        }
        
        cell.failV.isHidden = true
        cell.downV.isHidden = false
        cell.upV.isHidden = false
        cell.pureTextV.isHidden = false
        cell.midL.isHidden = false
        
        cell.upIconIgV.image = UIImage.init()
        cell.setTransferState(Stae: cellOrderCheckData.order_status)
        
        if cellOrderCheckData.order_status == "1" {
            cell.pureTextV.isHidden = false
            cell.upV.isHidden = true
            
            cell.barNumberV.isHidden = false
            cell.barTimeL.isHidden = true
            
            cell.pureNameL.text = NSLocalizedString("Transfer State Pure Text Title", comment: "") //cellData.recipient_name
            cell.pureValueL.text = "NTD " + cellData.total.stringToIntDecimalString()
            cell.pureCodeL.text = cellData.payment_info
            
            let expireTimeStr = cellOrderCheckData.lm_time_expire!
            let serverTimeStr = cellOrderCheckData.server_time!
            
            let time1 = UtilityTool().dateStringToTime(Str: expireTimeStr)
            let time2 = UtilityTool().dateStringToTime(Str: serverTimeStr)
            
            if time1 < 0 || time2 < 0 {
                cell.barNumberV.isHidden = true
            } else {
                cell.startCountDown(Time: expireTimeStr)
                /*
                let diffTime = Int(time1 - time2)
                if diffTime < 0 {
                    cell.barNumberV.isHidden = true
                } else {
                    let leftSecs = diffTime%60
                    cell.n5L.text = "\(leftSecs%10)"
                    cell.n4L.text = "\(Int(leftSecs/10))"
                    
                    let leftMins = Int(diffTime/60)%60
                    cell.n3L.text = "\(leftMins%10)"
                    cell.n2L.text = "\(Int(leftMins/10))"
                    
                    let leftHours = Int(diffTime/3600)
                    cell.n1L.text = "\(leftHours%10)"
                    cell.n0L.text = "\(Int(leftHours/10))"
                }*/
            }
            
            let imgurl = serchBankobj.bank_photo!
            let urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
            cell.downIconIgV.kf.setImage(with: urlhaed)
            
        } else if cellOrderCheckData.order_status == "5" {
            cell.barNumberV.isHidden = true
            cell.barTimeL.isHidden = false
            
            cell.failV.isHidden = false
            cell.downV.isHidden = true
            cell.upV.isHidden = true
            cell.pureTextV.isHidden = true
            cell.midL.isHidden = true
            
            let timeStr = UtilityTool().transferIndogoDate(Date:cellOrderCheckData.lm_time_failed!)
            cell.barTimeL.text = timeStr
            
            let imgurl = serchBankobj.bank_photo!
            let urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
            cell.failIconIgV.kf.setImage(with: urlhaed)
            
            cell.failNameL.text = cellData.recipient_name
            cell.failIDL.text = cellData.to_acc
            cell.failValueL.text = "IDR " + cellData.transfer_amount_idr.stringToIntDecimalString()
            cell.failNoteL.text = NSLocalizedString("Transfer State Down Kurs Value Title", comment: "") + " " + cellData.kurs_value
            
        } else {
            cell.barNumberV.isHidden = true
            cell.barTimeL.isHidden = false
            cell.pureTextV.isHidden = true
            cell.upV.isHidden = false
            
            var timeStr = cellOrderCheckData.lm_time_paid!
            if cellOrderCheckData.order_status == "2" {
                timeStr = cellOrderCheckData.lm_time_paid!
            } else if cellOrderCheckData.order_status == "3" {
                timeStr = cellOrderCheckData.lm_time_process!
            } else if cellOrderCheckData.order_status == "4" {
                timeStr = cellOrderCheckData.lm_time_transfer!
            }
            
            cell.barTimeL.text = UtilityTool().transferIndogoDate(Date:timeStr)
            
            let ary = timeStr.components(separatedBy: " ")
            
            if ary.count > 1 {
                cell.upIDL.text = NSLocalizedString("Transfer State Down Time Title", comment: "") + " " + ary[1]
            } else {
                cell.upIDL.text = ""
            }
            
            let imgurl = serchBankobj.bank_photo!
            let urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
            cell.downIconIgV.kf.setImage(with: urlhaed)
            
            cell.upValueL.text = "NTD " + cellData.total.stringToIntDecimalString()
            cell.upNoteL.text = cellData.payment_info
            
        }
        
        cell.downNameL.text = cellData.recipient_name
        cell.downIDL.text = cellData.to_acc
        cell.downValueL.text = "IDR " + cellData.transfer_amount_idr.stringToIntDecimalString()
        cell.downNoteL.text = NSLocalizedString("Transfer State Down Kurs Value Title", comment: "") + " " + cellData.kurs_value
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        
        return cell
     }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let realIdx = searchShowIndex[indexPath.row]
        let cellData = showDataList[realIdx]
        let cellOrderCheckData = showOrderCheckDataList[realIdx]
        
        if cellOrderCheckData.order_status == "5" {
            AppDelegate.shared().showFloatingContainer()
            return
        }
        
        if cellOrderCheckData.order_status != "1" {
            return
        }
        
        //新的首頁
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "TransactionNewMainVC") as? TransactionNewMainVC
        //let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "TransactionResultVC") as? TransactionResultVC
        nextVC?.payment_info = cellData.payment_info
        nextVC?.transferStateObj = cellData
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
    
    //MARK: - API
    public func getAllOrdersDetail() {
        var paymentAry:[String] = []
        for i in lastReadDetailIdx..<AppDelegate.shared().transferStateListObjs.count {
            let obj = AppDelegate.shared().transferStateListObjs[i]
            paymentAry.append(obj.payment_info)
        }
        
        if paymentAry.count == 0 {
            return
        }
        
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "payment_info":paymentAry, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        closeAll()
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_OrderCheckMuilti;
        
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
                
                //AppDelegate.shared().transferOrderCheckListObjs = []
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    self.lastReadDetailIdx = AppDelegate.shared().transferStateListObjs.count
                    self.reloadDataAndTable(Str: self.searchTextfield.text!)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    public func getTransferList(UsingDate usingDate:Bool = true) {
        /*
        var parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "date_start":dateStartStr, "date_end":dateEndStr, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString(), "transfered":choseState]
        Dlog("usingDate = \(usingDate)")
        if usingDate == false {
            AppDelegate.shared().transferStateListObjs = []
            parameters = ["token":AppDelegate.shared().sessionToken, "transfered":choseState]
        }
        */
        //改成都取得全部
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString(), "transfered":choseState]
        let headers: HTTPHeaders = [:]
        closeAll()
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_TransferHistory;
        Dlog("a list count = \(AppDelegate.shared().transferStateListObjs.count)")
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
                Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.setMoreStartNormally), userInfo: nil, repeats: true)
                self.dateEnd = self.tempDateEnd
                
                //AppDelegate.shared().transferStateListObjs = []
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                if result == ResponseState.ok {
                    
                    if usingDate == false {
                        self.pageEnd = true
                    } else {
                        Dlog("list count = \(AppDelegate.shared().transferStateListObjs.count)")
                        if AppDelegate.shared().transferStateListObjs.count == 0 { //如果第一次取得就是沒有項目，則轉成取得全部
                            //self.getTransferList(UsingDate: false)
                            self.reloadDataAndTable(Str: self.searchTextfield.text!)
                        } else {
                            self.getAllOrdersDetail()
                        }
                    }
                    
                    //self.reloadDataAndTable()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    @objc func setMoreStartNormally() {
        moreStart = false
    }
    
    //MARK: - Button-Action
    @IBAction func leftAction(_ sender: Any) {
        choseState = 0
        lastReadDetailIdx = 0
        AppDelegate.shared().transferStateListObjs = []
        AppDelegate.shared().transferOrderCheckListObjs = []
        btnStateAndAction(Next: true)
    }
    
    @IBAction func rightAction(_ sender: Any) {
        choseState = 1
        lastReadDetailIdx = 0
        AppDelegate.shared().transferStateListObjs = []
        AppDelegate.shared().transferOrderCheckListObjs = []
        btnStateAndAction(Next: true)
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
    func btnStateAndAction(Next next:Bool = false) {
        if choseState == 0 {
            leftV.backgroundColor = Color_BtnChose
            rightV.backgroundColor = Color_BtnNotChose
            rightImgV.image = UIImage.init(named: "rightcircle0")
        } else {
            rightV.backgroundColor = Color_BtnChose
            leftV.backgroundColor = Color_BtnNotChose
            rightImgV.image = UIImage.init(named: "rightcircle")
        }
        
        if next {
            getTransferList()
        }
    }
    
    func reloadDataAndTable(Str str:String) {
        //根據search字串過濾
        searchShowIndex = []
        showDataList = AppDelegate.shared().transferStateListObjs
        showOrderCheckDataList = AppDelegate.shared().transferOrderCheckListObjs
        
        if str == "" {
            for i in 0..<showDataList.count {
                searchShowIndex.append(i)
            }
        } else {
            let searchStr = str.lowercased()
            for i in 0..<showDataList.count {
                let obj = showDataList[i]
                if obj.payment_info.lowercased().contains(searchStr) || obj.to_acc.lowercased().contains(searchStr) || obj.recipient_name.lowercased().contains(searchStr) {
                    searchShowIndex.append(i)
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
        let nib = UINib(nibName: "TransferStateType1TableViewCell", bundle: nil)
        myTable.register(nib, forCellReuseIdentifier: "TransferStateType1TableViewCell")
        myTable.bounces = true
        myTable.backgroundColor = .clear
        myTable.separatorStyle = .none
        
        leftV.layer.cornerRadius = 5
        rightV.layer.cornerRadius = 5
        leftImgV.image = UIImage.init(named: "leftcircle")
        leftL.text = NSLocalizedString("Transfer State Left Btn", comment: "")
        
        rightImgV.image = UIImage.init(named: "rightcircle0")
        rightL.text = NSLocalizedString("Transfer State Right Btn", comment: "")
        btnStateAndAction()
        
        searchTextfield.keyboardType = .default
        searchTextfield.returnKeyType = .search
        searchTextfield.delegate = self
        
        searchBgV.layer.cornerRadius = searchBgV.frame.size.height/2
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if loadOnce {
            pageEnd = false
            btnStateAndAction(Next: true)
            AppDelegate.shared().showTopButton()
            return
        }
        
        loadOnce = true
        cellBarColor.append(UtilityTool().hexStringToUIColor(hex: "#BD1621"))
        cellBarColor.append(UtilityTool().hexStringToUIColor(hex: "#156784"))
        cellBarColor.append(UtilityTool().hexStringToUIColor(hex: "#FDA11A"))
        cellBarColor.append(UtilityTool().hexStringToUIColor(hex: "#2B712A"))
        cellBarColor.append(UtilityTool().hexStringToUIColor(hex: "#706F6F"))
        
        //nowPage = 1
        generateTimeString(FromeStart: true)
        btnStateAndAction(Next: true)
        
        //頂部兩個按鈕
        AppDelegate.shared().topMargin = self.view.safeAreaInsets.top
        AppDelegate.shared().addTopButton()
        
        AppDelegate.shared().nowBottomMenuType = .transState
        AppDelegate.shared().bottomMenu.paintMenu()
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
