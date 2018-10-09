//
//  ATAlertView.swift
//  ScanBarcode
//
//  Created by tingting on 2018/9/26.
//  Copyright © 2018年 tingting. All rights reserved.
//

import UIKit

class ATAlertView: NSObject {
    
    lazy var title_lab: UILabel = {
        let title = UILabel()
        title.textAlignment = .center
        title.textColor = UIColor.black
        title.font = UIFont.systemFont(ofSize: 15)
        return title
    }()
    
    lazy var detail_lab: UILabel = {
        let title = UILabel()
        title.textAlignment = .center
        title.textColor = UIColor.black
        title.font = UIFont.systemFont(ofSize: 15)
        return title
    }()
    
    private var bgView: UIView = {
        let bg = UIView()
        bg.backgroundColor = UIColor.blue
        return bg
    }()
    
    var title: String {
        get {
            return title_lab.text ?? ""
        }
        set {
            title_lab.text = newValue
        }
        
    }
    var detail:String {
        set {
            detail_lab.text = newValue
        }
        get {
            return detail_lab.text!
        }
    }
    
    static let shareInstance = ATAlertView()

    public func show(title: String?) -> () {
        let currentViewController = UIApplication.shared.topMostViewController()
        let alertView = UIAlertController(title: title, message: nil, preferredStyle: .alert);
//        setupViews(view: alertView.view)
        let alertAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (alert) in
            //
        }
        alertView.addAction(alertAction)
        currentViewController.present(alertView, animated: true, completion: nil)
    }
    
    private func setupViews(view: UIView) -> () {
        view.addSubview(bgView)
        view.sendSubviewToBack(bgView)
        bgView.addSubview(title_lab)
        bgView.addSubview(detail_lab)
        bgView.translatesAutoresizingMaskIntoConstraints = false
        title_lab.translatesAutoresizingMaskIntoConstraints = false
        detail_lab.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .leading, relatedBy: .equal, toItem: bgView, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .trailing, relatedBy: .equal, toItem: bgView, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .centerY, relatedBy: .equal, toItem: bgView, attribute: .centerY, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: view, attribute: .height, relatedBy: .equal, toItem: bgView, attribute: .height, multiplier: 1, constant: 0))

//        bgView.addConstraint(NSLayoutConstraint.init(item: bgView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 40))
        
        bgView.addConstraint(NSLayoutConstraint.init(item: bgView, attribute: .leading, relatedBy: .equal, toItem: detail_lab, attribute: .leading, multiplier: 1, constant: 0))
        bgView.addConstraint(NSLayoutConstraint.init(item: bgView, attribute: .trailing, relatedBy: .equal, toItem: detail_lab, attribute: .trailing, multiplier: 1, constant: 0))
        bgView.addConstraint(NSLayoutConstraint.init(item: bgView, attribute: .centerY, relatedBy: .equal, toItem: detail_lab, attribute: .centerY, multiplier: 1, constant: 0))
        
        bgView.addConstraint(NSLayoutConstraint.init(item: bgView, attribute: .leading, relatedBy: .equal, toItem: title_lab, attribute: .leading, multiplier: 1, constant: 0))
        bgView.addConstraint(NSLayoutConstraint.init(item: bgView, attribute: .trailing, relatedBy: .equal, toItem: title_lab, attribute: .trailing, multiplier: 1, constant: 0))
        bgView.addConstraint(NSLayoutConstraint.init(item: detail_lab, attribute: .top, relatedBy: .equal, toItem: title_lab, attribute: .bottom, multiplier: 1, constant: 10))

    }
    
}
