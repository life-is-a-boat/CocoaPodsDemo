//
//  ScanViewController.swift
//  ScanBarcode
//
//  Created by tingting on 2018/9/26.
//  Copyright © 2018年 tingting. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

class ScanViewController: UIViewController {
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
     * 获取设备:如摄像头
     */
    var currentDevice:AVCaptureDevice!
    /**
     * 输入设备
     */
    var videoInput: AVCaptureDeviceInput!
    /**
     * 输出设备 照片输出流
     */
    var stillImageOutput: AVCapturePhotoOutput!
    /**
     * 输出设备 data输出流
     */
    var metadataOutput: AVCaptureMetadataOutput!
    /**
     * 预览图层
     */
    var previewLayer: AVCaptureVideoPreviewLayer!
    /**
     * 闪光灯模式
     */
    var flashSwitch: AVCaptureDevice.FlashMode = .auto
    
    var scale: Float = 0
    
//    var backView: UIView = {
//        let bv = UIView()
//        bv.backgroundColor = UIColor.clear
//        return bv
//    }()
    
//    var lineView: UIView = {
//        let line = UIView()
//        line.backgroundColor = UIColor.red
//        return line
//    }()
    
    var rectView: ScannerView!
    
    @IBOutlet weak var dismiss: UIButton!
    @IBOutlet weak var frontOrAfter: UIButton!
    @IBOutlet weak var flashLight: UIButton!
    @IBOutlet weak var takePhoto: UIButton!
    @IBOutlet weak var light: UIButton!
    
    //MARK: TODO
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //set the rect of to scan
        self.rectView = ScannerView.init(frame: self.view.bounds, compat: ATCaptureCompat())
        self.rectView.backgroundColor = UIColor.clear
        
//        captureStillAndLivePhotos()
        
        captureStillPhoto()
        
        self.view.addSubview(rectView)
        self.view.bringSubviewToFront(self.dismiss)
        self.view.bringSubviewToFront(self.frontOrAfter)
        self.view.bringSubviewToFront(self.flashLight)
        self.view.bringSubviewToFront(self.takePhoto)
        self.view.bringSubviewToFront(self.light)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startScan()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopScan()
    }
    
   
}

//MARK: 操作
extension ScanViewController {
    @IBAction func switchDevicePosition(_ sender: Any) {
        var position = device.position
        position = position == .front ? .back: .front
        
        let d = ATCaptureManager.share.createDevice(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], position: position, mediaType: .video)
        
        guard let tmp_videoInput = try? AVCaptureDeviceInput.init(device: d!) else { return }
        
        session.beginConfiguration()
        session.removeInput(videoInput)
        session.addInput(tmp_videoInput)
        session.commitConfiguration()
        videoInput = tmp_videoInput
    }
    
    @IBAction func takePhoto(_ sender: Any) {
        
    }
    
    //闪光灯
    @IBAction func flashSwitch(_ sender: Any) {
        
        if device.hasFlash {
            flashSwitch = (stillImageOutput.photoSettingsForSceneMonitoring?.flashMode)!
            let settings = AVCapturePhotoSettings()
            switch flashSwitch {
                case .auto:
                    flashSwitch = .off
                case .on:
                    flashSwitch = .auto
                case .off:
                    flashSwitch = .on
            }
            settings.flashMode = flashSwitch
            stillImageOutput.capturePhoto(with: settings, delegate: self)
        }
        else {
            ATAlertView.shareInstance.show(title: NSLocalizedString("FlashNotAvailiable", comment: ""))
        }
    }
    @IBAction func lightClick(_ sender: Any) {
        
    }

}

extension ScanViewController:AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        print("\(#function)")
        guard error != nil else { print("Error capturing photo: \(error!)"); return }
        
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else { return }
            DispatchQueue.main.async {
                PHPhotoLibrary.shared().performChanges({
                    // Add the captured photo's file data as the main resource for the Photos asset.
                    //                DispatchQueue.main.asyncAfter(deadline: dis, execute: <#T##() -> Void#>)
                    let creationRequest = PHAssetCreationRequest.forAsset()
                    creationRequest.addResource(with: .photo, data: photo.fileDataRepresentation()!, options: nil)
                }, completionHandler: { (isFinished, error) in
                    print("isFinished:\(isFinished)  error:\(String(describing: error))");
                })
            }
        }
    }
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("\(#function)")
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        print("\(#function)")
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingLivePhotoToMovieFileAt outputFileURL: URL, duration: CMTime, photoDisplayTime: CMTime, resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        print("\(#function)")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("\(#function)")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("\(#function)")
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishRecordingLivePhotoMovieForEventualFileAt outputFileURL: URL, resolvedSettings: AVCaptureResolvedPhotoSettings) {
        print("\(#function)")
    }
}
//MARK: 扫描器
extension ScanViewController {
    //创建扫描器
    func initAVCaptureSession() -> () {
//        let device = createDevice(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], position: .back, mediaType: .video)
//
//        guard let videoInput = try? AVCaptureDeviceInput.init(device: device!) else { return }
//
//        let settings = AVCapturePhotoSettings()
//        settings.flashMode = flashSwitch
//
//        stillImageOutput = AVCapturePhotoOutput()
//        stillImageOutput.photoSettingsForSceneMonitoring = settings
//
//
//        if session.canAddInput(videoInput) {
//            session.addInput(videoInput)
//        }
//
//        if session.canAddOutput(stillImageOutput) {
//            session.addOutput(stillImageOutput)
//        }
//        self.videoInput = videoInput
        configureSession()
        
        
        self.previewLayer = AVCaptureVideoPreviewLayer.init(session: session)
        
        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        self.previewLayer.frame = self.view.bounds
        
        self.view.layer.addSublayer(self.previewLayer)
    }
    
    func configureSession() -> () {
        session.beginConfiguration()
       
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
            device = defaultVideoDevice
            videoInput = videoDeviceInput

        } catch  {
            print("Could not add video device input:\(error)")
            session.commitConfiguration()
            return
        }
        
        //高质量采集率
        session.sessionPreset = .high
        
        /**
         *  qr
         */
        //add metadataOutput
        /**
         let metadataOutput = AVCaptureMetadataOutput()
         metadataOutput.rectOfInterest = self.rectView.bounds
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
         */
        /**
         *  photo
         */
        stillImageOutput = AVCapturePhotoOutput()
        let settings = AVCapturePhotoSettings()
        stillImageOutput.capturePhoto(with: settings, delegate: self)
        if session.canAddOutput(stillImageOutput) {
            session.addOutput(stillImageOutput)
        }
        else {
            print("Could not add photo output to the session")
            session.commitConfiguration()
            return
        }
        
        session.commitConfiguration()
    }
    
    
    func bestDevice(in position: AVCaptureDevice.Position) -> AVCaptureDevice {
        let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes:
            [.builtInTrueDepthCamera, .builtInDualCamera, .builtInWideAngleCamera],
                                                                mediaType: .video, position: .unspecified)
        let devices = discoverySession.devices
        guard !devices.isEmpty else { fatalError("Missing capture devices.")}
        
        return devices.first(where: { device in device.position == position })!
    }
    
    func captureStillPhoto() {
        self.session.beginConfiguration()
        
        self.previewLayer = AVCaptureVideoPreviewLayer.init(session: session)
        
        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        self.previewLayer.frame = self.view.bounds
        
        self.view.layer.addSublayer(self.previewLayer)
        
        //获取设备 device
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            currentDevice = device
        }
        else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            currentDevice = device
        }
        else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            currentDevice = device
        }
        else {
            fatalError("Missing expected back camera device.")
        }
        device = currentDevice
        
        //输入 input
        do {
            let input = try AVCaptureDeviceInput(device: currentDevice)
            if self.session.canAddInput(input) {
                self.session.addInput(input)
                self.videoInput = input
                DispatchQueue.main.async {
                    let statusBarOrientation = UIApplication.shared.statusBarOrientation
                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    if statusBarOrientation != .unknown {
                        if let videoOrientation = AVCaptureVideoOrientation(rawValue: statusBarOrientation.rawValue) {
                            initialVideoOrientation = videoOrientation
                        }
                    }
                    self.previewLayer.connection?.videoOrientation = initialVideoOrientation
                }
            }
            else {
                fatalError("Missing expected AVCaptureDeviceInput.")
            }
        } catch  {
            fatalError("error:\(error)")
        }
        
        self.session.sessionPreset = .photo
        
        let photoOutput = AVCapturePhotoOutput()
        photoOutput.isDepthDataDeliveryEnabled = photoOutput.isDepthDataDeliverySupported
//        photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
        
        let photoSettings: AVCapturePhotoSettings
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.hevc])
        }
        else {
            photoSettings = AVCapturePhotoSettings()
        }
        photoSettings.flashMode = .auto
        photoSettings.isAutoStillImageStabilizationEnabled = photoOutput.isStillImageStabilizationSupported
        
        guard self.session.canAddOutput(photoOutput) else {
            fatalError("can not add output.")
        }
        self.session.addOutput(photoOutput)
        
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
        
        self.session.commitConfiguration()
    }
    //MARK:Capturing Still and Live Photos
    func captureStillAndLivePhotos() {
        
        self.session.beginConfiguration()

        self.previewLayer = AVCaptureVideoPreviewLayer.init(session: session)
        
        self.previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        self.previewLayer.frame = self.view.bounds
        
        self.view.layer.addSublayer(self.previewLayer)
        

        //获取设备 device
        if let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            currentDevice = device
        }
        else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            currentDevice = device
        }
        else if let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
            currentDevice = device
        }
        else {
            fatalError("Missing expected back camera device.")
        }
        device = currentDevice
        
        //输入 input
        do {
            let input = try AVCaptureDeviceInput(device: currentDevice)
            if self.session.canAddInput(input) {
                self.session.addInput(input)
                self.videoInput = input
                DispatchQueue.main.async {
                    let statusBarOrientation = UIApplication.shared.statusBarOrientation
                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    if statusBarOrientation != .unknown {
                        if let videoOrientation = AVCaptureVideoOrientation(rawValue: statusBarOrientation.rawValue) {
                            initialVideoOrientation = videoOrientation
                        }
                    }
                    self.previewLayer.connection?.videoOrientation = initialVideoOrientation
                }
            }
            else {
                fatalError("Missing expected AVCaptureDeviceInput.")
            }
        } catch  {
            fatalError("error:\(error)")
        }
        
        // Add audio input.
        do {
            let audioDevice = AVCaptureDevice.default(for: .audio)
            let audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice!)
            
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
            } else {
                print("Could not add audio device input to the session")
            }
        } catch {
            print("Could not create audio device input: \(error)")
        }
        
        self.session.sessionPreset = .photo

        let photoOutput = AVCapturePhotoOutput()
        photoOutput.isHighResolutionCaptureEnabled = true
        photoOutput.isLivePhotoCaptureEnabled = photoOutput.isLivePhotoCaptureSupported
        
        let photoSettings: AVCapturePhotoSettings
        if photoOutput.availablePhotoCodecTypes.contains(.hevc) {
            photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey:AVVideoCodecType.hevc])
        }
        else {
            photoSettings = AVCapturePhotoSettings()
        }
        photoSettings.flashMode = .auto
        photoSettings.isAutoStillImageStabilizationEnabled = photoOutput.isStillImageStabilizationSupported
        
        guard self.session.canAddOutput(photoOutput) else {
            fatalError("can not add output.")
        }
        self.session.addOutput(photoOutput)

        photoOutput.capturePhoto(with: photoSettings, delegate: self)

        
        self.session.commitConfiguration()
    }
}

extension ScanViewController:AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        print("metadataOutput  metadataObjects:\(metadataObjects) ")
        if metadataObjects.count > 0 {
            if let metadataObject = metadataObjects[0] as? AVMetadataMachineReadableCodeObject {
                if let stringValue = metadataObject.stringValue {
                    print(stringValue)
                    pauseAnimation()
                }
            }
        }
    }
}

extension ScanViewController {
    public func startScan() {
        session.startRunning()
        startAnimation()
    }
    public func stopScan() {
        session.stopRunning()
        stopAnimation()
    }
    func startAnimation() {
        DispatchQueue.main.async {
            self.rectView.startAnimation()
        }
    }
    
    func stopAnimation()  {
        DispatchQueue.main.async {
            self.rectView.stopAnimation()
        }
    }
    
    func pauseAnimation() {
        DispatchQueue.main.async {
            self.rectView.pauseAnimation()
        }
    }
    
    func resumeAnimation() {
        DispatchQueue.main.async {
            self.rectView.resumeAnimation()
        }
    }
}


