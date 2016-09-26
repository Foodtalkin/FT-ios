//
//  FoodTalkSuggestionsViewController.swift
//  FoodTalk
//
//  Created by Ashish on 18/07/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit

class FoodTalkSuggestionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate, WebServiceCallingDelegate {
    
    @IBOutlet var tableView : UITableView?
    
    var locationManager : CLLocationManager?
    var currentLocation : CLLocation?
    
    var locationVal : NSMutableDictionary?
    var callInt : Int = 0
    var loaderView  = UIView()
    var searchingLabel = UILabel()
    var activityIndicator1 = UIActivityIndicatorView()
    var btnSettings = UIButton()
    
    var restaurentNameList = NSMutableArray()
    var restaurantDetails = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    //    delegate = self
        self.title = "City guide"
    }
    
    override func viewWillDisappear(animated: Bool) {
        cancelRequest()
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.navigationController?.navigationBarHidden = false
        loaderView.frame = CGRectMake(0, 194, self.view.frame.size.width, 100)
        self.view.addSubview(loaderView)
        
        let imgView = UIImageView()
        imgView.frame = CGRectMake(self.view.frame.size.width/2 - 10, 0, 20, 20)
        imgView.image = UIImage(named: "search.png")
        loaderView.addSubview(imgView)
        
        
        //  searchingLabel = UILabel()
        searchingLabel.frame = CGRectMake(0, 32, self.view.frame.size.width, 60)
        searchingLabel.numberOfLines = 0
        searchingLabel.textAlignment = NSTextAlignment.Center
        searchingLabel.text = "Finding places we love around you"
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
        
        let tblView =  UIView(frame: CGRectZero)
        tableView!.tableFooterView = tblView
        tableView!.tableFooterView!.hidden = true

        callInt = 0
        if(isSuggestion == true){
            restaurentNameList = NSMutableArray()
            restaurantDetails = NSMutableArray()
        addLocationManager()
        loaderView.hidden = false
        }
        else{
            loaderView.hidden = true
        }
        isSuggestion = false
    }
    
    //MARK:- LocationManager
    func addLocationManager(){
        locationManager = CLLocationManager()
        locationManager!.delegate = self;
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.requestAlwaysAuthorization()
        locationManager!.startUpdatingLocation()
    }
    
    //MARK:- open Settings Method
    
    func openSettings(){
        if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(url)
        }
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
            
            dispatch_async(dispatch_get_main_queue()){
                self.restaurentNameList = NSMutableArray()
                self.restaurantDetails = NSMutableArray()
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
            
        
            self.searchingLabel.text = "Please enable location services in your privacy settings for us to suggest places we love around you."
            self.activityIndicator1.stopAnimating()
            self.btnSettings.hidden = false
            self.dismissViewControllerAnimated(true, completion: nil)
            
            
        } else if (status == CLAuthorizationStatus.AuthorizedAlways) {
          // self.refresh()
        }
    }
    
//    //MARK:- refreshControl
//    
    func refresh(){
        callInt = 0
        addLocationManager()
    }
    
    //MARK:- TableView Delegates
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurentNameList.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
        }
        
        let iconView = UIView()
        iconView.frame = CGRectMake(15, 10, 34, 34)
        iconView.backgroundColor = UIColor.redColor()
        iconView.tag = 29
        iconView.layer.cornerRadius = iconView.frame.size.width/2
        iconView.clipsToBounds = true
        
        
        let cellIcon = UIImageView()
        cellIcon.frame = CGRectMake(7, 7, 20, 20)
        cellIcon.layer.cornerRadius = cellIcon.frame.size.width/2
        cellIcon.tag = 2223
        cellIcon.clipsToBounds = true
        
        let cellText = UILabel()
        cellText.frame = CGRectMake(59, 5, self.view.frame.size.width - 59, 20)
        cellText.font = UIFont(name: fontName, size: 15)
        cellText.textColor = UIColor.blackColor()
        cellText.tag = 22
        cellText.numberOfLines = 2
        
        
        let cellSubText = UILabel()
        cellSubText.frame = CGRectMake(59, 26, self.view.frame.size.width - 59, 20)
        cellSubText.font = UIFont(name: fontName, size: 15)
        cellSubText.tag = 28
        cellSubText.textColor = UIColor.lightGrayColor()
        
        
        if(restaurantDetails.count > 0){
        var distnce = restaurantDetails.objectAtIndex(indexPath.row).objectForKey("distance")?.floatValue
        let restaurantPrice = restaurantDetails.objectAtIndex(indexPath.row).objectForKey("priceRange")?.floatValue
        distnce = distnce! / 1000
        
        let distance = UILabel()
        distance.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width - 76, 5, 70, 20)
        if(distnce < 1000){
        distance.text = String(format: "%.1f KM", distnce!)
        }
        else{
        distance.text = String(format: "%.0f KM", distnce!)    
        }
        distance.textColor = UIColor.grayColor()
        distance.textAlignment = NSTextAlignment.Right
        distance.tag = 2999
        distance.font = UIFont(name: fontName, size: 13)
            
            let priceLabel = UILabel()
            priceLabel.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width - 96, 26, 90, 20)
            priceLabel.textColor = UIColor.grayColor()
            priceLabel.textAlignment = NSTextAlignment.Right
            priceLabel.tag = 2997
            priceLabel.font = UIFont(name: fontName, size: 13)
            if((restaurantDetails.objectAtIndex(indexPath.row).objectForKey("priceRange") as! String).characters.count > 0){
            if(restaurantPrice < 499){
                priceLabel.text = "\u{20B9} Budget"
            }
            else if(restaurantPrice > 499 && restaurantPrice < 1000){
                priceLabel.text = "\u{20B9} Mid Range"
            }
            else if(restaurantPrice > 999){
                priceLabel.text = "\u{20B9} Splurge"
            }
        }
        else{
            priceLabel.text = "No cost"
        }
        
        cellText.text = restaurentNameList.objectAtIndex(indexPath.row) as? String
        cellSubText.text = restaurantDetails.objectAtIndex(indexPath.row).objectForKey("area") as? String
        
        
        cellIcon.image = UIImage(named: "likeIcon.png")
        
        
        if((cell.contentView.viewWithTag(22)) != nil){
            cell.contentView.viewWithTag(22)?.removeFromSuperview()
            cell.contentView.viewWithTag(28)?.removeFromSuperview()
            cell.contentView.viewWithTag(29)?.removeFromSuperview()
            cell.contentView.viewWithTag(2999)?.removeFromSuperview()
            cell.contentView.viewWithTag(2997)?.removeFromSuperview()
            cell.contentView.viewWithTag(2223)?.removeFromSuperview()
        }
        cell.contentView.addSubview(cellText)
        cell.contentView.addSubview(cellSubText)
        iconView.addSubview(cellIcon)
        cell.contentView.addSubview(iconView)
        cell.contentView.addSubview(distance)
        cell.contentView.addSubview(priceLabel)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        }
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(restaurantDetails.count > 0){
        restaurantProfileId = (self.restaurantDetails.objectAtIndex(indexPath.row).objectForKey("id") as? String)!
        
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("RestaurantProfile") as! RestaurantProfileViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
    }
    
    //MARK:- WebServiceCalling Delegates
    
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
            params.setObject("1", forKey: "foodtalksuggested")
            
//            webServiceCallingPost(url, parameters: params)
            delegate = self
            
            webServiceCallingPost(url, parameters: params)
            
        }
        else{
            internetMsg(view)
            stopLoading1(self.view)
        }
    }
    
    func getDataFromWebService(dict : NSMutableDictionary){
        if(dict.objectForKey("api") as! String == "restaurant/list"){
            
            let arr = dict.objectForKey("restaurants") as! NSArray
            for(var index : Int = 0; index < arr.count; index += 1){
                self.restaurentNameList.addObject(arr.objectAtIndex(index).objectForKey("restaurantName") as! String)
                self.restaurantDetails.addObject(arr.objectAtIndex(index))
            }
            self.tableView?.reloadData()
            stopLoading(self.view)
            loaderView.hidden = true
            activityIndicator1.hidden = true
        }
    }
    
    func serviceFailedWitherror(error : NSError){
        
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
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
