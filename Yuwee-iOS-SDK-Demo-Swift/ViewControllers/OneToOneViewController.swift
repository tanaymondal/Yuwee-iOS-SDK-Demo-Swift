//
//  OneToOneViewController.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 20/04/21.
//

import UIKit
import KRProgressHUD

class OneToOneViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var fieldEmail: UITextField!
    
    @IBOutlet weak var switchVideoCall: UISwitch!
    
    
    var callParams : CallParams?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.fieldEmail.delegate = self
        let isConnected = Yuwee.sharedInstance().getConnectionManager().isConnected()
        print("Is Yuwee Connected: \(isConnected)")
    }
    
    @IBAction func onStartCallPressed(_ sender: Any) {
        if !Utils.isValidEmail(email: fieldEmail.text!) {
            Utils.toast(message: "Email is not valid")
            return
        }
        
        self.startCall()
        
    }
    
    private func startCall(){
        
        KRProgressHUD.show()
        
        let callParams = CallParams()
        callParams.invitationMessage = "Let's have a call..."
        callParams.inviteeName = self.fieldEmail.text!
        callParams.isGroup = false
        callParams.inviteeEmail = self.fieldEmail.text!
        callParams.mediaType = switchVideoCall.isOn ? MediaType.VIDEO : MediaType.AUDIO
        
        Yuwee.sharedInstance().getCallManager().setUpCall(callParams, withClassListnerObject: self)
        
        
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.fieldEmail {
            self.fieldEmail.resignFirstResponder()
        }
        else{
            self.view.endEditing(true)
        }

        return false
    }


}

extension OneToOneViewController: YuWeeCallSetUpDelegate {
    

    
    func onAllUsersOffline() {
        print("onAllUsersOffline")
    }
    
    func onAllUsersBusy() {
        print("onAllUsersBusy")
    }
    
    func onReady(toInitiateCall callParams: CallParams!, withBusyUserList arrBusyUserList: [Any]!) {
        print("onReadyToInitiateCall")
            KRProgressHUD.dismiss()
            
            self.performSegue(withIdentifier: "CallViewController", sender: self)
    }
    
    func onError(_ callParams: CallParams!, withMessage strMessage: String!) {
        print("onError \(String(describing: strMessage))")
    }
}
