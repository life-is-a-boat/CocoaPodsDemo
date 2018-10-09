//
//  DismissSegue.swift
//  ScanBarcode
//
//  Created by tingting on 2018/9/26.
//  Copyright © 2018年 tingting. All rights reserved.
//

import UIKit

class DismissSegue: UIStoryboardSegue {
    override func perform() {
        let sourceViewController = self.source
        sourceViewController.presentingViewController!.dismiss(animated: true, completion: nil)
    }
}
