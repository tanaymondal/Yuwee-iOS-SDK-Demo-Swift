//
//  FileMyTableViewCell.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 17/05/21.
//

import UIKit

class FileMyTableViewCell: UITableViewCell {
    @IBOutlet weak var imageViewFile: UIImageView!
    @IBOutlet weak var btnPlay: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func onPlayPressed(_ sender: Any) {
        
    }
    
    func update(with message: Message) {

    }
    
}
