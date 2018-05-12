//
//  SettingsManager.swift
//  IDX-VideoDemo
//
//  Created by Andrew on 5/6/18.
//  Copyright © 2018 Andrew Nordahl. All rights reserved.
//

import Foundation
import AVKit

class SettingsManager {
    static let sharedInstance = SettingsManager()
    private init() {}
    
    //Front or back camera selection
    let cameraSelection: AVCaptureDevice.Position = .front
    
    //Face detected indicator, appears in top left of view when a face is detected
    let faceDetectedIndicator = "😀"
    
    //Delay before playing interstitial video after facial detection
    let delayTime = 3.0
    
    //Video to be looped while waiting for facial detection
    let loopVideo = VideoFile(videoName: "AmbientSquares", videoFiletype: "mp4")
    
    //Video that appears when face is detected
    let interstitialVideo = VideoFile(videoName: "Cat", videoFiletype: "mp4")

}

struct VideoFile {
    let videoName: String
    let videoFiletype: String
}
