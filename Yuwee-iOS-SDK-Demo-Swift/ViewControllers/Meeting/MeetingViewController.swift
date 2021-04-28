//
//  MeetingViewController.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 20/04/21.
//

import UIKit
import SwiftyJSON
import KRProgressHUD

class MeetingViewController: UIViewController, OnNewMeetingDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var array : [JSON] = []
    private var selectedRow : Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightItem = UIBarButtonItem(title: "Join",
                                       style: UIBarButtonItem.Style.plain,
                                       target: self,
                                       action: #selector(rightButtonAction(sender:)))

        self.navigationItem.rightBarButtonItem = rightItem
        self.navigationItem.title = "Meeting"
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsMultipleSelectionDuringEditing = false;
        
        self.getAllMeetings()
        
    }
    
    @objc func rightButtonAction(sender: UIBarButtonItem){
        performSegue(withIdentifier: "JoinMeeting", sender: self)
    }
    
    private func getAllMeetings(){
        KRProgressHUD.show()
        Yuwee.sharedInstance().getMeetingManager().fetchActiveMeetings { (data, isSuccess) in
            let json = JSON(data)
            print(json)
            if isSuccess{
                for data in json["result"].arrayValue {
                    if !data["isExpired"].exists() {
                        self.array.append(data)
                    }
                }
                
                KRProgressHUD.dismiss()
                self.tableView.reloadData()
                
            }
        }
    }
    
    private func deleteMeeting(indexPath: IndexPath){
        KRProgressHUD.show()
        let tokenId : String = array[indexPath.row]["meetingTokenId"].string!
        Yuwee.sharedInstance().getMeetingManager().deleteMeeting(tokenId) { (data, isSuccess) in
            if isSuccess{
                self.array.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            }
            KRProgressHUD.dismiss()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateMeeting" {
            let vc = segue.destination as! CreateMeetingViewController
            vc.delegate = self
        }
        else if segue.identifier == "MeetingDetailsFromCell" {
            let vc = segue.destination as! MeetingDetailsViewController
            vc.meetingDetails = array[self.selectedRow!]
        }
    }
    
    func onNewMeetingCreated(json: JSON) {
        array.removeAll()
        self.getAllMeetings()
    }

}

extension MeetingViewController: UITableViewDataSource, UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            self.deleteMeeting(indexPath: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "MeetingCell")!

        let json = array[indexPath.row]
        let millis = json["callId"]["meetingStartTime"].int64
        let date = Date(milliseconds: millis!)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        
        cell.textLabel?.text = json["meetingName"].string
        cell.detailTextLabel?.text = dateFormatter.string(from: date)
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath.row
        self.performSegue(withIdentifier: "MeetingDetailsFromCell", sender: self)
    }
}
        
