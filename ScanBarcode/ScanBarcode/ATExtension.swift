//
//  ATExtension.swift
//  ScanBarcode
//
//  Created by tingting on 2018/9/26.
//  Copyright © 2018年 tingting. All rights reserved.
//
import UIKit

extension UIViewController {
    public func topMostViewController() -> UIViewController {
        if (self.presentedViewController == nil || self.presentedViewController is UIImagePickerController){
            return self
        }
        else if self.presentedViewController is UINavigationController {
            let navigationViewController = self.presentedViewController as! UINavigationController
            let lastViewController = navigationViewController.viewControllers.last
            return (lastViewController?.topMostViewController())!
        }
        
        let presentedViewController1 = self.presentedViewController
        return presentedViewController1!.topMostViewController()
    }
}

extension UIApplication {
    public func topMostViewController() -> UIViewController {
        return (self.currentWindow().rootViewController?.topMostViewController())!
    }
    
    public func currentViewController() -> UIViewController? {
        var result: UIViewController?
        var window: UIWindow = UIApplication.shared.keyWindow!
        if window.windowLevel != .normal {
            let windows = UIApplication.shared.windows
            for tmpWin in windows {
                if tmpWin.windowLevel == UIWindow.Level.normal {
                    window = tmpWin
                    break
                }
            }
        }
        let frontView = window.subviews.first
        let nextResponder = frontView?.next
        if nextResponder is UIViewController {
            result = (nextResponder as! UIViewController)
        }
        else {
            result = window.rootViewController
        }
        return result
    }
    
    private func currentControler() -> UIViewController {
        var viewController: UIViewController? = nil
        let window = currentWindow()
        if window.rootViewController is UITabBarController {
            let viewController1 = (window.rootViewController as! UITabBarController).presentedViewController
            if viewController1 is UINavigationController {
                viewController = (viewController1 as! UINavigationController).presentedViewController!
            }
        }
        else if window.rootViewController is UINavigationController {
            viewController = (window.rootViewController as! UINavigationController).presentedViewController!
        }
        return viewController!
    }
    func currentWindow() -> UIWindow {
        var window = UIApplication.shared.windows.first
        if window == nil {
            window = UIApplication.shared.keyWindow
        }
        return window!
    }
}

