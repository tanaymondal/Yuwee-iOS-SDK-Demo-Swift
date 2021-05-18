//
//  ChatDetailsViewController.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 12/05/21.
//

import UIKit
import Toaster
import SwiftyJSON
import KRProgressHUD
import MessageInputBar

class ChatDetailsViewController: UIViewController {
    
    var chatListData : ChatListData?
    var array: [Message] = []
    var isConnected = false
    var inputBar: SlackInputBar?
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationItem.title = chatListData?.name
        
        tableView.register(UINib(nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier: "my_cell")
        tableView.register(UINib(nibName: "OtherTableViewCell", bundle: nil), forCellReuseIdentifier: "other_cell")
        tableView.register(UINib(nibName: "FileMyTableViewCell", bundle: nil), forCellReuseIdentifier: "my_file_cell")
        tableView.register(UINib(nibName: "FileOtherTableViewCell", bundle: nil), forCellReuseIdentifier: "other_file_cell")
        tableView.register(UINib(nibName: "CallTableViewCell", bundle: nil), forCellReuseIdentifier: "call_cell")
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .interactive
        tableView.rowHeight = UITableView.automaticDimension
        
        inputBar = SlackInputBar()
        inputBar?.delegate = self
        inputBar?.buttonDelegate = self
        
        isConnected = Yuwee.sharedInstance().getConnectionManager().isConnected()
        
        if !isConnected {
            Toast(text: "YuWee is not connected. Trying to reconnect...").show()
            Yuwee.sharedInstance().getConnectionManager().setConnectionDelegate(self)
            Yuwee.sharedInstance().getConnectionManager().forceReconnect()
        }
        
        Yuwee.sharedInstance().getChatManager().setMessageDeliveredDelegate(self)
        Yuwee.sharedInstance().getChatManager().setMessageDelete(self)
        Yuwee.sharedInstance().getChatManager().setNewMessageReceivedDelegate(self)
        
        self.getMessages()
        
        Yuwee.sharedInstance().getChatManager().getFileManager().initFileShare(withRoomId: chatListData!.roomId!) { message, isSuccess in
            
            if isSuccess {
                print(message!)
            }
            else {
                Toast(text: "Unable to init file share").show()
            }
        }
        
        
        
    }
    
    override var inputAccessoryView: UIView? {
        return inputBar
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    private func getMessages() {
        KRProgressHUD.show()
        Yuwee.sharedInstance().getChatManager().fetchChatMessages(forRoomId: chatListData!.roomId!, totalMessagesCountToSkip: 0) { (isSuccess, data) in
            if isSuccess {
                KRProgressHUD.dismiss()
                let json = JSON(data!)
                
                let arr = json["result"]["messages"]
                
                for item in arr.arrayValue {
                    self.addServerMessage(item: item)
                }
                
                print(json)
                self.tableView.reloadData()
            }
            else {
                KRProgressHUD.showInfo(withMessage: "No old messages")
            }
        }
    }
    
    private func addServerMessage(item: JSON) {
        let message = Message()
        message.messageId = item["messageId"].string
        message.senderName = item["sender"]["name"].string
        message.senderId = item["sender"]["_id"].string
        message.messageTime = item["dateOfCreation"].int64
        message.messageType = item["messageType"].string?.lowercased()
        if message.messageType == "text" {
            message.textData.text = item["message"].string
        }
        else if message.messageType == "file" {
            message.fileData.fileId = ""
            message.fileData.fileUrl = ""
            message.fileData.filePath = ""
        }
        
        self.array.append(message)
    }
    
    private func addTextMessage(with message: String) {
        let uuid = UUID().uuidString
        
        Yuwee.sharedInstance().getChatManager().sendMessage(message, toRoomId: chatListData!.roomId!, messageIdentifier: uuid, withQuotedMessageId: nil)
        
        let data = Message()
        data.messageType = "text"
        data.messageTime = Date().millisecondsSince1970
        data.senderId = AppDelegate.loggedInUserId
        data.senderName = AppDelegate.loggedInName
        data.textData.text = message
        
        self.array.append(data)
        self.tableView.insertRows(at: [IndexPath(item: self.array.count - 1, section: 0)], with: .fade)
    }
}

extension ChatDetailsViewController: InputbarButtonPressDelegate {
    func onInputbarButtonPressed(buttonType: Int) {
        switch buttonType {
        case 0:
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
            break
        case 1:
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
            break
        default:
            print("other")
        }
    }
    
}

extension ChatDetailsViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let pic : NSURL = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerImageURL")] as! NSURL
        print("imagePickerController Pic: \(String(describing: pic.path))")
        
        
        do {
            let fileSize = sizeForLocalFilePath(filePath: pic.path!)
            print("File Size: \(fileSize)")
            
            let url = URL(fileURLWithPath: pic.path!)
            print("Extension: \(url.pathExtension)")
            let uuid = UUID().uuidString
            let data = try Data(contentsOf: url)
            Yuwee.sharedInstance().getChatManager().getFileManager().sendFile(withRoomId: chatListData!.roomId!, withUniqueIdentifier: uuid, withFileData: data, withFileName: uuid, withFileExtension: url.pathExtension, withFileSize: UInt(fileSize), with: self)
        } catch {
            print(error)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("imagePickerControllerDidCancel")
        picker.dismiss(animated: true, completion: nil)
    }
    
    func getFromDocumentDir(imageName: String) -> UIImage {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath = paths.first{
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(imageName)
            let image    = UIImage(contentsOfFile: imageURL.path)
            return image!
        }
        return UIImage.init(named: "default.png")!
    }
    
    func sizeForLocalFilePath(filePath:String) -> UInt64 {
        do {
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: filePath)
            if let fileSize = fileAttributes[FileAttributeKey.size]  {
                return (fileSize as! NSNumber).uint64Value
            } else {
                print("Failed to get a size attribute from path: \(filePath)")
            }
        } catch {
            print("Failed to get file attributes for local path: \(filePath) with error: \(error)")
        }
        return 0
    }
}

extension ChatDetailsViewController: YuWeeFileUploadDelegate {
    
    func onUploadSuccess() {
        print("onUploadSuccess")
    }
    
    func onUploadStarted() {
        print("onUploadStarted")
    }
    
    func onUploadFailed() {
        print("onUploadFailed")
    }
    
    func onProgressUpdate(withProgress progress: Double) {
        print("onProgressUpdate")
    }
    
    
}



extension ChatDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if array[indexPath.row].messageType == "text" {
            if array[indexPath.row].senderId == AppDelegate.loggedInUserId {
                let cell: TextMyTableViewCell = tableView.dequeueReusableCell(withIdentifier: "my_cell", for: indexPath) as! TextMyTableViewCell
                cell.update(with: array[indexPath.row])
                return cell
            }
            else {
                let cell: TextOtherTableViewCell = tableView.dequeueReusableCell(withIdentifier: "other_cell", for: indexPath) as! TextOtherTableViewCell
                cell.update(with: array[indexPath.row])
                return cell
            }
        }
        else if array[indexPath.row].messageType == "file" {
            if array[indexPath.row].senderId == AppDelegate.loggedInUserId {
                let cell: FileMyTableViewCell = tableView.dequeueReusableCell(withIdentifier: "my_file_cell", for: indexPath) as! FileMyTableViewCell
                cell.update(with: array[indexPath.row])
                return cell
            }
            else {
                let cell: FileOtherTableViewCell = tableView.dequeueReusableCell(withIdentifier: "other_file_cell", for: indexPath) as! FileOtherTableViewCell
                cell.update(with: array[indexPath.row])
                return cell
            }
        }
        else { // call
            let cell: CallTableViewCell = tableView.dequeueReusableCell(withIdentifier: "call_cell", for: indexPath) as! CallTableViewCell
            cell.update(with: array[indexPath.row])
            return cell
        }
    }
}

extension ChatDetailsViewController: MessageInputBarDelegate {
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        if isConnected {
           
            if text.trim().count > 0 {
                addTextMessage(with: text)
            }
            else {
                Toast(text: "Please enter message").show()
            }
        }
        else {
            Toast(text: "Yuwee is not connected").show()
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, textViewTextDidChangeTo text: String) {
        
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didChangeIntrinsicContentTo size: CGSize) {
        
    }
}

extension ChatDetailsViewController: YuWeeMessageDeliveredDelegate, YuWeeNewMessageReceivedDelegate, YuWeeMessageDeletedDelegate {
    func onMessageDelivered(_ dictParameter: [AnyHashable : Any]!) {
        let json = JSON(dictParameter!)
        print("onMessageDelivered: \(json)")
    }
    
    func onNewMessageReceived(_ dictParameter: [AnyHashable : Any]!) {
        let json = JSON(dictParameter!)
        self.addServerMessage(item: json)
        self.tableView.insertRows(at: [IndexPath(item: self.array.count - 1, section: 0)], with: .fade)
    }
    
    func onMessageDeleted(_ dictParameter: [AnyHashable : Any]!) {
        let json = JSON(dictParameter!)
        print("onMessageDeleted: \(json)")
    }
}

extension ChatDetailsViewController: YuWeeConnectionDelegate {
    func onConnected() {
        print("onConnected")
        isConnected = true
    }
    
    func onDisconnected() {
        print("onDisconnected")
        isConnected = false
    }
    
    func onReconnection() {
        print("onReconnection")
    }
    
    func onReconnected() {
        print("onReconnected")
        isConnected = true
    }
    
    func onReconnectionFailed() {
        print("onReconnectionFailed")
        isConnected = false
    }
    
    func onClose() {
        print("onClose")
        isConnected = false
        Yuwee.sharedInstance().getConnectionManager().forceReconnect()
    }
    
    
}

class Message {
    var messageId: String?
    var messageType: String?
    var messageTime: Int64?
    var senderId: String?
    var senderName: String?
    var isDelivered = false
    var textData = TextData()
    var fileData = FileData()
}

class TextData {
    var text: String?
}

class FileData {
    var fileId: String?
    var fileUrl: String?
    var filePath: String?
}
