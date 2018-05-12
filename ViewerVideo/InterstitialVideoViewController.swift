//
//  SecondaryVideoViewController.swift
//  IDX-VideoDemo
//
//  Created by Andrew on 5/3/18.
//  Copyright © 2018 Andrew Nordahl. All rights reserved.
//

import UIKit
import AVKit

class InterstitialVideoViewController: AVPlayerViewController {

    //MARK: - Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeToNotifications()
        toggleCameraCaptureNotification()
        setupVideo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        player?.play()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - Video Functions
    func setupVideo() {
        let interstitialVideo = SettingsManager.sharedInstance.interstitialVideo
        guard let path = Bundle.main.path(forResource: interstitialVideo.videoName, ofType:interstitialVideo.videoFiletype) else {
            debugPrint("video.m4v not found")
            return
        }
        player = AVPlayer(url: URL(fileURLWithPath: path))
        showsPlaybackControls = false
        videoGravity = AVLayerVideoGravity.resizeAspectFill.rawValue
    }
    
    func toggleCameraCaptureNotification() {
        //Used to pause camera while secondary video is being shown
        NotificationCenter.default.post(name: .toggleCameraCapture, object: nil)
    }
    
    //MARK: - Delegation/Notification Functions
    func subscribeToNotifications() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: .main) { [weak self] _ in
            self?.toggleCameraCaptureNotification()
            self?.dismiss(animated: true, completion: nil)
        }
    }
}

//MARK: - Extension - Notification.Name
extension Notification.Name {
    static let toggleCameraCapture = Notification.Name("toggleCameraCapture")
}
