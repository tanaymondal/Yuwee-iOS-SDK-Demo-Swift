//
//  RegisterViewController.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 12/02/21.
//

import UIKit
import Toaster
import SwiftyJSON
import KRProgressHUD

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var fieldName: UITextField!
    @IBOutlet weak var fieldEmail: UITextField!
    @IBOutlet weak var fieldPassword: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navigationItem.title = "Sign up"
        
        self.fieldName.delegate = self
        self.fieldEmail.delegate = self
        self.fieldPassword.delegate = self
    }
    @IBAction func onBackPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onRegisterPressed(_ sender: Any) {
        

        
        if fieldName.text!.count < 1 {
            Utils.toast(message: "Name can't be empty.")
            return
        } else if !Utils.isValidEmail(email: self.fieldEmail.text!) {
            Utils.toast(message: "Email is not valid.")
            return
        } else if fieldPassword.text!.count < 6 || fieldPassword.text!.count > 20 {
            Utils.toast(message: "Password must be between 6 to 20 characters.")
            return
        }

        KRProgressHUD.show()
        Yuwee.sharedInstance().getUserManager().createUser(withName: fieldName.text!, email: fieldEmail.text!, password: fieldPassword.text!) { (isSuccess, data : [AnyHashable : Any]?) in
            if(isSuccess){
                KRProgressHUD.showSuccess(withMessage: "Sign up successful.")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else{
                KRProgressHUD.showError(withMessage: JSON(data!)["message"].string)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == fieldName {
            fieldName.resignFirstResponder()
            fieldEmail.becomeFirstResponder()
        }
        else if(textField == fieldEmail){
            fieldEmail.resignFirstResponder()
            fieldPassword.becomeFirstResponder()
        }
        else{
            self.view.endEditing(true)
        }

        return false
    }

}
