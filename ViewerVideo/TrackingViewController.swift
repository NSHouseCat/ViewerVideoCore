//
//  TrackingViewController.swift
//  IDX-VideoDemo
//
//  Created by Andrew on 5/6/18.
//  Copyright © 2018 Andrew Nordahl. All rights reserved.
//

import UIKit
import AVFoundation
import Vision
import AVKit

protocol TrackingDelegate: class {
    func currentTracking(state: TrackingState)
}

enum TrackingState {
    case nothing
    case face
}

class TrackingViewController: UIViewController {
    
    weak var trackingDelegate: TrackingDelegate?
    var session: AVCaptureSession?
    let faceDetection = VNDetectFaceRectanglesRequest()
    let faceDetectionRequest = VNSequenceRequestHandler()
    
    var captureCamera: AVCaptureDevice? = {
        return AVCaptureDevice.default(AVCaptureDevice.DeviceType.builtInWideAngleCamera, for: AVMediaType.video, position: SettingsManager.sharedInstance.cameraSelection)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToNotifications()
        sessionPrepare()
        session?.startRunning()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        playVideo()
    }

    private func playVideo() {
        present(LoopedVideoViewController(), animated: true)
    }
    
    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(toggleCaptureStatus), name: .toggleCameraCapture, object: nil)
    }

    @objc func toggleCaptureStatus() {
        if session?.isRunning == true {
            session?.stopRunning()
        } else {
            session?.startRunning()
        }
    }
}

extension TrackingViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    //  Created by Pawel Chmiel on 21.06.2017.
    //  Copyright © 2017 Droids On Roids. All rights reserved.
    //  https://github.com/DroidsOnRoids/VisionFaceDetection
    //  License Filename: VisionFaceDetectionLicense
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate)
        let ciImage = CIImage(cvImageBuffer: pixelBuffer!, options: attachments as! [String : Any]?)
        let ciImageWithOrientation = ciImage.oriented(forExifOrientation: Int32(currentOrientation()))
        detectFace(on: ciImageWithOrientation)
    }
}

extension TrackingViewController {
    //  Created by Pawel Chmiel on 21.06.2017.
    //  Copyright © 2017 Droids On Roids. All rights reserved.
    //  https://github.com/DroidsOnRoids/VisionFaceDetection
    //  License Filename: VisionFaceDetectionLicense
    func sessionPrepare() {
        session = AVCaptureSession()
        guard let session = session, let captureDevice = captureCamera else { return }
        do {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            session.beginConfiguration()
            
            if session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            }
            
            let output = AVCaptureVideoDataOutput()
            output.videoSettings = [
                String(kCVPixelBufferPixelFormatTypeKey) : Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
            ]
            
            output.alwaysDiscardsLateVideoFrames = true
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            session.commitConfiguration()
            let queue = DispatchQueue(label: "output.queue")
            output.setSampleBufferDelegate(self, queue: queue)
        } catch {
            print("can't setup session")
        }
    }
    
    func detectFace(on image: CIImage) {
        try? faceDetectionRequest.perform([faceDetection], on: image)
        if let results = faceDetection.results as? [VNFaceObservation] {
            if !results.isEmpty {
                trackingDelegate?.currentTracking(state: .face)
            } else {
                trackingDelegate?.currentTracking(state: .nothing)
            }
        }
    }
    
    func currentOrientation() -> UIDeviceOrientation.RawValue {
        switch UIDevice.current.orientation {
        case UIDeviceOrientation.landscapeLeft:
            return UIImageOrientation.right.rawValue
        case UIDeviceOrientation.landscapeRight:
            return UIImageOrientation.left.rawValue
        default:
            return UIImageOrientation.downMirrored.rawValue
        }
    }
    
}
