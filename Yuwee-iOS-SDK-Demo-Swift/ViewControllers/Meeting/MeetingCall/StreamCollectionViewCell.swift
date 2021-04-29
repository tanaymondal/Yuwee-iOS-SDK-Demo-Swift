//
//  StreamCollectionViewCell.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 29/04/21.
//

import UIKit
import SwiftyJSON

class StreamCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var yuweeVideoView: YuweeVideoView!
    
    public func attachStream(stream : OWTRemoteStream){
        Yuwee.sharedInstance().getMeetingManager().attach(stream, with: yuweeVideoView) { (data, isSuccess) in
            let json = JSON(data)
            print("\(isSuccess) \(json)")
        }
    }
}
