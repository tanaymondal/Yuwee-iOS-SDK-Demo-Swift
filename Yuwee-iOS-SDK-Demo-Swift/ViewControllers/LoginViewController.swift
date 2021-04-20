//
//  LoginViewController.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 12/02/21.
//

import UIKit
import Toaster
import KRProgressHUD
import SwiftyJSON

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var fieldEmail: UITextField!
    @IBOutlet weak var fieldPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Login"

        // Do any additional setup after loading the view.
        self.fieldEmail.delegate = self
        self.fieldPassword.delegate = self
        
        if Yuwee.sharedInstance().getUserManager().isLoggedIn() {
            self.performSegue(withIdentifier: "dashboardSegue", sender: nil)
        }
    }
    
    @IBAction func onLoginPressed(_ sender: Any) {
        if (!Utils.isValidEmail(email: self.fieldEmail.text!)) {
            Utils.toast(message: "Email is not valid.")
            return
        }
        else if (self.fieldPassword.text!.count < 6 || self.fieldPassword.text!.count > 20){
            Utils.toast(message: "Password must be between 6 to 20 characters.")
            return;
        }
        
    
        KRProgressHUD.show()
        Yuwee.sharedInstance().getUserManager().createSessionViaCredentials(withEmail: self.fieldEmail.text!, password: self.fieldPassword.text!, expiryTime: "100000000") { (isSuccess, data : [AnyHashable : Any]?) in
            if isSuccess{
                
                do{
                    let mData = try NSKeyedArchiver.archivedData(withRootObject: data!, requiringSecureCoding: false)
                    
                    let userDefault = UserDefaults.init(suiteName: Constants.APP_GROUP_NAME)
                    userDefault?.setValue(mData, forKey: Constants.LOGIN_DATA)
                }
                catch {
                    
                }

                
                KRProgressHUD.showSuccess(withMessage: "Login Successful.")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.performSegue(withIdentifier: "dashboardSegue", sender: nil)
                }
            }
            else{
                KRProgressHUD.showError(withMessage: JSON(data!)["message"].string)
            }
        }
        
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == fieldEmail {
            fieldEmail.resignFirstResponder()
            fieldPassword.becomeFirstResponder()
        }
        else{
            self.view.endEditing(true)
        }

        return false
    }
    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
        
    }

}
