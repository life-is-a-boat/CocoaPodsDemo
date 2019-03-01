//
//  UIApplication+NotificationHandler.swift
//  UNDemo
//
//  Created by ting on 2019/1/24.
//  Copyright © 2019 tingting. All rights reserved.
//
import UIKit

extension AppDelegate {
    func didFinishLaunchingWithOptions(launchOptions:[UIApplication.LaunchOptionsKey: Any]?) -> () {
        //初始化
        NotificationHandler.share.initNotificationCenter()
        
        //注册
        UIApplication.shared.registerForRemoteNotifications()
    }
    //TODO: delegate
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        //
    }

}
