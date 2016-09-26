//
//  BookStoreTableViewCell.swift
//  FoodTalk
//
//  Created by Ashish on 12/08/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit

class BookStoreTableViewCell: UITableViewCell {
    
    @IBOutlet var lblPurchaseLabel : UILabel?
    @IBOutlet var lblTitle : UILabel?
    @IBOutlet var lblDiscription : UILabel?
    @IBOutlet var lblConfirmed : UILabel?
    @IBOutlet var lblPoint : UILabel?
    @IBOutlet var lblCouponCode : UILabel?
    @IBOutlet var btnCupon : UIButton?
    @IBOutlet var btnBuy : UIButton?
    @IBOutlet var lblTap : UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
