//
//  ATScannerView.swift
//  ScanBarcode
//
//  Created by tingting on 2018/9/29.
//  Copyright © 2018年 tingting. All rights reserved.
//

import UIKit

class ScannerView: UIView {
    var scanner_width: CGFloat = 0.0
    var scanner_x: CGFloat = 0.0
    var scanner_y: CGFloat = 0.0
    var compat: ATCaptureCompat = ATCaptureCompat()
    /// 棱角颜色 默认RGB色值 r:63 g:187 b:54 a:1.0
    var scannerCornerColor: UIColor = UIColor(red: 63/255.0, green: 187/255.0, blue: 54/255.0, alpha: 1.0)
    var lineView: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(red: 63/255.0, green: 187/255.0, blue: 54/255.0, alpha: 1.0)
        return line
    }()
    
    init(frame: CGRect, compat: ATCaptureCompat) {
        super.init(frame: frame)
        self.compat = compat
        setupUI()
    }
    
    private func setupUI() {
        scanner_width = atPhotoWidth//0.7*self.frame.size.width
        scanner_x = (self.frame.size.width - atPhotoWidth)/2
        scanner_y = (self.frame.size.height - atPhotoWidth)/2
        self.lineView.frame = CGRect(x: scanner_x, y: scanner_y, width: atPhotoWidth, height: 1.5)
        self.addSubview(self.lineView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        //半透明区域
        UIColor(white: 0, alpha: 0.3).setFill()
        UIRectFill(rect)
        
        scanner_width = atPhotoWidth//0.7*self.frame.size.width

        // 透明区域
        let scanner_rect = CGRect(x: scanner_x, y: scanner_y, width: scanner_width, height: scanner_width)
        UIColor.clear.setFill()
        UIRectFill(scanner_rect)

        // 边框
        let borderPath = UIBezierPath(rect: CGRect(x: scanner_x, y: scanner_y, width: scanner_width, height: scanner_width))
        borderPath.lineCapStyle = .round
        borderPath.lineWidth = 0.5
        UIColor.white.set()
        borderPath.stroke()
        
        for index in 0...3 {
            let tempPath = UIBezierPath()
            tempPath.lineWidth = scanner_cornerWidth
            scannerCornerColor.set()
            switch index {
            // 左上角棱角
            case 0:
                tempPath.move(to: CGPoint(x: scanner_x + scanner_cornerLength, y: scanner_y))
                tempPath.addLine(to: CGPoint(x: scanner_x, y: scanner_y))
                tempPath.addLine(to: CGPoint(x: scanner_x, y: scanner_y + scanner_cornerLength))
            // 右上角
            case 1:
                tempPath.move(to: CGPoint(x: scanner_x + scanner_width - scanner_cornerLength, y: self.scanner_y))
                tempPath.addLine(to: CGPoint(x: scanner_x + scanner_width, y: scanner_y))
                tempPath.addLine(to: CGPoint(x: scanner_x + scanner_width, y: scanner_y + scanner_cornerLength))
            // 左下角
            case 2:
                tempPath.move(to: CGPoint(x: scanner_x, y: scanner_y + scanner_width - scanner_cornerLength))
                tempPath.addLine(to: CGPoint(x: scanner_x, y: scanner_y + scanner_width))
                tempPath.addLine(to: CGPoint(x: scanner_x + scanner_cornerLength, y: scanner_y + scanner_width))
            // 右下角
            case 3:
                tempPath.move(to: CGPoint(x: scanner_x + scanner_width - scanner_cornerLength, y: scanner_y + scanner_width))
                tempPath.addLine(to: CGPoint(x: scanner_x + scanner_width, y: scanner_y + scanner_width))
                tempPath.addLine(to: CGPoint(x: scanner_x + scanner_width, y: scanner_y + scanner_width - scanner_cornerLength))
            default:
                break
            }
            tempPath.stroke()
        }
    }
    
    func startAnimation() {
        let animation = CABasicAnimation.init(keyPath: "position.y")
        animation.fromValue = NSNumber.init(value: Float(scanner_y))
        animation.toValue = NSNumber.init(value: Float(scanner_y + atPhotoWidth))
        animation.duration = 3
        animation.repeatCount = MAXFLOAT
        animation.fillMode = .backwards
        animation.isRemovedOnCompletion = false
        lineView.layer.add(animation, forKey: "position.y")
    }
    
    func stopAnimation()  {
        self.lineView.layer.removeAllAnimations()
    }
    func pauseAnimation() {
        //申明一个暂停时间为这个层动画的当前时间
        let pausedTime:CFTimeInterval = lineView.layer.convertTime(CACurrentMediaTime(), from: nil)
        lineView.layer.speed = 0.0 //当前层的速度
        lineView.layer.timeOffset = pausedTime //层的停止时间设为上面申明的暂停时间
    }
    func resumeAnimation() {
        let pausedTime:CFTimeInterval = lineView.layer.timeOffset // 当前层的暂停时间
        /** 层动画时间的初始化值 **/
        lineView.layer.speed = 1.0
        lineView.layer.timeOffset = 0.0
        lineView.layer.beginTime = 0.0
        /** end **/
        let timeSincePause:CFTimeInterval = lineView.layer.convertTime(CACurrentMediaTime(), from: nil)
        let timePause = timeSincePause - pausedTime //计算从哪里开始恢复动画
        lineView.layer.beginTime = timePause //让层的动画从停止的位置恢复动效
    }
}



