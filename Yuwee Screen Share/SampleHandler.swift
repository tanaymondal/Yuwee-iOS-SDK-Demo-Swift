//
//  SampleHandler.swift
//  Yuwee Screen Share
//
//  Created by Tanay on 06/05/21.
//

import ReplayKit
import YuWeeScreenShare
import SwiftyJSON
import MMWormhole

class SampleHandler: RPBroadcastSampleHandler, RPBroadcastControllerDelegate {
    
    var json = JSON()
    var yuweeScreenShare = YWScreenShare()
    var isInitSuccessful = false
    var recordingId: String? = nil
    var mongoId: String? = nil
    let wormhole = MMWormhole(applicationGroupIdentifier: "group.com.yuwee.SwiftSdkDemo", optionalDirectory: "wormhole")
    
    override init() {
        super.init()
        let data = UserDefaults.init(suiteName: "group.com.yuwee.SwiftSdkDemo")?.value(forKey: "screen-share-data")
        json = JSON(data!)
        print(json)
        initWormHole()
    }
    
    private func initWormHole() {
        wormhole.listenForMessage(withIdentifier: "screen-sharing-started") { (data) in
            if data as! Bool == false {
                self.isInitSuccessful = false
                self.yuweeScreenShare.cleanUp()
                self.wormhole.clearAllMessageContents()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    let userInfo = [NSLocalizedFailureReasonErrorKey: "Screen share ended by user."]
                    let error = NSError(domain: "Yuwee Screen Share", code: -1, userInfo: userInfo)
                    self.finishBroadcastWithError(error)
                }
            }
        }
        
        wormhole.listenForMessage(withIdentifier: "screen-recording-started") { (data) in
            if data as! Bool == true {
                self.startScreenRecording()
            }
            else {
                self.stopScreenRecording()
            }
        }
    }
    
    private func startScreenRecording(){
        let mongoId: String? = nil
        yuweeScreenShare.startCallRecording(with: .presenter, withMId: mongoId!) { (data, isSuccess) in
            if isSuccess {
                let json = JSON(data)
                self.recordingId = json["recordingId"].string!
                self.mongoId = json["mongoId"].string!
            }
            else {
                self.startScreenRecording()
            }
        }
    }
    
    private func stopScreenRecording(){
        yuweeScreenShare.stopCallRecording(withRecordingId: self.recordingId!, withMId: self.mongoId!) { (message, isSuccess) in
            if isSuccess {
                print("screen recording stopped.")
            }
        }
    }
    
    private func startScreenSharing() {
        yuweeScreenShare.initScreenSharing(withAuthToken: json["authToken"].string!, withNickName: json["name"].string!, withUserId: json["userId"].string!, withEmail: json["email"].string!, withMeetingId: json["meetingId"].string!, withPasscode: json["passCode"].string!) { (message, isSuccess) in
            
            if isSuccess {
                print("screen sharing started")
                self.isInitSuccessful = true
                self.wormhole.passMessageObject(true as NSCoding, identifier: "screen-sharing-status")
            }
            else {
                print("screen sharing failed to start")
                self.wormhole.passMessageObject(false as NSCoding, identifier: "screen-sharing-status")
            }
        }
        
    }

    override func broadcastStarted(withSetupInfo setupInfo: [String : NSObject]?) {
        // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
        
        self.startScreenSharing()
 
    }
    
    override func broadcastPaused() {
        // User has requested to pause the broadcast. Samples will stop being delivered.
    }
    
    override func broadcastResumed() {
        // User has requested to resume the broadcast. Samples delivery will resume.
    }
    
    override func broadcastFinished() {
        // User has requested to finish the broadcast.
    }
    
    override func processSampleBuffer(_ sampleBuffer: CMSampleBuffer, with sampleBufferType: RPSampleBufferType) {
        switch sampleBufferType {
        case RPSampleBufferType.video:
            // Handle video sample buffer
            if !isInitSuccessful{
                return
            }
            
            let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
            yuweeScreenShare.processScreenFrame(with: pixelBuffer)
            
            break
        case RPSampleBufferType.audioApp:
            // Handle audio sample buffer for app audio
            break
        case RPSampleBufferType.audioMic:
            // Handle audio sample buffer for mic audio
            break
        @unknown default:
            // Handle other sample buffer types
            fatalError("Unknown type of sample buffer")
        }
    }
}
