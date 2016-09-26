//
//  UserProfileTableViewCell.swift
//  FoodTalk
//
//  Created by Ashish on 21/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit

class UserProfileTableViewCell: UITableViewCell {
    
    @IBOutlet var profilePic : UIImageView?
    @IBOutlet var username : UILabel?
    @IBOutlet var btnFollow : UIButton?
    @IBOutlet var noOfcheckins : UILabel?
    @IBOutlet var noOfFollowers : UILabel?
    @IBOutlet var noOfFollowing : UILabel?
    @IBOutlet var imgBackground : UIImageView?
    
    @IBOutlet var btnFollowerList : UIButton?
    @IBOutlet var btnFollowingList : UIButton?
    @IBOutlet var btnCheckInList : UIButton?
    
//    @IBOutlet var blurView : FXBlurView?
//    @IBOutlet var btnFollowerList : UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
