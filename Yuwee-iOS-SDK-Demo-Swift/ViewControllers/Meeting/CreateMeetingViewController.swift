//
//  CreateMeetingViewController.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 22/04/21.
//

import UIKit
import Toaster
import SwiftyJSON
import KRProgressHUD

class CreateMeetingViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet var fieldMeetingName: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var fieldMeetingDuration: UITextField!
    @IBOutlet weak var fieldPresenters: UITextField!
    weak var delegate: OnNewMeetingDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Create Meeting"
        self.fieldMeetingName.delegate = self
        self.fieldMeetingDuration.delegate = self
        self.fieldPresenters.delegate = self
        
    }
    @IBAction func onCreateMeetingPressed(_ sender: Any) {
        
        if fieldMeetingName.text!.count < 3 {
            Toast(text: "Meeting name should be at least of 3 characters.").show()
            return
        }
        
        if fieldMeetingDuration.text!.count != 0 {
            if Int(fieldMeetingDuration.text!)! < 5 {
                Toast(text: "Meeting must be at lease of 5 minutes.").show()
                return
            }
        }
        else{
            Toast(text: "Meeting must be at lease of 5 minutes.").show()
            return
        }

        let emails : NSMutableArray = []
        let array = fieldPresenters.text!.split(separator: ",")
        if array.count != 0 {
            for email in array {
                let em = String(email).trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
                if !Utils.isValidEmail(email: em) {
                    Toast(text: "One of the presenter email is not valid.").show()
                    return
                }
                else{
                    emails.add(em)
                }
            }
        }
         
        // adding logged in user as presenter
        emails.add(String(describing: Utils.getLoginJSON()["result"]["user"]["email"].string!))
        
        if datePicker.date.localDate() < Date().localDate() {
            Toast(text: "You can't create meeting in the past.").show()
            return
        }
        
        self.createMeeting(presentersEmail: emails)
        
    }
    
    func createMeeting(presentersEmail: NSMutableArray) {
        
        let adminsEmail: NSMutableArray = []
        adminsEmail.add(String(describing: Utils.getLoginJSON()["result"]["user"]["email"].string!))
        
        let body = HostMeetingBody()
        body.accessType = "open" //
        body.meetingName = self.fieldMeetingName.text!
        body.maxAllowedParticipant = 20
        body.callMode = 1 // sfu
        body.meetingExpireDuration = 5 * 60 // in seconds
        body.meetingStartTime = Int(datePicker.date.timeIntervalSince1970 * 1000)
        body.presenters = presentersEmail
        body.callAdmins = adminsEmail
        body.isCallAllowedWithoutInitiator = true

        KRProgressHUD.show()
        Yuwee.sharedInstance().getMeetingManager().hostMeeting(body) { (data, isSuccess) in
            let json = JSON(data)
            //print(json)
            KRProgressHUD.showSuccess(withMessage: json["message"].string)
            if isSuccess{
                self.delegate?.onNewMeetingCreated(json: json)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == fieldMeetingName {
            fieldMeetingName.resignFirstResponder()
            fieldMeetingDuration.becomeFirstResponder()
        }
        else if textField == fieldMeetingDuration{
            fieldMeetingDuration.resignFirstResponder()
            fieldPresenters.becomeFirstResponder()
        }
        else{
            self.view.endEditing(true)
        }

        return false
    }

}

protocol OnNewMeetingDelegate:class {
    func onNewMeetingCreated(json : JSON);
}
