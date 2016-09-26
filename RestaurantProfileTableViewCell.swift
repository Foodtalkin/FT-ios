//
//  RestaurantProfileTableViewCell.swift
//  FoodTalk
//
//  Created by Ashish on 18/01/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit

class RestaurantProfileTableViewCell: UITableViewCell {
    
    @IBOutlet var retaurentname : UILabel?
    @IBOutlet var address : UILabel?
    @IBOutlet var callBtn : UIButton?
    @IBOutlet var checkInBtn : UIButton?
    @IBOutlet var imgBackground : UIImageView?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
