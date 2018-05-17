//
//  VideoPlayerViewController.swift
//  ViewerVideoCore
//
//  Created by Andrew on 5/3/18.
//  Copyright © 2018 Andrew Nordahl. All rights reserved.
//

import UIKit
import AVKit

class LoopedVideoViewController: AVPlayerViewController {
    
    //MARK: - Variables
    var loopedVideoPaused: Bool = true
    var previewIsVisible: Bool = false
    var countdownTimer: Timer?

    //MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToNotifications()
        setupVideo()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        clearTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        setDelegates()
        player?.play()
        loopedVideoPaused = false
        showCapturePreview()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        player?.pause()
        clearTimer()
        loopedVideoPaused = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Video Functions
    func setupVideo() {
        let loopVideo = SettingsManager.sharedInstance.loopVideo
        guard let path = Bundle.main.path(forResource: loopVideo.videoName, ofType:loopVideo.videoFiletype) else {
            debugPrint("video.m4v not found")
            return
        }
        player = AVPlayer(url: URL(fileURLWithPath: path))
        showsPlaybackControls = false
        videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
    }
    
    @objc func playVideoForViewer() {
        if !loopedVideoPaused {
            let viewerVideoController = InterstitialVideoViewController()
            present(viewerVideoController, animated: true, completion: nil)
        }
    }
    
    //MARK: - Timer Functions
    func startTimer() {
        if countdownTimer == nil {
            DispatchQueue.main.async {
                self.countdownTimer = Timer.scheduledTimer(timeInterval: SettingsManager.sharedInstance.delayTime, target: self, selector: #selector(self.playVideoForViewer), userInfo: nil, repeats: false)
                let countdownLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
                countdownLabel.text = SettingsManager.sharedInstance.faceDetectedIndicator
                self.contentOverlayView!.addSubview(countdownLabel)
            }
        }
    }
    
    func clearTimer() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        DispatchQueue.main.async {
            self.contentOverlayView?.subviews.forEach({
                if $0 is UILabel {
                    $0.removeFromSuperview()
                }
            })
        }
    }
    
    //MARK: - Delegation/Notification Functions
    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { [weak self] _ in
            self?.player?.seek(to: kCMTimeZero)
            self?.player?.play()
        }
    }
    
    func setDelegates() {
        if let parentViewController = self.presentingViewController as? TrackingViewController {
            parentViewController.trackingDelegate = self
        }
    }
    
    //MARK: -
    func showCapturePreview() {
        if SettingsManager.sharedInstance.trackingPreviewEnabled && previewIsVisible == false {
            previewIsVisible = true
            if let parentViewController = self.presentingViewController as? TrackingViewController {
                DispatchQueue.main.async {
                    self.contentOverlayView?.addSubview(CameraCapturePreviewView.init(withSession: parentViewController.session!))
                }
            }
        }
    }
}

//MARK: - Extension - TrackingDelegate
extension LoopedVideoViewController: TrackingDelegate {
    func currentTracking(state: TrackingState) {
        switch state {
            case .face:
                startTimer()
            case .nothing:
                clearTimer()
        }
    }
}
