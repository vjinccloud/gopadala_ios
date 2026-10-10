//
//  SpecialPageVC.swift
//  indogo
//
//  Created by Wang Jen Chung on 2022/12/21.
//  Copyright © 2022 DIM. All rights reserved.
//

import UIKit

class SpecialPageVC: UIViewController {
    
    @IBOutlet weak var backL: UILabel!
    var backTitle = ""
    var urlStr = ""
    @IBOutlet weak var barV: UIView!
    var loadOnce = false
    
    @IBOutlet weak var nextBtn: UIButton!
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    public func setTitleAndCallURL(URL urlString:String, Title title:String) {
        backTitle = "Dispute Settlement"
        urlStr = urlString
    }
    
    @IBAction func nextAction(_ sender: Any) {
        let urlString:String = "https://www.foi.org.tw/Article.aspx?Lang=1&Arti=8452"
        let pasteboard = UIPasteboard.general
        pasteboard.string = urlString
        /*
        if let openURL = URL(string: urlString) {
            if (UIApplication.shared.canOpenURL(openURL)) {
                UIApplication.shared.open(openURL, options: [:], completionHandler: nil)
            }
        }*/
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        barV.addGradienOfIndoGo()
        nextBtn.addGradienOfIndoGo()
        nextBtn.setTitle("COPY LINK", for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        backL.text = "Dispute Settlement"
        if loadOnce {
            return
        }
        
        loadOnce = true
        var startY:CGFloat = barV.frame.origin.y+barV.frame.height
        
        let scrollV = UIScrollView.init(frame: CGRect.init(x: 0, y: startY, width: self.view.frame.width, height: self.view.frame.height-startY-60))
        self.view.addSubview(scrollV)
        
        startY = 10
        let imgV = UIImageView.init(frame: CGRect.init(x: 10, y: startY, width: self.view.frame.width-20, height: self.view.frame.width-20))
        imgV.image = UIImage.init(named: "FOI_pic")
        scrollV.addSubview(imgV)
        
        startY += self.view.frame.width + 10
        
        let label = UILabel.init(frame: CGRect.init(x: 10, y: startY, width: self.view.frame.width-20, height: 0))
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 17)
        label.text = "The Financial Ombudsman Institution is the Taiwanese agency responsible for resolving non-litigation disputes between consumers and financial service providers.\nShould you encounter any issues concerning remittance exchanges or financial matters, we offer consultation services in Mandarin or English. Additionally, we are committed to assisting you in addressing any complaints you may have.\nIf you require assistance in a language, our center will provide translation resources to facilitate smooth communication."
        label.sizeToFit()
        scrollV.addSubview(label)
        
        startY += label.frame.height + 100
        
        scrollV.contentSize = CGSize.init(width: scrollV.frame.width, height: startY)
        
        //SALIN LINK
        self.view.bringSubviewToFront(nextBtn)
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
