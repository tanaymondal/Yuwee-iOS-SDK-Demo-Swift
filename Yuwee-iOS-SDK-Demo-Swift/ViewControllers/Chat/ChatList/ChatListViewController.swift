//
//  ChatListViewController.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 12/05/21.
//

import UIKit
import KRProgressHUD
import SwiftyJSON

class ChatListViewController: UIViewController, UIAlertViewDelegate {
    
    private var array: [ChatListData] = []
    private var chatListData = ChatListData()
    private var enteredEmailsArray: [String] = []

    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        KRProgressHUD.show()
        
        
        let rightItem = UIBarButtonItem(title: "New Chat",
                                       style: UIBarButtonItem.Style.plain,
                                       target: self,
                                       action: #selector(rightButtonAction(sender:)))

        self.navigationItem.rightBarButtonItem = rightItem
        self.navigationItem.title = "Chat List"
        
        tableView.dataSource = self
        tableView.delegate = self
        
        Yuwee.sharedInstance().getChatManager().fetchChatList { (isSuccess, data) in
            if isSuccess {
                let json = JSON(data!)
                print(json)
                
                if json["result"]["results"].count > 0 {
                    for item in json["result"]["results"].arrayValue {
                        let data = ChatListData()
                        data.isGroup = item["isGroupChat"].boolValue
                        data.roomId = item["_id"].string
                        if data.isGroup {
                            data.name = item["groupInfo"]["name"].string
                        }
                        else {
                            for item in item["membersInfo"].arrayValue {
                                if item["_id"].string != Utils.getLoginJSON()["result"]["user"]["_id"].string! {
                                    data.name = item["name"].string
                                    break
                                }
                            }
                        }
                        if item["lastMessage"]["messageType"].exists() {
                            data.messageType = item["lastMessage"]["messageType"].stringValue
                        }
                        else {
                            data.messageType = ""
                        }
                        
                        if data.messageType?.lowercased() == "call" {
                            data.message = "Call"
                        }
                        else if data.messageType?.lowercased() == "text" {
                            if item["lastMessage"]["message"].exists() {
                                data.message = item["lastMessage"]["message"].stringValue
                            }
                            else {
                                data.message = "N/A"
                            }
                        }
                        else if data.messageType?.lowercased() == "file" {
                            data.message = "File"
                        }
                        else {
                            data.message = "N/A"
                        }
                        
                        // dateOfCreation
                        
                        if item["lastMessage"]["dateOfCreation"].exists() {
                            data.date = item["lastMessage"]["dateOfCreation"].rawString()
                        }
                        else {
                            data.date = ""
                        }
                        self.array.append(data)
                    }
                    
                    self.tableView.reloadData()
                    KRProgressHUD.dismiss()
                }
                else {
                    KRProgressHUD.showError(withMessage: "No chat found.")
                }
                

                
            }
            else {
                KRProgressHUD.showError(withMessage: "Unable to fetch chat list.")
            }
        }
    }
    
    @objc func rightButtonAction(sender: UIBarButtonItem){
        
        let alert = UIAlertController(title: "New Chat", message: "Enter members seperated by commas!", preferredStyle: .alert)
        alert.addTextField { (field) in
            field.placeholder = "Enter here..."
        }
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { (action) in
            
            let enteredEmails = alert.textFields![0] as UITextField
            self.processCreateChat(enteredEmails.text)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func processCreateChat(_ enteredEmails: String?) {
            let items = enteredEmails?.components(separatedBy: ",")

            if (items?.count ?? 0) > 0 {
                var validEmail: [String] = []
                if (items?.count ?? 0) == 1 {
                    let email = items?[0]
                    if Utils.isValidEmail(email: email!) {
                        validEmail.append(email ?? "")
                    } else {
                        showErrorAlert(withMessage: "Email id is not valid.")
                        return
                    }
                } else {
                    for i in 0..<(items?.count ?? 0) {
                        let email = items?[i].trim()
                        if Utils.isValidEmail(email: email!) {
                            validEmail.append(email ?? "")
                        } else {
                            showErrorAlert(withMessage: "One of the Email entered is not valid.")
                            return
                        }
                    }
                }

                if validEmail.count > 0 {
                    if validEmail.count == 1 {
                        fetchRoom(withEmails: validEmail, withGroupName: "", withIsBroadcast: false)
                    } else if validEmail.count > 1 {
                        enteredEmailsArray = validEmail
                        
                        let alert = UIAlertController(title: "New Chat", message: "Choose group type", preferredStyle: .alert)
                        
                        alert.addTextField { (field) in
                            field.placeholder = "Enter group name..."
                        }
                        
                        alert.addAction(UIAlertAction(title: "Create Broadcast Room", style: .default, handler: { (action) in
                            
                            let enteredName = alert.textFields![0] as UITextField
                            self.fetchRoom(withEmails: self.enteredEmailsArray, withGroupName: enteredName.text, withIsBroadcast: true)
                        }))
                        alert.addAction(UIAlertAction(title: "Create Group Chat", style: .default, handler: { (action) in
                            
                            let enteredName = alert.textFields![0] as UITextField
                            self.fetchRoom(withEmails: self.enteredEmailsArray, withGroupName: enteredName.text, withIsBroadcast: false)
                        }))
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } else {
                showErrorAlert(withMessage: "Please enter email to create chat.")
            }
        }
    
    func fetchRoom(withEmails array: [AnyHashable]?, withGroupName groupName: String?, withIsBroadcast isBroadcast: Bool) {
        
        KRProgressHUD.show()
        
        Yuwee.sharedInstance().getChatManager().fetchChatRoom(byEmails: array!, withAllowReuseOfRoom: true, withIsBroadcast: isBroadcast, withGroupName: groupName!) { (isSuccess, data) in
            
            KRProgressHUD.dismiss()
            if isSuccess {
                let json = JSON(data!)
                
                if json["result"]["room"]["isGroupChat"].boolValue {
                    self.chatListData.name = json["result"]["room"]["groupInfo"]["name"].string
                    self.chatListData.isGroup = true
                }
                else {
                    self.chatListData.isGroup = false
                    for item in json["result"]["room"]["membersInfo"].arrayValue {
                        if item["_id"].string != Utils.getLoginJSON()["result"]["user"]["_id"].string! {
                            self.chatListData.name = item["name"].string
                            break
                        }
                    }
                }
                self.chatListData.roomId = json["result"]["room"]["_id"].string
                self.performSegue(withIdentifier: "chat_details", sender: self)
            }
            else {
                
            }
            
        }
        
    }
    
    func showErrorAlert(withMessage message: String?) {
        
        let alert = UIAlertController(title: "New Chat", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let dest = segue.destination as! ChatDetailsViewController
        dest.chatListData = self.chatListData
    }

}

extension ChatListViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ChatListTableViewCell = tableView.dequeueReusableCell(withIdentifier: "chat_list_cell", for: indexPath) as! ChatListTableViewCell
        cell.labelName.text = array[indexPath.row].name
        cell.labelMessage.text = array[indexPath.row].message
        
        if array[indexPath.row].date! != "" {
            let millis = Int64(array[indexPath.row].date!)
            let date = Date(milliseconds: millis!)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            cell.labelDate.text = dateFormatter.string(from: date)
        }
        else {
            cell.labelDate.text = "N/A"
        }

        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            self.deleteChat(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.chatListData = array[indexPath.row]
        performSegue(withIdentifier: "chat_details", sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(50)
    }
    
    private func deleteChat(indexPath: IndexPath) {
        KRProgressHUD.show()
        Yuwee.sharedInstance().getChatManager().deleteChatRoom(array[indexPath.row].roomId!) { (isSuccess, data) in
            if isSuccess {
                self.array.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            }
            KRProgressHUD.dismiss()
        }
    }
    
}


class ChatListData {
    var name: String?
    var message: String?
    var messageType: String?
    var date: String?
    var roomId: String?
    var isGroup = false
}
