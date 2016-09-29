//
//  CheckInViewController.swift
//  FoodTalk
//
//  Created by Ashish on 22/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

var restaurantId = String()
var selectedRestaurantName = String()
var isRatedLater : Bool = false
var imageSelected = UIImage()
var isCameraCancel : Bool = false

class CheckInViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate,  UIGestureRecognizerDelegate, FloatRatingViewDelegate, UITabBarControllerDelegate, CLLocationManagerDelegate, TTTAttributedLabelDelegate, WebServiceCallingDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var tableView : UITableView?
    @IBOutlet var btnAddRestaurant : UIButton?
    var searchBar = UISearchBar()
    
    var restaurentNameList = NSMutableArray()
    var restaurantDetails = NSMutableArray()
    var filtered : NSArray = []
    var searchActive : Bool = false
    
    //    var ratingValues = NSDictionary()
    var rateLaterView = UIView()
    var floatRatingView = FloatRatingView()
    
    var submitRatingView = UIView()
    
    var ratedLaterValue = Float()
    var postIdRating = String()
    var nameString = NSMutableAttributedString()
    
    var refreshControl:UIRefreshControl!
    var locationManager : CLLocationManager?
    var currentLocation : CLLocation?
    
    var locationVal : NSMutableDictionary?
    
    var callInt : Int = 0
    
    var loaderView  = UIView()
    var searchingLabel = UILabel()
    var activityIndicator1 = UIActivityIndicatorView()
    var btnSettings = UIButton()
    var isImageClicked : Bool = false
    
    let captureSession = AVCaptureSession()
    let stillImageOutput = AVCaptureStillImageOutput()
    var error: NSError?
    var imagePicker1 = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()

//
        //     restaurantId = String()
        selectedRestaurantName = String()
        
        callInt = 0
        searchActive = false
        // Do any additional setup after loading the view.
        self.tabBarController?.tabBar.hidden = true
        self.tabBarController?.tabBar.translucent = true
        self.view.bringSubviewToFront(btnAddRestaurant!)
        self.tabBarController?.delegate = self
        
        
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
        searchBar.backgroundColor = UIColor.clearColor()
        searchBar.placeholder = "Search Restaurant"
        //  let leftNavBarButton = UIBarButtonItem(customView:searchBar)
        self.navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        searchBar.returnKeyType = UIReturnKeyType.Go
        tableView?.backgroundColor = UIColor.whiteColor()
        //  self.title = "CheckIn"
        Flurry.logEvent("CheckIn Screen")
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        self.refreshControl = UIRefreshControl()
        let attr = [NSForegroundColorAttributeName:UIColor.grayColor()]
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes:attr)
        self.refreshControl.tintColor = colorSlate
        
        
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "Back icon.png"), forState: UIControlState())
        button.addTarget(self, action: #selector(CheckInViewController.backPressed), forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItem = barButton
        
        tableView?.separatorStyle = .SingleLine
        tableView?.separatorColor = UIColor.lightGrayColor()
        let tblView =  UIView(frame: CGRect.zero)
        tableView!.tableFooterView = tblView
        tableView!.tableFooterView!.hidden = true
        
        let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField
        
        textFieldInsideSearchBar?.textColor = colorSnow
        textFieldInsideSearchBar?.backgroundColor = UIColor.clearColor()
        //
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Skip", style: .Plain, target: self, action: #selector(CheckInViewController.addTapped))

        self.tabBarController?.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.refreshControl.endRefreshing()
        searchBar.text = ""
        if(isComingFromDishTag == true){
         //   imagePicker.removeFromParentViewController()
            loaderView.hidden = true
            self.performSelector(#selector(CheckInViewController.openPost), withObject: nil, afterDelay: 0.5)
            callInt = 0
            self.restaurantDetails = NSMutableArray()
            self.restaurentNameList = NSMutableArray()
            isComingFromDishTag = false
            isImageClicked = false
        }
        else if(isCameraCancel == true){
            loaderView.hidden = true
            self.tabBarController?.tabBar.hidden = false
            self.tabBarController?.tabBar.translucent = false
            self.navigationController?.navigationBarHidden = false
            UIApplication.sharedApplication().statusBarHidden = false
            isCameraCancel = false
            self.performSelector(#selector(CheckInViewController.callDelay), withObject: nil, afterDelay: 0.2)
        }
        else{
            selectedTabBarIndex = 2
            
            searchActive = false
            searchBar.resignFirstResponder()
            searchActive = false
            
            btnSettings.removeFromSuperview()
            
            loaderView.frame = CGRect(x: 0, y: 194, width: self.view.frame.size.width, height: 100)
            self.view.addSubview(loaderView)
            
            let imgView = UIImageView()
            imgView.frame = CGRect(x: self.view.frame.size.width/2 - 10, y: 0, width: 20, height: 20)
            imgView.image = UIImage(named: "search.png")
            loaderView.addSubview(imgView)
            
            
            //  searchingLabel = UILabel()
            searchingLabel.frame = CGRect(x: 0, y: 32, width: self.view.frame.size.width, height: 60)
            searchingLabel.numberOfLines = 0
            searchingLabel.textAlignment = NSTextAlignment.Center
            searchingLabel.text = "Looking for places around you."
            searchingLabel.textColor = UIColor.grayColor()
            searchingLabel.font = UIFont(name: fontBold, size: 14)
            loaderView.addSubview(searchingLabel)
            
            activityIndicator1 = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            activityIndicator1.frame = CGRect(x: self.view.frame.size.width/2 - 15, y: 74, width: 30, height: 30)
            activityIndicator1.startAnimating()
            loaderView.addSubview(activityIndicator1)
            
            loaderView.hidden = false
            
            btnSettings.frame = CGRectMake(30, loaderView.frame.origin.y + loaderView.frame.size.height + 10, self.view.frame.size.width - 60, 30)
            btnSettings.setTitle("Go to Settings", forState: UIControlState.Normal)
            btnSettings.addTarget(self, action: #selector(CheckInViewController.openSettings), forControlEvents: UIControlEvents.TouchUpInside)
            btnSettings.backgroundColor = UIColor.blackColor()
            btnSettings.layer.cornerRadius = 2
            btnSettings.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            
            self.view.addSubview(btnSettings)
            btnSettings.hidden = true
            
            loaderView.backgroundColor = UIColor.clearColor()
            
            //  searchBar?.text = ""
            self.navigationController?.navigationBarHidden = false
            self.tabBarController?.tabBar.hidden = true
            self.tabBarController?.tabBar.translucent = true
            self.tabBarController?.delegate = self
            
            if(isConnectedToNetwork() == false){
                loaderView.hidden = true
            }
            
            
            if(ratingValue.count > 0){
                navigationItem.rightBarButtonItem?.enabled = false
                showRatinglaterView()
            }
            else
            {
                rateLaterView.removeFromSuperview()
            }
            if(isImageClicked == false){
                loaderView.hidden = false
                
                self.restaurantDetails = NSMutableArray()
                self.restaurentNameList = NSMutableArray()
                self.openPost()
                
            }
            else{
              //  if(restaurentNameList.count > 0){
                  //  loaderView.hidden = true
                    callInt = 0
                    addLocationManager()

           //     }
            }
            
        }
        
        tableView?.reloadData()
    }
    
    func callDelay(){
        dispatch_async(dispatch_get_main_queue()) {
            self.tabBarController?.selectedIndex = 0
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        cancelRequest()
        btnSettings.removeFromSuperview()
        btnSettings.hidden = true
        super.viewWillDisappear(animated)
    }
    
    //MARK:- open Settings Method
    
    func openSettings(){
        if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    //MARK:- refresh Screen
    func refresh(sender:AnyObject)
    {
        searchActive = false
        searchBar.text = ""
        btnSettings.removeFromSuperview()
        btnSettings.hidden = true
        restaurantDetails = NSMutableArray()
        restaurentNameList = NSMutableArray()
        dispatch_async(dispatch_get_main_queue())  {
            self.webServiceCallingForRestaurant()
        }
    }
    
    func addTapped(){
        selectedRestaurantName = ""
        restaurantId = ""
        //       self.performSelector(#selector(CheckInViewController.openPost), withObject: nil, afterDelay: 0.0)
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("DishTag") as! DishTagViewController;
        self.navigationController!.pushViewController(openPost, animated:true);
        self.navigationController?.navigationBarHidden = false
        isImageClicked = false
    }
    
    func backPressed(){
        isImageClicked = false
        self.tabBarController?.selectedIndex = 0
        self.tabBarController?.tabBar.hidden = false
        self.tabBarController?.tabBar.translucent = false
    }

    
    
    //MARK:- TableView Delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            return filtered.count
        }
        else {
            return restaurantDetails.count;
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 51
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
        }
        cell?.backgroundColor = UIColor.whiteColor()
        cell?.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        dispatch_async(dispatch_get_main_queue()) {
            let image = UIImageView()
            image.frame = CGRect(x: 15, y: 17, width: 20, height: 20)
            image.layer.cornerRadius = 10
            image.layer.masksToBounds = true
            image.userInteractionEnabled = true
            image.image = UIImage(named: "restaurant_white.png")
            image.backgroundColor = UIColor.lightGrayColor()
            //   cell.contentView.addSubview(image)
            
            let labelText = UILabel()
            labelText.frame = CGRectMake(20, 5, UIScreen.mainScreen().bounds.size.width - 50, 23)
            labelText.textColor = colorBlack
            labelText.tag = (indexPath as NSIndexPath).row
            labelText.userInteractionEnabled = true
            labelText.font = UIFont(name : fontBold, size : 16)
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CheckInViewController.doubleTabMethod(_:)))
            labelText.addGestureRecognizer(gestureRecognizer)
            labelText.backgroundColor = UIColor.whiteColor()
            cell?.contentView.addSubview(labelText)
            
            let labelText1 = UILabel()
            labelText1.frame = CGRect(x: 20, y: 25, width: UIScreen.mainScreen().bounds.size.width - 50, height: 20)
            labelText1.textColor = UIColor.grayColor()
            labelText1.backgroundColor = UIColor.whiteColor()
            labelText1.tag = (indexPath as NSIndexPath).row
            labelText1.userInteractionEnabled = true
            labelText1.font = UIFont(name : fontName, size: 12)
            let gestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(CheckInViewController.doubleTabMethod(_:)))
            labelText1.addGestureRecognizer(gestureRecognizer1)
            cell?.contentView.addSubview(labelText1)
            
            if(self.searchActive){
                if(self.filtered.count > 0){
                    labelText.text = self.filtered.objectAtIndex(indexPath.row).objectForKey("restaurantName") as? String
                    labelText1.text = self.filtered.objectAtIndex(indexPath.row).objectForKey("area") as? String
                    if(self.filtered.objectAtIndex(indexPath.row).objectForKey("restaurantIsActive") as? String == "0"){
                        labelText1.text = "unverified"
                        labelText1.textColor = UIColor.redColor()
                    }
                }
            } else {
                if(self.restaurantDetails.count > 0){
                    labelText.text = self.restaurantDetails[indexPath.row].objectForKey("restaurantName") as? String;
                    labelText1.text = self.restaurantDetails[indexPath.row].objectForKey("area") as? String
                    if(self.restaurantDetails.objectAtIndex(indexPath.row).objectForKey("restaurantIsActive") as? String == "0"){
                        labelText1.text = "unverified"
                        labelText1.textColor = UIColor.redColor()
                    }
                }
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        }
        return cell

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(searchActive){
            if(self.filtered.count > 0){
                restaurantId = filtered.objectAtIndex(indexPath.row).objectForKey("id") as! String
                selectedRestaurantName = filtered.objectAtIndex(indexPath.row) .objectForKey("restaurantName") as! String
            }
        }
        else{
            if(self.restaurantDetails.count > 0){
                restaurantId = restaurantDetails.objectAtIndex(indexPath.row) .objectForKey("id") as! String
                selectedRestaurantName = restaurantDetails.objectAtIndex(indexPath .row).objectForKey("restaurantName") as! String
            }
        }
        
        //        self.performSelector(#selector(CheckInViewController.openPost), withObject: nil, afterDelay: 0.0)
        
        let openPost1 = self.storyboard!.instantiateViewControllerWithIdentifier("DishTag") as! DishTagViewController;
        self.navigationController!.pushViewController(openPost1, animated:true);
        self.navigationController?.navigationBarHidden = false
        isImageClicked = false
    }
    
    
    //MARK:- SkipButtonMethod
    func openPost(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            
               imagePicker.allowsEditing = true
            imagePicker.showsCameraControls = true
            
            addOnImagePicker(imagePicker)
      //      self.present(imagePicker, animated: true, completion: nil)
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

    
    func doubleTabMethod(sender : UITapGestureRecognizer){
        
        if(searchActive){
            restaurantId = filtered.objectAtIndex((sender.view?.tag)!).objectForKey("id") as! String
            selectedRestaurantName = filtered.objectAtIndex((sender.view?.tag)!).objectForKey("restaurantName") as! String
        }
        else{
            restaurantId = restaurantDetails.objectAtIndex((sender.view?.tag)!).objectForKey("id") as! String
            selectedRestaurantName = restaurantDetails.objectAtIndex((sender.view?.tag)!).objectForKey("restaurantName") as! String
        }
        
        //        self.performSelector(#selector(CheckInViewController.openPost), withObject: nil, afterDelay: 0.0)
        
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("DishTag") as! DishTagViewController;
        self.navigationController!.pushViewController(openPost, animated:true);
        self.navigationController?.navigationBarHidden = false
        
    }
    
    //MARK:- SEarchBar Delegates
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        //  searchBar.setShowsCancelButton(true, animated: true)
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        
        let searchPredicate = NSPredicate(format: "restaurantName CONTAINS[cd] %@", searchText)
        let array = (self.restaurantDetails).filteredArrayUsingPredicate(searchPredicate)
        //       filtered = array as! [String]
        
        self.filtered = []
        self.filtered = array as NSArray
        
        if(searchBar.text?.characters.count < 1){
            self.searchActive = false;
            self.btnAddRestaurant?.frame = CGRectMake(0, self.view.frame.size.height - 40, (self.btnAddRestaurant?.frame.size.width)!, (self.btnAddRestaurant?.frame.size.height)!)
        }
        else{
            if(self.filtered.count == 0){
                self.searchActive = true;
                self.btnAddRestaurant?.frame = CGRect(x: 0, y: self.view.frame.size.height - 216 - 52, width: (self.btnAddRestaurant?.frame.size.width)!, height: (self.btnAddRestaurant?.frame.size.height)!)
            } else {
                if(self.filtered.count == 1){
                    self.btnAddRestaurant?.frame = CGRect(x: 0, y: self.view.frame.size.height - 216 - 52, width: (self.btnAddRestaurant?.frame.size.width)!, height: (self.btnAddRestaurant?.frame.size.height)!)
                }
                else if(self.filtered.count == 2){
                    self.btnAddRestaurant?.frame = CGRect(x: 0, y: self.view.frame.size.height - 216 - 52, width: (self.btnAddRestaurant?.frame.size.width)!, height: (self.btnAddRestaurant?.frame.size.height)!)
                }
                else if(self.filtered.count == 3){
                    self.btnAddRestaurant?.frame = CGRect(x: 0, y: self.view.frame.size.height - 216 - 52, width: (self.btnAddRestaurant?.frame.size.width)!, height: (self.btnAddRestaurant?.frame.size.height)!)
                }
                else if(self.filtered.count == 4){
                    self.btnAddRestaurant?.frame = CGRect(x: 0, y: self.view.frame.size.height - 216 - 52, width: (self.btnAddRestaurant?.frame.size.width)!, height: (self.btnAddRestaurant?.frame.size.height)!)
                }
                    
                else{
                    self.btnAddRestaurant?.frame = CGRect(x: 0, y: self.view.frame.size.height - 40, width: (self.btnAddRestaurant?.frame.size.width)!, height: (self.btnAddRestaurant?.frame.size.height)!)
                }
                self.searchActive = true;
            }
        }
        
        self.tableView!.reloadData()
        
    }

    //MARK:- WebServiceCalling & Delegates
    
    func webServiceCallRating(){
        if (isConnectedToNetwork()){
            showLoader(self.view)
            
            let url = String(format: "%@%@%@", baseUrl,controllerPost,"getUnreated")
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            
            webServiceCallingPost(url, parameters: params)
            
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
        stopLoading(self.view)
    }
    
    func webServiceUpdateRating(){
        if (isConnectedToNetwork()){
            showLoader(self.view)
            dispatch_async(dispatch_get_main_queue()) {
                let url = String(format: "%@%@%@", baseUrl,controllerPost,"updateRating")
                let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
                
                let params = NSMutableDictionary()
                
                params.setObject(sessionId!, forKey: "sessionId" as NSCopying)
                params.setObject(self.postIdRating, forKey: "postId" as NSCopying)
                params.setObject(self.ratedLaterValue, forKey: "rating" as NSCopying)
                
                webServiceCallingPost(url,parameters: params)
                delegate = self
            }
        }
        else{
            internetMsg(self.view)
        }
        stopLoading(self.view)
    }
    
    func webServiceCallingForRestaurant(){
        if (isConnectedToNetwork()){
            
            
            let url = String(format: "%@%@%@", baseUrl, controllerRestaurant, searchListMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let userId = NSUserDefaults.standardUserDefaults().objectForKey("userId")
            
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(userId!, forKey: "selectedUserId")
            params.setObject(self.locationVal!.valueForKey("latitude") as! NSNumber, forKey: "latitude")
            params.setObject(self.locationVal!.valueForKey("longitute") as! NSNumber, forKey: "longitude")
            
            webServiceCallingPost(url, parameters: params)
           
            delegate = self
            
        }
        else{
            internetMsg(view)
            stopLoading1(self.view)
        }
    }
    
    func getDataFromWebService(dict : NSMutableDictionary){
        
        if(dict.objectForKey("api") as! String == "restaurant/list"){
            
            if((dict.objectForKey("status")! as! String).isEqual("OK")){
            let arr = dict.objectForKey("restaurants") as! NSArray
            for index : Int in 0 ..< arr.count {
                self.restaurentNameList.addObject(arr.objectAtIndex(index).objectForKey("restaurantName") as! String)
                self.restaurantDetails.addObject(arr.objectAtIndex(index))
            }
               
            }
            else if((dict.objectForKey("status")! as! String).isEqual("error")){
            if((dict.objectForKey("errorCode")! as! NSNumber).isEqual(6)){
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "sessionId")
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userId")
                self.dismissViewControllerAnimated(true, completion: nil)
                
                let nav = (self.navigationController?.viewControllers)! as NSArray
                if(!(nav.objectAtIndex(0) as! UIViewController).isKindOfClass(LoginViewController)){
                    for viewController in nav {
                        // some process
                        if (viewController as! UIViewController).isKindOfClass(LoginViewController) {
                            self.navigationController?.visibleViewController?.navigationController?.popToViewController(viewController as! UIViewController, animated: true)
                            break
                        }
                    }
                }
                let openPost = self.storyboard!.instantiateInitialViewController() as! LoginViewController;
                self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            }
           
        }
            loaderView.hidden = true
            self.tableView?.reloadData()
            stopLoading(self.view)
        
        }
    
    else if(dict.objectForKey("api") as! String == "post/GetUnreated"){
    dispatch_async(dispatch_get_main_queue()){
    if(dict.objectForKey("status") as! String == "OK"){
    let arrayVal = dict.objectForKey( "post")?.mutableCopy() as? NSMutableArray
    if(arrayVal!.count > 0){
    ratingValue = arrayVal?.objectAtIndex(0) as! NSDictionary
    }
    else{
    self.webServiceCallingForRestaurant()
    }
    }
    else if(dict.objectForKey("status")!.isEqual("error")){
    if(dict.objectForKey("errorCode")!.isEqual(6)){
    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "sessionId")
    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userId")
    self.dismissViewControllerAnimated(true, completion: nil)
    
    let nav = (self.navigationController?.viewControllers)! as NSArray
    if(!(nav.objectAtIndex(0).isKindOfClass(LoginViewController))){
    for viewController in nav {
    // some process
    if (viewController.isKindOfClass(LoginViewController)) {
    self.navigationController?.visibleViewController?.navigationController?.popToViewController(viewController as! UIViewController, animated: true)
    break
    }
    }
    }
    let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("Login") as! LoginViewController;
    self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    }
    stopLoading(self.view)
    }
    }
    else if(dict.objectForKey("api") as! String == "post/updateRating"){
    
    floatRatingView.removeFromSuperview()
    submitRatingView.removeFromSuperview()
    rateLaterView.removeFromSuperview()
    ratingValue = NSDictionary()
    btnAddRestaurant?.enabled = true
    if(dict.objectForKey("status") as! String == "OK"){
    dispatch_async(dispatch_get_main_queue()) {
    self.webServiceCallingForRestaurant()
    }
    }
    else if((dict.objectForKey("status")! as! String).isEqual("error")){
    if((dict.objectForKey("errorCode")! as! NSNumber).isEqual(6)){
    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "sessionId")
    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userId")
    self.dismissViewControllerAnimated(true, completion: nil)
    
    let nav = (self.navigationController?.viewControllers)! as NSArray
    if(!(nav.objectAtIndex(0) as! UIViewController).isKindOfClass(LoginViewController)){
    for viewController in nav {
    // some process
    if (viewController as! UIViewController).isKindOfClass( LoginViewController) {
    self.navigationController?.visibleViewController?.navigationController?.popToViewController(viewController as! UIViewController, animated: true)
    break
    }
    }
    }
    let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("Login") as! LoginViewController;
    self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    }
    }
    if(restaurentNameList.count > 0){
    loaderView.hidden = true
    }
    else{
    searchingLabel.text = "No restaurant around :("
    }
    btnSettings.hidden = true
    self.refreshControl.endRefreshing()
    
}

    func serviceFailedWitherror(error : NSError){
        
    }

    func serviceUploadProgress(myprogress : float_t){
        
    }

    //MARK:- LocationManager
    func addLocationManager(){
        locationManager = CLLocationManager()
        locationManager!.delegate = self;
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.requestAlwaysAuthorization()
        locationManager!.startUpdatingLocation()
    }

    //MARK:- UserLocations Methods

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0]
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        //Do What ever you want with it
        locationVal = NSMutableDictionary()
        locationVal!.setObject(long, forKey: "longitute")
        locationVal!.setObject(lat, forKey: "latitude")
        
        
        if(callInt == 0){
            if let location:CLLocation = locationManager!.location {
                Flurry.setLatitude(location.coordinate.latitude,
                                   longitude: location.coordinate.longitude,
                                   horizontalAccuracy: 10.0,
                                   verticalAccuracy: 10.0
                );
            }
            dispatch_async(dispatch_get_main_queue()){
                self.webServiceCallingForRestaurant()
            }
        }
        callInt += 1
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.Denied) {
            
               refreshControl.removeFromSuperview()
                self.searchingLabel.text = "Please enable location services in your privacy settings to post or press skip"
                self.activityIndicator1.stopAnimating()
                self.btnSettings.hidden = false
                self.dismissViewControllerAnimated(true, completion: nil)

            
        } else if (status == CLAuthorizationStatus.AuthorizedAlways) {
            self.refreshControl.addTarget(self, action: #selector(CheckInViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
            self.tableView!.addSubview(refreshControl)
        }
    }

    
    //MARK:- RateLaterView
    
    func showRatinglaterView(){
        
        let isContain = self.view.subviews.contains(rateLaterView)
        if(isContain == true){
            
        }
        else{
            rateLaterView = UIView()
            floatRatingView = FloatRatingView()
        
        
        btnAddRestaurant?.enabled = false
        
        rateLaterView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
        rateLaterView.backgroundColor = UIColor.blackColor()
        self.view.addSubview(rateLaterView)
        rateLaterView.alpha = 1.0
        
        let viewCell = UIView()
        viewCell.frame = CGRectMake(10, 100, self.view.frame.size.width - 20, self.view.frame.size.height - 10)
        viewCell.backgroundColor = UIColor.clearColor()
        rateLaterView.addSubview(viewCell)
        
        let upperView = UIView()
        upperView.frame = CGRectMake(0, 0, viewCell.frame.size.width, 50)
        upperView.backgroundColor = UIColor.whiteColor()
        viewCell.addSubview(upperView)
        
        let imgView = UIImageView()
        imgView.frame = CGRectMake(0, 50, viewCell.frame.size.width, viewCell.frame.size.width)
        imgView.image = UIImage(named: "placeholder.png")
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2), dispatch_get_main_queue()) {
         //   loadImageAndCache(imgView,url: ratingValue.objectForKey("postImage") as! String)
            imgView.hnk_setImageFromURL(NSURL(string: ratingValue.objectForKey("postImage") as! String)!)
        }
        viewCell.addSubview(imgView)
        
        
        //upperView's Subview
        let profilePic = UIImageView()
        profilePic.frame = CGRectMake(8, 8, 34, 34)
        profilePic.backgroundColor = UIColor.grayColor()
      //  loadImageAndCache(profilePic, url:(ratingValue.objectForKey("userThumb") as? String)!)
        profilePic.hnk_setImageFromURL(NSURL(string: (ratingValue.objectForKey("userThumb") as? String)!)!)
        profilePic.layer.cornerRadius = 16
        profilePic.layer.masksToBounds = true
        profilePic.image = UIImage(named: "username.png")
        upperView.addSubview(profilePic)
                
            let statusLabel = TTTAttributedLabel(frame: CGRectMake(50, 0, upperView.frame.size.width - 75, 50))
            statusLabel.numberOfLines = 0
            statusLabel.font = UIFont(name: fontBold, size: 14)
            upperView.addSubview(statusLabel)
            
            let lengthRestaurantname = (ratingValue.objectForKey("restaurantName") as! String).characters.count
            
            var status = ""
            
            if(lengthRestaurantname < 1){
                status = String(format: "How did you like %@ ?", ratingValue.objectForKey("dishName") as! String)
            }
            else{
                status = String(format: "How did you like %@ at %@ ?", ratingValue.objectForKey("dishName") as! String,ratingValue.objectForKey("restaurantName") as! String)
            }
            
            statusLabel.text = status
            statusLabel.delegate = self
            statusLabel.tag = 0
        
        let timeLabel = UILabel()
        timeLabel.frame = CGRectMake(upperView.frame.size.width - 25, 0, 25, 60)
        timeLabel.text = ratingValue.objectForKey("timeElapsed") as? String
        timeLabel.textColor = UIColor.grayColor()
        timeLabel.font = UIFont(name: fontName, size: 12)
        upperView.addSubview(timeLabel)
        
        floatRatingView.frame = CGRectMake(0, imgView.frame.origin.y+imgView.frame.size.height, viewCell.frame.size.width, 40)
        viewCell.addSubview(floatRatingView)
        floatRatingView.emptyImage = UIImage(named: "stars-02.png")
        floatRatingView.fullImage = UIImage(named: "stars-01.png")
        // Optional params
        floatRatingView.delegate = self
        floatRatingView.contentMode = UIViewContentMode.ScaleAspectFit
        floatRatingView.maxRating = 5
        floatRatingView.minRating = 1
        floatRatingView.rating = 0
        floatRatingView.editable = true
        floatRatingView.halfRatings = false
        floatRatingView.floatRatings = false
        floatRatingView.backgroundColor = UIColor.whiteColor()
        }
    }
    
    // MARK: FloatRatingViewDelegate
    
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
        //   self.liveLabel.text = NSString(format: "%.2f", self.floatRatingView.rating) as String
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        //   self.updatedLabel.text = NSString(format: "%.2f", self.floatRatingView.rating) as String
        ratedLaterValue = ratingView.rating
        floatRatingView.hidden = true
        submitRatingView.frame = CGRectMake(0, floatRatingView.frame.origin.y, floatRatingView.frame.size.width, floatRatingView.frame.size.height)
        submitRatingView.backgroundColor = UIColor.whiteColor()
        
        let superview = ratingView.superview
        superview!.addSubview(submitRatingView)
        
        let btnSubmit = UIButton()
        btnSubmit.frame = CGRectMake(submitRatingView.frame.size.width/2 - 30, 0, 60, 40)
        btnSubmit.backgroundColor = UIColor.whiteColor()
        btnSubmit.tag = floatRatingView.tag
        btnSubmit.setTitle("Submit", forState: UIControlState.Normal)
        btnSubmit.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        btnSubmit.addTarget(self, action: #selector(CheckInViewController.ratingSubmit(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        submitRatingView.addSubview(btnSubmit)
        
        let btnBack = UIButton()
        btnBack.frame = CGRectMake(10, 0, 60, 40)
        btnBack.backgroundColor = UIColor.whiteColor()
        btnBack.setTitle("Back", forState: UIControlState.Normal)
        btnBack.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
        btnBack.addTarget(self, action: #selector(CheckInViewController.ratingBack(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        submitRatingView.addSubview(btnBack)
    }
    
    func ratingSubmit(sender : UIButton){
        postIdRating = ratingValue.objectForKey("id") as! String
        floatRatingView.removeFromSuperview()
        submitRatingView.removeFromSuperview()
        rateLaterView.removeFromSuperview()
        ratingValue = NSDictionary()
        btnAddRestaurant?.enabled = true
        rateLaterView.hidden = true
        webServiceUpdateRating()
        navigationItem.rightBarButtonItem?.enabled = true
        isRatedLater = true
    }
    
    func ratingBack(sender : UIButton){
        self.floatRatingView.rating = 0
        floatRatingView.hidden = false
        submitRatingView.removeFromSuperview()
    }
    
    //MARK:- Tabbarcontroller delegate
//    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
//        if (!(viewController.isEqual(CheckInViewController))) {
//        self.navigationController?.popToRootViewControllerAnimated(false)
//        }
//    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
                if (!(viewController.isEqual(CheckInViewController))) {
                self.navigationController?.popToRootViewControllerAnimated(true)
                }
    }
    
    //MARK:- TTTAttributedLabelDelegates
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if(url == NSURL(string: "action://users/\("userName")")){
            isUserInfo = false
                        postDictHome = ratingValue
                        openProfileId = (postDictHome.objectForKey("userId") as? String)!
                        postImageOrgnol = (postDictHome.objectForKey("userImage") as? String)!
                        postImagethumb = (postDictHome.objectForKey("userThumb") as? String)!
                        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfile") as! UserProfileViewController;
                        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
            
        else if(url == NSURL(string: "action://dish/\("dishName")")){
            selectedDishHome = ratingValue.objectForKey("dishName") as! String
                        arrDishList.removeAllObjects()
                        comingFrom = "HomeDish"
                        comingToDish = selectedDishHome
                        //     self.backButton?.hidden = false
                        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("DishProfile") as! DishProfileViewController;
                        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
            
        else if(url == NSURL(string: "action://restaurant/\("restaurantName")")){
                        restaurantProfileId = (ratingValue.objectForKey("checkedInRestaurantId") as? String)!
            
                        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("RestaurantProfile") as! RestaurantProfileViewController;
                        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
    }

    func setUsersClosestCity()
    {
        let geoCoder = CLGeocoder()
        let location = locationManager?.location
        geoCoder.reverseGeocodeLocation(location!)
        {
            (placemarks, error) -> Void in
            
            let placeArray = placemarks as [CLPlacemark]!
            
            // Place details
            var placeMark: CLPlacemark!
            placeMark = placeArray?[0]
            
            // Address dictionary
           
            
            // Location name
            if let locationName = placeMark.addressDictionary?["Name"] as? NSString
            {
                print(locationName)
            }
            
            // Street address
            if let street = placeMark.addressDictionary?["Thoroughfare"] as? NSString
            {
                print(street)
            }
            
            // City
            if let city = placeMark.addressDictionary?["City"] as? NSString
            {
                print(city)
            }
            
            // Zip code
            if let zip = placeMark.addressDictionary?["ZIP"] as? NSString
            {
                print(zip)
            }
            
            // Country
            if let country = placeMark.addressDictionary?["Country"] as? NSString
            {
                print(country)
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        for var view : UIView in self.view.subviews {
            if(view == conectivityMsg){
                if(isConnectedToNetwork()){
                    conectivityMsg.removeFromSuperview()
                    dispatch_async(dispatch_get_main_queue()) {
                        self.callInt = 0
                        self.addLocationManager()
                    }
                }
            }
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
