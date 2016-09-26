//
//  CardViewCell.swift
//  FoodTalk
//
//  Created by Ashish on 14/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit

class CardViewCell: UITableViewCell {
    
    @IBOutlet var imageProfilePicture : UIImageView?
    @IBOutlet var labelStatus : TTTAttributedLabel?
    @IBOutlet var labelTimeOfPost : UILabel?
    @IBOutlet var imageDishPost : UIImageView?
    @IBOutlet var btnLike : UIButton?
    @IBOutlet var btnComment : UIButton?
    @IBOutlet var btnFavorite : UIButton?
    @IBOutlet var btnMore : UIButton?
    
    @IBOutlet var btnLike1 : UIButton?
    @IBOutlet var btnComment1 : UIButton?
    @IBOutlet var btnFavorite1 : UIButton?
    @IBOutlet var btnMore1 : UIButton?
    
    @IBOutlet var btnOpenPost : UIButton?
    
    
    @IBOutlet var numberOfLikes : UILabel?
    @IBOutlet var numberOfComments : UILabel?
    @IBOutlet var numberOfFav : UILabel?
    
    @IBOutlet var star1 : UIImageView?
    @IBOutlet var star2 : UIImageView?
    @IBOutlet var star3 : UIImageView?
    @IBOutlet var star4 : UIImageView?
    @IBOutlet var star5 : UIImageView?
    
    @IBOutlet var blackLabel : UILabel?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String!) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.btnLike?.frame = CGRectMake(20, 30, 100, 100)
        self.btnLike?.backgroundColor = UIColor.redColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
