//
//  GlobalConstants.swift
//  Swift Evolution Proposals
//
//  Created by Asif on 30/10/16.
//  Copyright © 2016 Vibgyor Applications. All rights reserved.
//

import Foundation

struct APIConstants {
    
    static let BaseUrl: String = "https://api.github.com/repos/apple/swift-evolution/contents/"
    static let ProposalsURL: String = APIConstants.BaseUrl + "proposals"
    
    static let TimeoutValue: TimeInterval = 10.0
    
}
