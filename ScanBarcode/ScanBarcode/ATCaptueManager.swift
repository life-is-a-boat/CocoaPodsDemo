//
//  ATCaptueManager.swift
//  ScanBarcode
//
//  Created by tingting on 2018/9/29.
//  Copyright © 2018年 tingting. All rights reserved.
//


import UIKit
import AVFoundation

/**
 *  扫描器类型
 *  - qr: 仅支持二维码
 *  - bar: 仅支持条码
 *  - both: 支持二维码以及条码
 */
enum ATScannerType {
    case qr
    case bar
    case both
}
/**
 *  设备捕捉类型
 *  - audio: 音频
 *  - video: 音视频
 *  - qrcode: 扫描
 */
enum ATAVCaptureType {
    case audio
    case video
    case qrcode
}

struct ATCaptureCompat {
    var captureType: ATAVCaptureType = .video
}


class ATCaptureManager: NSObject {
    var captureCompat: ATCaptureCompat
    /**
     * sessionQueue
     */
    var sessionQueue: DispatchQueue = DispatchQueue.init(label: "session queue")
    /**
     * AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
     */
    let session: AVCaptureSession = AVCaptureSession()
    /**
     * 获取设备:如摄像头
     */
    var device:AVCaptureDevice!
    /**
     * 输入设备
     */
    var videoInput: AVCaptureDeviceInput!
    /**
     * 输出设备 照片输出流
     */
    var stillImageOutput: AVCapturePhotoOutput!
    /**
     * 预览图层
     */
    var previewLayer: AVCaptureVideoPreviewLayer!
    /**
     * 闪光灯模式
     */
    var flashSwitch: AVCaptureDevice.FlashMode = .auto
    
    public static let share = ATCaptureManager()
    
    override init() {
        captureCompat = ATCaptureCompat.init()
        super.init()
    }
}
extension ATCaptureManager:AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        print("metadataOutput  metadataObjects:\(metadataObjects) ")
    }
}
extension ATCaptureManager {
    public func startScan() {
        session.startRunning()
    }
    public func stopScan() {
        session.stopRunning()
    }
    fileprivate func configureSession() -> () {
        session.beginConfiguration()
        switch captureCompat.captureType {
        case .audio:
            break
        case .video:
            //输出文件的格式
            session.sessionPreset = .photo
            //添加 video input
            do {
                var defaultVideoDevice: AVCaptureDevice?
                if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                    defaultVideoDevice = dualCameraDevice
                }
                else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                    defaultVideoDevice = backCameraDevice
                }
                else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                    defaultVideoDevice = frontCameraDevice
                }
                let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice!)
                if session.canAddInput(videoInput) {
                    session.addInput(videoDeviceInput)
                    DispatchQueue.main.async {
                        //
                    }
                }
                else {
                    print("Could not add video device input to the session")
                    session.commitConfiguration()
                    return
                }
            } catch  {
                print("Could not add video device input:\(error)")
                session.commitConfiguration()
                return
            }
            
            //添加 audio input
            do {
                let audioDevice = AVCaptureDevice.default(for: .audio)
                let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
                
                if session.canAddInput(audioDeviceInput) {
                    session.addInput(audioDeviceInput)
                }
                else {
                    print("Could not add audio device input to the session")
                }
            } catch {
                print("Could not add audio device input:\(error)")
            }
            
            //add photo output
            let photoOutput = AVCapturePhotoOutput()
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
                photoOutput.isHighResolutionCaptureEnabled = true
                photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
                photoOutput.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
            }
            else {
                print("Could not add photo output to the session")
                session.commitConfiguration()
                return
            }
            break
        case .qrcode:
            //高质量采集率
            session.sessionPreset = .high
            //添加 video input
            do {
                var defaultVideoDevice: AVCaptureDevice?
                if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                    defaultVideoDevice = dualCameraDevice
                }
                else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                    defaultVideoDevice = backCameraDevice
                }
                
                let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice!)
                if session.canAddInput(videoDeviceInput) {
                    session.addInput(videoDeviceInput)
                    DispatchQueue.main.async {
                        //
                    }
                }
                else {
                    print("Could not add video device input to the session")
                    session.commitConfiguration()
                    return
                }
            } catch  {
                print("Could not add video device input:\(error)")
                session.commitConfiguration()
                return
            }
            
            //add metadataOutput
            let metadataOutput = AVCaptureMetadataOutput()
            metadataOutput.setMetadataObjectsDelegate(self, queue: sessionQueue)
            if session.canAddOutput(metadataOutput) {
                session.addOutput(metadataOutput)
                metadataOutput.metadataObjectTypes = metadataOutput.availableMetadataObjectTypes
            }
            else {
                print("Could not add photo output to the session")
                session.commitConfiguration()
                return
            }
            break
        }
        
        session.commitConfiguration()
    }
    
    //创建设备
    internal func createDevice(deviceTypes:[AVCaptureDevice.DeviceType],position: AVCaptureDevice.Position, mediaType:AVMediaType) -> AVCaptureDevice?{
        let devices = AVCaptureDevice.DiscoverySession.init(deviceTypes: deviceTypes, mediaType: mediaType, position: position).devices
        if devices.count > 0 {
            let device = devices.filter({return $0.position == position}).first
            return device
        }
        else {
            let device = AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: mediaType, position: position)//AVCaptureDevice.default(for: mediaType)//
            return device
        }
    }
}

