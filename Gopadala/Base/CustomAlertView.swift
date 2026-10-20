//
//  CustomAlertView.swift
//  indogo
//
//  Created by mac on 2020/7/18.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

protocol CustomAlertDelegate {
    func customAlertnextAction(Ref obj:CustomAlertView)
    func customAlertnextActionSecond(Ref obj:CustomAlertView)
}

class CustomAlertView: UIView {
    
    var customDelegate:CustomAlertDelegate?
    /// false 時點視窗外面（以及共用 cancelAction 的按鈕）不會關閉，用於必須按確認的提醒
    var tapOutsideToClose = true

    public func initSimpleAlert(Title title:String, Content content:String, NextBtn1Str btnStr1:String) {
        self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8)
        let divX:CGFloat = 50
        let centerY:CGFloat = self.frame.size.height/2
        
        let closeBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.addSubview(closeBtn)
        closeBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        //背景框
        let centerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width-2*divX, height: 0))
        self.addSubview(centerView)
        centerView.backgroundColor = .white
        let width = centerView.frame.size.width
        var startY:CGFloat = 0
        
        let divX2:CGFloat = 20
        let labelTitleL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelTitleL.textAlignment = .center
        labelTitleL.textColor = .white
        labelTitleL.font = UIFont.systemFont(ofSize: 25)
        labelTitleL.text = title
        labelTitleL.numberOfLines = 0
        labelTitleL.sizeToFit()
        
        startY += 24 + labelTitleL.frame.size.height
        
        //標題列
        let barView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: startY))
        barView.addSubview(labelTitleL)
        barView.backgroundColor = Color_Main_Red
        centerView.addSubview(barView)
        
        labelTitleL.center = CGPoint(x: barView.center.x, y: labelTitleL.center.y)
        
        //內容
        startY += 6
        let labelContentL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelContentL.textColor = .black
        labelContentL.font = UIFont.systemFont(ofSize: 14)
        labelContentL.text = content
        labelContentL.numberOfLines = 0
        labelContentL.sizeToFit()
        centerView.addSubview(labelContentL)
        
        //按鈕
        startY += labelContentL.frame.size.height + 35
        let nextBtn = UIButton.init(frame: CGRect.init(x: divX2, y: startY, width: width-2*divX2, height: 35))
        nextBtn.setTitle(btnStr1, for: .normal)
        nextBtn.backgroundColor = Color_Main_Red
        nextBtn.setTitleColor(.white, for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        centerView.addSubview(nextBtn)
        nextBtn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        startY += nextBtn.frame.size.height + 10
        
        //最後位置調整
        centerView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width-2*divX, height: startY)
        centerView.center = CGPoint(x: self.frame.size.width/2, y: centerY-20)
        centerView.layer.cornerRadius = 15
        centerView.clipsToBounds = true
        
    }
    
    /// 防詐提醒視窗（compliance-202610 需求 5-2，對齊設計稿 fraud-gopadala.png）
    /// 版型：藍色漸層色帶白字粗體標題 → 人形警告圖示 fraud_alert_icon → 內文置中 → 深藍窄版膠囊按鈕置中。視窗寬約螢幕 80%。
    /// 只管外觀，按鈕與點外面的行為沿用 nextAction / cancelAction。
    public func initFraudAlert(Title title:String, Content content:String, NextBtn1Str btnStr1:String) {
        self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.6)
        let dialogWidth:CGFloat = (self.frame.size.width * 0.8).rounded()
        let centerY:CGFloat = self.frame.size.height/2
        let darkBlue = UtilityTool().hexStringToUIColor(hex: "#1F2E5C")

        let closeBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.addSubview(closeBtn)
        closeBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)

        //背景框
        let centerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: dialogWidth, height: 0))
        self.addSubview(centerView)
        centerView.backgroundColor = .white
        let width = centerView.frame.size.width
        var startY:CGFloat = 0

        //標題列：藍色漸層、白字粗體置中
        let barHeight:CGFloat = 42
        let barView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: barHeight))
        barView.backgroundColor = Color_Main_Red
        barView.addGradienOfIndoGo()
        centerView.addSubview(barView)

        let labelTitleL = UILabel.init(frame: barView.bounds)
        labelTitleL.textAlignment = .center
        labelTitleL.textColor = .white
        labelTitleL.font = UIFont.boldSystemFont(ofSize: 20)
        labelTitleL.text = title
        labelTitleL.adjustsFontSizeToFitWidth = true
        labelTitleL.minimumScaleFactor = 0.7
        barView.addSubview(labelTitleL)

        startY += barHeight

        //圖示：紫色人形加警告三角（佔位圖從設計稿裁切，之後換 Assets 內的檔即可）
        startY += 12
        let iconSize:CGFloat = 48
        let icon = UIImageView.init(frame: CGRect.init(x: (width-iconSize)/2, y: startY, width: iconSize, height: iconSize))
        icon.contentMode = .scaleAspectFit
        icon.image = UIImage.init(named: "fraud_alert_icon")
        centerView.addSubview(icon)
        startY += iconSize

        //內文：置中、深藍字、左右留白
        startY += 8
        let contentDivX:CGFloat = 14
        let labelContentL = UILabel.init(frame: CGRect.init(x: contentDivX, y: startY, width: width-2*contentDivX, height: 0))
        labelContentL.textColor = darkBlue
        labelContentL.font = UIFont.systemFont(ofSize: 13.5)
        labelContentL.textAlignment = .center
        labelContentL.text = content
        labelContentL.numberOfLines = 0
        labelContentL.sizeToFit()
        let contentHeight = labelContentL.frame.size.height
        //內文最高佔螢幕 50%，超過就放進可捲動的區域，讓按鈕一定留在視窗內；短文字時外觀和原本一樣
        let maxContentHeight:CGFloat = (self.frame.size.height * 0.5).rounded()
        if contentHeight > maxContentHeight {
            let contentScroll = UIScrollView.init(frame: CGRect.init(x: contentDivX, y: startY, width: width-2*contentDivX, height: maxContentHeight))
            contentScroll.showsVerticalScrollIndicator = true
            contentScroll.alwaysBounceVertical = true
            contentScroll.contentSize = CGSize(width: width-2*contentDivX, height: contentHeight)
            labelContentL.frame = CGRect.init(x: 0, y: 0, width: width-2*contentDivX, height: contentHeight)
            contentScroll.addSubview(labelContentL)
            centerView.addSubview(contentScroll)
            startY += maxContentHeight
        } else {
            labelContentL.frame = CGRect.init(x: contentDivX, y: startY, width: width-2*contentDivX, height: contentHeight)
            centerView.addSubview(labelContentL)
            startY += contentHeight
        }

        //按鈕：深藍膠囊、白字粗體、寬約視窗 64%、置中
        startY += 14
        let btnHeight:CGFloat = 30
        let btnWidth:CGFloat = (width * 0.64).rounded()
        let nextBtn = UIButton.init(frame: CGRect.init(x: (width-btnWidth)/2, y: startY, width: btnWidth, height: btnHeight))
        nextBtn.setTitle(btnStr1, for: .normal)
        nextBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        nextBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        nextBtn.backgroundColor = darkBlue
        nextBtn.setTitleColor(.white, for: .normal)
        nextBtn.layer.cornerRadius = btnHeight/2
        centerView.addSubview(nextBtn)
        nextBtn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        startY += btnHeight + 20

        //最後位置調整
        centerView.frame = CGRect.init(x: 0, y: 0, width: dialogWidth, height: startY)
        centerView.center = CGPoint(x: self.frame.size.width/2, y: centerY)
        centerView.layer.cornerRadius = 12
        centerView.clipsToBounds = true
    }

    public func initAlert(Title title:String, Content content:String, NextBtn1Str btnStr1:String, CancelBtn1Str btnStr2:String) {
        self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8)
        let divX:CGFloat = 50
        let centerY:CGFloat = self.frame.size.height/2
        
        let closeBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.addSubview(closeBtn)
        closeBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        //背景框
        let centerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width-2*divX, height: 0))
        self.addSubview(centerView)
        centerView.backgroundColor = .white
        let width = centerView.frame.size.width
        var startY:CGFloat = 0
        
        let divX2:CGFloat = 20
        let labelTitleL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelTitleL.textAlignment = .center
        labelTitleL.textColor = .white
        labelTitleL.font = UIFont.systemFont(ofSize: 25)
        labelTitleL.text = title
        labelTitleL.numberOfLines = 0
        labelTitleL.sizeToFit()
        
        startY += 24 + labelTitleL.frame.size.height
        
        //標題列
        let barView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: startY))
        barView.addSubview(labelTitleL)
        barView.backgroundColor = Color_Main_Red
        centerView.addSubview(barView)
        
        labelTitleL.center = CGPoint(x: barView.center.x, y: labelTitleL.center.y)
        
        //內容
        startY += 6
        let labelContentL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelContentL.textColor = .black
        labelContentL.font = UIFont.systemFont(ofSize: 14)
        labelContentL.text = content
        labelContentL.numberOfLines = 0
        labelContentL.sizeToFit()
        centerView.addSubview(labelContentL)
        
        //按鈕
        startY += labelContentL.frame.size.height + 35
        let nextBtn = UIButton.init(frame: CGRect.init(x: divX2, y: startY, width: width-2*divX2, height: 35))
        nextBtn.setTitle(btnStr1, for: .normal)
        nextBtn.backgroundColor = Color_Main_Red
        nextBtn.setTitleColor(.white, for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        centerView.addSubview(nextBtn)
        nextBtn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        startY += nextBtn.frame.size.height + 10
        
        let cancelBtn = UIButton.init(frame: CGRect.init(x: divX2, y: startY, width: width-2*divX2, height: 35))
        cancelBtn.setTitle(btnStr2, for: .normal)
        cancelBtn.layer.borderColor = Color_Main_Red.cgColor
        cancelBtn.layer.borderWidth = 1
        cancelBtn.setTitleColor(Color_Main_Red, for: .normal)
        cancelBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        centerView.addSubview(cancelBtn)
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        startY += cancelBtn.frame.size.height + 20
        
        //最後位置調整
        centerView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width-2*divX, height: startY)
        centerView.center = CGPoint(x: self.frame.size.width/2, y: centerY-20)
        centerView.layer.cornerRadius = 15
        centerView.clipsToBounds = true
        
    }
    
    public func initAmountAlert(Title title:String) {
        self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8)
        let divX:CGFloat = 50
        let centerY:CGFloat = self.frame.size.height/2
        
        let closeBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.addSubview(closeBtn)
        closeBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        //背景框
        let centerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width-2*divX, height: 0))
        self.addSubview(centerView)
        centerView.backgroundColor = .white
        let width = centerView.frame.size.width
        var startY:CGFloat = 0
        
        let divX2:CGFloat = 20
        let labelTitleL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelTitleL.textAlignment = .center
        labelTitleL.textColor = .white
        labelTitleL.font = UIFont.systemFont(ofSize: 25)
        labelTitleL.text = title
        labelTitleL.numberOfLines = 0
        labelTitleL.sizeToFit()
        
        startY += 24 + labelTitleL.frame.size.height
        
        //標題列
        let barView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: startY))
        barView.addSubview(labelTitleL)
        barView.backgroundColor = Color_Main_Red
        centerView.addSubview(barView)
        
        labelTitleL.center = CGPoint(x: barView.center.x, y: labelTitleL.center.y)
        
        let ary = AppDelegate.shared().tempTransferMaxWarningStr.components(separatedBy: " \(AppDelegate.shared().tempTransferMaxAmountStr) ")
        let content1 = ary[0]
        var content2 = ""
        
        if ary.count>1 {
            content2 = ary[1]
        }
        
        //內容1
        startY += 20
        
        let labelContentL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelContentL.textColor = .black
        labelContentL.font = UIFont.systemFont(ofSize: 14)
        labelContentL.text = content1
        labelContentL.numberOfLines = 0
        labelContentL.sizeToFit()
        labelContentL.textAlignment = .center
        labelContentL.center = CGPoint.init(x: barView.center.x, y: labelContentL.center.y)
        centerView.addSubview(labelContentL)
        
        startY += labelContentL.frame.size.height + 15
        
        //數字
        let numL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 54))
        numL.textAlignment = .center
        numL.textColor = Color_Purple
        numL.font = UIFont.boldSystemFont(ofSize: 50)
        numL.text = String.stringToOnlyIntString(Number: AppDelegate.shared().tempTransferMaxAmount)
        centerView.addSubview(numL)
        
        startY += 70
        
        let labelContent2L = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelContent2L.textColor = .black
        labelContent2L.font = UIFont.systemFont(ofSize: 14)
        labelContent2L.text = content2
        labelContent2L.numberOfLines = 0
        labelContent2L.sizeToFit()
        labelContent2L.textAlignment = .center
        labelContent2L.center = CGPoint.init(x: barView.center.x, y: labelContent2L.center.y)
        centerView.addSubview(labelContent2L)
        
        //按鈕
        startY += labelContent2L.frame.size.height + 35
        
        //最後位置調整
        centerView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width-2*divX, height: startY)
        centerView.center = CGPoint(x: self.frame.size.width/2, y: centerY-20)
        centerView.layer.cornerRadius = 15
        centerView.clipsToBounds = true
        
        let nextBtn = UIButton.init(frame: self.bounds)
        nextBtn.backgroundColor = .clear
        nextBtn.setTitleColor(.white, for: .normal)
        nextBtn.setTitle("", for: .normal)
        self.addSubview(nextBtn)
        nextBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
    }
    
    public func initDataCheckAlert(Title title:String, Content content:String, NextBtn1Str btnStr1:String) {
        self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8)
        let divX:CGFloat = 50
        let centerY:CGFloat = self.frame.size.height/2
        
        let closeBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.addSubview(closeBtn)
        closeBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        //背景框
        let centerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width-2*divX, height: 0))
        self.addSubview(centerView)
        centerView.backgroundColor = .white
        let width = centerView.frame.size.width
        var startY:CGFloat = 0
        
        let divX2:CGFloat = 20
        let labelTitleL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelTitleL.textAlignment = .center
        labelTitleL.textColor = .white
        labelTitleL.font = UIFont.systemFont(ofSize: 25)
        labelTitleL.text = title
        labelTitleL.numberOfLines = 0
        labelTitleL.sizeToFit()
        
        startY += 24 + labelTitleL.frame.size.height
        
        //標題列
        let barView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: startY))
        barView.addSubview(labelTitleL)
        barView.backgroundColor = Color_Main_Red
        centerView.addSubview(barView)
        
        labelTitleL.center = CGPoint(x: barView.center.x, y: labelTitleL.center.y)
        
        //icon
        startY += 15
        
        let icon = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 60))
        icon.contentMode = .scaleAspectFit
        icon.center = CGPoint(x: barView.center.x, y: startY + 30)
        icon.image = UIImage.init(named: "user_arc")
        centerView.addSubview(icon)
        
        //內容
        startY += 70
        let labelContentL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelContentL.textColor = .black
        labelContentL.font = UIFont.systemFont(ofSize: 14)
        labelContentL.text = content
        labelContentL.numberOfLines = 0
        labelContentL.sizeToFit()
        
        labelContentL.textAlignment = .center
        labelContentL.center = CGPoint.init(x: barView.center.x, y: labelContentL.center.y)
        centerView.addSubview(labelContentL)
        
        //按鈕
        startY += labelContentL.frame.size.height + 35
        let nextBtn = UIButton.init(frame: CGRect.init(x: divX2, y: startY, width: width-2*divX2, height: 35))
        nextBtn.setTitle(btnStr1, for: .normal)
        nextBtn.backgroundColor = Color_Main_Red
        nextBtn.setTitleColor(.white, for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        centerView.addSubview(nextBtn)
        nextBtn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        nextBtn.addGradienOfIndoGo()
        startY += nextBtn.frame.size.height + 25
        
        //最後位置調整
        centerView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width-2*divX, height: startY)
        centerView.center = CGPoint(x: self.frame.size.width/2, y: centerY-20)
        centerView.layer.cornerRadius = 15
        centerView.clipsToBounds = true
        
    }
    
    public func initTwoActionAlert(Title title:String, Content content:String, NextBtn1Str btnStr1:String, NextBtn2Str btnStr2:String, CancelBtn1Str btnStr3:String) {
        self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8)
        let divX:CGFloat = 50
        let centerY:CGFloat = self.frame.size.height/2
        
        let closeBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.addSubview(closeBtn)
        closeBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        //背景框
        let centerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width-2*divX, height: 0))
        self.addSubview(centerView)
        centerView.backgroundColor = .white
        let width = centerView.frame.size.width
        var startY:CGFloat = 0
        
        let divX2:CGFloat = 20
        let labelTitleL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelTitleL.textAlignment = .center
        labelTitleL.textColor = .white
        labelTitleL.font = UIFont.systemFont(ofSize: 25)
        labelTitleL.text = title
        labelTitleL.numberOfLines = 0
        labelTitleL.sizeToFit()
        
        startY += 24 + labelTitleL.frame.size.height
        
        //標題列
        let barView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: startY))
        barView.addSubview(labelTitleL)
        barView.backgroundColor = Color_Main_Red
        centerView.addSubview(barView)
        
        labelTitleL.center = CGPoint(x: barView.center.x, y: labelTitleL.center.y)
        
        //內容
        startY += 6
        let labelContentL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelContentL.textColor = .black
        labelContentL.font = UIFont.systemFont(ofSize: 14)
        labelContentL.text = content
        labelContentL.numberOfLines = 0
        labelContentL.sizeToFit()
        centerView.addSubview(labelContentL)
        
        //按鈕
        startY += labelContentL.frame.size.height + 35
        let nextBtn = UIButton.init(frame: CGRect.init(x: divX2, y: startY, width: width-2*divX2, height: 35))
        nextBtn.setTitle(btnStr1, for: .normal)
        nextBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        nextBtn.backgroundColor = .clear
        nextBtn.layer.borderColor = Color_Main_Red.cgColor
        nextBtn.layer.borderWidth = 1
        nextBtn.setTitleColor(Color_Main_Red, for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        centerView.addSubview(nextBtn)
        nextBtn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        startY += nextBtn.frame.size.height + 10
        
        //按鈕2
        let nextBtn2 = UIButton.init(frame: CGRect.init(x: divX2, y: startY, width: width-2*divX2, height: 35))
        nextBtn2.setTitle(btnStr2, for: .normal)
        nextBtn2.backgroundColor = Color_Main_Red
        nextBtn2.setTitleColor(.white, for: .normal)
        nextBtn2.layer.cornerRadius = nextBtn.frame.size.height/2
        centerView.addSubview(nextBtn2)
        nextBtn2.addTarget(self, action: #selector(nextActionSecond), for: .touchUpInside)
        
        startY += nextBtn2.frame.size.height + 10
        
        let cancelBtn = UIButton.init(frame: CGRect.init(x: divX2, y: startY, width: width-2*divX2, height: 35))
        cancelBtn.setTitle(btnStr3, for: .normal)
        cancelBtn.layer.borderColor = Color_Main_Red.cgColor
        cancelBtn.layer.borderWidth = 1
        cancelBtn.setTitleColor(Color_Main_Red, for: .normal)
        cancelBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        centerView.addSubview(cancelBtn)
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        startY += cancelBtn.frame.size.height + 20
        
        //最後位置調整
        centerView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width-2*divX, height: startY)
        centerView.center = CGPoint(x: self.frame.size.width/2, y: centerY-50)
        centerView.layer.cornerRadius = 15
        centerView.clipsToBounds = true
        
    }
    
    @objc func nextAction() {
        customDelegate?.customAlertnextAction(Ref: self)
    }
    
    @objc func nextActionSecond() {
        customDelegate?.customAlertnextActionSecond(Ref: self)
    }
    
    
    @objc func cancelAction() {
        if !tapOutsideToClose {
            return
        }
        self.removeFromSuperview()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
