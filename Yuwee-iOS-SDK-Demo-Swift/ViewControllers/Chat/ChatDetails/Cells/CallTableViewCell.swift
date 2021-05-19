//
//  CallTableViewCell.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 17/05/21.
//

import UIKit

class CallTableViewCell: UITableViewCell {
    @IBOutlet weak var labelCallText: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    
    private var array: [Message] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setList(list: [Message]) {
        array = list
    }
    
    func update(with message: Message) {
        //labelTime.text = message.messageTime!.dateFormat(format: "HH:mm:ss")
    }
    
}
