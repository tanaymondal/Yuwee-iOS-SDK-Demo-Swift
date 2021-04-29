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
    private var isAudioEnabled = true
    private var isVideoEnabled = true
    private var isSpeakerEnabled = false
    private var remoteStreamArray : [YWRemoteStream] = []
    
    @IBOutlet weak var mainVideoView: YuweeVideoView!
    @IBOutlet weak var buttonEnd: UIButton!
    @IBOutlet weak var buttonChat: UIButton!
    @IBOutlet weak var buttonAudio: UIButton!
    @IBOutlet weak var buttonVideo: UIButton!
    @IBOutlet weak var buttonSpeaker: UIButton!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Meeting"
        
        let image = UIImage(named: "menu_icon")
        let leftItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(rightButtonAction(sender:)))

        self.navigationItem.leftBarButtonItem = leftItem
        self.meetingData = AppDelegate.meetingData
        self.meetingTokenId = AppDelegate.callTokenId
        self.isAudioEnabled = AppDelegate.isAudioEnabled
        self.isVideoEnabled = AppDelegate.isVideoEnabled
        self.loggedInEmail = Utils.getLoginJSON()["result"]["user"]["email"].string!
        self.loggedInUserId = Utils.getLoginJSON()["result"]["user"]["_id"].string!
        
        stackView.layer.cornerRadius = 20
        
        buttonEnd.setBackgroundImage(UIImage(named: "call_end"), for: .normal)
        buttonEnd.layoutIfNeeded()
        buttonEnd.subviews.first?.contentMode = .scaleAspectFit
        
        buttonChat.setBackgroundImage(UIImage(named: "chat_icon"), for: .normal)
        buttonChat.layoutIfNeeded()
        buttonChat.subviews.first?.contentMode = .scaleAspectFit
        
        buttonAudio.setBackgroundImage(UIImage(named: self.isAudioEnabled ? "audio_unmute" : "audio_mute"), for: .normal)
        buttonAudio.layoutIfNeeded()
        buttonAudio.subviews.first?.contentMode = .scaleAspectFit
        
        buttonVideo.setBackgroundImage(UIImage(named: self.isVideoEnabled ? "video_unmute" : "video_mute"), for: .normal)
        buttonVideo.layoutIfNeeded()
        buttonVideo.subviews.first?.contentMode = .scaleAspectFit
        
        buttonSpeaker.setBackgroundImage(UIImage(named: "speaker_off"), for: .normal)
        buttonSpeaker.layoutIfNeeded()
        buttonSpeaker.subviews.first?.contentMode = .scaleAspectFit
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
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
        params.isVideoEnabled = self.isVideoEnabled
        params.isAudioEnabled = self.isAudioEnabled
        
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
        self.collectionView.reloadData()
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
            for (index, item) in self.remoteStreamArray.enumerated() {
                if item.remoteStream?.streamId == remoteStream.streamId {
                    item.subscription = subsription
                    
                    let indexPath = IndexPath(index: index)
                    self.collectionView.reloadItems(at: [indexPath])
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
        print("onStreamAdded")
        let stream = YWRemoteStream()
        stream.remoteStream = remoteStream
        self.remoteStreamArray.append(stream)
        if self.remoteStreamArray.count == 1 {
            self.collectionView.reloadData()
        }
        else{
            let index = self.remoteStreamArray.count - 1
            self.collectionView.insertItems(at: [IndexPath(index: index)])
        }

        self.subscribeStream(remoteStream: remoteStream)
    }
    
    func onStreamRemoved(_ remoteStream: OWTRemoteStream!) {
        print("onStreamRemoved")
        for (index, item) in self.remoteStreamArray.enumerated() {
            if item.remoteStream?.streamId == remoteStream.streamId {
                self.remoteStreamArray.remove(at: index)
                self.collectionView.deleteItems(at: [IndexPath(index: index)])
                break
            }
        }
    }
    
    func onCallParticipantRoleUpdated(_ dict: [AnyHashable : Any]!) {
        let json = JSON(dict!)
        print("onCallParticipantRoleUpdated \(json)")
    }
    
    func onCallAdminsUpdated(_ dict: [AnyHashable : Any]!) {
        let json = JSON(dict!)
        print("onCallAdminsUpdated \(json)")
    }
    
    func onCallParticipantMuted(_ dict: [AnyHashable : Any]!) {
        let json = JSON(dict!)
        print("onCallParticipantMuted \(json)")
    }
    
    func onCallParticipantDropped(_ dict: [AnyHashable : Any]!) {
        let json = JSON(dict!)
        print("onCallParticipantDropped \(json)")
    }
    
    func onCallParticipantJoined(_ dict: [AnyHashable : Any]!) {
        let json = JSON(dict!)
        print("onCallParticipantJoined \(json)")
    }
    
    func onCallParticipantLeft(_ dict: [AnyHashable : Any]!) {
        let json = JSON(dict!)
        print("onCallParticipantLeft \(json)")
    }
    
    func onCallParticipantStatusUpdated(_ dict: [AnyHashable : Any]!) {
        let json = JSON(dict!)
        print("onCallParticipantStatusUpdated \(json)")
    }
    
    func onCallHandRaised(_ dict: [AnyHashable : Any]!) {
        let json = JSON(dict!)
        print("onCallHandRaised \(json)")
    }
    
    func onMeetingEnded(_ dict: [AnyHashable : Any]!) {
        let json = JSON(dict!)
        print("onMeetingEnded \(json)")
    }
    
    func onCallActiveSpeaker(_ dict: [AnyHashable : Any]!) {
        let json = JSON(dict!)
        print("onCallActiveSpeaker \(json)")
    }
    
    func onCallRecordingStatusChanged(_ dict: [AnyHashable : Any]!) {
        let json = JSON(dict!)
        print("onCallRecordingStatusChanged \(json)")
    }
    
    func onError(_ error: String!) {
        print("onError \(error)")
    }
    
    
}

extension MeetingCallViewController : UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.remoteStreamArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell: StreamCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "collection_view_cell", for: indexPath) as! StreamCollectionViewCell
        
        let remoteStream = self.remoteStreamArray[indexPath.row]
        
        if remoteStream.subscription != nil {
            print("subscription is not nil, show stream on view")
            cell.attachStream(stream: remoteStream.remoteStream!)
        }
        
        return cell
    }
    
    
}


class YWRemoteStream {
    var remoteStream: OWTRemoteStream?
    var subscription: OWTConferenceSubscription?
}
