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
        backTitle = title
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
        nextBtn.setTitle("SALIN LINK", for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        backL.text = "LEMBAGA PENYELESAIAN"
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
        label.text = "Lembaga Ombudsman Keuangan, merupakan lembaga penyelesaian yang menangani perselisihan di luar litigasi antara konsumen keuangan & industri jasa keuangan.\n\nBila terjadi permasalah mengenai pertukaran mata uang nilai kecil, atau masalah yang menyangkut keuangan negara dan pemerintah.\n\nKami akan memberikan layanan konsultasi kepada Anda dalam Bahasa Mandarin atau Bahasa Inggris, serta membantu pengaduan yang berkaitan dan prosedur penanganan evaluasi.\n\nBila Anda membutuhkan bantuan dalam bahasa lain, pusat kami akan membantu mencari sumber terjemahan, supaya kita bisa berkomunikasi dengan lancar."
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
