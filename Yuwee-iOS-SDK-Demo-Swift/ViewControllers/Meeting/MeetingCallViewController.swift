//
//  MeetingCallViewController.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 22/04/21.
//

import UIKit
import SwiftyJSON
import KYDrawerController
import SwiftyJSON
import KRProgressHUD
import Toaster

class MeetingCallViewController: UIViewController {
    
    var meetingData: JSON?
    var meetingTokenId: String?
    private var isDrawerOpened = false
    private var loggedInEmail = ""
    private var loggedInUserId = ""
    private var amIPresenter = false
    private var amISubPresenter = false
    private var amIAdmin = false
    private var isAudioEnabled = false
    private var isVideoEnabled = false
    private var isSpeakerEnabled = false
    private var remoteStreamArray : [YWRemoteStream] = []
    
    @IBOutlet weak var mainVideoView: YuweeVideoView!
    @IBOutlet weak var buttonEnd: UIButton!
    @IBOutlet weak var buttonChat: UIButton!
    @IBOutlet weak var buttonAudio: UIButton!
    @IBOutlet weak var buttonVideo: UIButton!
    @IBOutlet weak var buttonSpeaker: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Meeting"
        
        let image = UIImage(named: "menu_icon")
        let leftItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(rightButtonAction(sender:)))

        self.navigationItem.leftBarButtonItem = leftItem
        self.meetingData = AppDelegate.meetingData
        self.meetingTokenId = AppDelegate.callTokenId
        self.loggedInEmail = Utils.getLoginJSON()["result"]["user"]["email"].string!
        self.loggedInUserId = Utils.getLoginJSON()["result"]["user"]["_id"].string!
        
        stackView.layer.cornerRadius = 20
        
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
        
        print(self.meetingData!)
        
        self.joinMeeting()
        Yuwee.sharedInstance().getMeetingManager().setMeetingDelegate(self)
    }
    
    @objc func rightButtonAction(sender: UIBarButtonItem){
        isDrawerOpened = !isDrawerOpened
        let vc = self.navigationController?.parent as! KYDrawerController
        if isDrawerOpened {
            vc.setDrawerState(.opened, animated: true)
        }
        else{
            vc.setDrawerState(.closed, animated: true)
        }
    }
    
    private func joinMeeting(){
        KRProgressHUD.show()
        
        let params = MeetingParams()
        params.callId = self.meetingData!["result"]["callData"]["callId"].string!
        params.icsCallResourceId = self.meetingData!["result"]["callTokenInfo"]["ICSCallResourceId"].string!
        params.meetingTokenId = self.meetingTokenId!
        params.roomId = self.meetingData!["result"]["callData"]["roomId"].string!
        params.token = self.meetingData!["result"]["callTokenInfo"]["token"].string!
        params.meetingType = .TRAINING
        
        Yuwee.sharedInstance().getMeetingManager().joinMeeting(params) { (data, isSuccess) in
            
            let json = JSON(data)
            print("Meeting Joined: \(isSuccess) \(json)")
            if isSuccess{
                KRProgressHUD.showSuccess(withMessage: "Successfully Joined.")
                self.nextStep()
            }
            else {
                KRProgressHUD.showError(withMessage: "Unable to join meeting.")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.onEndPressed(self)
                }
            }
        }
    }
    
    private func nextStep() {
        let arrayPresenters = self.meetingData!["result"]["callData"]["presenters"].arrayValue
        for email in arrayPresenters {
            if email.stringValue == self.loggedInEmail {
                self.amIPresenter = true
                break
            }
        }
        
        let arrayAdmin = self.meetingData!["result"]["callData"]["callAdmins"].arrayValue
        for email in arrayAdmin {
            if email.stringValue == self.loggedInEmail {
                self.amIAdmin = true
                break
            }
        }

        self.publishStream()
        self.getAllRemoteStreams()
        

    }
    
    private func publishStream(){
        
        if !amIPresenter {
            if !amISubPresenter {
                return
            }
        }
        
        var roleType : RoleType = .viewer
        if amIPresenter {
            roleType = .presenter
        }
        else if amISubPresenter {
            roleType = .subPresenter
        }
        
        KRProgressHUD.show()
        Yuwee.sharedInstance().getMeetingManager().publishCameraStream(roleType) { (data, isSuccess) in
            let json = JSON(data)
            print(json)
            if isSuccess{
                KRProgressHUD.showSuccess(withMessage: "Camera Stream successfully published")
            }
            else{
                KRProgressHUD.showError(withMessage: "Unable to publish camera stream")
            }
        }
    }
    
    private func getAllRemoteStreams(){
        let remoteStreamArray = Yuwee.sharedInstance().getMeetingManager().getAllRemoteStream() as NSArray as! [OWTRemoteStream]
        
        for item in remoteStreamArray {
            let stream = YWRemoteStream()
            stream.remoteStream = item
            self.remoteStreamArray.append(stream)
            self.subscribeStream(remoteStream: item)
        }
    }
    
    private func subscribeStream(remoteStream: OWTRemoteStream){
        Yuwee.sharedInstance().getMeetingManager().subscribeRemoteStream(remoteStream, withlistener: self)
    }
    
    @IBAction func onChatPressed(_ sender: Any) {
    }
    
    @IBAction func onVideoPressed(_ sender: Any) {
        isVideoEnabled = !isVideoEnabled
        
        Yuwee.sharedInstance().getMeetingManager().setMediaEnabled(isAudioEnabled, withVideoEnabled: isVideoEnabled) { (data, isSuccess) in
            let json = JSON(data)
            print(json)
            if isSuccess{
                if !self.isVideoEnabled {
                    self.buttonVideo.setBackgroundImage(UIImage(named: "video_mute"), for: .normal)
                    self.buttonVideo.layoutIfNeeded()
                    self.buttonVideo.subviews.first?.contentMode = .scaleAspectFit
                }
                else{
                    self.buttonVideo.setBackgroundImage(UIImage(named: "video_unmute"), for: .normal)
                    self.buttonVideo.layoutIfNeeded()
                    self.buttonVideo.subviews.first?.contentMode = .scaleAspectFit
                }
            }
        }
    }
    
    @IBAction func onEndPressed(_ sender: Any) {
        KRProgressHUD.show()
        Yuwee.sharedInstance().getMeetingManager().leaveMeeting { (data, isSuccess) in
            let json = JSON(data)
            print("\(isSuccess) \(json)")
            KRProgressHUD.showSuccess(withMessage: "Successfully Left.")
            self.dismiss(animated: true, completion: nil)
        }
    }
    @IBAction func onAudioPressed(_ sender: Any) {
        isAudioEnabled = !isAudioEnabled
        
        Yuwee.sharedInstance().getMeetingManager().setMediaEnabled(isAudioEnabled, withVideoEnabled: isVideoEnabled) { (data, isSuccess) in
            let json = JSON(data)
            print(json)
            if isSuccess{
                if !self.isAudioEnabled {
                    self.buttonAudio.setBackgroundImage(UIImage(named: "audio_mute"), for: .normal)
                    self.buttonAudio.layoutIfNeeded()
                    self.buttonAudio.subviews.first?.contentMode = .scaleAspectFit
                }
                else{
                    self.buttonAudio.setBackgroundImage(UIImage(named: "audio_unmute"), for: .normal)
                    self.buttonAudio.layoutIfNeeded()
                    self.buttonAudio.subviews.first?.contentMode = .scaleAspectFit
                }
            }
        }
    }
    @IBAction func onSpeakerPressed(_ sender: Any) {
        isSpeakerEnabled = !isSpeakerEnabled
        Yuwee.sharedInstance().getMeetingManager().setSpeakerEnabled(isSpeakerEnabled)
        if !self.isSpeakerEnabled {
            self.buttonSpeaker.setBackgroundImage(UIImage(named: "speaker_off"), for: .normal)
            self.buttonSpeaker.layoutIfNeeded()
            self.buttonSpeaker.subviews.first?.contentMode = .scaleAspectFit
        }
        else{
            self.buttonSpeaker.setBackgroundImage(UIImage(named: "speaker_on"), for: .normal)
            self.buttonSpeaker.layoutIfNeeded()
            self.buttonSpeaker.subviews.first?.contentMode = .scaleAspectFit
        }
    }
    
}

extension MeetingCallViewController : YuWeeRemoteStreamSubscriptionDelegate{
    func onSubscribeRemoteStreamResult(_ subsription: OWTConferenceSubscription!, with remoteStream: OWTRemoteStream!, withMessage message: String!, withStatus success: Bool) {
        if success {
            print(message!)
            Yuwee.sharedInstance().getMeetingManager().attach(remoteStream, with: self.mainVideoView) { (data, isSuccess) in
                let json = JSON(data)
                print("\(isSuccess) \(json)")
            }
            for item in self.remoteStreamArray {
                if item.remoteStream?.streamId == remoteStream.streamId {
                    item.subscription = subsription
                    break
                }
            }
            
        }
        else {
            Toast(text: message).show()
        }
        
    }
    
    
}

extension MeetingCallViewController: OnHostedMeetingDelegate{
    func onStreamAdded(_ remoteStream: OWTRemoteStream!) {
        let stream = YWRemoteStream()
        stream.remoteStream = remoteStream
        self.remoteStreamArray.append(stream)
        self.subscribeStream(remoteStream: remoteStream)
    }
    
    func onStreamRemoved(_ remoteStream: OWTRemoteStream!) {
        for (index, item) in self.remoteStreamArray.enumerated() {
            if item.remoteStream?.streamId == remoteStream.streamId {
                self.remoteStreamArray.remove(at: index)
                break
            }
        }
    }
    
    func onCallParticipantRoleUpdated(_ dict: [AnyHashable : Any]!) {
        
    }
    
    func onCallAdminsUpdated(_ dict: [AnyHashable : Any]!) {
        
    }
    
    func onCallParticipantMuted(_ dict: [AnyHashable : Any]!) {
        
    }
    
    func onCallParticipantDropped(_ dict: [AnyHashable : Any]!) {
        
    }
    
    func onCallParticipantJoined(_ dict: [AnyHashable : Any]!) {
        
    }
    
    func onCallParticipantLeft(_ dict: [AnyHashable : Any]!) {
        
    }
    
    func onCallParticipantStatusUpdated(_ dict: [AnyHashable : Any]!) {
        
    }
    
    func onCallHandRaised(_ dict: [AnyHashable : Any]!) {
        
    }
    
    func onMeetingEnded(_ dict: [AnyHashable : Any]!) {
        
    }
    
    func onCallActiveSpeaker(_ dict: [AnyHashable : Any]!) {
        
    }
    
    func onCallRecordingStatusChanged(_ dict: [AnyHashable : Any]!) {
        
    }
    
    func onError(_ error: String!) {
        
    }
    
    
}


class YWRemoteStream {
    var remoteStream: OWTRemoteStream?
    var subscription: OWTConferenceSubscription?
}
