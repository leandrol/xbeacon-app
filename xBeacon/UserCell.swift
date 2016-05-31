//
//  UserCell.swift
//  xBeacon
//
//  Created by Leandro on 5/30/16.
//  Copyright © 2016 BaDaSS. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    var user: User! {
        didSet {
            userName.text = user.name
            userImage.image = user.image
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
