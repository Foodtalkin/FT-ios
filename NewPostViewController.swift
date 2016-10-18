//
//  NewPostViewController.swift
//  FoodTalk
//
//  Created by Ashish on 03/10/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit
import AVFoundation

class NewPostViewController: UIViewController, UITextViewDelegate, FloatRatingViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet var imgDish : UIImageView?
    @IBOutlet var floatRatingView: FloatRatingView!
    @IBOutlet var txtReview : UITextView?
    var btnSharePost = UIButton()
    var ratingSegmentedControl: UISegmentedControl!
    @IBOutlet var btnAddDish : UIButton?
    @IBOutlet var btnRestaurant : UIButton?
    
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var error: NSError?
    var imagePicker1 = UIImagePickerController()
    var isImageClicked : Bool = false
    
    var imgFullImage = UIImageView()
    var viewFullImage = UIView()
    var fullImage = String()
    var isFullPressed = Bool()
    
    var currentDeviceOrientation: UIDeviceOrientation = .Unknown

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = "Post"
        
        self.fitFloatRating()
        
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
     //   txtReview!.autocorrectionType = UITextAutocorrectionType.No
        
        btnSharePost = UIButton()
        btnSharePost.frame = CGRectMake(0, self.view.frame.size.height - 45, self.view.frame.size.width, 45)
        btnSharePost.backgroundColor = colorActive
        btnSharePost.setTitle("Share post", forState: UIControlState.Normal)
        btnSharePost.addTarget(self, action: #selector(NewPostViewController.sharePostCall(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(btnSharePost)
        
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "Back icon.png"), forState: UIControlState())
        button.addTarget(self, action: #selector(NewPostViewController.backPressed), forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRect(x: -20, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
        
      UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
        
        imgDish?.userInteractionEnabled = true
        isFullPressed = false
        imageEnlargeSetting()
        
        let cameraMediaType = AVMediaTypeVideo
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatusForMediaType(cameraMediaType)
        
        switch cameraAuthorizationStatus {
        case .Denied: break
        case .Authorized: break
        case .Restricted: break
            
        case .NotDetermined:
            // Prompting user for the permission to use the camera.
            AVCaptureDevice.requestAccessForMediaType(cameraMediaType) { granted in
                if granted {
                    print("Granted access to \(cameraMediaType)")
                } else {
                    print("Denied access to \(cameraMediaType)")
                }
            }
        }
    }
    
    override func shouldAutorotate() -> Bool {
        // Lock autorotate
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        
        
        // Only allow Portrait
        return UIInterfaceOrientationMask.Portrait
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        
        // Only allow Portrait
        return UIInterfaceOrientation.Portrait
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        if(isImageClicked == false){
            selectedRestaurantName = ""
            dishNameSelected = ""
            restaurantId = 0
            imgDish?.image = UIImage(named: "placeholder.png")
            btnAddDish?.setTitle("Add a dish", forState: UIControlState.Normal)
            btnRestaurant?.setTitle("Checkin", forState: UIControlState.Normal)
            self.floatRatingView.rating = 0
            txtReview?.text = ""

            openPost()
        }
        else{
            if(isDishSelect == true){
            btnAddDish!.setTitle(dishNameSelected, forState: UIControlState.Normal)
                isDishSelect = false
            }
            if(isRestaurantSelect == true){
            btnRestaurant!.setTitle(selectedRestaurantName, forState: UIControlState.Normal)
                isRestaurantSelect = false
            }
        }
        
       
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
    
    func deviceDidRotate(notification: NSNotification) {
        self.currentDeviceOrientation = UIDevice.currentDevice().orientation
        print(self.currentDeviceOrientation)
    }
    
    func backPressed(){
        if(isFullPressed == true){
            imageSmall()
        }
        else{
        openPost()
        }
    }
    
    func imageEnlargeSetting(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(UserProfileViewController.imageFull))
        tap.numberOfTapsRequired = 1
        imgDish!.tag = 100012
        imgDish!.addGestureRecognizer(tap)
        
        viewFullImage.frame = CGRectMake(imgDish!.frame.origin.x + imgDish!.frame.size.width/2, imgDish!.frame.origin.y + imgDish!.frame.size.height/2, 1, 1)
        viewFullImage.userInteractionEnabled = true
        viewFullImage.backgroundColor = UIColor.clearColor()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window!.addSubview(viewFullImage)
    //    UIApplication.sharedApplication().keyWindow!.addSubview(viewFullImage)
        
        let blurEffect1 = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView1 = UIVisualEffectView(effect: blurEffect1)
        blurEffectView1.frame = viewFullImage.bounds
        blurEffectView1.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        viewFullImage.addSubview(blurEffectView1)
        
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(UserProfileViewController.imageSmall))
        tap1.numberOfTapsRequired = 1
        viewFullImage.tag = 100012
        viewFullImage.addGestureRecognizer(tap1)
        
        self.imgFullImage.contentMode = UIViewContentMode.ScaleAspectFit;
        
    }
    
    //MARK:- fullImage
    
    func imageFull(){
        isFullPressed = true
        UIView.animateWithDuration(0.4, animations: {
            self.viewFullImage.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
            self.imgFullImage.frame = CGRectMake(0, UIScreen.mainScreen().bounds.size.height/2 - UIScreen.mainScreen().bounds.size.width/2, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.width)
            
            self.viewFullImage.addSubview(self.imgFullImage)
            self.imgFullImage.image = imageSelected
        })
    }
    
    func imageSmall(){
        UIView.animateWithDuration(0.4, animations: {
            self.viewFullImage.frame = CGRectMake(self.imgDish!.frame.origin.x + self.imgDish!.frame.size.width/2, self.imgDish!.frame.origin.y + self.imgDish!.frame.size.height/2, 1, 1)
            
            self.imgFullImage.frame = CGRectMake(self.viewFullImage.frame.size.width/2, self.viewFullImage.frame.size.height/2, 0, 0)
        })
        isFullPressed = false
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
        viewBlack.frame = CGRect(x: self.view.frame.size.width/2 - 45, y: self.view.frame.size.height - 85, width: self.view.frame.size.width/2 + 40, height: 85)
        viewBlack.backgroundColor = UIColor.blackColor()
        viewBlack.tag = 10998
        imagePicker.view.addSubview(viewBlack)
        
        let btnGallary = UIButton(type : .Custom)
        btnGallary.frame = CGRect(x: 10, y: 0, width: 80, height: 80)
        btnGallary.addTarget(self, action: #selector(NewPostViewController.capture(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        btnGallary.setTitle("", forState: UIControlState.Normal)
        btnGallary.setImage(UIImage(named: "click icon.png"), forState: UIControlState.Normal)
        btnGallary.tag = 1011
        viewBlack.addSubview(btnGallary)
        
        let btnGallary1 = UIButton(type : .Custom)
        btnGallary1.frame = CGRect(x: viewBlack.frame.size.width/2 + 30, y: 0, width: 80, height: 80)
        btnGallary1.addTarget(self, action: #selector(NewPostViewController.openPhotoLibraryButton(_:)), forControlEvents: UIControlEvents.TouchUpInside)
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
            
         //   let imgFinal = rotateImage(pickedImage)
            imageSelected = resizeImage(pickedImage)
            self.imgDish?.image = imageSelected
            isCameraCancel = false
            isImageClicked = true
            isComingFromDishTag = false
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
         else if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageSelected = resizeImage(pickedImage)
            self.imgDish?.image = imageSelected
            isCameraCancel = false
            isImageClicked = true
            isComingFromDishTag = false
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
            
                self.isImageClicked = false
                self.tabBarController?.selectedIndex = 0
                self.tabBarController?.tabBar.hidden = false
                self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func cancel(sender : UIButton){
        isImageClicked = false
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func capture(sender : UIButton){
        
        if UIDevice.currentDevice().orientation.isLandscape.boolValue {
            print("landscape")
        } else {
            print("portrait")
        }
        
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
        btnGallary.addTarget(self, action: #selector(NewPostViewController.retake(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        btnGallary.setTitle("", forState: UIControlState.Normal)
        btnGallary.tag = 101100
        viewBlack.addSubview(btnGallary)
        
    }
    
    func rotateImage(image: UIImage) -> UIImage {
        
        
        let portraitImage  : UIImage = UIImage(CGImage: image.CGImage! ,
                                               scale: 1.0 ,
                                               orientation: UIImageOrientation.Right)
        return portraitImage
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

        })
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.view.frame.origin.y = self.view.frame.origin.y + 100

            })
            
            textView.resignFirstResponder()
            return false
        }
       
        return textView.text.characters.count + (text.characters.count - range.length) <= 200;
        
    }
    
    //MARK:- sharePostMethod
    
    @IBAction func sharePostCall(sender : UIButton){
        if(btnAddDish?.titleLabel?.text != "Add a dish"){
         
                if(self.floatRatingView.rating > 0){
                        isUploadingStart = true
                        isImageClicked = false
                        reviewSelected = (txtReview?.text)!
                        self.tabBarController?.selectedIndex = 0
                        self.tabBarController?.tabBar.hidden = false
                        UIApplication.sharedApplication().statusBarHidden = true
                }
                else{
                    self.navigationController?.view.makeToast("Please give rating")
                }
        }
        else{
            self.navigationController?.view.makeToast("Please add a dish")
        }
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
