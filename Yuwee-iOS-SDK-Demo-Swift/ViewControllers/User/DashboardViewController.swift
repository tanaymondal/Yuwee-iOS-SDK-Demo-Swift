//
//  DashboardViewController.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 20/04/21.
//

import UIKit
import SwiftyJSON
import KRProgressHUD

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelEmail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.title = "YuWee iOS SDK Demo"
        
        let json = Utils.getLoginJSON()
        
        self.labelName.text = "Name: \(String(describing: json["result"]["user"]["name"].string!))"
        self.labelEmail.text = "Email: \(String(describing: json["result"]["user"]["email"].string!))"
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
