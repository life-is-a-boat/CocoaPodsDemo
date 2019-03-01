//
//  ScanViewController.swift
//  QRCode
//
//  Created by ting on 2019/3/1.
//  Copyright © 2019 tingting. All rights reserved.
//

import UIKit
import AVFoundation

typealias completeBlock = (Bool,String) -> ()

class ScanViewController: UIViewController ,AVCaptureMetadataOutputObjectsDelegate {
    
    private var session:AVCaptureSession?
    @IBOutlet var cropView: UIView!
    
    var complete:completeBlock?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initSession()
        cropView.layer.borderColor = UIColor.yellow.cgColor
        cropView.layer.borderWidth = 2
    }
    
    //MARK: - Private
    private func initSession(){
        //获取摄像设备
        let device = AVCaptureDevice.default(for: .video)
        //创建输入流
        let input = try? AVCaptureDeviceInput(device: device!)
        if input == nil {return}
        //创建输出流
        let output = AVCaptureMetadataOutput()
        //设置代理 在主线程里刷新
        output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        //设置有效扫描区域
        let scanCrop = getScanCrop(rect: UIScreen.main.bounds, readerViewBounds: cropView.frame)
        output.rectOfInterest = scanCrop
        //初始化链接对象
        session = AVCaptureSession()
        //高质量采集率
        session!.sessionPreset = AVCaptureSession.Preset.high
        session!.addInput(input!)
        session!.addOutput(output)
        //设置扫码支持的编码格式(如下设置条形码和二维码兼容)AVMetadataObjectTypeQRCode
        output.metadataObjectTypes =  [.ean8,.code128,.code39,.aztec]//output.availableMetadataObjectTypes//
        let layer = AVCaptureVideoPreviewLayer(session: session!)
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        layer.frame = view.layer.bounds
        view.layer.insertSublayer(layer, at: 0)
        //开始捕获
        session!.startRunning()
    }
    
    private func getScanCrop(rect:CGRect,readerViewBounds:CGRect) -> CGRect {
        let x = (readerViewBounds.height - rect.height)/2/readerViewBounds.height
        let y = (readerViewBounds.width - rect.width)/2/readerViewBounds.width
        let width = rect.height/readerViewBounds.height
        let height = rect.width/readerViewBounds.width
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    
    //MARK: AVCaptrueMetadataOutputObjectsDelegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject
        if metadataObject?.stringValue != nil {
            print(metadataObject!.stringValue!)
            session?.stopRunning()
            if complete == nil {
                print("扫描不到数据")
            }
            else {
                self.complete!(true,metadataObject!.stringValue!)
            }
        }
        else {
            if complete == nil {
                print("扫描不到数据")
            }
            else {
                self.complete!(false,"扫描不到数据")
            }
        }
        self.navigationController?.popViewController(animated: true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
