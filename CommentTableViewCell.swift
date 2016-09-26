//
//  CommentTableViewCell.swift
//  FoodTalk
//
//  Created by Ashish on 25/04/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    
    @IBOutlet var imgUserName : UIImageView?
    @IBOutlet var btnUserName : UIButton?
    @IBOutlet var btnFullName : UIButton?
    @IBOutlet var commentLabel : TTTAttributedLabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
