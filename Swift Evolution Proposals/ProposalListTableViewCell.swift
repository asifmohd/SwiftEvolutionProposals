//
//  ProposalListTableViewCell.swift
//  Swift Evolution Proposals
//
//  Created by Asif on 30/10/16.
//  Copyright © 2016 Vibgyor Applications. All rights reserved.
//

import UIKit

class ProposalListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
}

extension ProposalListTableViewCell: ReusableCell {
    static var ReuseIdentifier: String {
        return "ProposalListTableViewCell"
    }
    static var NibName: String {
        return "ProposalListTableViewCell"
    }
}
