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
    @IBOutlet weak var mainView: UIView!
    
    private var array: [Message] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        mainView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setList(list: [Message]) {
        array = list
    }
    
    func update(with message: Message) {
        labelMessage.text = message.textData.text
        labelMessage.numberOfLines = 0
        labelMessage.sizeToFit()
        labelTime.text = message.messageTime!.dateFormat(format: "HH:mm:ss")
    }
    
}
