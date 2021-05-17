//
//  DashboardViewController.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 20/04/21.
//

import UIKit
import SwiftyJSON
import KRProgressHUD
import Toaster

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    private var callData: JSON?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.title = "YuWee iOS SDK Demo"
        
        let json = Utils.getLoginJSON()
        
        AppDelegate.loggedInUserId = json["result"]["user"]["_id"].string!
        AppDelegate.loggedInEmail = json["result"]["user"]["email"].string!
        AppDelegate.loggedInName = json["result"]["user"]["name"].string!
        
        self.labelName.text = "Name: \(AppDelegate.loggedInName)"
        self.labelEmail.text = "Email: \(AppDelegate.loggedInEmail)"
        
        Yuwee.sharedInstance().getCallManager().setIncomingCallEventDelegate(self)
    }
    

    @IBAction func logoutPressed(_ sender: Any) {
        KRProgressHUD.show()
        Yuwee.sharedInstance().getUserManager().logout()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            KRProgressHUD.dismiss()
            self.performSegue(withIdentifier: "unwindToLogin", sender: self)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DashboardViewController: YuWeeIncomingCallEventDelegate {
    
    func onIncomingCall(_ callData: [AnyHashable : Any]!) {
        
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyBoard.instantiateViewController(withIdentifier: "incoming_call") as! IncomingCallViewController
        controller.modalPresentationStyle = .fullScreen
        controller.callData = callData
        self.present(controller, animated: true, completion: nil)
        
    }
    
    func onIncomingCallAcceptSuccess(_ callData: [AnyHashable : Any]!) {
        self.callData = JSON(callData!)
        print("Accept \(callData!)")
        Toast(text: "Call Accepted").show()
        self.performSegue(withIdentifier: "DashboardToCall", sender: self)
    }
    
    func onIncomingCallRejectSuccess(_ callData: [AnyHashable : Any]!) {
        print("Reject \(JSON(callData!))")
        Toast(text: "Call Rejected").show()
    }
    
    func onIncomingCallActionPerformed(fromOtherDevice data: [AnyHashable : Any]!) {
        print("onIncomingCallActionPerformedFromOtherDevice")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DashboardToCall" {
            let vc = segue.destination as! OneToOneCallViewController
            vc.callData = self.callData
        }
    }
}
