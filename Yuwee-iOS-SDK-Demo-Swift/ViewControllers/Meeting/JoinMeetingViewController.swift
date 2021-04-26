//
//  JoinMeetingViewController.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 22/04/21.
//

import UIKit
import Toaster
import SwiftyJSON

class JoinMeetingViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var fieldMeetingId: UITextField!
    
    @IBOutlet weak var fieldPasscode: UITextField!
    @IBOutlet weak var videoSwitch: UISwitch!
    @IBOutlet weak var audioSwitch: UISwitch!
    
    var meetingId : String?
    var passcode : String?
    
    private var meetingData: JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Join Meeting"
        self.fieldMeetingId.delegate = self
        self.fieldPasscode.delegate = self
        
        if meetingId != nil {
            fieldMeetingId.text = meetingId
        }
        
        if passcode != nil {
            fieldPasscode.text = passcode
        }
    }
    @IBAction func onJoinMeetingPressed(_ sender: Any) {
        if fieldMeetingId.text?.count == 0 {
            Toast(text: "Meeting ID is empty.").show()
            return
        }
        
        if fieldPasscode.text?.count == 0 {
            Toast(text: "Passcode is empty.").show()
            return
        
        }
        
        let joinMedia = JoinMedia()
        joinMedia.audio = audioSwitch.isOn
        joinMedia.video = videoSwitch.isOn
        
        let params = RegisterMeetingBody()
        params.guestId = String(describing: Utils.getLoginJSON()["result"]["user"]["_id"].string!)
        params.meetingTokenId = fieldMeetingId.text!
        params.passcode = fieldPasscode.text!
        params.nickName = String(describing: Utils.getLoginJSON()["result"]["user"]["name"].string!)
        params.joinMedia = joinMedia
        
        print(JSON(params))
        
        Yuwee.sharedInstance().getMeetingManager().register(inMeeting: params) { (data, isSuccess) in
            if isSuccess{
                self.meetingData = JSON(data)
                self.performSegue(withIdentifier: "MeetingCall", sender: self)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as! MeetingCallViewController
        vc.meetingData = self.meetingData
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == fieldMeetingId {
            fieldMeetingId.resignFirstResponder()
            fieldPasscode.becomeFirstResponder()
        }
        else{
            self.view.endEditing(true)
        }

        return false
    }

}
