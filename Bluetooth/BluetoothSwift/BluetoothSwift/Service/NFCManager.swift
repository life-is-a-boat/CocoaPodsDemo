//
//  NFCManager.swift
//  iOSmodao
//
//  Created by SephirothKwon on 2018/5/24.
//  Copyright © 2018年 SephirothKwon. All rights reserved.
//

import Foundation
import CoreNFC

protocol NFCManagerDelegate:class {
    func didDetectNDEF( messages: [NFCNDEFMessage])
    func didInvalidateWithError(error: Error)
    func notSupportCurrentDevice()
}

class NFCManager: NSObject,NFCNDEFReaderSessionDelegate {
    
    static let shareInstance = NFCManager()
    weak var delegate: NFCManagerDelegate?
    private var nfcSession:NFCNDEFReaderSession?
    
    //MARK: - NFC Delegate
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print(error.localizedDescription)
        delegate?.didInvalidateWithError(error: error)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        print(messages)
        delegate?.didDetectNDEF(messages: messages)
    }
    
    // MARK: - Device Detect
    @discardableResult
    func startNFCScan() -> Bool{
        let deviceModel = UIDevice.deviceModelType
        if deviceModel.rawValue < UIDevice.DeviceModelType.iPhone7.rawValue {
            delegate?.notSupportCurrentDevice()
            return false
        }else{
            nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
            nfcSession?.begin()
            return true
        }
    }
    
    func stopNFCSession() -> Bool{
        nfcSession?.invalidate()
        nfcSession = nil
        return true
    }

}
