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

class ChatDetailsViewController: UIViewController, UITextViewDelegate {
    
    var chatListData : ChatListData?
    var array: [Message] = []
    var isConnected = false
    var inputBar: SlackInputBar?
    private var selectedIndexPath: IndexPath?
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.navigationItem.title = chatListData?.name
        let rightItem = UIBarButtonItem(title: "Clear",
                                       style: UIBarButtonItem.Style.plain,
                                       target: self,
                                       action: #selector(rightButtonAction(sender:)))

        self.navigationItem.rightBarButtonItem = rightItem
        
        tableView.register(UINib(nibName: "MyTableViewCell", bundle: nil), forCellReuseIdentifier: "my_cell")
        tableView.register(UINib(nibName: "OtherTableViewCell", bundle: nil), forCellReuseIdentifier: "other_cell")
        tableView.register(UINib(nibName: "FileMyTableViewCell", bundle: nil), forCellReuseIdentifier: "my_file_cell")
        tableView.register(UINib(nibName: "FileOtherTableViewCell", bundle: nil), forCellReuseIdentifier: "other_file_cell")
        tableView.register(UINib(nibName: "CallTableViewCell", bundle: nil), forCellReuseIdentifier: "call_cell")
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.keyboardDismissMode = .interactive
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        
        inputBar = SlackInputBar()
        inputBar?.delegate = self
        inputBar?.buttonDelegate = self
        inputBar?.inputTextView.delegate = self
        
        isConnected = Yuwee.sharedInstance().getConnectionManager().isConnected()
        
        if !isConnected {
            Toast(text: "YuWee is not connected. Trying to reconnect...").show()
            Yuwee.sharedInstance().getConnectionManager().setConnectionDelegate(self)
            Yuwee.sharedInstance().getConnectionManager().forceReconnect()
        }
        
        Yuwee.sharedInstance().getChatManager().setMessageDeliveredDelegate(self)
        Yuwee.sharedInstance().getChatManager().setMessageDelete(self)
        Yuwee.sharedInstance().getChatManager().setNewMessageReceivedDelegate(self)
        Yuwee.sharedInstance().getChatManager().setTypingEventDelegate(self)
        
        self.getMessages()
        
        Yuwee.sharedInstance().getChatManager().getFileManager().initFileShare(withRoomId: chatListData!.roomId!) { message, isSuccess in
            
            if isSuccess {
                print(message!)
            }
            else {
                Toast(text: "Unable to init file share").show()
            }
        }
        Yuwee.sharedInstance().getChatManager().getFileManager().setUploadDelegate(self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(tablePressed))
        tableView.addGestureRecognizer(recognizer)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        Yuwee.sharedInstance().getChatManager().sendTypingStatus(toRoomId: chatListData!.roomId!)
    }
    
    @objc func tablePressed(_ recognizer: UILongPressGestureRecognizer) {
        let point = recognizer.location(in: tableView)
        
        if recognizer.state == .began {
            let indexPath: IndexPath = tableView.indexPathForRow(at: point)!
            self.selectedIndexPath = indexPath
            let cell = tableView.cellForRow(at: indexPath)
            
            let copyItem = UIMenuItem(title: "Copy", action: #selector(copyMessage))
            let deleteForMeItem = UIMenuItem(title: "Delete for me", action: #selector(deleteForMe))
            let deleteForAllItem = UIMenuItem(title: "Delete for all", action: #selector(deleteForAll))
            
            var menuItems: [UIMenuItem] = []
            switch self.array[indexPath.row].messageType {
            case "text":
                menuItems.append(copyItem)
                menuItems.append(deleteForMeItem)
                if self.array[indexPath.row].senderId == AppDelegate.loggedInUserId {
                    menuItems.append(deleteForAllItem)
                }
                break
            case "file":
                menuItems.append(deleteForMeItem)
                if self.array[indexPath.row].senderId == AppDelegate.loggedInUserId {
                    menuItems.append(deleteForAllItem)
                }
                break
            case "call":
                menuItems.append(deleteForMeItem)
                break
            default:
                break
            }
            
            UIMenuController.shared.menuItems?.removeAll()
            UIMenuController.shared.menuItems = menuItems
            UIMenuController.shared.update()
            
            self.becomeFirstResponder()
            let menu = UIMenuController.shared
            menu.setTargetRect(cell!.frame, in: cell!.superview!)
            menu.setMenuVisible(true, animated: true)
        }
        else {
            
        }
    }
    
    @objc func copyMessage() {
        print("copyMessage")
        switch self.array[self.selectedIndexPath!.row].messageType {
        case "text":
            UIPasteboard.general.string = self.array[self.selectedIndexPath!.row].textData.text
            break
        default:
            break
        }
    }
    @objc func deleteForMe() {
        print("deleteForMe")

        Yuwee.sharedInstance().getChatManager().deleteMessage(forMessageId: self.array[self.selectedIndexPath!.row].messageId!, roomId: chatListData!.roomId!, deleteType: .DELETE_FOR_ME) { isSuccess, data in
            let json = JSON(data!)
            print(json)
            if isSuccess {
                Toast(text: "Message deleted").show()
                self.array.remove(at: self.selectedIndexPath!.row)
                self.tableView.deleteRows(at: [self.selectedIndexPath!], with: .fade)
            }
        }
    }
    @objc func deleteForAll() {
        print("deleteForAll")
        Yuwee.sharedInstance().getChatManager().deleteMessage(forMessageId: self.array[self.selectedIndexPath!.row].messageId!, roomId: chatListData!.roomId!, deleteType: .DELETE_FOR_ME) { isSuccess, data in
            let json = JSON(data!)
            print(json)
            if isSuccess {
                Toast(text: "Message deleted").show()
                self.array.remove(at: self.selectedIndexPath!.row)
                self.tableView.deleteRows(at: [self.selectedIndexPath!], with: .fade)
            }
        }
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {

        //print("keyboardWillShow")
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            //print("Keyboard Show Height \(keyboardSize.height)")
            tableView.contentInset.bottom = keyboardSize.height
        }
        scrollToBottom()
    }
    @objc func keyboardWillHide(_ notification:Notification) {
        //print("keyboardWillHide")
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            //print("Keyboard Hide Height \(keyboardSize.height)")
            tableView.contentInset.bottom = keyboardSize.height
        }
        scrollToBottom()
    }
    
    @objc func rightButtonAction(sender: UIBarButtonItem){
        let alert = UIAlertController(title: "Chear Chat", message: "Do you want to clear chat messages in this room?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action) in
            self.clearChat()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func clearChat() {
        KRProgressHUD.show()
        Yuwee.sharedInstance().getChatManager().clearChats(forRoomId: chatListData!.roomId!) { isSuccess, data in
            KRProgressHUD.dismiss()
            if isSuccess {
                Toast(text: "Chat room cleared").show()
                self.array.removeAll()
                self.tableView.reloadData()
            }
            else {
                Toast(text: "Unable to clear chat room").show()
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
                self.scrollToBottom()
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
            message.fileData.fileId = item["fileInfo"]["_id"].string
            message.fileData.fileUrl = nil
            message.fileData.filePath = nil
            message.fileData.fileKey = item["fileInfo"]["fileKey"].string
            message.fileData.fileName = item["fileInfo"]["fileName"].string
            message.fileData.fileExt = item["fileInfo"]["fileExtension"].string
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
        scrollToBottom()
    }
    
    private func scrollToBottom() {
        if array.count > 0 {
            self.tableView.scrollToRow(at: IndexPath(item:array.count-1, section: 0), at: .bottom, animated: true)
        }
    }
    
    private func addFileMessage(pic: NSURL) {
        do {
            let fileSize = sizeForLocalFilePath(filePath: pic.path!)
            print("File Size: \(fileSize)")

            let url = URL(fileURLWithPath: pic.path!)
            print("Extension: \(url.pathExtension)")
            let uuid = UUID().uuidString
            let data = try Data(contentsOf: url)
            Yuwee.sharedInstance().getChatManager().getFileManager().sendFile(withRoomId: chatListData!.roomId!, withUniqueIdentifier: uuid, withFileData: data, withFileName: uuid, withFileExtension: url.pathExtension, withFileSize: UInt(fileSize))
            
            let mData = Message()
            mData.messageType = "file"
            mData.messageTime = Date().millisecondsSince1970
            mData.senderId = AppDelegate.loggedInUserId
            mData.senderName = AppDelegate.loggedInName
            mData.fileData.fileExt = url.pathExtension
            mData.fileData.fileId = uuid
            //data.fileData.fileKey = nil
            mData.fileData.filePath = pic.path
            //data.fileData.fileUrl = ""
            mData.fileData.fileName = uuid
            mData.fileData.isLocalFile = true
            
            self.array.append(mData)
            self.tableView.insertRows(at: [IndexPath(item: self.array.count - 1, section: 0)], with: .fade)
            scrollToBottom()
            
        } catch {
            print(error)
        }
    }
}

extension ChatDetailsViewController: InputbarButtonPressDelegate {
    func onInputbarButtonPressed(buttonType: Int) {
        switch buttonType {
        case 0:
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            //imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
            break
        case 1:
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .photoLibrary
            //imagePicker.allowsEditing = true
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

        self.addFileMessage(pic: pic)
        
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
    func onUploadSuccess(withUniqueId uniqueId: String!) {
        print("onUploadSuccess \(uniqueId!)")
    }
    
    func onUploadStarted(withUniqueId uniqueId: String!) {
        print("onUploadStarted \(uniqueId!)")
    }
    
    func onUploadFailed(withUniqueId uniqueId: String!) {
        print("onUploadFailed \(uniqueId!)")
    }
    
    func onProgressUpdate(withProgress progress: Double, withUniqueId uniqueId: String!) {
        print("onProgressUpdate \(uniqueId!)  \(progress)")
        
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        let messageType: String = self.array[indexPath.row].messageType!
        
        switch messageType {
        case "text":
            return 46
        case "file":
            return 158
        default:
            return 22
        }
    }
}

extension ChatDetailsViewController: MessageInputBarDelegate {
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        if isConnected {
           
            if text.trim().count > 0 {
                addTextMessage(with: text)
                inputBar.inputTextView.text = ""
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

extension ChatDetailsViewController: YuWeeMessageDeliveredDelegate, YuWeeNewMessageReceivedDelegate, YuWeeMessageDeletedDelegate, YuWeeTypingEventDelegate {
    func onUserTyping(inRoom dictObject: [AnyHashable : Any]!) {
        let json = JSON(dictObject!)
        if json["roomId"].stringValue == chatListData!.roomId! {
            if chatListData!.isGroup {
                self.navigationItem.title = "\(json["senderName"].stringValue) is typing..."
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.navigationItem.title = self.chatListData!.name
                }
            }
            else {
                self.navigationItem.title = "Typing..."
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.navigationItem.title = self.chatListData!.name
                }
            }
        }
    }
    
    func onMessageDelivered(_ dictParameter: [AnyHashable : Any]!) {
        let json = JSON(dictParameter!)
        print("onMessageDelivered: \(json)")
    }
    
    func onNewMessageReceived(_ dictParameter: [AnyHashable : Any]!) {
        let json = JSON(dictParameter!)
        self.addServerMessage(item: json)
        self.tableView.insertRows(at: [IndexPath(item: self.array.count - 1, section: 0)], with: .fade)
        scrollToBottom()
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
    var fileKey: String?
    var fileUrl: String?
    var filePath: String?
    var isDownloaded = false
    var isLocalFile = false
    var fileName: String?
    var fileExt: String?
}
