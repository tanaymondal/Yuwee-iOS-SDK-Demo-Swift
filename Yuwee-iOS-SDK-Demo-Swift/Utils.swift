//
//  Utils.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 20/04/21.
//

import Foundation
import SwiftyJSON
import Toaster

class Utils {
    
    static func getLoginJSON() -> JSON{
        let data = UserDefaults.init(suiteName: Constants.APP_GROUP_NAME)?.value(forKey: Constants.LOGIN_DATA)
        
        do{
            let dict = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data as! Data)
            
            let json = JSON(dict!)
            return json
        }
        catch{
            return JSON("")
        }
    }
    
    static func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    static func toast(message: String){
        Toast(text: message).show()
    }
    
}
