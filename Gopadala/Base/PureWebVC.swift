//
//  PureWebVC.swift
//  indogo
//
//  Created by mac on 2020/8/11.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import WebKit

class PureWebVC: UIViewController {

    @IBOutlet weak var backL: UILabel!
    @IBOutlet weak var webView: WKWebView!
    var backTitle = ""
    var urlStr = ""
    
    @IBAction func backAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    public func setTitleAndCallURL(URL urlString:String, Title title:String) {
        backTitle = title
        urlStr = urlString
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()

        guard let oldWebView = webView,
              let superview = oldWebView.superview else {
            return
        }

        let newWebView = WKWebView(frame: .zero, configuration: config)
        newWebView.translatesAutoresizingMaskIntoConstraints = false

        superview.insertSubview(newWebView, aboveSubview: oldWebView)

        let constraintsToCopy = superview.constraints.filter { constraint in
            (constraint.firstItem as AnyObject?) === oldWebView ||
            (constraint.secondItem as AnyObject?) === oldWebView
        }

        for constraint in constraintsToCopy {
            let firstItem = ((constraint.firstItem as AnyObject?) === oldWebView) ? newWebView : constraint.firstItem
            let secondItem = ((constraint.secondItem as AnyObject?) === oldWebView) ? newWebView : constraint.secondItem

            let newConstraint = NSLayoutConstraint(
                item: firstItem as Any,
                attribute: constraint.firstAttribute,
                relatedBy: constraint.relation,
                toItem: secondItem,
                attribute: constraint.secondAttribute,
                multiplier: constraint.multiplier,
                constant: constraint.constant
            )
            newConstraint.priority = constraint.priority
            newConstraint.shouldBeArchived = constraint.shouldBeArchived
            newConstraint.identifier = constraint.identifier
            newConstraint.isActive = true
        }

        oldWebView.removeFromSuperview()
        self.webView = newWebView
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        backL.text = backTitle
        let url = URL(string: urlStr)
        Dlog("urlStr = \(urlStr)")
        let request = URLRequest(url: url!)
        webView.load(request)
    }
    
    /*
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // NOTE: WKWebViewConfiguration must be provided at initialization time.
        // You cannot assign to an existing WKWebView's configuration.
        let config = WKWebViewConfiguration()
        config.websiteDataStore = .nonPersistent()

        // Replace the storyboard WKWebView with a new one using this configuration
        let oldWebView = webView
        let newWebView = WKWebView(frame: .zero, configuration: config)
        newWebView.translatesAutoresizingMaskIntoConstraints = false

        if let superview = oldWebView?.superview {
            superview.insertSubview(newWebView, aboveSubview: oldWebView!)
            NSLayoutConstraint.activate([
                newWebView.leadingAnchor.constraint(equalTo: oldWebView!.leadingAnchor),
                newWebView.trailingAnchor.constraint(equalTo: oldWebView!.trailingAnchor),
                newWebView.topAnchor.constraint(equalTo: oldWebView!.topAnchor),
                newWebView.bottomAnchor.constraint(equalTo: oldWebView!.bottomAnchor)
            ])
            oldWebView?.removeFromSuperview()
        } else {
            // Fallback (should not happen in storyboard)
            view.addSubview(newWebView)
            NSLayoutConstraint.activate([
                newWebView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                newWebView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                newWebView.topAnchor.constraint(equalTo: view.topAnchor),
                newWebView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }

        self.webView = newWebView
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        backL.text = backTitle
        let url = URL(string: urlStr)
        let request = URLRequest(url: url!)
        webView.load(request)
    }*/
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

