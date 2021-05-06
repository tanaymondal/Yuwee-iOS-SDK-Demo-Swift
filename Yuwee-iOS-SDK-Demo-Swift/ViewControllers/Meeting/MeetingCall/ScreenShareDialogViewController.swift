//
//  ScreenShareDialogViewController.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 06/05/21.
//

import UIKit
import ReplayKit
import MMWormhole

class ScreenShareDialogViewController: UIViewController {

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var recordIconView: UIView!
    @IBOutlet var rootView: UIView!
    let wormhome = MMWormhole(applicationGroupIdentifier: "group.com.yuwee.SwiftSdkDemo", optionalDirectory: "wormhole")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        showBroadcastPicker()
        listenWormhole()
        stackView.layer.cornerRadius = 20
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        rootView.addGestureRecognizer(tapGesture)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        self.onClosePressed(self)
    }
    
    @IBAction func onClosePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    private func showBroadcastPicker() {
        let broadcastPicker = RPSystemBroadcastPickerView(frame: CGRect(x: 0, y: 0,
                                                                        width: recordIconView.bounds.width, height: recordIconView.bounds.height))
                    broadcastPicker.preferredExtension = "com.yuwee.Yuwee-iOS-SDK-Demo-Swift.Yuwee-Screen-Share"
        broadcastPicker.backgroundColor = .cyan
        broadcastPicker.tag = 100
        broadcastPicker.showsMicrophoneButton = false
        recordIconView.addSubview(broadcastPicker)
    }
    
    private func listenWormhole() {
        self.wormhome.listenForMessage(withIdentifier: "screen-sharing-status") { (data) in
            self.onClosePressed(self)
        }
    }
}
