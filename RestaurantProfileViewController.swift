//
//  RestaurantProfileViewController.swift
//  FoodTalk
//
//  Created by Ashish on 18/01/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit

var restaurantProfileId = String()
var restaurantDistance : Float = 0

class RestaurantProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout,  UIActionSheetDelegate, WebServiceCallingDelegate {
    
    @IBOutlet var tableView : UITableView?
    
    private let barSize : CGFloat = 44.0
    private let kCellReuse : String = "PackCell"
    private let kCellheaderReuse : String = "PackHeader"
    var collectionView : UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var profileInfo = NSDictionary()
    var btnCall : UIButton?
    var callNumber = String()
    
    var arrPhoneNumbers = NSMutableArray()
    var arrImages = NSMutableArray()
    var reportType = Int()
    
    var pageList : Int = 0
    
    var lblAlert = UILabel()
    var isComplete : Bool = false
    
    var activityIndicator1 = UIActivityIndicatorView()
    var isResponseCome : Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      //  showLoader(self.view)
        
        if(activityIndicator1.isEqual(nil)){
            activityIndicator1 = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        }
        activityIndicator1.frame = CGRect(x: self.view.frame.size.width/2 - 15, y: 360, width: 30, height: 30)
        activityIndicator1.startAnimating()
        self.view.addSubview(activityIndicator1)
        
        Flurry.logEvent("Restaurant Profile Screen")
        tableView!.registerNib(UINib(nibName: "RestaurantProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "restaurant")
        tableView?.backgroundColor = UIColor.whiteColor()
        tableView?.separatorColor = UIColor.clearColor()
        
        self.view.backgroundColor = UIColor.whiteColor()
        
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "moreWhite.png"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(RestaurantProfileViewController.reportDeleteMethod(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 25, 30)
        
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        
        self.title = "Restaurant"
        comingFrom = "HomeDish"
        
        // (Current navigation item
        dispatch_async(dispatch_get_main_queue()) {
          self.webServiceForRestaurant()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        cancelRequest()
        isSuggestion = false
        if (self.isMovingFromParentViewController()){
           
            self.navigationController?.navigationBarHidden = true
        }
    }
    
    
    //MARK:- TableView Delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.row == 0){
            let cell = tableView.dequeueReusableCellWithIdentifier("restaurant", forIndexPath: indexPath) as! RestaurantProfileTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            if(profileInfo.count > 0){
                
            btnCall = UIButton()
            btnCall = cell.callBtn
            btnCall!.tag = indexPath.row
            btnCall?.addTarget(self, action: #selector(RestaurantProfileViewController.followServiceCall(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            cell.callBtn?.layer.cornerRadius = 5
            cell.checkInBtn?.layer.borderWidth = 2
            cell.checkInBtn!.layer.borderColor = UIColor.whiteColor().CGColor
            cell.checkInBtn?.layer.cornerRadius = 5
            
                
            cell.retaurentname?.text = profileInfo.objectForKey("restaurantName") as? String
            cell.address?.text = profileInfo.objectForKey("address") as? String
                
                if((profileInfo.objectForKey("priceRange") as! String).characters.count > 0){
                let restaurantPrice = profileInfo.objectForKey("priceRange")?.floatValue
                    
                if(restaurantPrice < 499){
                    cell.checkInBtn?.setTitle(("\u{20B9} Budget"), forState: UIControlState.Normal)
                }
                else if(restaurantPrice > 499 && restaurantPrice < 1000){
                    cell.checkInBtn?.setTitle(("\u{20B9} Mid Range"), forState: UIControlState.Normal)
                }
                else if(restaurantPrice > 999){
                    cell.checkInBtn?.setTitle(("\u{20B9} Splurge"), forState: UIControlState.Normal)
                }
                }
                else{
                    cell.checkInBtn?.setTitle(("No cost"), forState: UIControlState.Normal)
                }
                
                if(self.arrImages.count > 0){
                dispatch_async(dispatch_get_main_queue()) {
                    cell.imgBackground!.hnk_setImageFromURL(NSURL(string: self.arrImages.objectAtIndex(indexPath.row).objectForKey("postImage") as! String)!)
                }
                
                let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
                let blurEffectView = UIVisualEffectView(effect: blurEffect)
                blurEffectView.frame = cell.imgBackground!.bounds
                blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
                cell.imgBackground!.addSubview(blurEffectView)
                }
            }
            
            return cell
        }
        else{
            var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
            if (cell == nil) {
                cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
            }
            cell.backgroundColor = UIColor.whiteColor()
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            if(arrImages.count < 1){
                if(isResponseCome == true){
                lblAlert.frame = CGRectMake(0, 50, self.view.frame.size.width, 44)
                lblAlert.text = "No one eaten here yet :("
                lblAlert.font = UIFont(name: fontBold, size: 15)
                lblAlert.textAlignment = NSTextAlignment.Center
                lblAlert.textColor = UIColor.grayColor()
                cell.addSubview(lblAlert)
                }
                
            }
            
            
            if(view.viewWithTag(59) == nil){
                if(arrImages.count > 3){
                self.collectionView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width,CGFloat (arrImages.count/3) * self.collectionView.frame.size.width / 3 + UIScreen.mainScreen().bounds.size.width / 3)
                }
                else{
                self.collectionView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width,CGFloat (1) * self.collectionView.frame.size.width / 3)
                }
                self.collectionView.delegate = self     // delegate  :  UICollectionViewDelegate
                self.collectionView.dataSource = self   // datasource  : UICollectionViewDataSource
                self.collectionView.tag = 59
                self.collectionView.scrollEnabled = false
                self.collectionView.backgroundColor = UIColor.clearColor()
                self.collectionView.registerClass(PackCollectionViewCell.self, forCellWithReuseIdentifier: kCellReuse) // UICollectionViewCell
                let nipName=UINib(nibName: "PackCollectionViewCell", bundle:nil)
                
                collectionView.registerNib(nipName, forCellWithReuseIdentifier: "PackCell")
                // UICollectionReusableView
                
                cell.contentView.addSubview(self.collectionView)
            }
            
            if(arrImages.count > 3){
                self.collectionView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width,CGFloat (arrImages.count/3) * self.collectionView.frame.size.width / 3 + UIScreen.mainScreen().bounds.size.width / 3)
            }
            else{
                self.collectionView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width,CGFloat (1) * self.collectionView.frame.size.width / 3)
            }
            self.collectionView.reloadData()
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if(indexPath.row == 0){
            return 205
        }
        else if(indexPath.row == 1){
            if(arrImages.count > 0){
                if(arrImages.count < 3){
                   return  1 * self.collectionView.frame.size.width / 3
                }
                return CGFloat (arrImages.count / 3) * self.collectionView.frame.size.width / 3
            }
            else{
                return 350
            }
        }
        return 350
    }
    
    //MARK:- Calling Method
    func followServiceCall(sender : UIButton){
        if(arrPhoneNumbers.count > 0){
        if(arrPhoneNumbers.count == 1){
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: arrPhoneNumbers.objectAtIndex(0) as! String)
        
        actionSheet.showInView(self.view)
        }
        else{
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: arrPhoneNumbers.objectAtIndex(0) as! String, arrPhoneNumbers.objectAtIndex(1) as! String)
            actionSheet.showInView(self.view)
        }
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int)
    {
        if(actionSheet.tag == 1233){
            switch (buttonIndex){
            case 0:
                print("Cancel")
            case 1:
                reportType = 1
                webServiceRestaurantReport()
            case 2:
                reportType = 2
                webServiceRestaurantReport()
            case 3:
                reportType = 3
                webServiceRestaurantReport()
            default:
                print("Default")
            }
        }
        else{
        if(arrPhoneNumbers.count == 1){
            
            switch (buttonIndex){
                
            case 0:
                print("Cancel")
            case 1:
                callNumber = arrPhoneNumbers.objectAtIndex(0) as! String
            //    self.navigationController?.popViewControllerAnimated(true)
                callOnNumber()
            default:
                print("Default")
                //Some code here..
                
            }
        }
        else{
            switch (buttonIndex){
                
            case 0:
                print("Cancel")
            case 1:
                print("Report")
                callNumber = arrPhoneNumbers.objectAtIndex(0) as! String
             //   self.navigationController?.popViewControllerAnimated(true)
                callOnNumber()
            case 2:
                
                callNumber = arrPhoneNumbers.objectAtIndex(1) as! String
             //   self.navigationController?.popViewControllerAnimated(true)
                callOnNumber()
            default:
                print("Default")
                //Some code here..
            }
        }
        }
    }

   //MARK:- CallingMethod
    
    func callOnNumber(){
       
        
        let stringArray = callNumber.componentsSeparatedByCharactersInSet(
            NSCharacterSet.decimalDigitCharacterSet().invertedSet)
        let newString = stringArray.joinWithSeparator("")
        
        if let url = NSURL(string: "tel://\(newString)") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    //MARK:- CollectionViewDelegates
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : PackCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellReuse, forIndexPath: indexPath) as! PackCollectionViewCell
        if(arrImages.count > 0){
  //      loadImageAndCache(cell.packCellImage!,url: arrImages.objectAtIndex(indexPath.row).objectForKey("postThumb") as! String)
            dispatch_async(dispatch_get_main_queue()) {
            cell.packCellImage!.hnk_setImageFromURL(NSURL(string: self.arrImages.objectAtIndex(indexPath.row).objectForKey("postThumb") as! String)!)
            }
       // cell.backgroundColor = UIColor.clearColor()
        }
        return cell    // Create UICollectionViewCell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1  // Number of section
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
     
        return arrImages.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        // Select operation
        
        selectedProfileIndex = indexPath.row
        arrDishList.removeAllObjects()
        selectedDishHome = self.arrImages.objectAtIndex(indexPath.row).objectForKey("dishName") as! String
        arrDishList = self.arrImages.mutableCopy() as! NSMutableArray
        comingFrom = "Restaurant"
        comingToDish = (profileInfo.objectForKey("restaurantName") as? String)!
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("DishProfile") as! DishProfileViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return CGSize(width: (UIScreen.mainScreen().bounds.size.width/3 - 1), height: (UIScreen.mainScreen().bounds.size.width/3 - 1));
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.80
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.80
    }
    
    //MARK:- WebServiceCalling & Delagates
    
    func webServiceForRestaurant(){
    //   if(dictLocations.objectForKey("latitude") != nil){
        if(isConnectedToNetwork()){
            pageList += 1
            //showLoader(self.view)
            let url = String(format: "%@%@%@", baseUrl,controllerRestaurant,getprofileMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(pageList, forKey: "page")
            params.setObject(restaurantProfileId, forKey: "restaurantId")
            if(dictLocations.objectForKey("latitude") != nil){
            params.setObject(dictLocations.valueForKey("latitude") as! NSNumber, forKey: "latitude")
            params.setObject(dictLocations.valueForKey("longitute") as! NSNumber, forKey: "longitude")
            }
            
     //       webServiceCallingPost(url, parameters: params)
            webServiceCallingPost(url, parameters: params)
            delegate = self
        }
        else{
            internetMsg(view)
        }
//        }
//       else{
//        let alertController = UIAlertController(
//            title: "Location Disabled",
//            message: "Please enable Location Services in your iPhone Setting to share photos of dishes and where to find them on FoodTalk.'",
//            preferredStyle: .Alert)
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
//        alertController.addAction(cancelAction)
//        
//        let openAction = UIAlertAction(title: "Settings", style: .Default) { (action) in
//            if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
//                UIApplication.sharedApplication().openURL(url)
//            }
//        }
//        alertController.addAction(openAction)
//        self.presentViewController(alertController, animated: true, completion: nil)
//        }
    }
    
    func webServiceRestaurantReport(){
        if(isConnectedToNetwork()){
            showLoader(self.view)
            let url = String(format: "%@%@%@", baseUrl,controllerRestaurentReport,addlikeMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(reportType, forKey: "reportType")
            params.setObject(restaurantProfileId, forKey: "restaurantId")
        //    webServiceCallingPost(url, parameters: params)
            webServiceCallingPost(url, parameters: params)
            delegate = self
        }
        else{
            internetMsg(view)
        }
    }
    
    func getDataFromWebService(dict : NSMutableDictionary){
        
        stopLoading(self.view)
        if(dict.objectForKey("api") as! String == "restaurantReport/add"){
            if(dict.objectForKey("status") as! String == "OK"){
                let alertView = UIAlertView(title: "FoodTalk", message: "Your report saved successfully.", delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
            }
            else if(dict.objectForKey("status")!.isEqual("error")){
                if(dict.objectForKey("errorCode")!.isEqual(6)){
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "sessionId")
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userId")
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                    let nav = (self.navigationController?.viewControllers)! as NSArray
                    if(!nav.objectAtIndex(0).isKindOfClass(LoginViewController)){
                        for viewController in nav {
                            // some process
                            if viewController.isKindOfClass(LoginViewController) {
                                self.navigationController?.visibleViewController?.navigationController?.popToViewController(viewController as! UIViewController, animated: true)
                                break
                            }
                        }
                    }
                    let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("Login") as! LoginViewController;
                    self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
                }
                else{
                    let alertView = UIAlertView(title: "FoodTalk", message: "Your report saved successfully.", delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                }
            }
        }
        else{
        
        if(dict.objectForKey("status") as! String == "OK"){
           
            profileInfo = dict.objectForKey("restaurantProfile") as! NSDictionary
            if(profileInfo.objectForKey("distance") is NSNull){
               restaurantDistance = 0.0
            }
            else{
            restaurantDistance = (profileInfo.objectForKey("distance")?.floatValue)!
            }
            if((dict.objectForKey("images")?.mutableCopy() as? NSMutableArray)!.count > 0){
               arrImages = dict.objectForKey("images")?.mutableCopy() as! NSMutableArray
            }
            
            if((profileInfo.objectForKey("phone1") as! String).characters.count > 2){
                arrPhoneNumbers.addObject(profileInfo.objectForKey("phone1") as! String)
            }
            if((profileInfo.objectForKey("phone2") as! String).characters.count > 2){
                arrPhoneNumbers.addObject(profileInfo.objectForKey("phone2") as! String)
            }
            self.collectionView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width,CGFloat (arrImages.count/3) * self.collectionView.frame.size.width / 3)
            collectionView.reloadData()
        }
        
        isResponseCome = true
        activityIndicator1.removeFromSuperview()
        if(arrImages.count > 0){
            lblAlert.removeFromSuperview()
            activityIndicator1.stopAnimating()
            activityIndicator1.removeFromSuperview()
        }
        hideProcessLoader(self.view)
        tableView?.reloadData()
        if((dict.objectForKey("images")?.mutableCopy() as? NSMutableArray)!.count > 0){
            
            self.collectionView.reloadData()
            stopLoading(self.view)
            activityIndicator1.removeFromSuperview()
            activityIndicator1.stopAnimating()
            self.performSelector(#selector(RestaurantProfileViewController.removeProcess), withObject: nil, afterDelay: 0.5)
            
        }
        else{
            self.isComplete = true
            self.removeProcess()
            stopLoading(self.view)
            activityIndicator1.removeFromSuperview()
            activityIndicator1.stopAnimating()
            self.tabBarController?.tabBar.userInteractionEnabled = true
        }
        }
       
    }
    
    func removeProcess(){
        hideProcessLoader(self.view)
    }
    
    func serviceFailedWitherror(error : NSError){
        
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    //MARK:- ScrollView Delegates
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if(arrImages.count > 0){
            if(isComplete == false){
        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let size = scrollView.contentSize
        let inset = scrollView.contentInset
        let y = offset.y + bounds.size.height - inset.bottom as CGFloat
        let h = size.height as CGFloat
        let reload_distance = 25.0 as CGFloat
        if(y > h + reload_distance) {
            dispatch_async(dispatch_get_main_queue()) {
             showProcessLoder(self.view)
             self.webServiceForRestaurant()
            }
        }
            }
        }
        else{
            removeProcess()
        }
    }
    
    //MARK:- ReportMethod
    func reportDeleteMethod(sender : UIButton){
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Number Mismatch","Address Mismatch","Shutdown")
        actionSheet.tag = 1233
        actionSheet.showInView(self.view)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        
        for var view : UIView in self.view.subviews {
            if(view == conectivityMsg){
                if(isConnectedToNetwork()){
                    conectivityMsg.removeFromSuperview()
                    dispatch_async(dispatch_get_main_queue()) {
                        self.webServiceForRestaurant()
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
