//
//  ViewController.swift
//  ScanBarcode
//
//  Created by tingting on 2018/9/26.
//  Copyright © 2018年 tingting. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var detail_label: UILabel!
    
    @IBAction func showAlert(_ sender: Any) {
        ATAlertView.shareInstance.show(title: "测试")
    }
    var backView: UIView = {
        let bv = UIView()
        bv.backgroundColor = UIColor.cyan
        return bv
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.addSubview(self.backView)
        self.backView.center = self.view.center
        self.backView.bounds = CGRect(x: 0, y: 0, width: atPhotoWidth, height: atPhotoWidth)
        self.view.sendSubviewToBack(self.backView)
    }

    //判断是否跳转
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return ATQRCodeHelper.at_checkCameraAvilable()
    }
    //一般在这里 传值
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //
    }
}

