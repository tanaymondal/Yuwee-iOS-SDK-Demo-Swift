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
import PopMenu
import MMWormhole
import ReplayKit

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
    private var isRecordingStarted = false
    private var isScreenSharingStarted = false
    private var isHandRaised = false
    private var remoteStreamArray: [YWRemoteStream] = []
    private var membersArray: [YWMember] = []
    private var drawerController: KYDrawerController?
    private var drawer: DrawerMenuTableViewController?
    private var memberData: YWMember?
    private var attachedViewId: String? = nil
    private var recordingId: String? = nil
    private var mongoId : String? = nil
    let wormhome = MMWormhole(applicationGroupIdentifier: "group.com.yuwee.SwiftSdkDemo", optionalDirectory: "wormhole")
    
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
        KRProgressHUD.show()
        
        self.navigationItem.title = "Meeting"
        
        let leftImage = UIImage(named: "menu_icon")
        let leftItem = UIBarButtonItem(image: leftImage, style: .plain, target: self, action: #selector(leftButtonAction(sender:)))
        
        let btn = UIButton(type: .custom)
        btn.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
        btn.setBackgroundImage(UIImage(named: "three_dot"), for: .normal)
        btn.addTarget(self, action: #selector(rightButtonAction), for: .touchUpInside)
        let rightItem = UIBarButtonItem(customView: btn)
        
        self.drawerController = self.navigationController?.parent as? KYDrawerController

        self.navigationItem.leftBarButtonItem = leftItem
        self.navigationItem.rightBarButtonItem = rightItem
        self.meetingData = AppDelegate.meetingData
        self.meetingTokenId = AppDelegate.callTokenId
        self.isAudioEnabled = AppDelegate.isAudioEnabled
        self.isVideoEnabled = AppDelegate.isVideoEnabled
        self.loggedInEmail = Utils.getLoginJSON()["result"]["user"]["email"].string!
        self.loggedInUserId = Utils.getLoginJSON()["result"]["user"]["_id"].string!
        
        
        let screenShareName = "\(Utils.getLoginJSON()["result"]["user"]["name"].string!) (Screen)"
        let dict: [String: String?] = [
            "name" : screenShareName,
            "userId" : loggedInUserId,
            "email" : loggedInEmail,
            "authToken": Utils.getLoginJSON()["access_token"].string!,
            "meetingId": self.meetingTokenId!,
            "passCode": AppDelegate.passCode]
        
        UserDefaults.init(suiteName: Constants.APP_GROUP_NAME)?.setValue(dict, forKey: Constants.SCREEN_SHARE_DATA)
        
        
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
        
        Communication.shared.setMemberActionDelegate(memberActionDelegate: self)
        self.drawer = self.drawerController?.drawerViewController?.children[0] as? DrawerMenuTableViewController
        
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.landscapeRight, andRotateTo: UIInterfaceOrientation.landscapeRight)
        
    }
    
    private func resetToPortrait() {
        AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)
    }
    
    // MARK: Navigation Left and Right Button Action
    
    @objc func leftButtonAction(sender: UIBarButtonItem) {
        isDrawerOpened = !isDrawerOpened
        
        if isDrawerOpened {
            self.drawerController!.setDrawerState(.opened, animated: true)
        }
        else {
            self.drawerController!.setDrawerState(.closed, animated: true)
        }
    }
    
    @objc func rightButtonAction(sender: UIBarButtonItem) {
        var array: [PopMenuDefaultAction] = []

        if amIAdmin {
            array.append(PopMenuDefaultAction(title: "End Meeting", image: nil))
        }
        
        if isHandRaised {
            array.append(PopMenuDefaultAction(title: "Lower Hand", image: nil))
        }
        else {
            array.append(PopMenuDefaultAction(title: "Raise Hand", image: nil))
        }

        if isScreenSharingStarted {
            array.append(PopMenuDefaultAction(title: "Stop Screen Sharing", image: nil))
        }
        else {
            array.append(PopMenuDefaultAction(title: "Start Screen Sharing", image: nil))
        }

        if amIAdmin {
            if isRecordingStarted {
                array.append(PopMenuDefaultAction(title: "Stop Recording", image: nil))
            }
            else{
                array.append(PopMenuDefaultAction(title: "Start Recording", image: nil))
            }
        }

        let menuViewController = PopMenuViewController(sourceView: self.navigationItem.rightBarButtonItem?.customView, actions: array, appearance: .none)

        menuViewController.delegate = self

        present(menuViewController, animated: true, completion: nil)
    }
    
    // MARK: Yuwee Methods Starts
    
    private func joinMeeting() {
        
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
            if isSuccess {
                KRProgressHUD.showSuccess(withMessage: "Successfully Joined.")
                
                if json["isRecording"].boolValue {
                    self.mongoId = json["mongoId"].string!
                    // when senderUserId is not mine, means I'm not starting the recording.
                    self.startRecording(senderUserId: "other")
                }
                
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
        let role = self.meetingData!["result"]["role"].string
        if role == "presenter" {
            self.amIPresenter = true
        }
        else if role == "subPresenter" {
            self.amISubPresenter = true
        }
        
        self.amIAdmin = self.meetingData!["result"]["isCallAdmin"].boolValue

        self.publishStream()
        self.getAllRemoteStreams()
        self.getAllParticipants()
        self.drawer?.setAmIAdmin(amIAdmin: self.amIAdmin)
    }
    
    private func publishStream() {
        Yuwee.sharedInstance().getMeetingManager().unpublishCameraStream()
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
            if isSuccess {
                KRProgressHUD.showSuccess(withMessage: "Camera Stream published")
            }
            else {
                KRProgressHUD.showError(withMessage: "Unable to publish camera stream")
            }
        }
    }
    
    private func getAllRemoteStreams() {
        let remoteStreamArray = Yuwee.sharedInstance().getMeetingManager().getAllRemoteStream() as NSArray as! [OWTRemoteStream]
        
        for item in remoteStreamArray {
            let stream = YWRemoteStream()
            stream.remoteStream = item
            self.remoteStreamArray.append(stream)
            self.subscribeStream(remoteStream: item)
        }
        self.collectionView.reloadData()
    }
    
    private func getAllParticipants() {
        Yuwee.sharedInstance().getMeetingManager().fetchActiveParticipantsList { (data, isSuccess) in
            let json = JSON(data)
            print(json)
            if isSuccess {
                print("Get All Participants")
                let array = json["result"].arrayValue
                for item in array {
                    let member = YWMember()
                    member.email = item["email"].string
                    member.isAdmin = item["isCallAdmin"].bool!
                    member.isAudioOn = item["isAudioOn"].bool!
                    member.isVideoOn = item["isVideoOn"].bool!
                    member.name = item["name"].string
                    
                    var roleType : RoleType = .viewer
                    if item["isPresenter"].bool! {
                        roleType = .presenter
                    }
                    if item["isSubPresenter"].bool! {
                        roleType = .subPresenter
                    }
                    member.roleType = roleType
                    member.userId = item["_id"].string
                    
                    self.membersArray.append(member)
                }
                self.drawer?.reloadTable(memberArray: self.membersArray)
                
            }
        }
    }
    
    private func subscribeStream(remoteStream: OWTRemoteStream) {
        Yuwee.sharedInstance().getMeetingManager().subscribeRemoteStream(remoteStream, withlistener: self)
    }
    
    // MARK: Controll Bar Button Actions
    
    @IBAction func onChatPressed(_ sender: Any) {
        
    }
    
    @IBAction func onVideoPressed(_ sender: Any) {
        isVideoEnabled = !isVideoEnabled
        
        Yuwee.sharedInstance().getMeetingManager().setMediaEnabled(isAudioEnabled, withVideoEnabled: isVideoEnabled) { (data, isSuccess) in
            let json = JSON(data)
            print(json)
            if isSuccess {
                if !self.isVideoEnabled {
                    self.buttonVideo.setBackgroundImage(UIImage(named: "video_mute"), for: .normal)
                    self.buttonVideo.layoutIfNeeded()
                    self.buttonVideo.subviews.first?.contentMode = .scaleAspectFit
                }
                else {
                    self.buttonVideo.setBackgroundImage(UIImage(named: "video_unmute"), for: .normal)
                    self.buttonVideo.layoutIfNeeded()
                    self.buttonVideo.subviews.first?.contentMode = .scaleAspectFit
                }
            }
        }
        
        for item in membersArray {
            if item.userId == loggedInUserId {
                item.isVideoOn = isVideoEnabled
                self.drawer?.reloadTable(memberArray: membersArray)
                break
            }
        }
    }
    
    @IBAction func onEndPressed(_ sender: Any) {
        KRProgressHUD.show()
        if isScreenSharingStarted {
            self.stopScreenSharing()
        }
        Yuwee.sharedInstance().getMeetingManager().leaveMeeting { (data, isSuccess) in
            let json = JSON(data)
            print("\(isSuccess) \(json)")
            KRProgressHUD.showSuccess(withMessage: "Successfully Left.")
            self.dismiss(animated: true, completion: nil)
            self.resetToPortrait()
        }
    }
    @IBAction func onAudioPressed(_ sender: Any) {
        isAudioEnabled = !isAudioEnabled
        
        Yuwee.sharedInstance().getMeetingManager().setMediaEnabled(isAudioEnabled, withVideoEnabled: isVideoEnabled) { (data, isSuccess) in
            let json = JSON(data)
            print(json)
            if isSuccess {
                if !self.isAudioEnabled {
                    self.buttonAudio.setBackgroundImage(UIImage(named: "audio_mute"), for: .normal)
                    self.buttonAudio.layoutIfNeeded()
                    self.buttonAudio.subviews.first?.contentMode = .scaleAspectFit
                }
                else {
                    self.buttonAudio.setBackgroundImage(UIImage(named: "audio_unmute"), for: .normal)
                    self.buttonAudio.layoutIfNeeded()
                    self.buttonAudio.subviews.first?.contentMode = .scaleAspectFit
                }
            }
        }
        
        for item in membersArray {
            if item.userId == loggedInUserId {
                item.isAudioOn = isAudioEnabled
                self.drawer?.reloadTable(memberArray: membersArray)
                break
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
        else {
            self.buttonSpeaker.setBackgroundImage(UIImage(named: "speaker_on"), for: .normal)
            self.buttonSpeaker.layoutIfNeeded()
            self.buttonSpeaker.subviews.first?.contentMode = .scaleAspectFit
        }
    }
    
}

extension MeetingCallViewController : YuWeeRemoteStreamSubscriptionDelegate {
    func onSubscribeRemoteStreamResult(_ subsription: OWTConferenceSubscription!, with remoteStream: OWTRemoteStream!, withMessage message: String!, withStatus success: Bool) {
        if success {
            print(message!)
            if self.attachedViewId != nil {
                for item in self.remoteStreamArray {
                    if item.remoteStream?.streamId == self.attachedViewId {
                        Yuwee.sharedInstance().getMeetingManager().detach(item.remoteStream!, videoView: self.mainVideoView)
                        self.attachedViewId = nil
                        break
                    }
                }
            }
            Yuwee.sharedInstance().getMeetingManager().attach(remoteStream, with: self.mainVideoView)
            self.attachedViewId = remoteStream.streamId
            
            for (index, item) in self.remoteStreamArray.enumerated() {
                if item.remoteStream?.streamId == remoteStream.streamId {
                    item.subscription = subsription
                    
                    let indexPath = IndexPath(row: index, section: 0)
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

// MARK: Host Meeting Callbacks

extension MeetingCallViewController: OnHostedMeetingDelegate {
    func onStreamAdded(_ remoteStream: OWTRemoteStream!) {
        print("onStreamAdded")
        let stream = YWRemoteStream()
        stream.remoteStream = remoteStream
        self.remoteStreamArray.append(stream)
        if self.remoteStreamArray.count == 1 {
            self.collectionView.reloadData()
        }
        else {
            let index = self.remoteStreamArray.count - 1
            self.collectionView.insertItems(at: [IndexPath(row: index, section: 0)])
        }

        self.subscribeStream(remoteStream: remoteStream)
    }
    
    func onStreamRemoved(_ remoteStream: OWTRemoteStream!) {
        print("onStreamRemoved")
        for (index, item) in self.remoteStreamArray.enumerated() {
            if item.remoteStream?.streamId == remoteStream.streamId {
                self.remoteStreamArray.remove(at: index)
                self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
                
                if self.attachedViewId == item.remoteStream?.streamId {
                    print("VideoTrack Count: \(remoteStream.mediaStream.videoTracks.count)")
                    Yuwee.sharedInstance().getMeetingManager().detach(remoteStream, videoView: self.mainVideoView)
                    if self.remoteStreamArray.count > 0 {
                        Yuwee.sharedInstance().getMeetingManager().attach(self.remoteStreamArray[0].remoteStream!, with: self.mainVideoView)
                        self.attachedViewId = self.remoteStreamArray[0].remoteStream?.streamId
                    }
                    else {
                        self.attachedViewId = nil
                    }
                }
                break
            }
        }
    }
    
    func onCallParticipantRoleUpdated(_ dict: [AnyHashable : Any]!) {
        let json = JSON(dict!)
        print("onCallParticipantRoleUpdated \(json)")
        let _id = json["userId"].string

        for item in membersArray {
            if item.userId == _id {
                let newRole = json["newRole"].string
                switch newRole {
                case "presenter":
                    item.roleType = .presenter
                    break
                case "subPresenter":
                    item.roleType = .subPresenter
                    break
                default:
                    item.roleType = .viewer
                }
                if _id == loggedInUserId {
                    switch item.roleType {
                    case .presenter:
                        self.amIPresenter = true
                        self.amISubPresenter = false
                        break
                    case .subPresenter:
                        self.amISubPresenter = true
                        self.amIPresenter = false
                        break
                    default:
                        self.amIPresenter = false
                        self.amISubPresenter = false
                    }
                    self.publishStream()
                }
                self.drawer?.reloadTable(memberArray: membersArray)
                break
            }
        }
    }
    
    func onCallAdminsUpdated(_ dict: [AnyHashable : Any]!) {
        let json = JSON(dict!)
        print("onCallAdminsUpdated \(json)")
        let _id = json["userId"].string
        if json["userId"].string == loggedInUserId {
            self.amIAdmin = false
            self.drawer?.setAmIAdmin(amIAdmin: amIAdmin)
        }
        
        for item in membersArray {
            if item.userId == _id {
                item.isAdmin = json["isCallAdmin"].boolValue
                self.drawer?.reloadTable(memberArray: membersArray)
                break
            }
        }
    }
    
    func onCallParticipantMuted(_ dict: [AnyHashable : Any]!) {
        let json = JSON(dict!)
        print("onCallParticipantMuted \(json)")
        let _id = json["userId"].string
        
        for item in membersArray {
            if item.userId == _id {
                item.isAudioOn = !json["isMuted"].boolValue
                self.drawer?.reloadTable(memberArray: membersArray)
                break
            }
        }
    }
    
    func onCallParticipantDropped(_ dict: [AnyHashable : Any]!) {
        let json = JSON(dict!)
        print("onCallParticipantDropped \(json)")
        for (index, item) in membersArray.enumerated() {
            if item.userId == json["userId"].string {
                membersArray.remove(at: index)
                self.drawer?.reloadTable(memberArray: membersArray)
                break
            }
        }
    }
    
    func onCallParticipantJoined(_ dict: [AnyHashable : Any]!) {
        let json = JSON(dict!)
        print("onCallParticipantJoined \(json)")
        let member = YWMember()
        member.email = json["info"]["email"].string
        member.name = json["info"]["name"].string
        member.isAdmin = json["info"]["isCallAdmin"].boolValue
        member.isVideoOn = json["info"]["isVideoOn"].boolValue
        member.isAudioOn = json["info"]["isAudioOn"].boolValue
        member.userId = json["info"]["_id"].string
        var role : RoleType = .viewer
        if json["isSubPresenter"].boolValue {
            role = .subPresenter
        }
        else if json["isPresenter"].boolValue {
            role = .presenter
        }
        member.roleType = role
        
        self.membersArray.append(member)
        self.drawer?.reloadTable(memberArray: self.membersArray)
    }
    
    func onCallParticipantLeft(_ dict: [AnyHashable : Any]!) {
        let json = JSON(dict!)
        print("onCallParticipantLeft \(json)")
        for (index, item) in membersArray.enumerated() {
            if item.userId == json["userId"].string {
                membersArray.remove(at: index)
                self.drawer?.reloadTable(memberArray: membersArray)
                break
            }
        }
    }
    
    func onCallParticipantStatusUpdated(_ dict: [AnyHashable : Any]!) {
        let json = JSON(dict!)
        print("onCallParticipantStatusUpdated \(json)")
        let _id = json["userId"].string
        
        for item in membersArray {
            if item.userId == _id {
                if json["info"]["isAudioOn"].exists() {
                    item.isAudioOn = json["info"]["isAudioOn"].boolValue
                }
                if json["info"]["isVideoOn"].exists() {
                    item.isVideoOn = json["info"]["isVideoOn"].boolValue
                }
                self.drawer?.reloadTable(memberArray: membersArray)
                break
            }
        }
    }
    
    func onCallHandRaised(_ dict: [AnyHashable : Any]!) {
        let json = JSON(dict!)
        print("onCallHandRaised \(json)")
        let _id = json["userId"].string
        for item in membersArray {
            if item.userId == _id {
                item.isHandRaised = json["isHandRaised"].boolValue
                self.drawer?.reloadTable(memberArray: membersArray)
            }
        }
    }
    
    func onMeetingEnded(_ dict: [AnyHashable : Any]!) {
        //let json = JSON(dict!)
        KRProgressHUD.show()
        Yuwee.sharedInstance().getMeetingManager().leaveMeeting { (data, isSuccess) in
            let json = JSON(data)
            print("\(isSuccess) \(json)")
            KRProgressHUD.showSuccess(withMessage: "Meeting ended by admin.")
            self.dismiss(animated: true, completion: nil)
            self.resetToPortrait()
        }
    }
    
    func onCallActiveSpeaker(_ dict: [AnyHashable : Any]!) {
        //let json = JSON(dict!)
        //print("onCallActiveSpeaker \(json)")
    }
    
    func onCallRecordingStatusChanged(_ dict: [AnyHashable : Any]!) {
        let json = JSON(dict!)
        print("onCallRecordingStatusChanged \(json)")
        if json["status"].string! == "started" {
            self.mongoId = json["mongoId"].string!
            
            self.startRecording(senderUserId: json["senderUserId"].string!)
        }
    }
    
    func onError(_ error: String!) {
        print("onError \(String(describing: error))")
    }
    
}

// MARK: Remote Stream Collection View
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if remoteStreamArray[indexPath.row].subscription != nil {
            
            for item in remoteStreamArray {
                if self.attachedViewId == item.remoteStream?.streamId {
                    Yuwee.sharedInstance().getMeetingManager().detach(item.remoteStream!, videoView: self.mainVideoView)
                    break
                }
            }
            
            Yuwee.sharedInstance().getMeetingManager().attach(remoteStreamArray[indexPath.row].remoteStream!, with: self.mainVideoView)
            self.attachedViewId = remoteStreamArray[indexPath.row].remoteStream!.streamId
        }
        else {
            Toast(text: "Stream is not subscribed yet").show()
        }

    }
}

    // MARK: Drawer Action Delegate Methods

extension MeetingCallViewController: MemberActionDelegate {
    
    func onThreeDotIcon(view: UIButton, member: YWMember) {
        self.memberData = member
        
        var array: [PopMenuDefaultAction] = []
        
        switch member.roleType {
        case .presenter:
            array.append(PopMenuDefaultAction(title: "Make Sub-Presenter", image: nil))
            break
        case .subPresenter:
            array.append(PopMenuDefaultAction(title: "Make Presenter", image: nil))
            break
        case .viewer:
            array.append(PopMenuDefaultAction(title: "Make Presenter", image: nil))
            array.append(PopMenuDefaultAction(title: "Make Sub-Presenter", image: nil))
            break
        default:
            return
        }
        
        array.append(PopMenuDefaultAction(title: member.isAdmin ? "Remove Admin" : "Make Admin", image: nil))
        
        array.append(PopMenuDefaultAction(title: member.isAudioOn ? "Mute" : "Unmute", image: nil))
        array.append(PopMenuDefaultAction(title: "Remove", image: nil))

        
        let menuViewController = PopMenuViewController(sourceView: view, actions: array, appearance: .none)
        menuViewController.delegate = self
        
        present(menuViewController, animated: true, completion: nil)
    }
    
    func onHandButtonPressed(member: YWMember) {
        if !self.amIAdmin {
            return
        }
        if member.userId == self.loggedInUserId {
            self.raiseHand()
            member.isHandRaised = !member.isHandRaised
            self.drawer?.reloadTable(memberArray: self.membersArray)
            return
        }
        let body = HandRaiseBody()
        body.raiseHand = !member.isHandRaised
        body.userId = member.userId!
        
        Yuwee.sharedInstance().getMeetingManager().toggleHandRaise(body) { (data, isSuccess) in
            if isSuccess {
                Toast(text: "Hand toggled successfully").show()
                member.isHandRaised = !member.isHandRaised
                self.drawer?.reloadTable(memberArray: self.membersArray)
            }
            else {
                Toast(text: "Toggle hand failed.").show()
            }
        }
    }
    
    
}

extension MeetingCallViewController: PopMenuViewControllerDelegate {

    func popMenuDidSelectItem(_ popMenuViewController: PopMenuViewController, at index: Int) {
        
        let title = popMenuViewController.actions[index].title
        switch title {
        case "Make Sub-Presenter":
            changeRoleType(role: .subPresenter)
            break
            
        case "Make Presenter":
            changeRoleType(role: .presenter)
            break
            
        case "Make Admin":
            makeRemoveAdmin(makeAdmin: true)
            break
            
        case "Remove Admin":
            makeRemoveAdmin(makeAdmin: false)
            break
            
        case "Mute":
            muteUnmuteAudio(audioEnabled: false)
            break
            
        case "Unmute":
            muteUnmuteAudio(audioEnabled: true)
            break
            
        case "Remove":
            removeUser()
            break
            
        case "Start Screen Sharing":
            print("Start Screen Sharing")
            self.showScreenShareDialog()
            self.listenWormhole()
            break
            
        case "Stop Screen Sharing":
            print("End Screen Sharing")
            self.stopScreenSharing()
            break
            
        case "End Meeting":
            endMeeting()
            break
            
        case "Start Recording":
            self.startRecording(senderUserId: self.loggedInUserId)
            break
            
        case "Stop Recording":
            self.stopCallRecording()
            break
            
        case "Raise Hand":
            self.raiseHand()
            break
            
        case "Lower Hand":
            self.raiseHand()
            break
            
        default:
            return
        }
    }
    
    private func stopScreenSharing() {
        self.wormhome.passMessageObject(false as NSCoding, identifier: "screen-sharing-started")
        self.isScreenSharingStarted = false
    }
    
    private func raiseHand() {
        let body = HandRaiseBody()
        body.raiseHand = !isHandRaised
        body.userId = self.loggedInUserId
        
        Yuwee.sharedInstance().getMeetingManager().toggleHandRaise(body) { (data, isSuccess) in
            if isSuccess {
                Toast(text: self.isHandRaised ? "Hand lowered" : "Hand raised").show()
                self.isHandRaised = !self.isHandRaised
                for item in self.membersArray {
                    if item.userId == self.loggedInUserId {
                        item.isHandRaised = self.isHandRaised
                        break
                    }
                }
                self.drawer?.reloadTable(memberArray: self.membersArray)
            }
            else {
                Toast(text: self.isHandRaised ? "Failed to lower hand" : "Failed to raise hand").show()
            }
        }
    }
    
    private func startRecording(senderUserId: String) {
        var roleType : RoleType = .viewer
        
        if amIPresenter {
            roleType = .presenter
        }
        else if amISubPresenter {
            roleType = .subPresenter
        }
        
        // I am starting the recording for first time, so send mongoId nil
        
        Yuwee.sharedInstance().getMeetingManager().startCallRecording(with: roleType, withSenderUserId: senderUserId, withMongoId: self.mongoId!) { (data, isSuccess) in
            let json = JSON(data)
            if isSuccess {
                self.recordingId = json["recordingId"].string!
                self.mongoId = json["mongoId"].string!
                self.isRecordingStarted = true
                self.startScreenRecording()
            }
            else {
                // due to a bug, call recording may not start.
                // start call recording until we get success.
                self.startRecording(senderUserId: senderUserId)
            }
            
        }
    }
    
    private func stopCallRecording() {
        KRProgressHUD.show()
        
        Yuwee.sharedInstance().getMeetingManager().stopCallRecording(withRecordingId: self.recordingId!, withMongoId: self.mongoId!, withIsRoleUpdated: false) { (message, isSuccess) in
            if isSuccess {
                KRProgressHUD.showSuccess(withMessage: "Call Recording Ended.")
                self.recordingId = ""
                self.mongoId = nil
                self.isRecordingStarted = false
                self.stopScreenRecording()
            }
            else {
                KRProgressHUD.showError(withMessage: "Ending call recording failed.")
            }
        }
    }
    
    private func startScreenRecording() {
        UserDefaults.init(suiteName: "group.com.yuwee.SwiftSdkDemo")?.setValue(true, forKey: "screen-recording-started")
        
        self.wormhome.passMessageObject(true as NSCoding, identifier: "screen-recording-started")
    }
    
    private func stopScreenRecording() {
        UserDefaults.init(suiteName: "group.com.yuwee.SwiftSdkDemo")?.setValue(false, forKey: "screen-recording-started")
        
        self.wormhome.passMessageObject(false as NSCoding, identifier: "screen-recording-started")
    }
    
    private func showScreenShareDialog() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let myAlert = storyboard.instantiateViewController(withIdentifier: "screen_share_alert")
        myAlert.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        myAlert.modalTransitionStyle = UIModalTransitionStyle.crossDissolve
        self.present(myAlert, animated: true, completion: nil)
    }
    
    private func listenWormhole() {
        self.wormhome.listenForMessage(withIdentifier: "screen-sharing-status") { (data) in
            print("broadcast started \(String(describing: data))")
            if data as! Bool == true {
                self.isScreenSharingStarted = true
                KRProgressHUD.showSuccess(withMessage: "Screen Sharing Started")
            }
            else {
                KRProgressHUD.showError(withMessage: "Unable to start screen sharing.")
            }
        }
    }
    
    private func endMeeting() {
        KRProgressHUD.show()
        Yuwee.sharedInstance().getMeetingManager().endMeeting { (data, isSuccess) in
            KRProgressHUD.showSuccess(withMessage: "Meeting Ended")
            if isSuccess {
                self.dismiss(animated: true, completion: nil)
                self.resetToPortrait()
            }
        }
    }
    
    func changeRoleType(role: RoleType) {
        let body = CallPresenterBody()
        body.isTempPresenter = false
        body.userId = self.memberData!.userId!
        KRProgressHUD.show()
        Yuwee.sharedInstance().getMeetingManager().updatePresenterStatus(body, roleType: role) { (data, isSuccess) in
            KRProgressHUD.dismiss()
            if isSuccess {
                self.memberData!.roleType = role
                self.drawer?.reloadTable(memberArray: self.membersArray)
            }
            else {
                Toast(text: "Role changing failed.").show()
            }
        }
        
    }
    
    func muteUnmuteAudio(audioEnabled: Bool) {
        
        let body = MuteUnmuteBody()
        body.audioStatus = audioEnabled
        body.userId = self.memberData!.userId!
        KRProgressHUD.show()
        Yuwee.sharedInstance().getMeetingManager().toggleParticipantAudio(body) { (data, isSuccess) in
            KRProgressHUD.dismiss()
            if isSuccess {
                self.memberData!.isAudioOn = audioEnabled
                self.drawer?.reloadTable(memberArray: self.membersArray)
            }
            else {
                Toast(text: "Audio status change failed.").show()
            }
        }
    }
    
    func makeRemoveAdmin(makeAdmin: Bool) {
        let body = CallAdminBody()
        body.userId = self.memberData!.userId!
        body.isCallAdmin = makeAdmin
        KRProgressHUD.show()
        Yuwee.sharedInstance().getMeetingManager().makeOrRevokeAdmin(body) { (data, isSuccess) in
            KRProgressHUD.dismiss()
            if isSuccess {
                self.memberData!.isAdmin = makeAdmin
                self.drawer?.reloadTable(memberArray: self.membersArray)
            }
            else {
                Toast(text: "Admin status change failed.").show()
            }
        }
    }
    
    func removeUser() {
        KRProgressHUD.show()
        Yuwee.sharedInstance().getMeetingManager().dropParticipant(self.memberData!.userId!) { (data, isSuccess) in
            KRProgressHUD.dismiss()
            if isSuccess {
                for (index, item) in self.membersArray.enumerated() {
                    if  item.userId == self.memberData!.userId! {
                        self.membersArray.remove(at: index)
                        self.drawer?.reloadTable(memberArray: self.membersArray)
                        break
                    }
                }
            }
            else {
                Toast(text: "Unable to remove user.").show()
            }
        }
    }

}


class YWRemoteStream {
    var remoteStream: OWTRemoteStream?
    var subscription: OWTConferenceSubscription?
}

class YWMember {
    var userId: String?
    var name: String?
    var email: String?
    var isAdmin = false
    var roleType: RoleType = .viewer
    var isVideoOn = true
    var isAudioOn = true
    var isHandRaised = false
}
