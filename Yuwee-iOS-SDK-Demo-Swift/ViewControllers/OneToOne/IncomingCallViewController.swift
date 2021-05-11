//
//  IncomingCallViewController.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 11/05/21.
//

import UIKit
import SwiftyJSON

class IncomingCallViewController: UIViewController {
    @IBOutlet weak var labelIncomingMessage: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var btnVideo: UIButton!
    
    var callData: [AnyHashable : Any] = [:]
    private var workItem: DispatchWorkItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let json = JSON(callData)
        print(json)
        if json["callType"].string?.lowercased() == "video" {
            self.labelIncomingMessage.text = "Incoming Video Call"
        }
        else {
            self.labelIncomingMessage.text = "Incoming Audio Call"
        }
        
        self.labelName.text = json["sender"]["name"].string
        
        workItem = DispatchWorkItem {
            Yuwee.sharedInstance().getCallManager().timeOutIncomingCall()
            self.dismiss(animated: true, completion: nil)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(20), execute: workItem!)
        
    }
    
    @IBAction func onAcceptAudioCall(_ sender: Any) {
        Yuwee.sharedInstance().getCallManager().acceptIncomingCall(callData)
        self.workItem?.cancel()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onAcceptVideoCall(_ sender: Any) {
        Yuwee.sharedInstance().getCallManager().acceptIncomingCall(callData)
        self.workItem?.cancel()
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onRejectCall(_ sender: Any) {
        Yuwee.sharedInstance().getCallManager().rejectIncomingCall(callData)
        self.workItem?.cancel()
        self.dismiss(animated: true, completion: nil)
    }

}
