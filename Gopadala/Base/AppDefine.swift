//
//  AppDefine.swift
//  GISWork
//
//  Created by askAir on 2018/10/7.
//  Copyright © 2018年 TrendGo. All rights reserved.
//

import Foundation
import UIKit

//尺寸
var AppWidth:CGFloat = 320.0
var AppTotalHeight:CGFloat = 960.0
var AppTopBarHeight:CGFloat = 50.0
var AppBottomBarHeight:CGFloat = 50.0
var AppEmptyHeight:CGFloat = 800.0
var FirebaseToken = ""

var ImageLimitInBytes:Int = 300000

let SecureSaltStr = "indo"
let SecureIvStr = "indogoEncodeIv00"
let SecurePSStr = "indogoEncodePass"
let AES28Key = "cryptindogocrypt"

//顏色
public let Color_Main_Bule = UtilityTool().hexStringToUIColor(hex: "#2a65ec")
public let Color_Main_Red = UtilityTool().hexStringToUIColor(hex: "#0032A0") //UtilityTool().hexStringToUIColor(hex: "#b20808")
public let Color_Main_LightGray = UtilityTool().hexStringToUIColor(hex: "#d6d7d8")
public let Color_Main_DarkGray = UtilityTool().hexStringToUIColor(hex: "#3b3f47")
public let Color_Gradient_Left = UtilityTool().hexStringToUIColor(hex: "#0c5ed9")
public let Color_Gradient_Right = UtilityTool().hexStringToUIColor(hex: "#0032a0")

public let Color_BtnChose = UIColor.init(named: "BtnChose")!
public let Color_BtnNotChose = UIColor.init(named: "BtnNotChose")!
public let Color_NewBg = UIColor.init(named: "NewBg")!
public let Color_Purple = UIColor.init(named: "Purple")!

//開發階段
let DevMode = false
let Lang_APIDecodeFail = NSLocalizedString("API DecodeFail", comment: "伺服器忙線中，請稍候再試")

let AppVersion = "1.0"
let AppId = 1
//正式
// ---- 環境切換（由 CTO 維護；見 ../docs/工作流程.md）----
// Debug build（開發、QA）打測試機；Release / Archive 打正式機。不要再用註解切換。
let ProdServerURL = "https://prod.gopadala.com.tw"
let TestServerURL = "https://test-prod.gopadala.com.tw"   // 測試機（後端 2026-10-16 提供）。上線 Archive 用 Release，自動走 ProdServerURL
#if DEBUG
let ServerURL = TestServerURL
#else
let ServerURL = ProdServerURL
#endif
//(測試機全家會有問題)

let PinCodeMode = 3

//訂票時限
let orderTicketTimeLimitSecs:Double = 300

//API後續網址設定
let API_Promo = ServerURL + "/app/remit/app_photos"
let API_Login = ServerURL + "/app/remit/login"
let API_CheckArcExist = ServerURL + "/app/check_arc_exists"
let API_CheckLogin = ServerURL + "/app/remit/check_token"
let API_CheckMemExist = ServerURL + "/app/remit/check_mem_exists"
let API_SendSMS = ServerURL + "/app/remit/password_forget_sms"
let API_Register = ServerURL + "/app/remit/register"
let API_RegisterStep1 = ServerURL + "/app/remit/register_step_1"
let API_RegisterStep2 = ServerURL + "/app/remit/register_step_2"
let API_ResendRegisterSMS = ServerURL + "/app/remit/request_sms_code"
let API_VerifyRegisterSMS = ServerURL + "/app/remit/verify_sms_code"
let API_NoticeRecordList = ServerURL + "/app/remit/notification_record"
let API_PointHistoryList = ServerURL + "/app/remit/point_history"
let API_GetDoc = ServerURL + "/app/remit/doc_get"
let API_TransferPointFirstStep = ServerURL + "/app/remit/point_transfer_check"
let API_TransferPointSecondStep = ServerURL + "/app/remit/point_transfer"
let API_MemberRecipents = ServerURL + "/app/remit/member_recipients"
let API_MemberRecipentsOther = ServerURL + "/app/remit/get_member_recipients_others"
let API_MemberRecipentsOther_Transfer = ServerURL + "/app/remit/member_recipients_others"
let API_MemberCheckAmountOther = ServerURL + "/app/remit/member_recipients_others"
let API_MemberHideRecipent = ServerURL + "/app/remit/hide_recipient"
let API_MemberDelete = ServerURL + "/app/remit/delete_member"
let API_BankList = ServerURL + "/app/remit/bank_list"
let API_AddRecipient = ServerURL + "/app/remit/add_recipient_v2"
let API_TransferHistory = ServerURL + "/app/remit/money_transfer_history"
let API_OrderCheckSingle = ServerURL + "/app/remit/order_check"
let API_OrderCheckMuilti = ServerURL + "/app/remit/orders_check"
let API_TransactionCreate = ServerURL + "/app/remit/create"
let API_BarCode_711 = ServerURL + "/app/remit/ibon_barcode"
let API_BarCode_fami = ServerURL + "/app/remit/fami_barcode"
let API_BarCode_ok = ServerURL + "/app/remit/ok_barcode"
let API_BarCode_hilife = ServerURL + "/app/remit/hilife_barcode"
let API_NotificationRead = ServerURL + "/app/remit/notification_read"
let API_UpdateARC = ServerURL + "/app/remit/update_arc"
let API_UpdateID = ServerURL + "/app/remit/update_id_card"
let API_PassUpdate = ServerURL + "/app/remit/password_update"
let API_PhoneTokenSet = ServerURL + "/app/remit/phone_token_set"

let API_GetBankCode = ServerURL + "/console/api/getVAccount"
let API_GetPurpose = ServerURL + "/app/remit/transfer_purpose"
let API_GetRelation = ServerURL + "/app/remit/relationship"
let API_SendUpdatePhoneSMS = ServerURL + "/app/remit/update_phone_sms"
let API_VerifyUpdatePhoneSMS = ServerURL + "/app/remit/update_phone"

let API_GetInfo = ServerURL + "/app/get_info"
let API_VerifyPointMsg = ServerURL + "/app/remit/verify_point_msg"
let API_VerifyPoint = ServerURL + "/app/remit/verify_point"
let API_DataCheck = ServerURL + "/app/remit/data_check"

let API_BankBranch = ServerURL + "/app/remit/getBranchAreaList"

let API_ShareMemberCheck = ServerURL + "/app/remit/share_member_check"

let API_CashPickupOptionList = ServerURL + "/app/remit/getCashPickupOptions"
let API_PaymentTypeList = ServerURL + "/app/remit/getPaymentTypeList"
let API_PHNContributionList = ServerURL + "/app/remit/getPHNContributionList"
let API_SSSContributionList = ServerURL + "/app/remit/getSSSContributionList"
let API_AddRecipient_Other = ServerURL + "/app/remit/add_recipient_v2_others"
let API_TransactionCreate_Other = ServerURL + "/app/remit/create_others"

let API_GetQuota = ServerURL + "/app/remit/get_quota"

let API_TransferToday = ServerURL + "/app/remit/money_transfer_today"
let API_TransferHistoryBeforeToday = ServerURL + "/app/remit/money_transfer_before_today"
let API_CheckDiscountCode = ServerURL + "/app/remit/check_discount_code"

let API_MemberRecipentsV2 = ServerURL + "/app/remit/member_recipients_v2"
let API_MemberRecipentsOther_TransferV2 = ServerURL + "/app/remit/member_recipients_others_v2"

let API_TransactionCreateV2 = ServerURL + "/app/remit/create_v2"
let API_TransactionCreate_OtherV2 = ServerURL + "/app/remit/create_others_v2"

//後台控制 App icon（POST、免參數，回傳 remit_reply 0 <icon名稱>）
let API_LauncherIcon = ServerURL + "/app/getLauncherIcon.php"

public enum TransferMemberStyle {
    case normal
    case shop
}

enum MemberPhotoEditFrom {
    case avatar
    case visa
    case none
}

enum EnterPassNextAction {
    case Login
    case Transfer
}

enum ScanParentType {
    case forgotPass
    case register
    case mainToScan
}

enum PhotoIDType {
    case normal
    case front
    case back
    case faceAndId
    case passport
    case sign
    case normalFromEdit
    case frontFromEdit
    case backFromEdit
    case faceAndIdFromEdit
    case passportFromEdit
    case signFromEdit
}

enum LoginFuncType {
    case main
    case member
    case transState
    case transaction
    case sharing
    case notice
}

enum StoreType {
    case sevenEleven
    case familymart
    case ok
    case hiLife
}

enum BottomMenuType {
    case transaction
    case transState
    case sharing
    case notice
    case profile
}

enum TransferMethod {
    case Bank, Cash, SSS, Pag, Health
}

enum AddRecipientRowType {
    case txt, select, day, total
}

enum AddRecipientRowSubType {
    case none,t_txt, t_phone, t_banknum, t_num, t_php, t_ntd, d_birth, d_from, d_to, s_cashOption, s_bank, s_relation, s_branch, s_payType, s_contribution, s_contribution_loan, s_shortTermLoan, s_phpAmount
}

struct checkCode {
    var result:Bool = true
    var message:String = ""
}
