//
//  ReviewViewController.swift
//  FoodTalk
//
//  Created by Ashish on 23/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit

var reviewSelected = String()

class ReviewViewController: UIViewController, UITextViewDelegate, UITabBarControllerDelegate {
    
    var imgView = UIImageView()
    var txtView = UITextView()
    var viewU = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        imgView.frame = CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.width)
        imgView.contentMode = UIViewContentMode.ScaleAspectFill
        viewU.frame = CGRectMake(0, imgView.frame.origin.y + imgView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - imgView.frame.size.height)
        viewU.backgroundColor = UIColor.whiteColor()
        txtView.frame = CGRectMake(0, 0, viewU.frame.size.width, 80)
        txtView.text = "Write a review"
        txtView.textColor = UIColor.lightGrayColor()
        txtView.backgroundColor = UIColor.clearColor()
        txtView.font = UIFont(name: fontName, size: 16)
       // txtView.textColor = UIColor.blackColor()
        UITextView.appearance().tintColor = UIColor.blackColor()
        txtView.delegate = self
        
        self.view.addSubview(imgView)
        self.view.addSubview(viewU)
        viewU.addSubview(txtView)
        
        self.title = "Review"
        Flurry.logEvent("Review Screen")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .Plain, target: self, action: #selector(ReviewViewController.addTapped))
        imgView.image = imageSelected
        

        self.tabBarController?.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
        self.view.frame.origin.y = -120
        txtView.becomeFirstResponder()
    }
    
   
    
    func addTapped(){
        if (isConnectedToNetwork()){
            if(txtView.text == "Write a review"){
               reviewSelected = ""
            }
            else{
            reviewSelected = (txtView.text)!
            }
            isUploadingStart = true
            self.tabBarController?.selectedIndex = 0
            self.tabBarController?.tabBar.hidden = false
            UIApplication.sharedApplication().statusBarHidden = true
        }
        else{
            internetMsg(view)
        }
    }
    
    //MARK:- TextView Delegate
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n") {
          return false
        }
        else{
            
                    if textView.textColor == UIColor.lightGrayColor() {
                        textView.text = ""
                        textView.textColor = UIColor.blackColor()
                      //  UITextView.appearance().tintColor = UIColor.blackColor()
                       // textView.text = text
                        return true
                    }
                    else{
        var textFrame = CGRect()
        textFrame = textView.frame;
        textFrame.size.height = textView.contentSize.height+20;
        textView.frame = textFrame;
     //    UITextView.appearance().tintColor = UIColor.blackColor()
        let newText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        let numberOfChars = newText.characters.count // for Swift use count(newText)
        return numberOfChars < 120;
            }
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        UITextView.appearance().tintColor = UIColor.blackColor()
        if textView.textColor == UIColor.lightGrayColor() {
           self.performSelector(#selector(ReviewViewController.changePositon(_:)), withObject: textView, afterDelay: 0.01)
          //  textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Write a review"
            textView.textColor = UIColor.lightGrayColor()
        }
    }
    
    func changePositon(textView : UITextView){
        textView.selectedRange = NSMakeRange(0, 0);
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        self.navigationController?.popToRootViewControllerAnimated(false)
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
