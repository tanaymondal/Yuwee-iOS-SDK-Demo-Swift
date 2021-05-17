//
//  OtherTableViewCell.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 13/05/21.
//

import UIKit

class TextOtherTableViewCell: UITableViewCell {

    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func update(with message: Message) {
        labelMessage.text = message.textData.text
        labelTime.text = message.messageTime!.dateFormat(format: "HH:mm:ss")
    }
    
}
