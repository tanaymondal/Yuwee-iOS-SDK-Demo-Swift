//
//  Communication.swift
//  Yuwee-iOS-SDK-Demo-Swift
//
//  Created by Tanay on 03/05/21.
//

import Foundation

class Communication {
    
    static let shared = Communication()
    private var memberActionDelegate: MemberActionDelegate?
    
    private init() {}
    
    func setMemberActionDelegate(memberActionDelegate: MemberActionDelegate) {
        self.memberActionDelegate = memberActionDelegate
    }
    
    func onThreeDotIconClicked(view: UIButton, member: YWMember){
        self.memberActionDelegate?.onThreeDotIcon(view: view, member: member)
    }
}

protocol MemberActionDelegate {
    func onThreeDotIcon(view: UIButton, member: YWMember)
}
