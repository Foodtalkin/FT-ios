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
var isRestaurantSelect : Bool = false

class CheckInViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate,  UIGestureRecognizerDelegate,  UITabBarControllerDelegate, CLLocationManagerDelegate, TTTAttributedLabelDelegate, WebServiceCallingDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

        self.tabBarController?.delegate = self
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
        restaurentNameList = NSMutableArray()
        dispatch_async(dispatch_get_main_queue())  {
            self.webServiceCallingForRestaurant()
        }
    }
    
    
    func backPressed(){
//        isImageClicked = false
//        self.tabBarController?.selectedIndex = 0
//        self.tabBarController?.tabBar.hidden = false
//        self.tabBarController?.tabBar.translucent = false
        self.navigationController?.popViewControllerAnimated(false)
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
        isRestaurantSelect = true
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    
    //MARK:- SkipButtonMethod
    
    
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
