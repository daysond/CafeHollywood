//
//  ScannerViewController.swift
//  HYSOR
//
//  Created by Dayson Dong on 2020-03-12.
//  Copyright © 2020 Dayson Dong. All rights reserved.
//

import AVFoundation
import UIKit

protocol QRCodeScannerDelegate: AnyObject {
    
    func found()
    func failedReadingQRCode()
    
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    weak var delegate: QRCodeScannerDelegate?
    var loadingView = LoadingViewController(animationFileName: "scanner")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkManager.shared.removeTableOrderListener()
        
        self.navigationController?.isNavigationBarHidden = false
        view.backgroundColor = UIColor.black
        let backButton = UIBarButtonItem(image: UIImage(named: "back84x84"), style: .plain, target: self, action:  #selector(backButtonTapped))
        navigationController?.navigationBar.tintColor = .white
        self.navigationItem.leftBarButtonItem = backButton
        self.navigationItem.title = "Please Scan the Table QRCode"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.standardAppearance.titleTextAttributes = textAttributes
        self.navigationController?.navigationBar.standardAppearance.configureWithTransparentBackground()
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
        createLoadingView()
    }
    
    private func createLoadingView() {
        
        addChild(loadingView)
        loadingView.view.frame = view.frame
        view.addSubview(loadingView.view)
        loadingView.didMove(toParent: self)

    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    @objc private func backButtonTapped() {
        navigationController?.dismiss(animated: true, completion: nil)
//        self.navigationController?.popViewController(animated: true)
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }

        dismiss(animated: true)
    }
    
    
    func found(code: String) {
        
        let defaultURL = "http://www.enjoy2eat.ca/hollywood2/index.php?route=common/home&table="
        let num = code.suffix(2)
        let url = code.prefix(69)
        
        guard defaultURL == url, num.count == 2 else {
            let alert = UIAlertController(title: "Error", message: "Unrecognizable QR Code.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true)
            return
        }
        
        Table.shared.tableNumber = String(num)
        
        NetworkManager.shared.addTableOrderListener { error in
            
            DispatchQueue.main.async {
                
                error == nil ? self.delegate?.found() : self.delegate?.failedReadingQRCode()
               
                if error != nil {
                    Table.shared.tableNumber = nil
                }
                
                self.navigationController?.dismiss(animated: true, completion: nil)
            }

            
        }
 

    }

//    func found(code: String) {
//        /* Note: QR Code should be  { "table"  :  "01", "info", "info"}
//         code is of type String
//         1. convert code to data
//        */
//        guard let data = code.data(using: .utf8) else {
//            self.delegate?.failedReadingQRCode()
//            return
//        }
//
//        // 2.  data to dictionary with JSONSerialization
//        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//
//           // print(json) // Output: ["table": 01, "info": info]
//            self.delegate?.foundResturantDataFromQRCode(data: json)
////            NetworkManager.shared.getResturants(fromCode: json) { (resturantData) in
////                guard resturantData != nil else {
////                    print("no resturant found")
////                    self.delegate?.failedReadingQRCode()
////                    return
////                }
////                self.delegate?.foundResturantDataFromQRCode(data: resturantData!)
////            }
//        } else {
//            self.delegate?.failedReadingQRCode()
//        }
//
//        self.navigationController?.popViewController(animated: true)
//    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
