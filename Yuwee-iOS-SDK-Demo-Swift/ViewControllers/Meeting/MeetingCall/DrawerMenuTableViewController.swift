//
//  DrawerMenuTableViewController.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 27/04/21.
//

import UIKit

class DrawerMenuTableViewController: UITableViewController {
    
    private var memberArray: [YWMember] = []
    private var amIAdmin = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        print("Drawer View Did Load")
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return memberArray.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MemberTableViewCell = tableView.dequeueReusableCell(withIdentifier: "member_cell", for: indexPath) as! MemberTableViewCell
        
        cell.buttonThreeDots.isHidden = !amIAdmin
        cell.labelAdmin.padding()
        cell.labelPresenter.padding()
        cell.labelAdmin.layer.cornerRadius = 5
        cell.labelPresenter.layer.cornerRadius = 5
        cell.selectionStyle = .none
        //textView.textContainerInset = UIEdgeInsetsMake(10, 0, 10, 0);
        cell.update(member: memberArray[indexPath.row])
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    public func reloadTable(memberArray: [YWMember]){
        self.memberArray = memberArray
        self.tableView.reloadData()
    }
    
    public func setAmIAdmin(amIAdmin: Bool){
        self.amIAdmin = amIAdmin
    }

}

