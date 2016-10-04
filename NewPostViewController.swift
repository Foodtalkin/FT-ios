//
//  NewPostViewController.swift
//  FoodTalk
//
//  Created by Ashish on 03/10/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit
import AVFoundation

class NewPostViewController: UIViewController, UITextViewDelegate, FloatRatingViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var floatRatingView: FloatRatingView!
    @IBOutlet var txtReview : UITextView?
    var btnSharePost = UIButton()
    var ratingSegmentedControl: UISegmentedControl!
    
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var error: NSError?
    var imagePicker1 = UIImagePickerController()
    var isImageClicked : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Post"
        
        self.fitFloatRating()
        
        self.tabBarController?.tabBar.hidden = true
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        txtReview!.autocorrectionType = UITextAutocorrectionType.No
        
        btnSharePost = UIButton()
        btnSharePost.frame = CGRectMake(0, self.view.frame.size.height - 45, self.view.frame.size.width, 45)
        btnSharePost.backgroundColor = colorActive
        btnSharePost.setTitle("Share post", forState: UIControlState.Normal)
        self.view.addSubview(btnSharePost)
    }
    
    override func viewWillAppear(animated: Bool) {
        openPost()
    }
    
    func fitFloatRating(){
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
    }
    
    //MARK:- Camera Controls methods
    
    func openPost(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            
            imagePicker.allowsEditing = true
            imagePicker.showsCameraControls = true
            
            addOnImagePicker(imagePicker)
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func openPhotoLibraryButton(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
            
        }
    }
    
    func addOnImagePicker(imagePicker : UIImagePickerController){
        let viewBlack = UIView()
        viewBlack.frame = CGRect(x: self.view.frame.size.width/2 - 45, y: self.view.frame.size.height - 100, width: self.view.frame.size.width/2 + 40, height: 100)
        viewBlack.backgroundColor = UIColor.blackColor()
        viewBlack.tag = 10998
        imagePicker.view.addSubview(viewBlack)
        
        let btnGallary = UIButton(type : .Custom)
        btnGallary.frame = CGRect(x: 10, y: 0, width: 80, height: 80)
        btnGallary.addTarget(self, action: #selector(CheckInViewController.capture(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        btnGallary.setTitle("", forState: UIControlState.Normal)
        btnGallary.setImage(UIImage(named: "click icon.png"), forState: UIControlState.Normal)
        btnGallary.tag = 1011
        viewBlack.addSubview(btnGallary)
        
        let btnGallary1 = UIButton(type : .Custom)
        btnGallary1.frame = CGRect(x: viewBlack.frame.size.width/2 + 30, y: 0, width: 80, height: 80)
        btnGallary1.addTarget(self, action: #selector(CheckInViewController.openPhotoLibraryButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        btnGallary1.setTitle("", forState: UIControlState.Normal)
        btnGallary1.setImage(UIImage(named: "gallery Icon.png"), forState: UIControlState.Normal)
        btnGallary1.tag = 1011
        viewBlack.addSubview(btnGallary1)
        
        imagePicker1 = imagePicker
        imagePicker1.delegate = self
        imagePicker1.allowsEditing = true
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            
            imageSelected = resizeImage(pickedImage)
            isCameraCancel = false
            isImageClicked = true
            isComingFromDishTag = false
            self.dismissViewControllerAnimated(true, completion: nil)
        }
            
        else if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageSelected = resizeImage(pickedImage)
            isCameraCancel = false
            isImageClicked = true
            isComingFromDishTag = false
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.tabBarController?.selectedIndex = 0
        self.tabBarController?.tabBar.hidden = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancel(sender : UIButton){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func capture(sender : UIButton){
        
        imagePicker1.showsCameraControls = true
        imagePicker1.takePicture()
        
        imagePicker1.allowsEditing = true
        imagePicker1.delegate = self
        
        imagePicker1.view.viewWithTag(1009)?.hidden = true
        imagePicker1.view.viewWithTag(1010)?.hidden = true
        imagePicker1.view.viewWithTag(1011)?.hidden = true
        imagePicker1.view.viewWithTag(10998)?.hidden = true
        
        let viewBlack = UIView()
        viewBlack.frame = CGRect(x: 0, y: self.view.frame.size.height - 70, width: 100, height: 90)
        viewBlack.backgroundColor = UIColor.clearColor()
        // viewBlack.alpha = 0.7
        viewBlack.tag = 10910
        imagePicker1.view.addSubview(viewBlack)
        
        let btnGallary = UIButton(type : .Custom)
        btnGallary.frame = CGRect(x: 10, y: 0, width: 80, height: 80)
        btnGallary.addTarget(self, action: #selector(CheckInViewController.retake(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        btnGallary.setTitle("", forState: UIControlState.Normal)
        btnGallary.tag = 101100
        viewBlack.addSubview(btnGallary)
        
    }
    
    func retake(sender : UIButton){
        sender.superview!.viewWithTag(1009)?.hidden = false
        sender.superview!.viewWithTag(1010)?.hidden = false
        sender.superview!.viewWithTag(1011)?.hidden = true
        sender.superview!.viewWithTag(10998)?.hidden = false
        sender.superview!.viewWithTag(10910)?.hidden = true
        sender.superview!
            .viewWithTag(101100)?.hidden = true
        
        isComingFromDishTag = true
        dismissViewControllerAnimated(true, completion: nil)
        //        self.performSelector(#selector(CheckInViewController.openPost), withObject: nil, afterDelay: 0.5)
    }
    
    func resizeImage(image : UIImage) -> UIImage
    {
        var actualHeight = image.size.height as CGFloat;
        var actualWidth = image.size.width as CGFloat;
        let maxHeight = 1080.0 as CGFloat
        let maxWidth = 1080.0 as CGFloat
        var imgRatio = actualWidth/actualHeight;
        let maxRatio = maxWidth/maxHeight;
        let compressionQuality = 0.1 as CGFloat;//50 percent compression
        
        if (actualHeight > maxHeight || actualWidth > maxWidth)
        {
            if(imgRatio < maxRatio)
            {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight;
                actualWidth = imgRatio * actualWidth;
                actualHeight = maxHeight;
            }
            else if(imgRatio > maxRatio)
            {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth;
                actualHeight = imgRatio * actualHeight;
                actualWidth = maxWidth;
            }
            else
            {
                actualHeight = maxHeight;
                actualWidth = maxWidth;
            }
        }
        
        let rect = CGRect(x: 0.0, y: 0.0, width: actualWidth, height: actualHeight);
        UIGraphicsBeginImageContext(rect.size);
        image.drawInRect(rect);
        let img = UIGraphicsGetImageFromCurrentImageContext();
        let imageData = UIImageJPEGRepresentation(img!, compressionQuality);
        UIGraphicsEndImageContext();
        
        return UIImage(data: imageData!)!;
        //      return image
        
    }

    
    //MARK:- dish List Method
    
    @IBAction func dishListMethod(sender : UIButton){
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("DishTag") as! DishTagViewController;
        self.navigationController!.pushViewController(openPost, animated:false);
        self.navigationController?.navigationBarHidden = false
    }
    
    //MARK:- checkin List Method
    
    @IBAction func checkInListMethod(sender : UIButton){
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("CheckIn") as! CheckInViewController;
        self.navigationController!.pushViewController(openPost, animated:false);
        self.navigationController?.navigationBarHidden = false
    }
    
    // MARK: FloatRatingViewDelegate
    
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
        
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        
        selectedRating = String(format: "%f", self.floatRatingView.rating)
        
    }
    
    //MARK:- textViewDelegates
    
    func textViewDidBeginEditing(textView: UITextView) {
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.frame.origin.y = self.view.frame.origin.y - 100
            self.btnSharePost.frame = CGRect(x: 0, y: self.view.frame.size.height - 116 - 45, width: (self.btnSharePost.frame.size.width), height: (self.btnSharePost.frame.size.height))
        })
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.view.frame.origin.y = self.view.frame.origin.y + 100
                self.btnSharePost.frame = CGRectMake(0, self.view.frame.size.height - 45, (self.btnSharePost.frame.size.width), (self.btnSharePost.frame.size.height))
            })
            
            textView.resignFirstResponder()
            return false
        }
        return true
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
