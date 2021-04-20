//
//  OneToOneCallViewController.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 20/04/21.
//

import UIKit
import SwiftyJSON
import KRProgressHUD

class OneToOneCallViewController: UIViewController {
    @IBOutlet weak var remoteVideoView: YuweeRemoteVideoView!
    
    @IBOutlet weak var localVideoView: YuweeLocalVideoView!

    
    var callParams: CallParams?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.title = "Call"
        self.setupCall()
        
    }
    
    private func setupCall() {
        Yuwee.sharedInstance().getCallManager().initCall(withLocalView: self.localVideoView, withRemoteView: self.remoteVideoView)
        
        Yuwee.sharedInstance().getCallManager().setCallManagerDelegate(self)
    }
    
    @IBAction func onEndPressed(_ sender: Any) {
        KRProgressHUD.show()
        Yuwee.sharedInstance().getCallManager().hangUpCall { (isSuccess, data) in
            if isSuccess{
                KRProgressHUD.showSuccess(withMessage: "Call Ended.")
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    

}

extension OneToOneCallViewController: YuWeeCallManagerDelegate{
    
    func onCallTimeOut() {
        print("onCallTimeOut")
    }
    
    func onCallReject() {
        print("onCallReject")
        DispatchQueue.main.async {
            KRProgressHUD.showInfo(withMessage: "Call Rejected.")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func onCallAccept() {
        print("onCallAccept")
    }
    
    func onCallConnected() {
        print("onCallConnected")
    }
    
    func onCallDisconnected() {
        print("onCallDisconnected")
    }
    
    func onCallReconnecting() {
        print("onCallReconnecting")
    }
    
    func onCallReconnected() {
        print("onCallReconnected")
    }
    
    func onCallRinging() {
        print("onCallRinging")
    }
    
    func onRemoteCallHangUp(_ callData: [AnyHashable : Any]!) {
        let data = JSON(callData!)
        print("onRemoteCallHangUp \(data)")
    }
    
    func onRemoteVideoToggle(_ callData: [AnyHashable : Any]!) {
        let data = JSON(callData!)
        print("onRemoteVideoToggle \(data)")
    }
    
    func onRemoteAudioToggle(_ callData: [AnyHashable : Any]!) {
        let data = JSON(callData!)
        print("onRemoteAudioToggle \(data)")
    }
    
    func onCallEnd(_ callData: [AnyHashable : Any]!) {
        let data = JSON(callData!)
        print("onCallEnd \(data)")
        DispatchQueue.main.async {
            KRProgressHUD.showInfo(withMessage: "Call Ended.")
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func onCallConnectionFailed() {
        print("onCallConnectionFailed")
    }
    
    func setUpAditionalViewsOn(_ remoteView: YuweeRemoteVideoView!, with size: CGSize) {
        print("setUpAditionalViewsOn")
    }
}
