//
//  StoreTableViewCell.swift
//  FoodTalk
//
//  Created by Ashish on 11/08/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit

class StoreTableViewCell: UITableViewCell {

    @IBOutlet var imgStore : UIImageView?
    @IBOutlet var lblRestaurant : UILabel?
    @IBOutlet var lblDescription1 : UILabel?
    @IBOutlet var lblDescription2 : UILabel?
    @IBOutlet var lblPoints : UILabel?
    @IBOutlet var btnBookNow : UIButton?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
