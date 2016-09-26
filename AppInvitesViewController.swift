//
//  AppInvitesViewController.swift
//  FoodTalk
//
//  Created by Ashish on 21/01/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit
import FBSDKShareKit

class AppInvitesViewController: UIViewController{
    
    @IBOutlet var btnInvite : UIButton?
    @IBOutlet var btnSkip : UIButton?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBarHidden = true
        btnInvite?.layer.cornerRadius = 3
    }
    
    @IBAction func inviteClicked(sender : UIButton){
        
 
    }
    
    @IBAction func skipClicked(sender : UIButton){
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
