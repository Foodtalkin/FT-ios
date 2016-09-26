//
//  UpdateVersionViewController.swift
//  FoodTalk
//
//  Created by Himanshu on 3/7/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit

var updateText = String()
class UpdateVersionViewController: UIViewController {
    
    @IBOutlet var updateLabel : UILabel?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        self.tabBarController?.tabBar.hidden = true
        updateLabel?.text = updateText
        // Do any additional setup after loading the view.
    }
    
    @IBAction func updateTapped(sender : UIButton){
        UIApplication.sharedApplication().openURL(NSURL(string: "itms://itunes.apple.com/in/app/food-talk-plus/id923340748?mt=8")!)
        
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
