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

var restaurantId = NSNumber()
var selectedRestaurantName = String()
var isRatedLater : Bool = false
var imageSelected = UIImage()
var isCameraCancel : Bool = false
var isRestaurantSelect : Bool = false

class CheckInViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate,  UIGestureRecognizerDelegate,  UITabBarControllerDelegate, CLLocationManagerDelegate, TTTAttributedLabelDelegate, WebServiceCallingDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var tableView : UITableView?
    @IBOutlet var btnAddRestaurant : UIButton?
    var searchBar = UISearchBar()
    
//    var restaurentNameList = NSMutableArray()
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
    var isLocationOn : Bool = false
    
    var myTimer : NSTimer?
    
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
        
        textFieldInsideSearchBar?.textColor = colorSlate
        textFieldInsideSearchBar?.backgroundColor = UIColor.whiteColor()
        //

        self.tabBarController?.delegate = self
         delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.refreshControl.endRefreshing()
        searchBar.text = ""

            selectedTabBarIndex = 2
            
        
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
        
                    callInt = 0
                    addLocationManager()
        
        
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
 //       restaurentNameList = NSMutableArray()
        dispatch_async(dispatch_get_main_queue())  {
            self.webServiceForCheckinSearch()
        }
    }
    
    
    func backPressed(){

        self.navigationController?.popViewControllerAnimated(false)
    }

    
    
    //MARK:- TableView Delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive) {
            if(isLocationOn){
            return restaurantDetails.count
            }
            else{
            return restaurantDetails.count + 1
            }
        }
        else {
            if(isLocationOn){
                return restaurantDetails.count
            }
            else{
                return restaurantDetails.count + 1
            }
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
   //     dispatch_async(dispatch_get_main_queue()) {
            
            let labelText = UILabel()
            labelText.frame = CGRectMake(20, 5, UIScreen.mainScreen().bounds.size.width - 50, 23)
            labelText.textColor = colorBlack
            labelText.tag = 10990
            labelText.userInteractionEnabled = true
            labelText.font = UIFont(name : fontBold, size : 16)
//            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CheckInViewController.doubleTabMethod(_:)))
//            labelText.addGestureRecognizer(gestureRecognizer)
            labelText.backgroundColor = UIColor.clearColor()
    //        cell?.contentView.addSubview(labelText)
            
            let labelText1 = UILabel()
            labelText1.frame = CGRect(x: 20, y: 25, width: UIScreen.mainScreen().bounds.size.width - 50, height: 20)
            labelText1.textColor = UIColor.grayColor()
            labelText1.backgroundColor = UIColor.clearColor()
            labelText1.tag = 1234543
            labelText1.userInteractionEnabled = true
            labelText1.font = UIFont(name : fontName, size: 12)
//            let gestureRecognizer1 = UITapGestureRecognizer(target: self, action: #selector(CheckInViewController.doubleTabMethod(_:)))
//            labelText1.addGestureRecognizer(gestureRecognizer1)
     //       cell?.contentView.addSubview(labelText1)
            
            if(self.searchActive){
                if(self.restaurantDetails.count > 0){
                    if(isLocationOn){
                    labelText.text = (self.restaurantDetails.objectAtIndex(indexPath.row).objectForKey("_source") as! NSDictionary).objectForKey("restaurantname") as? String
                    labelText1.text = (self.restaurantDetails.objectAtIndex(indexPath.row).objectForKey("_source") as! NSDictionary).objectForKey("area") as? String
                    if(self.restaurantDetails.objectAtIndex(indexPath.row).objectForKey("restaurantIsActive") as? String == "0"){
                        labelText1.text = "unverified"
                        labelText1.textColor = UIColor.redColor()
                    }
                    }
                    else{
                        if(indexPath.row == 0){
                        cell.backgroundColor = colorWarning
                        cell.textLabel?.text = "We use your location to find nearby places. Tap on this bar to turn on location."
                        }
                        else{
                            labelText.text = ((self.restaurantDetails.objectAtIndex(indexPath.row - 1) as! NSDictionary).objectForKey("_source") as! NSDictionary).objectForKey("restaurantname") as? String
                            labelText1.text = ((self.restaurantDetails.objectAtIndex(indexPath.row - 1) as! NSDictionary).objectForKey("_source") as! NSDictionary).objectForKey("area") as? String
                            if(self.restaurantDetails.objectAtIndex(indexPath.row - 1).objectForKey("restaurantIsActive") as? String == "0"){
                                labelText1.text = "unverified"
                                labelText1.textColor = UIColor.redColor()
                            }

                        }
                    }
                }
            } else {
                if(self.restaurantDetails.count > 0){
                    if(isLocationOn){
                        labelText.text = (self.restaurantDetails.objectAtIndex(indexPath.row).objectForKey("_source") as! NSDictionary).objectForKey("restaurantname") as? String
                        labelText1.text = (self.restaurantDetails.objectAtIndex(indexPath.row).objectForKey("_source") as! NSDictionary).objectForKey("area") as? String
                        if(self.restaurantDetails.objectAtIndex(indexPath.row).objectForKey("restaurantIsActive") as? String == "0"){
                            labelText1.text = "unverified"
                            labelText1.textColor = UIColor.redColor()
                        }
                    }
                    else{
                        if(indexPath.row == 0){
                            labelText.removeFromSuperview()
                            labelText1.removeFromSuperview()
                            cell.backgroundColor = colorWarning
                            cell.textLabel?.text = "We use your location to find nearby places. Tap on this bar to turn on location."
                            cell.textLabel?.font = UIFont(name: fontName, size: 12)
                            cell.textLabel?.numberOfLines = 2
                        }
                        else{
                          
                            labelText.text = (self.restaurantDetails.objectAtIndex(indexPath.row - 1).objectForKey("_source") as! NSDictionary).objectForKey("restaurantname") as? String
                            labelText1.text = (self.restaurantDetails.objectAtIndex(indexPath.row - 1).objectForKey("_source") as! NSDictionary).objectForKey("area") as? String
                            if(self.restaurantDetails.objectAtIndex(indexPath.row - 1).objectForKey("restaurantIsActive") as? String == "0"){
                                labelText1.text = "unverified"
                                labelText1.textColor = UIColor.redColor()
                            }
                        }
                    }
                }
            }
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        if((cell.contentView.viewWithTag(10990)) != nil){
            cell.contentView.viewWithTag(10990)?.removeFromSuperview()
            cell.contentView.viewWithTag(1234543)?.removeFromSuperview()
            
        }
        
        cell.contentView.addSubview(labelText)
        cell.contentView.addSubview(labelText1)
    //    }
        return cell

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(searchActive){
            if(self.restaurantDetails.count > 0){
                if(isLocationOn){
                restaurantId = ((self.restaurantDetails.objectAtIndex(indexPath.row).objectForKey("_source") as! NSDictionary).objectForKey("id") as? NSNumber)!
                selectedRestaurantName = ((self.restaurantDetails.objectAtIndex(indexPath.row).objectForKey("_source") as! NSDictionary).objectForKey("restaurantname") as? String)!
                }
                else{
                    if(indexPath.row != 0){
                    restaurantId = ((self.restaurantDetails.objectAtIndex(indexPath.row - 1).objectForKey("_source") as! NSDictionary).objectForKey("id") as? NSNumber)!
                    selectedRestaurantName = ((self.restaurantDetails.objectAtIndex(indexPath.row - 1).objectForKey("_source") as! NSDictionary).objectForKey("restaurantname") as? String)!
                    }
                    else{
                        openSettings()
                    }
                }
            }
        }
        else{
            if(self.restaurantDetails.count > 0){
                if(isLocationOn){
                    restaurantId = ((self.restaurantDetails.objectAtIndex(indexPath.row).objectForKey("_source") as! NSDictionary).objectForKey("id") as? NSNumber)!
                    selectedRestaurantName = ((self.restaurantDetails.objectAtIndex(indexPath.row).objectForKey("_source") as! NSDictionary).objectForKey("restaurantname") as? String)!
                }
                else{
                    if(indexPath.row != 0){
                        restaurantId = ((self.restaurantDetails.objectAtIndex(indexPath.row - 1).objectForKey("_source") as! NSDictionary).objectForKey("id") as? NSNumber)!
                        selectedRestaurantName = ((self.restaurantDetails.objectAtIndex(indexPath.row - 1).objectForKey("_source") as! NSDictionary).objectForKey("restaurantname") as? String)!
                    }
                    else{
                        openSettings()
                    }
                }
            }
        }
        
        //        self.performSelector(#selector(CheckInViewController.openPost), withObject: nil, afterDelay: 0.0)
        isRestaurantSelect = true
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    
    //MARK:- SkipButtonMethod
    
    
    func doubleTabMethod(sender : UITapGestureRecognizer){
        
        if(searchActive){
            if(self.restaurantDetails.count > 0){
                if(isLocationOn){
                    restaurantId = ((self.restaurantDetails.objectAtIndex((sender.view?.tag)!).objectForKey("_source") as! NSDictionary).objectForKey("id") as? NSNumber)!
                    selectedRestaurantName = ((self.restaurantDetails.objectAtIndex((sender.view?.tag)!).objectForKey("_source") as! NSDictionary).objectForKey("restaurantname") as? String)!
                }
                else{
                    if((sender.view?.tag)! != 0){
                        restaurantId = ((self.restaurantDetails.objectAtIndex((sender.view?.tag)! - 1).objectForKey("_source") as! NSDictionary).objectForKey("id") as? NSNumber)!
                        selectedRestaurantName = ((self.restaurantDetails.objectAtIndex((sender.view?.tag)! - 1).objectForKey("_source") as! NSDictionary).objectForKey("restaurantname") as? String)!
                    }
                    else{
                        openSettings()
                    }
                }
            }
        }
        else{
            if(self.restaurantDetails.count > 0){
                if(isLocationOn){
                   
                    restaurantId = ((self.restaurantDetails.objectAtIndex((sender.view?.tag)!).objectForKey("_source") as! NSDictionary).objectForKey("id") as? NSNumber)!
                    selectedRestaurantName = ((self.restaurantDetails.objectAtIndex((sender.view?.tag)!).objectForKey("_source") as! NSDictionary).objectForKey("restaurantname") as? String)!
                }
                else{
                    if((sender.view?.tag)! != 0){
                        restaurantId = ((self.restaurantDetails.objectAtIndex((sender.view?.tag)! - 1).objectForKey("_source") as! NSDictionary).objectForKey("id") as? NSNumber)!
                        selectedRestaurantName = ((self.restaurantDetails.objectAtIndex((sender.view?.tag)! - 1).objectForKey("_source") as! NSDictionary).objectForKey("restaurantname") as? String)!
                    }
                    else{
                        openSettings()
                    }
                }
            }
        }

        
        //        self.performSelector(#selector(CheckInViewController.openPost), withObject: nil, afterDelay: 0.0)
        isRestaurantSelect = true
        self.navigationController?.popViewControllerAnimated(false)
        
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
        

        
        var str = NSString()
        str = searchBar.text!
        if(str.length > 0){
            self.restaurantDetails = []
            tableView?.reloadData()
           
            searchingLabel.text = "Searching.."
            activityIndicator.hidden = false
            if(searchBar.text != ""){
                loaderView.hidden = false
            //    self.tableView?.userInteractionEnabled = false
                
                if (myTimer != nil) {
                    if ((myTimer?.valid) != nil)
                    {
                        myTimer!.invalidate();
                    }
                    myTimer = nil;
                }
                cancelRequest()
                myTimer = NSTimer.scheduledTimerWithTimeInterval(0.20, target: self, selector: #selector(CheckInViewController.webServiceForCheckinSearch1(_:)), userInfo: searchText, repeats: false)
            }
            else{
                cancelRequest()
                myTimer?.invalidate()
                self.restaurantDetails = []
                activityIndicator.hidden = true
                loaderView.hidden = true
                tableView?.reloadData()
            }
        }
        else{
            cancelRequest()
            myTimer?.invalidate()
            self.restaurantDetails = []
            activityIndicator.hidden = true
            loaderView.hidden = true
            tableView?.reloadData()
        }

        
    }

    //MARK:- WebServiceCalling & Delegates
    
    func webServiceForCheckinSearch1(timer : NSTimer){
        if (isConnectedToNetwork()){
            let url = String(format: "%@%@%@", baseUrl, controllerSearch, "es")
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
    
            let params = NSMutableDictionary()
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject("restaurant", forKey: "type")
            let searchText = (timer.userInfo as! String).lowercaseString
            
            params.setObject(searchText, forKey: "searchText")
            
            webServiceCallingPost(url, parameters: params)
            
            delegate = self
            
        }
        else{
            internetMsgForCheckin(self.view)
            stopLoading1(self.view)
        }
    }
    
    func webServiceForCheckinSearch(){
        if (isConnectedToNetwork()){
            
            
            let url = String(format: "%@%@%@", baseUrl, controllerSearch, "es")
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject("restaurant", forKey: "type")
            
            if(isLocationOn == true){
            params.setObject(self.locationVal!.valueForKey("latitude") as! NSNumber, forKey: "latitude")
            params.setObject(self.locationVal!.valueForKey("longitute") as! NSNumber, forKey: "longitude")
            }
             
            webServiceCallingPost(url, parameters: params)
            
            delegate = self
            
        }
        else{
            internetMsgForCheckin(view)
            stopLoading1(self.view)
        }
    }
    
    
    func getDataFromWebService(dict : NSMutableDictionary){
        
        if(dict.objectForKey("api") as! String == "restaurant/list"){
            
            if((dict.objectForKey("status")! as! String).isEqual("OK")){
            let arr = dict.objectForKey("restaurants") as! NSArray
            for index : Int in 0 ..< arr.count {
                //self.restaurentNameList.addObject(arr.objectAtIndex(index).objectForKey("restaurantname") as! String)
                self.restaurantDetails.addObject(arr.objectAtIndex(index) as! NSDictionary)
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
        else if(dict.objectForKey("api") as! String == "Search/es"){
            self.restaurantDetails.removeAllObjects()
        
            if((dict.objectForKey("status")! as! String).isEqual("OK")){
                
                let arr = ((dict.objectForKey("result") as! NSDictionary).objectForKey("hits") as! NSDictionary).objectForKey("hits") as! NSArray
                if(arr.count > 0){
                    removePlace()
                for index : Int in 0 ..< arr.count {
                
                    self.restaurantDetails.addObject(arr.objectAtIndex(index) as! NSDictionary)
                }
                }
                else{
                   placeHolderNoRestaurants()
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
    
    
    if(restaurantDetails.count > 0){
    loaderView.hidden = true
    }
    else{
    searchingLabel.text = "No restaurant around :("
    }
    btnSettings.hidden = true
    self.refreshControl.endRefreshing()
    self.tableView?.reloadData()
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
                self.isLocationOn = true
                self.webServiceForCheckinSearch()
            }
        }
        callInt += 1
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.Denied) {
            isLocationOn = false
               refreshControl.removeFromSuperview()
//                self.searchingLabel.text = "Please enable location services in your privacy settings to post or press skip"
//                self.activityIndicator1.stopAnimating()
//                self.btnSettings.hidden = false
//                self.dismissViewControllerAnimated(true, completion: nil)
            
            self.webServiceForCheckinSearch()

            
        } else if (status == CLAuthorizationStatus.AuthorizedAlways) {
            isLocationOn = true
            self.refreshControl.addTarget(self, action: #selector(CheckInViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
            self.tableView!.addSubview(refreshControl)
        }
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
        self.navigationController?.popToRootViewControllerAnimated(false)
        
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
    
    func placeHolderNoRestaurants(){
        let viewPlaceHolder = UIView()
        viewPlaceHolder.frame = CGRectMake(0, 100, self.view.frame.size.width, 350)
        viewPlaceHolder.tag = 1234523
        
        let imgPlace = UIImageView()
        imgPlace.frame = CGRectMake(self.view.frame.size.width/2 - 24, 10, 48, 48)
        imgPlace.image = UIImage(named : "crying-1.png")
        viewPlaceHolder.addSubview(imgPlace)
        
        let lblAlert = UILabel()
        lblAlert.frame = CGRectMake(20, imgPlace.frame.origin.y + imgPlace.frame.size.height + 10, self.view.frame.size.width - 40, 20)
        lblAlert.text = "Can't find this restaurant."
        lblAlert.textColor = UIColor.blackColor()
        lblAlert.textAlignment = NSTextAlignment.Center
        lblAlert.font = UIFont(name : fontName, size: 14)
        viewPlaceHolder.addSubview(lblAlert)
        
//        let lblAlert1 = UILabel()
//        lblAlert1.frame = CGRectMake(20, lblAlert.frame.origin.y + lblAlert.frame.size.height + 10, self.view.frame.size.width - 40, 20)
//        lblAlert1.text = String(format : "You can add \"%@\" to FoodTalk", searchBar.text!)
//        lblAlert1.textColor = colorActive
//        lblAlert1.textAlignment = NSTextAlignment.Center
//        lblAlert1.font = UIFont(name : fontName, size: 14)
//        viewPlaceHolder.addSubview(lblAlert1)
        
        let btnSettings1 = UIButton()
        btnSettings1.frame = CGRectMake(20, lblAlert.frame.origin.y + lblAlert.frame.size.height + 10, self.view.frame.size.width - 40, 20)
        btnSettings1.setTitle(String(format : "You can add \"%@\" to FoodTalk", searchBar.text!), forState: UIControlState.Normal)
        btnSettings1.addTarget(self, action: #selector(CheckInViewController.forward), forControlEvents: UIControlEvents.TouchUpInside)
        btnSettings1.setTitleColor(colorActive, forState: UIControlState.Normal)
        viewPlaceHolder.addSubview(btnSettings1)
        
        self.view.addSubview(viewPlaceHolder)
        
        let btnSettings = UIButton()
        btnSettings.frame = CGRectMake(0, self.view.frame.size.height - 256, self.view.frame.size.width, 40)
        btnSettings.setTitle("Skip checkin", forState: UIControlState.Normal)
        btnSettings.addTarget(self, action: #selector(CheckInViewController.skipCheckin), forControlEvents: UIControlEvents.TouchUpInside)
        btnSettings.setTitleColor(colorActive, forState: UIControlState.Normal)
        self.view.addSubview(btnSettings)
    }
    
    func removePlace(){
        for var view : UIView in self.view.subviews {
            if(view.tag == 1234523){
                view.removeFromSuperview()
            }
        }
    }
    
    func forward(){
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("AddRestaurant") as! AddRestaurantViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    func skipCheckin(){
        self.navigationController?.popViewControllerAnimated(true)
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
