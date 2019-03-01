//
//  NotificationHandler.swift
//  UNDemo
//
//  Created by ting on 2019/1/24.
//  Copyright © 2019 tingting. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

/**
     public static var badge: UNAuthorizationOptions { get }
 
     public static var sound: UNAuthorizationOptions { get }
 
     public static var alert: UNAuthorizationOptions { get }
 
     public static var carPlay: UNAuthorizationOptions { get }
 
     // 重要警报，可无视勿扰模式和铃声开关的限制进行提醒，适用于灾难预警等重要信息
     // 需要单独申请权限
     @available(iOS 12.0, *)
     public static var criticalAlert: UNAuthorizationOptions { get }
 
     // 在通知管理里直接进入app内部设置页面时使用(跳转需自己在代理方法中处理)
     // 代理方法为 userNotificationCenter(_:,openSettingsFor)，后续会讲
     @available(iOS 12.0, *)
     public static var providesAppNotificationSettings: UNAuthorizationOptions { get }
 
     // 临时授权，通知会以隐式推送的方式推送，并带有两个权限按钮让用户自己选择之后正常推送还是关闭
     // 隐式推送:出现在通知中心并可在应用图标上出现标记，但不会显示在锁定屏幕上，不会显示横幅，也不会播放声音
     @available(iOS 12.0, *)
     public static var provisional: UNAuthorizationOptions { get }
 */

enum UserNotificationType:String {
    case timeInterval
    case timeIntervalForeground
    case pendingRemoval
    case pendingUpdate
    case deliveredRemoval
    case deliveredUpdate
    case actionable
    case mutableContent
    case media
    case customUI
}

extension UserNotificationType {
    var descriptionText:String {
        switch self {
        case .timeInterval:
            return "You need to switch to background to see the notification."
        case .timeIntervalForeground:
            return "The notification will show in-app. See NotificationHandlerfor more."
        default:
            return rawValue
        }
    }
    
    var title:String {
        switch self {
        case .timeInterval:
            return "Time"
        case .timeIntervalForeground:
            return "Foreground"
        default:
            return rawValue
        }
    }
}

enum UserNotificationCategoryType:String {
    case onlyTextMessage
    case customUI
}
enum TextMessageCategoryAction:String {
    case input      //输入框
    case accept     //接受
    case decline    //拒绝
    case cancel     //取消
    case send       //发送
    case confirm    //确定
    case none       //None
}
extension TextMessageCategoryAction {
    
    static func textMessageHandler(response:UNNotificationResponse) {
        let text:String
        
        if let actionType =  TextMessageCategoryAction(rawValue: response.actionIdentifier){
            switch actionType {
            case .input: text = (response as! UNTextInputNotificationResponse).userText
            case .accept:
                text = ""
            case .decline:
                text = ""
            case .cancel:
                text = ""
            case .send:
                text = ""
            case .confirm:
                text = ""
            case .none:
                text = ""
            }
        }
        else {
            // Only tap or clear. (You will not receive this callback when user clear your notification unless you set .customDismissAction as the option of category)
            text = ""
        }
        if !text.isEmpty {
            UIAlertController.showConfirmAlertFromTopViewController(message: "You just said \(text)")
        }
    }
}

let threadIndetifier = "app-threadIndetifier"

class NotificationHandler: NSObject {
    static let share = NotificationHandler()

    public func initNotificationCenter() {
        //请求授权
        let notificationCenter = UNUserNotificationCenter.current()
        //请求通知支持的形式   Asking Permission to Use Notifications.
        var options:UNAuthorizationOptions =  [UNAuthorizationOptions.alert,UNAuthorizationOptions.alert,UNAuthorizationOptions.sound,UNAuthorizationOptions.badge]
        if #available(iOS 12.0, *) {
            options = [.alert,.sound,.badge,.providesAppNotificationSettings]
        }
        // Declaring Your Actionable Notification Types
        configLocalNotification()
        
        //TODO: 第一次启动APP 拉起系统授权弹框
        notificationCenter.requestAuthorization(options: options) { (granted, error) in
            if granted {
                // Enable or disable features based on authorization.
            }
        }
        //Configure Notification Support Based on Authorized Interactions
        notificationCenter.getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else{return}
            if settings.alertSetting == .enabled {
                self.myScheduleAlertnotification()
            }
            else {
                self.badgeAppAndPlaySound()
            }
        }
        //Declaring Your Actionable Notification Types
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION", title: "Accept", options: UNNotificationActionOptions(rawValue: 0))
        let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION", title: "Decline", options: UNNotificationActionOptions(rawValue: 0))
        
        let meetingInviteCategory = UNNotificationCategory(identifier: "MEETING_INVITATION", actions: [acceptAction,declineAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
        notificationCenter.setNotificationCategories([meetingInviteCategory])
        
        notificationCenter.delegate = self
        
    }
    private func configContentCategory() -> UNNotificationCategory {
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION", title: "Accept", options: UNNotificationActionOptions(rawValue: 0))
        let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION", title: "Decline", options: UNNotificationActionOptions(rawValue: 0))
        let inputAction = UNTextInputNotificationAction(identifier: "SEND_ACTION", title: "Send", options: UNNotificationActionOptions(rawValue: 0), textInputButtonTitle: "Send", textInputPlaceholder: "请输入")
        
        //摘要
        let summaryFormat = "%u 更多信息!来自OceanFish"
        return UNNotificationCategory(identifier: "category-identifier", actions: [acceptAction,declineAction,inputAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: nil, categorySummaryFormat: summaryFormat, options: [])
    }
    
    func configLocalNotification() {
        //Include a Notification Category in the Payload
        let content = UNMutableNotificationContent()
        content.title = "Weekly Staff Meeting"
        content.body = "Every Tuesday at 2pm"
        //通知的附件内容
        let filePath = Bundle.main.path(forResource: "YZFimg@2x", ofType: "png")
        if filePath != nil {
            let att = try? UNNotificationAttachment(identifier: "att1", url: URL.init(fileURLWithPath: filePath!), options: nil)
            content.attachments = [att] as! [UNNotificationAttachment]
        }
        content.badge = 1
        content.launchImageName = "YZFimg@2x"
        content.subtitle = "hhd-subtitle"
        
        //摘要
        content.summaryArgument = "说的是摘要 但是不是很明白"
        content.summaryArgumentCount = 3
        //通过这个属性设置分组，如果此属性没有设置则以APP为分组依据
        content.threadIdentifier = threadIndetifier
        //设置声音
        content.sound = UNNotificationSound.default
        
        content.userInfo = ["MEETING_ID":"123456789",
                            "USER_ID":"ABCD1234"]
        content.categoryIdentifier = "MEETING_INVITATION"
        /*
         {
         “aps” : {
         “category” : “MEETING_INVITATION”
         “alert” : {
         “title” : “Weekly Staff Meeting”
         “body” : “Every Tuesday at 2pm”
         },
         },
         “MEETING_ID” : “123456789”,
         “USER_ID” : “ABCD1234”
         }
         */
        //触发模式
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "TestRequet", content: content, trigger: trigger)
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            print("\(error.debugDescription)")
        }
    }
    
    private func myScheduleAlertnotification() {
        print("\(#file)____\(#line)____\(#function)")
    }
    private func badgeAppAndPlaySound() {
        print("\(#file)____\(#line)____\(#function)")
    }
}

extension NotificationHandler:UNUserNotificationCenterDelegate {
    //TODO:@available(iOS 10.0, *)
    //APP在前台、进入前台的时候 通知执行该方法
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("\(#line)_\(#function)_\(notification.request.content.userInfo)")
        
        guard let notificationType = UserNotificationType(rawValue: notification.request.identifier) else {
            completionHandler([])
            return
        }
        let options:UNNotificationPresentationOptions
        
        switch notificationType {
        case .timeIntervalForeground:
            options = [.alert,.sound]
        case .media:
            options = [.alert,.sound]
        default:
            options = []
        }
        completionHandler(options)
    }
    //APP在后台时 执行该方法
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let category = UserNotificationCategoryType(rawValue: response.notification.request.content.categoryIdentifier) {
            switch category {
            case .onlyTextMessage: TextMessageCategoryAction.textMessageHandler(response: response)
            case .customUI:
                break
            }
        }
        completionHandler()
    }
    
    //TODO:@available(iOS 12.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        //
    }
}
