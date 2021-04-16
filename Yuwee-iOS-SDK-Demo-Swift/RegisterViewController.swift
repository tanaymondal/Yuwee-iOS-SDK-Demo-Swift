//
//  RegisterViewController.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 12/02/21.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var fieldName: UITextField!
    @IBOutlet weak var fieldEmail: UITextField!
    @IBOutlet weak var fieldPassword: UITextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.fieldName.delegate = self
        self.fieldEmail.delegate = self
        self.fieldPassword.delegate = self
    }
    
    @IBAction func onRegisterPressed(_ sender: Any) {
        

        
        if fieldName.text!.count < 1 {
            self.showAlert(message: "Name can't be empty.")
            return
        } else if !isStringIsValidEmail(fieldEmail.text) {
            self.showAlert(message: "Email is not valid.")
            return
        } else if fieldPassword.text!.count < 6 || fieldPassword.text!.count > 20 {
            self.showAlert(message: "Password must be between 6 to 20 characters.")
            return
        }

        
        Yuwee.sharedInstance().getUserManager().createUser(withName: fieldName.text!, email: fieldEmail.text!, password: fieldPassword.text!) { (isSuccess, _: [AnyHashable : Any]?) in
            if(isSuccess){
                self.fieldName.text = ""
                self.fieldEmail.text = ""
                self.fieldPassword.text = ""
                self.showAlert(message: "Registration successful.")
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
    
    func isStringIsValidEmail(_ checkString: String?) -> Bool {
        let stricterFilter = false
        let stricterFilterString = "^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$"
        let laxString = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        let emailRegex = stricterFilter ? stricterFilterString : laxString
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)

        return emailTest.evaluate(with: checkString)
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
