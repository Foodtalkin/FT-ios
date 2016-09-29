//
//  RatingViewController.swift
//  FoodTalk
//
//  Created by Ashish on 23/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit

var selectedRating : String = ""

class RatingViewController: UIViewController, FloatRatingViewDelegate, UITabBarControllerDelegate {
    
    @IBOutlet var imgView : UIImageView?
    @IBOutlet var viewBg : UIView?
    @IBOutlet var floatRatingView: FloatRatingView!
    var ratingSegmentedControl: UISegmentedControl!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Rating"
        Flurry.logEvent("Rating Screen")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Rate Later", style: .Plain, target: self, action: #selector(RatingViewController.addTapped))
        imgView?.image = imageSelected
        
        self.floatRatingView.emptyImage = UIImage(named: "stars-02.png")
        self.floatRatingView.fullImage = UIImage(named: "stars-01.png")
        // Optional params
        self.floatRatingView.delegate = self
        self.floatRatingView.contentMode = UIViewContentMode.ScaleAspectFit
        self.floatRatingView.maxRating = 5
        self.floatRatingView.minRating = 1
        self.floatRatingView.rating = 0
        self.floatRatingView.editable = true
        self.floatRatingView.halfRatings = false
        self.floatRatingView.floatRatings = false
        
        // Segmented control init
 //       self.ratingSegmentedControl.selectedSegmentIndex = 1
    }
    
    override func viewWillAppear(animated: Bool) {
        self.floatRatingView.rating = 0
        self.tabBarController?.delegate = self
    }
    
   
    
    func addTapped(){
        selectedRating = ""
        Flurry.logEvent("Rate Later Pressed")
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("RiviewVC") as! ReviewViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    // MARK: FloatRatingViewDelegate
    
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
     //   self.liveLabel.text = NSString(format: "%.2f", self.floatRatingView.rating) as String
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
     //   self.updatedLabel.text = NSString(format: "%.2f", self.floatRatingView.rating) as String
        
        selectedRating = String(format: "%f", self.floatRatingView.rating)
        
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("RiviewVC") as! ReviewViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        self.navigationController?.popToRootViewControllerAnimated(true)
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
