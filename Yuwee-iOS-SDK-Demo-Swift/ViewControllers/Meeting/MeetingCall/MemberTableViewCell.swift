//
//  MemberCollectionViewCell.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 30/04/21.
//

import UIKit
import PopMenu

class MemberTableViewCell: UITableViewCell {
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelAdmin: UIButton!
    @IBOutlet weak var labelPresenter: UIButton!
    @IBOutlet weak var buttonVideo: UIButton!
    @IBOutlet weak var buttonAudio: UIButton!
    @IBOutlet weak var buttonThreeDots: UIButton!
    
    private var member : YWMember?
    
    @IBAction func onThreeDotPressed(_ sender: Any) {
        Communication.shared.onThreeDotIconClicked(view: buttonThreeDots, member: member!)
    }
    @IBAction func onAudioPressed(_ sender: Any) {
        
    }
    @IBAction func onVideoPressed(_ sender: Any) {
       
    }
    
    public func update(member: YWMember) {
        self.member = member
        let myId = Utils.getLoginJSON()["result"]["user"]["_id"].string!
        let isMe = myId == member.userId
        labelName.text = member.name
        labelAdmin.isHidden = !member.isAdmin
        buttonThreeDots.isHidden = isMe
        
        buttonAudio.setBackgroundImage(UIImage(named: member.isAudioOn ? "audio_unmute" : "audio_mute"), for: .normal)
        buttonAudio.layoutIfNeeded()
        buttonAudio.subviews.first?.contentMode = .scaleAspectFit
        
        buttonVideo.setBackgroundImage(UIImage(named: member.isVideoOn ? "video_unmute" : "video_mute"), for: .normal)
        buttonVideo.layoutIfNeeded()
        buttonVideo.subviews.first?.contentMode = .scaleAspectFit
        
        switch member.roleType {
        case .presenter:
            labelPresenter.setTitle("Presenter", for: .normal)
            break
        case .subPresenter:
            labelPresenter.setTitle("Sub-Presenter", for: .normal)
            break
        case .viewer:
            labelPresenter.setTitle("Viewer", for: .normal)
            break
        @unknown default:
            labelPresenter.setTitle("Viewer", for: .normal)
        }
    }
}
