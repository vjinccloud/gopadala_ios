//
//  TransferPurposeEmbededVC.swift
//  indogo
//
//  Created by Wang Jen Chung on 2022/3/10.
//  Copyright © 2022 DIM. All rights reserved.
//

import UIKit

class TransferPurposeEmbededVC: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var purposeBgV: UIView!
    
    @IBOutlet weak var nameBgV: UIView!
    @IBOutlet weak var resultL: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var purposeListTableView: UITableView!
    var chosePurposeIdx = -1
    var loadFrom = 0
    var parentVC:RecipientListVC!
    var parentAddVC:AddRecipientVC!
    
    //MARK: - Tableview Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppDelegate.shared().purposeObj.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let cellData = AppDelegate.shared().purposeObj[indexPath.row]
        cell.textLabel?.text = cellData.name
        if indexPath.row == chosePurposeIdx {
            cell.backgroundColor = .white
        } else {
            cell.backgroundColor = .clear
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosePurposeIdx = indexPath.row
        let cellData = AppDelegate.shared().purposeObj[indexPath.row]
        resultL.text = cellData.name
        checkBtnState()
        tableView.reloadData()
    }
    
    func checkBtnState() {
        if chosePurposeIdx != -1 {
            nextBtn.addGradienOfIndoGo()
            nextBtn.isEnabled = true
            nextBtn.backgroundColor = Color_Main_Red
            nextBtn.setTitleColor(.white, for: .normal)
        } else {
            nextBtn.removeGradienLayer()
            nextBtn.isEnabled = false
            nextBtn.backgroundColor = .clear
            nextBtn.setTitleColor(Color_Main_Red, for: .normal)
        }
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        nameL.text = NSLocalizedString("Purpose Select Title", comment: "")
        resultL.text = NSLocalizedString("Purpose Select default word", comment: "")
        purposeListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        purposeListTableView.separatorStyle = .none
        purposeListTableView.delegate = self
        purposeListTableView.dataSource = self
        
        purposeBgV.layer.cornerRadius = purposeBgV.frame.size.height/2
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.setTitle(NSLocalizedString("ok", comment: ""), for: .normal)
        nextBtn.backgroundColor = .clear
        nextBtn.layer.borderWidth = 0.5
        nextBtn.layer.borderColor = Color_Main_Red.cgColor
        nextBtn.setTitleColor(Color_Main_Red, for: .normal)
        nextBtn.isEnabled = false
        nameBgV.addGradienOfIndoGo()
        
        Dlog("count = \(AppDelegate.shared().purposeObj.count)")
    }

    @IBAction func nextAction(_ sender: Any) {
        AppDelegate.shared().transactionObj.purposes_id = AppDelegate.shared().purposeObj[chosePurposeIdx].idx
        if loadFrom == 0 {
            parentVC.addPurposeNextAction()
        } else if loadFrom == 1 {
            parentAddVC.addPurposeNextAction()
        }
        
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
