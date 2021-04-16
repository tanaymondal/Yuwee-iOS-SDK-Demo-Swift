//
//  LoginViewController.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 12/02/21.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var fieldEmail: UITextField!
    @IBOutlet weak var fieldPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.fieldEmail.delegate = self
        self.fieldPassword.delegate = self
    }
    
    @IBAction func onLoginPressed(_ sender: Any) {
        if (!self.isValidEmail(self.fieldEmail.text!)) {
            self.showAlert(message: "Email is not valid.")
            return
        }
        else if (self.fieldPassword.text!.count < 6 || self.fieldPassword.text!.count > 20){
            self.showAlert(message: "Password must be between 6 to 20 characters.")
            return;
        }
        
        
        Yuwee.sharedInstance().getUserManager().createSessionViaCredentials(withEmail: self.fieldEmail.text!, password: self.fieldPassword.text!, expiryTime: "100000000") { (isSuccess, _: [AnyHashable : Any]?) in
            if isSuccess{
                self.showAlert(message: "Login Successful.")
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
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        present(alert, animated: true, completion: nil)
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
