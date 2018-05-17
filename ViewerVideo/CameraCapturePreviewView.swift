//
//  CameraCapturePreviewView.swift
//  ViewerVideoCore
//
//  Created by Andrew on 5/15/18.
//  Copyright © 2018 Andrew Nordahl. All rights reserved.
//

import UIKit
import AVKit

class CameraCapturePreviewView: UIView {
    
    var session: AVCaptureSession!
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.connection?.videoOrientation = .portrait
        previewLayer.videoGravity = .resizeAspectFill
        return previewLayer
    }()
    
    init(withSession session: AVCaptureSession) {
        self.session = session
        super.init(frame: CGRect())
        self.updatePreviewFrame()
        self.subscribeToNotifications()
        self.layer.addSublayer(previewLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func updatePreviewFrame() {
        DispatchQueue.main.async {
            if let parentView = self.superview {
                self.frame = CGRect(origin: CGPoint(x: parentView.bounds.width / 2, y: parentView.bounds.height / 2), size: CGSize(width: parentView.bounds.width / 2, height: parentView.bounds.height / 2))
                self.previewLayer.frame = self.bounds
                
                //Set preview video orientation based off of new device orientation
                if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft {
                    self.previewLayer.connection?.videoOrientation = .landscapeRight
                } else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight {
                    self.previewLayer.connection?.videoOrientation = .landscapeLeft
                } else {
                    self.previewLayer.connection?.videoOrientation = .portrait
                }
            }
        }
    }

    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIDeviceOrientationDidChange, object: nil, queue: .main) { [unowned self] _ in
            self.updatePreviewFrame()
        }
    }
}
