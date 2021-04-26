//
//  MeetingDetailsViewController.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 26/04/21.
//

import UIKit
import SwiftyJSON
import Toaster

class MeetingDetailsViewController: UIViewController {
    
    var meetingDetails : JSON?

    @IBOutlet weak var labelMeetingName: UILabel!
    @IBOutlet weak var labelMeetingId: UILabel!
    @IBOutlet weak var labelStartTime: UILabel!
    @IBOutlet weak var labelPresenters: UILabel!
    @IBOutlet weak var labelAdmins: UILabel!
    @IBOutlet weak var labelPasscode: UILabel!
    @IBOutlet weak var labelPresenterPasscode: UILabel!
    @IBOutlet weak var labelSubPresenterPasscode: UILabel!
    
    @IBOutlet weak var labelJoinMessage: UILabel!
    
    private var isPresenter = false

    override func viewDidLoad() {
        super.viewDidLoad()

        let rightItem = UIBarButtonItem(title: "Join",
                                       style: UIBarButtonItem.Style.plain,
                                       target: self,
                                       action: #selector(rightButtonAction(sender:)))

        self.navigationItem.rightBarButtonItem = rightItem
        self.navigationItem.title = "Meeting Details"
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapPasscode))
        labelPasscode.isUserInteractionEnabled = true
        labelPasscode.addGestureRecognizer(tap)
        
        let presenterTap = UITapGestureRecognizer(target: self, action: #selector(tapPresenterPasscode))
        labelPresenterPasscode.isUserInteractionEnabled = true
        labelPresenterPasscode.addGestureRecognizer(presenterTap)
        
        let subPresentertap = UITapGestureRecognizer(target: self, action: #selector(tapSubPresenterPasscode))
        labelSubPresenterPasscode.isUserInteractionEnabled = true
        labelSubPresenterPasscode.addGestureRecognizer(subPresentertap)
        
        self.labelMeetingName.text = meetingDetails!["meetingName"].string
        self.labelMeetingId.text = "Meeting Token ID: \(meetingDetails!["meetingTokenId"].string!)"
        let date = Date(milliseconds: meetingDetails!["callId"]["meetingStartTime"].int64!).localDate()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.labelStartTime.text = "Start Time: \(dateFormatter.string(from: date))"
        
        var strAdmin = ""
        for data in meetingDetails!["callId"]["callAdmins"].arrayValue {
            strAdmin = "\(strAdmin)\n\(data.string!)"
        }
        labelAdmins.numberOfLines = 0
        labelAdmins.text = strAdmin.trim()
        
        let email = Utils.getLoginJSON()["result"]["user"]["email"].string!
        
        var strPresenter = ""
        for data in meetingDetails!["callId"]["presenters"].arrayValue {
            strPresenter = "\(strPresenter)\n\(data.string!)"
            if email == data.string! {
                isPresenter = true
            }
        }
        labelPresenters.numberOfLines = 0
        labelPresenters.text = strPresenter.trim()
        
        labelPasscode.text = meetingDetails!["passcode"].string
        labelPresenterPasscode.text = meetingDetails!["presenterPasscode"].string
        labelSubPresenterPasscode.text = meetingDetails!["subPresenterPasscode"].string
        
        labelJoinMessage.numberOfLines = 0
        if isPresenter {
            labelJoinMessage.text = "You are a Presenter! Join using presenter passcode."
        }
        else {
            labelJoinMessage.text = "You can join using either Sub-Presenter passcode or only passcode."
        }
        
    }
    
    @objc func tapPasscode(sender:UITapGestureRecognizer) {
        UIPasteboard.general.string = labelPasscode.text
        Toast(text: "Copied").show()
    }
    
    @objc func tapPresenterPasscode(sender:UITapGestureRecognizer) {
        UIPasteboard.general.string = labelPresenterPasscode.text
        Toast(text: "Copied").show()
    }
    
    @objc func tapSubPresenterPasscode(sender:UITapGestureRecognizer) {
        UIPasteboard.general.string = labelSubPresenterPasscode.text
        Toast(text: "Copied").show()
    }
    
    @objc func rightButtonAction(sender: UIBarButtonItem){
        performSegue(withIdentifier: "JoinMeetingFromDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! JoinMeetingViewController
        vc.meetingId = meetingDetails!["meetingTokenId"].string!
        vc.passcode = isPresenter ? meetingDetails!["presenterPasscode"].string! : meetingDetails!["subPresenterPasscode"].string!
    }
    
}
