//
//  JoinMeetingViewController.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 22/04/21.
//

import UIKit
import Toaster
import SwiftyJSON
import KRProgressHUD

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
        
        let json = Utils.getLoginJSON()
        
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
        params.guestId = json["result"]["user"]["email"].string!
        params.meetingTokenId = fieldMeetingId.text!
        params.passcode = fieldPasscode.text!
        params.nickName = json["result"]["user"]["name"].string!
        params.joinMedia = joinMedia
        
        KRProgressHUD.show()
        Yuwee.sharedInstance().getMeetingManager().register(inMeeting: params) { (data, isSuccess) in
            let json = JSON(data)
            if isSuccess{
                KRProgressHUD.dismiss()
                AppDelegate.callTokenId = self.fieldMeetingId.text!
                AppDelegate.meetingData = json
                self.performSegue(withIdentifier: "MainMeetingDrawer", sender: self)
            }
            else{
                KRProgressHUD.showError(withMessage: json["message"].string)
            }
        }
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
