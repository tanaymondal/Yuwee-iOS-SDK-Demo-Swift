//
//  OneToOneCallViewController.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 20/04/21.
//

import UIKit
import SwiftyJSON
import KRProgressHUD
import Toaster

class OneToOneCallViewController: UIViewController {
    @IBOutlet weak var remoteVideoView: YuweeRemoteVideoView!
    
    @IBOutlet weak var localVideoView: YuweeLocalVideoView!

    @IBOutlet weak var buttonEnd: UIButton!
    @IBOutlet weak var buttonChat: UIButton!
    @IBOutlet weak var buttonAudio: UIButton!
    @IBOutlet weak var buttonVideo: UIButton!
    @IBOutlet weak var buttonSpeaker: UIButton!
    
    @IBOutlet weak var bottomStackView: UIStackView!
    var callParams: CallParams?
    
    private var isAudioMuted = false
    private var isVideoMuted = false
    private var isSpeakerOff = true
    private var timer: Timer?
    private var totalSecond = 0
    
    var callData : JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.title = "Connecting..."
        self.navigationController?.navigationBar.tintColor = UIColor.black

        let name = callData!["destination"]["name"].string
        
        let leftItem = UIBarButtonItem(title: name,
                                       style: UIBarButtonItem.Style.plain,
                                       target: nil,
                                       action: nil)

        self.navigationItem.leftBarButtonItem = leftItem
        
        let button = UIBarButtonItem(image: UIImage(named: "video_unmute"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(rightButtonAction(sender:)))
        self.navigationItem.rightBarButtonItem = button
        
        bottomStackView.layer.cornerRadius = 20
        
        buttonEnd.setBackgroundImage(UIImage(named: "call_end"), for: .normal)
        buttonEnd.layoutIfNeeded()
        buttonEnd.subviews.first?.contentMode = .scaleAspectFit
        
        buttonChat.setBackgroundImage(UIImage(named: "chat_icon"), for: .normal)
        buttonChat.layoutIfNeeded()
        buttonChat.subviews.first?.contentMode = .scaleAspectFit
        
        buttonAudio.setBackgroundImage(UIImage(named: "audio_unmute"), for: .normal)
        buttonAudio.layoutIfNeeded()
        buttonAudio.subviews.first?.contentMode = .scaleAspectFit
        
        buttonVideo.setBackgroundImage(UIImage(named: "video_unmute"), for: .normal)
        buttonVideo.layoutIfNeeded()
        buttonVideo.subviews.first?.contentMode = .scaleAspectFit
        
        buttonSpeaker.setBackgroundImage(UIImage(named: "speaker_off"), for: .normal)
        buttonSpeaker.layoutIfNeeded()
        buttonSpeaker.subviews.first?.contentMode = .scaleAspectFit
        
        self.setupCall()
        
    }
    
    @objc func rightButtonAction(sender: UIBarButtonItem){
        Yuwee.sharedInstance().getCallManager().switchCamera()
    }
    
    private func setupCall() {
        Yuwee.sharedInstance().getCallManager().initCall(withLocalView: self.localVideoView, withRemoteView: self.remoteVideoView)
        
        Yuwee.sharedInstance().getCallManager().setCallManagerDelegate(self)
        
        if callData!["callType"].string == "AUDIO" {
            self.onVideoToggle(self)
        }
    }
    
    @IBAction func onEndPressed(_ sender: Any) {
        KRProgressHUD.show()
        self.timer?.invalidate()
        self.navigationItem.title = "Ending call..."
        Yuwee.sharedInstance().getCallManager().hangUpCall { (isSuccess, data) in
            if isSuccess{
                KRProgressHUD.showSuccess(withMessage: "Call Ended.")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    @IBAction func onVideoToggle(_ sender: Any) {
        self.isVideoMuted = !self.isVideoMuted
        if self.isVideoMuted {
            buttonVideo.setBackgroundImage(UIImage(named: "video_mute"), for: .normal)
            buttonVideo.layoutIfNeeded()
            buttonVideo.subviews.first?.contentMode = .scaleAspectFit
        }
        else{
            buttonVideo.setBackgroundImage(UIImage(named: "video_unmute"), for: .normal)
            buttonVideo.layoutIfNeeded()
            buttonVideo.subviews.first?.contentMode = .scaleAspectFit
        }
        self.localVideoView.isHidden = self.isVideoMuted
        Yuwee.sharedInstance().getCallManager().setVideoEnabled(!self.isVideoMuted)
    }
    @IBAction func onAudioToggle(_ sender: Any) {
        self.isAudioMuted = !self.isAudioMuted
        if self.isAudioMuted {
            buttonAudio.setBackgroundImage(UIImage(named: "audio_mute"), for: .normal)
            buttonAudio.layoutIfNeeded()
            buttonAudio.subviews.first?.contentMode = .scaleAspectFit
        }
        else{
            buttonAudio.setBackgroundImage(UIImage(named: "audio_unmute"), for: .normal)
            buttonAudio.layoutIfNeeded()
            buttonAudio.subviews.first?.contentMode = .scaleAspectFit
        }
        Yuwee.sharedInstance().getCallManager().setAudioEnabled(!self.isAudioMuted)
    }
    @IBAction func onSpeakerToggle(_ sender: Any) {
        self.isSpeakerOff = !self.isSpeakerOff
        if self.isSpeakerOff {
            buttonSpeaker.setBackgroundImage(UIImage(named: "speaker_off"), for: .normal)
            buttonSpeaker.layoutIfNeeded()
            buttonSpeaker.subviews.first?.contentMode = .scaleAspectFit
            Yuwee.sharedInstance().getCallManager().setAudioOutputType(AudioOutputType.EARPIECE)
        }
        else{
            buttonSpeaker.setBackgroundImage(UIImage(named: "speaker_on"), for: .normal)
            buttonSpeaker.layoutIfNeeded()
            buttonSpeaker.subviews.first?.contentMode = .scaleAspectFit
            Yuwee.sharedInstance().getCallManager().setAudioOutputType(AudioOutputType.SPEAKER)
        }
    }
    @IBAction func onOpenChat(_ sender: Any) {
        Toast(text: "Work in progress.").show()
    }
    
    
    func startTimer(){
    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
    }

    @objc func countdown() {
        var hours: Int
        var minutes: Int
        var seconds: Int

        totalSecond = totalSecond + 1;
        hours = totalSecond / 3600
        minutes = (totalSecond % 3600) / 60
        seconds = (totalSecond % 3600) % 60
        self.navigationItem.title = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

}

extension OneToOneCallViewController: YuWeeCallManagerDelegate{
    
    func onCallTimeOut() {
        print("onCallTimeOut")
    }
    
    func onCallReject() {
        print("onCallReject")
        DispatchQueue.main.async {
            KRProgressHUD.showInfo(withMessage: "Call Rejected.")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func onCallAccept() {
        print("onCallAccept")
    }
    
    func onCallConnected() {
        print("onCallConnected")
        self.navigationItem.title = "Connected"
        startTimer()
    }
    
    func onCallDisconnected() {
        print("onCallDisconnected")
    }
    
    func onCallReconnecting() {
        print("onCallReconnecting")
    }
    
    func onCallReconnected() {
        print("onCallReconnected")
    }
    
    func onCallRinging() {
        print("onCallRinging")
    }
    
    func onRemoteCallHangUp(_ callData: [AnyHashable : Any]!) {
        let data = JSON(callData!)
        print("onRemoteCallHangUp \(data)")
        DispatchQueue.main.async {
            KRProgressHUD.showInfo(withMessage: "Call Ended by \(data["senderName"].string!).")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func onRemoteVideoToggle(_ callData: [AnyHashable : Any]!) {
        let data = JSON(callData!)
        print("onRemoteVideoToggle \(data)")
    }
    
    func onRemoteAudioToggle(_ callData: [AnyHashable : Any]!) {
        let data = JSON(callData!)
        print("onRemoteAudioToggle \(data)")
    }
    
    func onCallEnd(_ callData: [AnyHashable : Any]!) {
        let data = JSON(callData!)
        print("onCallEnd \(data)")
//        DispatchQueue.main.async {
//            KRProgressHUD.showInfo(withMessage: "Call Ended.")
//            self.navigationController?.popViewController(animated: true)
//        }
    }
    
    func onCallConnectionFailed() {
        print("onCallConnectionFailed")
    }
    
    func setUpAditionalViewsOn(_ remoteView: YuweeRemoteVideoView!, with size: CGSize) {
        print("setUpAditionalViewsOn")
    }
}
