//
//  ATQRCodeHelper.swift
//  ScanBarcode
//
//  Created by tingting on 2018/9/26.
//  Copyright © 2018年 tingting. All rights reserved.
//

import UIKit
import AVFoundation

struct ATQRCodeHelper {
    @discardableResult
    static func at_checkCameraEnable() -> Bool {
        return (UIImagePickerController.availableMediaTypes(for: .camera) != nil)
//        return (UIImagePickerController.isCameraDeviceAvailable(.rear) ||  UIImagePickerController.isCameraDeviceAvailable(.front))
    }
    @discardableResult
    static func at_checkCamera() -> Bool {
        let cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
        switch cameraAuthStatus {
        case .authorized:
            return true
        case .notDetermined://未询问用户是否授权
            AVCaptureDevice.requestAccess(for: .video) { (_ result: Bool) in
                return result
            }
        case .denied, .restricted://用户拒绝授权、权限受限
            ATAlertView.shareInstance.show(title: NSLocalizedString("CameraAvilableSetting", comment: ""))
            return false
        }
        return false
    }
    @discardableResult
    static func at_checkCameraAvilable() -> Bool {
        if at_checkCamera() {
            return at_checkCameraEnable()
        }
        ATAlertView.shareInstance.show(title: NSLocalizedString("IsCameraAvilabel", comment: ""))
        return false
    }
        
//
//    public enum CameraDeviceAvailableType : Int {
//        case notSupport
//        case available
//        case denied
//        case restricted
//    }
    
}

