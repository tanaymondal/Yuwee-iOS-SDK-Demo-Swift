//
//  FileOtherTableViewCell.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 17/05/21.
//

import UIKit

class FileOtherTableViewCell: UITableViewCell {

    @IBOutlet weak var imageViewFile: UIImageView!
    @IBOutlet weak var btnPlay: UIButton!
    
    private var array: [Message] = []
    
    private var message: Message?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        imageViewFile.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func onPlayPressed(_ sender: Any) {
        if message?.fileData.fileExt == "jpeg"
            || message?.fileData.fileExt == "jpg"
            || message?.fileData.fileExt == "png"
            || message?.fileData.fileExt == "gif" {
            Yuwee.sharedInstance().getChatManager().getFileManager().getFileUrl(withFileId: message!.fileData.fileId!, withFileKey: message!.fileData.fileKey!) { fileURL, isSuccess in
                if isSuccess {
                    self.message?.fileData.fileUrl = fileURL
                    self.imageViewFile.setImage(with: URL(string: fileURL!))
                    self.btnPlay.isHidden = true
                }
                else {
                    
                }
            }
        }
        else {
            // todo
        }
        
    }
    
    func setList(list: [Message]) {
        array = list
    }
    
    func update(with message: Message) {
        self.message = message
    }
    
}
