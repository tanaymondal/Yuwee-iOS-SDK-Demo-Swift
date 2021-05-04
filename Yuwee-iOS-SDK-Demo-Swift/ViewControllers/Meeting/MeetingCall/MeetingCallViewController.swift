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
    private var remoteStreamArray: [YWRemoteStream] = []
    private var membersArray: [YWMember] = []
    private var drawerController: KYDrawerController?
    private var drawer: DrawerMenuTableViewController?
    private var memberData: YWMember?
    private var attachedViewId = ""
    
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
        
        self.drawerController = self.navigationController?.parent as? KYDrawerController

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
        
        Communication.shared.setMemberActionDelegate(memberActionDelegate: self)
        self.drawer = self.drawerController?.drawerViewController?.children[0] as? DrawerMenuTableViewController
    }
    
    @objc func rightButtonAction(sender: UIBarButtonItem){
        isDrawerOpened = !isDrawerOpened
        
        if isDrawerOpened {
            self.drawerController!.setDrawerState(.opened, animated: true)
        }
        else{
            self.drawerController!.setDrawerState(.closed, animated: true)
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
    
    private func publishStream(){
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
    
    private func getAllParticipants(){
        Yuwee.sharedInstance().getMeetingManager().fetchActiveParticipantsList { (data, isSuccess) in
            let json = JSON(data)
            print(json)
            if isSuccess{
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
                self.attachedViewId = remoteStream.streamId
            }
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
                    //self.mainVideoView.clear
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
        let json = JSON(dict!)
        print("onMeetingEnded \(json)")
    }
    
    func onCallActiveSpeaker(_ dict: [AnyHashable : Any]!) {
        //let json = JSON(dict!)
        //print("onCallActiveSpeaker \(json)")
    }
    
    func onCallRecordingStatusChanged(_ dict: [AnyHashable : Any]!) {
        let json = JSON(dict!)
        print("onCallRecordingStatusChanged \(json)")
    }
    
    func onError(_ error: String!) {
        print("onError \(String(describing: error))")
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

extension MeetingCallViewController: MemberActionDelegate{    
    
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
        default:
            return
        }
    }
    
    func changeRoleType(role: RoleType) {
        let body = CallPresenterBody()
        body.isTempPresenter = false
        body.userId = self.memberData!.userId!
        KRProgressHUD.show()
        Yuwee.sharedInstance().getMeetingManager().updatePresenterStatus(body, roleType: .presenter) { (data, isSuccess) in
            KRProgressHUD.dismiss()
            if isSuccess{
                self.memberData!.roleType = .presenter
                self.drawer?.reloadTable(memberArray: self.membersArray)
            }
            else{
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
            if isSuccess{
                self.memberData!.isAudioOn = audioEnabled
                self.drawer?.reloadTable(memberArray: self.membersArray)
            }
            else{
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
            if isSuccess{
                self.memberData!.isAdmin = makeAdmin
                self.drawer?.reloadTable(memberArray: self.membersArray)
            }
            else{
                Toast(text: "Admin status change failed.").show()
            }
        }
    }
    
    func removeUser() {
        KRProgressHUD.show()
        Yuwee.sharedInstance().getMeetingManager().dropParticipant(self.memberData!.userId!) { (data, isSuccess) in
            KRProgressHUD.dismiss()
            if isSuccess{
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
