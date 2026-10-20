//
//  FraudMessageGate.swift
//  indogo
//
//  新增收款人前的防詐提醒（compliance-202610 需求2）。
//  所有會進新增收款人頁的入口都改成：
//      FraudMessageGate.shared.check { [weak self] in ...進新增收款人頁... }
//
//  行為（對齊 Android 最終版，見 docs/spec/三國合規更新.md）
//  1. 先呼叫 API_FraudMessage，期間 loading，進行中不接受第二次呼叫
//  2. 成功且有文字：跳提醒視窗，點外面關不掉，只有一顆確認鈕
//  3. 按確認才執行 proceed
//  4. 成功但文字空白：不跳窗，直接 proceed
//  5. 失敗（非 0、網路錯誤、404）：跳錯誤，不放行；9001 照既有慣例不另外跳窗
//

import UIKit
import Alamofire

final class FraudMessageGate: NSObject, CustomAlertDelegate {
    
    static let shared = FraudMessageGate()
    
    /// API 進行中或提醒視窗顯示中，擋連點
    private(set) var isRunning = false
    private var proceedAction: (() -> Void)?
    
    func check(_ proceed: @escaping () -> Void) {
        if isRunning {
            return
        }
        isRunning = true
        proceedAction = proceed
        
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "gps_code":AppDelegate.shared().gpsCode, "mobile_type":"iphone","ip_addr":AppDelegate.shared().ipAddr, "req_timestamp":Date.giveCurrentDateString()]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_FraudMessage
        
        AppDelegate.shared().alamofireManagerWithTimeout.requestWithoutCache(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in
                AppDelegate.shared().removeLoadingView()
                
                guard response.result.error == nil, let data = response.data, let responseStr = String.init(data: data, encoding: String.Encoding.utf8) else {
                    print("error calling on \(todoEndpoint)")
                    self.fail(Message: NSLocalizedString("API Timeout", comment: ""))
                    return
                }
                
                Dlog("(\(todoEndpoint), responseStr = \(responseStr)")
                
                AppDelegate.shared().fraudMessageStr = ""
                let result = APIHandle().getResponseState(ResponseStr: responseStr, APIStr: todoEndpoint, SubStr: "")
                
                if result == ResponseState.ok {
                    let msg = AppDelegate.shared().fraudMessageStr
                    if msg == "" {
                        self.finishAndProceed()
                    } else {
                        self.showAlert(Message: msg)
                    }
                    return
                }
                
                //9001 由 getResponseState 依既有慣例處理（登出回首頁），不另外跳窗
                if self.responseCode(responseStr) == "9001" {
                    self.reset()
                    return
                }
                
                //非 remit_reply 格式（例如 404 頁面）時 apiBackContentStr 不會被更新，改顯示連線錯誤
                let backMsg = responseStr.hasPrefix("remit_reply") ? AppDelegate.shared().apiBackContentStr : ""
                self.fail(Message: backMsg != "" ? backMsg : NSLocalizedString("API Timeout", comment: ""))
            }
    }
    
    //MARK: - Private
    private func showAlert(Message msg:String) {
        guard let window = UIApplication.shared.keyWindow else {
            fail(Message: NSLocalizedString("API Timeout", comment: ""))
            return
        }
        let customAlert = CustomAlertView.init(frame: window.bounds)
        customAlert.tapOutsideToClose = false
        customAlert.initFraudAlert(Title: NSLocalizedString("Fraud Alert Title", comment: ""), Content: msg, NextBtn1Str: NSLocalizedString("Fraud Alert Confirm", comment: ""))
        customAlert.customDelegate = self
        window.addSubview(customAlert)
    }
    
    private func fail(Message msg:String) {
        reset()
        AppDelegate.shared().showAlertView(Message: msg, ConfrimStr: NSLocalizedString("cancelForError", comment: ""))
    }
    
    private func finishAndProceed() {
        let action = proceedAction
        reset()
        action?()
    }
    
    private func reset() {
        isRunning = false
        proceedAction = nil
    }
    
    /// 取 remit_reply 後面的狀態碼
    private func responseCode(_ resStr:String) -> String {
        let parts = resStr.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
        if parts.count >= 2, parts[0] == "remit_reply" {
            return String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return ""
    }
    
    //MARK: - CustomAlertDelegate
    func customAlertnextAction(Ref obj: CustomAlertView) {
        obj.removeFromSuperview()
        finishAndProceed()
    }
    
    func customAlertnextActionSecond(Ref obj: CustomAlertView) {
        
    }
}
