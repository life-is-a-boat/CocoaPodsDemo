//
//  UIAlertControllerExtension.swift
//  UNDemo
//
//  Created by ting on 2019/1/25.
//  Copyright © 2019 tingting. All rights reserved.
//

import UIKit

extension UIAlertController {
    static func showConfirmAlert(message:String,in viewController:UIViewController) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    static func showConfirmAlertFromTopViewController(message:String){
        if let vc = UIApplication.shared.keyWindow?.rootViewController {
            showConfirmAlert(message: message, in: vc)
        }
    }
}
