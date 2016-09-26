//
//  UserProfileViewController.swift
//  FoodTalk
//
//  Created by Ashish on 21/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit

var postImagethumb = String()
var postImageOrgnol = String()

var userListType = String()
var userIdForFollow = String()
var pointsTap = Int()

class UserProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,  UIGestureRecognizerDelegate,UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIActionSheetDelegate, WebServiceCallingDelegate{
    
    @IBOutlet var tableView : UITableView?
    var isDescribe : Bool = false
    var btnFollow : UIButton?
    var cardsInfoDict = NSDictionary()
    var arrNumberOfCard = NSMutableArray()
    var dictProfileInfo = NSDictionary()
    var isFollowPressed : Bool = false

    private let barSize : CGFloat = 44.0
    private let kCellReuse : String = "PackCell"
    private let kCellheaderReuse : String = "PackHeader"
    var collectionView : UICollectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    
    var pageList : Int = 0
    
    var userImage = String()
    var thumbImage = String()
    var lblAlert = UILabel()
    var isComplete : Bool = false
    var activityIndicator1 = UIActivityIndicatorView()
    
    var isResponseCome : Bool = false
   // var firstLabel = UILabel()
    var navTitleLabel = UILabel()
    var imgFullImage = UIImageView()
    var viewFullImage = UIView()
    
    var fullImage = String()
    
    var isFullPressed = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.userInteractionEnabled = false
        Flurry.logEvent("UserProfile Screen")
        if(activityIndicator1.isEqual(nil)){
            activityIndicator1 = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        }
        activityIndicator1.frame = CGRect(x: self.view.frame.size.width/2 - 15, y: 360, width: 30, height: 30)
        activityIndicator1.startAnimating()
        self.view.addSubview(activityIndicator1)
        
        tableView?.separatorColor = UIColor.clearColor()
 //       tableView?.backgroundColor = UIColor(red: 21/255.0, green: 29/255.0, blue: 46/255.0, alpha: 1)
        tableView?.backgroundColor = UIColor.whiteColor()
        tableView!.decelerationRate = UIScrollViewDecelerationRateFast;
   //     self.view.backgroundColor = UIColor(red: 21/255.0, green: 29/255.0, blue: 46/255.0, alpha: 1)
        
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self

        
        if let navigationBar = self.navigationController?.navigationBar {
           
            
            navTitleLabel = UILabel()
            navTitleLabel.frame = CGRectMake(0, 0, 0, 18)
            navTitleLabel.textColor = UIColor.whiteColor()
         
            navTitleLabel.font = UIFont(name: fontBold, size: 15)
            navigationItem.titleView = navTitleLabel
        }
        
        if let navigationBar = self.navigationController?.navigationBar {
//            let firstFrame = CGRect(x: 0, y: 28, width: navigationBar.frame.size.width , height: 17)
            
//            firstLabel = UILabel(frame: firstFrame)
//            
//            firstLabel.textColor = UIColor(red: 4/255.0, green: 209/255.0, blue: 205/255.0, alpha: 1)
//            firstLabel.textAlignment = NSTextAlignment.Center
//            firstLabel.font = UIFont(name: fontName, size: 10)
//            navigationBar.addSubview(firstLabel)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        showLoader(self.view)
        isFullPressed = false
        userLoginAllInfo =  (NSUserDefaults.standardUserDefaults().objectForKey("LoginDetails") as? NSMutableDictionary)!
        arrNumberOfCard = NSMutableArray()
    //    firstLabel.hidden = false
        navTitleLabel.hidden = false
        if(isConnectedToNetwork()){
        dispatch_async(dispatch_get_main_queue()) {
        self.webserviceForCards()
        }
        }
        else{
            internetMsg(self.view)
            stopLoading(self.view)
        }
        
        // Do any additional setup after loading the view.
        tableView!.registerNib(UINib(nibName: "UserProfileTableViewCell", bundle: nil), forCellReuseIdentifier: "ProfileCell")
        tableView?.separatorColor = UIColor.clearColor()
        
        self.navigationController?.navigationBarHidden = false
        
        if(isUserInfo == true){
            navTitleLabel.text = userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String
            navTitleLabel.sizeToFit()
//            firstLabel.text = String(format: "%@ Points",(userLoginAllInfo.objectForKey("profile")?.objectForKey("totalPoints") as? String)!)
            self.btnFollow?.hidden = true
            self.navigationItem.rightBarButtonItem = nil
        }
        else{
          //  self.title = dictProfileInfo.objectForKey("fullName") as? String
                  navTitleLabel.text  = postDictHome.objectForKey("userName") as? String
            navTitleLabel.sizeToFit()
            if(postDictHome.objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String){
                
            let button: UIButton = UIButton(type: UIButtonType.Custom)
            button.setImage(UIImage(named: "moreWhite.png"), forState: UIControlState.Normal)
            button.addTarget(self, action: #selector(UserProfileViewController.reportDeleteMethod(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            button.frame = CGRectMake(0, 0, 25, 30)
            
            let barButton = UIBarButtonItem(customView: button)
            self.navigationItem.rightBarButtonItem = barButton
            }
            else{
              self.btnFollow?.hidden = true  
            }
        }
        
        tableView!.registerNib(UINib(nibName: "CardViewCell", bundle: nil), forCellReuseIdentifier: "CardCell")
    }
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
   //    firstLabel.hidden = true
        navTitleLabel.hidden = true
            cancelRequest()
        if (self.isMovingFromParentViewController()){
           //   self.tabBarController?.selectedIndex = 0
            
        //    self.navigationController?.popViewControllerAnimated(true)
            self.navigationController?.navigationBarHidden = true
        }
    }

    
    //MARK:- TableView Delegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(dictProfileInfo.count > 0){
            return 2
        }
            return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if(indexPath.row == 0){
        //    let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! UserProfileTableViewCell
            let cell = tableView.dequeueReusableCellWithIdentifier("ProfileCell", forIndexPath: indexPath) as! UserProfileTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            cell.btnFollow?.hidden = true
            //    cell.backgroundColor = UIColor.blackColor()
            
            
            if(dictProfileInfo.count > 0){
                let numberFormatter = NSNumberFormatter()
                let number = numberFormatter.numberFromString((dictProfileInfo.objectForKey("avilablePoints") as? String)!)
                let numberFloatValue = number!.floatValue
                
                let f = numberFloatValue
                let y = Int(f)
                
                if(y == 0 || y == 1){
                    cell.noOfcheckins?.text = String(format: "%d", y)
                }
                else{
                    cell.noOfcheckins?.text = String(format: "%d", y)
                }
                
                
                //            cell.noOfcheckins?.text = dictProfileInfo.objectForKey("checkInCount") as? String
                cell.noOfFollowers?.text = dictProfileInfo.objectForKey("followersCount") as? String
                cell.noOfFollowing?.text = dictProfileInfo.objectForKey("followingCount") as? String
                
                cell.btnFollowerList?.addTarget(self, action: #selector(UserProfileViewController.showFollowers(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                cell.btnFollowingList!.addTarget(self, action: #selector(UserProfileViewController.showFollowing(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                //            cell.btnCheckInList!.addTarget(self, action: #selector(UserProfileViewController.showCheckIn(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                btnFollow = cell.btnFollow
                btnFollow!.tag = indexPath.row
                btnFollow?.addTarget(self, action: #selector(UserProfileViewController.followServiceCall(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                
                if(isFollowPressed == false){
                    btnFollow?.backgroundColor = UIColor.whiteColor()
                    btnFollow?.setTitle("Follow", forState: UIControlState.Normal)
                }
                else{
                    btnFollow?.backgroundColor = UIColor.greenColor()
                    btnFollow?.setTitle("Following", forState: UIControlState.Normal)
                }
            }
            
            if(isUserInfo == true){
                if(dictProfileInfo.count > 0){
                    cell.username?.text = String(format: "%@ | %@", (dictProfileInfo.objectForKey("fullName") as? String)!, (dictProfileInfo.objectForKey("cityName") as? String)!)
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        cell.profilePic!.hnk_setImageFromURL(NSURL(string: (userLoginAllInfo.objectForKey("profile")?.objectForKey("image") as? String)!)!)
                        
                        cell.imgBackground!.hnk_setImageFromURL(NSURL(string: (userLoginAllInfo.objectForKey("profile")?.objectForKey("image") as? String)!)!)
                        
                    }
                    fullImage = (userLoginAllInfo.objectForKey("profile")!.objectForKey("image") as? String)!
                    cell.btnFollow?.hidden = true
                }
                
            }
            else{
                if(dictProfileInfo.count > 0){
                    cell.username?.text = String(format: "%@ | %@", (dictProfileInfo.objectForKey("fullName") as? String)!, (dictProfileInfo.objectForKey("region") as? String)!)
                    //   self.title = dictProfileInfo.objectForKey("userName") as? String
                    navTitleLabel.text = dictProfileInfo.objectForKey("userName") as? String
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        cell.profilePic!.hnk_setImageFromURL(NSURL(string: (self.userImage))!)
                        
                        cell.imgBackground!.hnk_setImageFromURL(NSURL(string: (self.thumbImage))!)
                    }
                    fullImage = (dictProfileInfo.objectForKey("image") as? String)!
                    if(postDictHome.objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String){
                        cell.btnFollow?.hidden = false
                    }
                    else{
                        cell.btnFollow?.hidden = true
                    }
                }
                
            }
            
            cell.profilePic?.layer.cornerRadius = 42
            cell.profilePic?.layer.masksToBounds = true
            cell.btnFollow?.layer.cornerRadius = 5
            cell.profilePic?.userInteractionEnabled = true
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(UserProfileViewController.imageFull))
            tap.numberOfTapsRequired = 1
            cell.profilePic?.tag = (indexPath as NSIndexPath).row
            cell.profilePic!.addGestureRecognizer(tap)
            
            viewFullImage.frame = CGRectMake(cell.profilePic!.frame.origin.x + cell.profilePic!.frame.size.width/2, 114, 1, 1)
            viewFullImage.userInteractionEnabled = true
            viewFullImage.backgroundColor = UIColor.clearColor()
            self.view.addSubview(viewFullImage)
            
            let blurEffect1 = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let blurEffectView1 = UIVisualEffectView(effect: blurEffect1)
            blurEffectView1.frame = viewFullImage.bounds
            blurEffectView1.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
            viewFullImage.addSubview(blurEffectView1)
            
            let tap1 = UITapGestureRecognizer(target: self, action: #selector(UserProfileViewController.imageSmall))
            tap1.numberOfTapsRequired = 1
            viewFullImage.tag = indexPath.row
            viewFullImage.addGestureRecognizer(tap1)
            
            self.imgFullImage.contentMode = UIViewContentMode.ScaleAspectFit;
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            blurEffectView.frame = cell.imgBackground!.bounds
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
            cell.imgBackground!.addSubview(blurEffectView)
            
            return cell
        }
        else{
            
            var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
            if (cell == nil) {
                cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
            }
    //        cell.backgroundColor = UIColor(red: 21/255.0, green: 29/255.0, blue: 46/255.0, alpha: 1)
            
            
            if(arrNumberOfCard.count < 1){
                
                if(isResponseCome == true){
            lblAlert.frame = CGRectMake(0, 50, self.view.frame.size.width, 44)
                
            if(postDictHome.objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String){
            lblAlert.text = "No dishes to show :("
                }
                 else{
             lblAlert.text = " Your dishes will show here :)"
                }
                
            lblAlert.font = UIFont(name: fontBold, size: 15)
                lblAlert.textAlignment = NSTextAlignment.Center
                lblAlert.textColor = UIColor.grayColor()
            cell.addSubview(lblAlert)
                }
                
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            
            // Register parts(header and cell
            if(view.viewWithTag(59) == nil){
                if(arrNumberOfCard.count > 3){
                    
                    self.collectionView.frame = CGRectMake(0, 0, tableView.frame.size.width,CGFloat (arrNumberOfCard.count/3) * self.collectionView.frame.size.width / 3 * 2)
                }
                else{
                    
                    self.collectionView.frame = CGRectMake(0, 0, tableView.frame.size.width,CGFloat (1) * self.collectionView.frame.size.width / 3)
                }
            self.collectionView.reloadItemsAtIndexPaths(self.collectionView.indexPathsForVisibleItems())
            self.collectionView.delegate = self     // delegate  :  UICollectionViewDelegate
            self.collectionView.dataSource = self   // datasource  : UICollectionViewDataSource
            self.collectionView.tag = 59
            self.collectionView.scrollEnabled = false
            self.collectionView.backgroundColor = UIColor.clearColor()
            self.collectionView.registerClass(PackCollectionViewCell.self, forCellWithReuseIdentifier: kCellReuse) // UICollectionViewCell
            
        //    self.collectionView.decelerationRate = UIScrollViewDecelerationRateFast;
            let nipName=UINib(nibName: "PackCollectionViewCell", bundle:nil)
            
            collectionView.registerNib(nipName, forCellWithReuseIdentifier: "PackCell")
              // UICollectionReusableView
            
            cell.contentView.addSubview(self.collectionView)
            }
            if(arrNumberOfCard.count > 3){
                self.collectionView.frame = CGRectMake(0, 0, tableView.frame.size.width,CGFloat (arrNumberOfCard.count/3) * self.collectionView.frame.size.width / 3 * 2 )
            }
            else{
                self.collectionView.frame = CGRectMake(0, 0, tableView.frame.size.width,CGFloat (1) * self.collectionView.frame.size.width / 3)
            }
          //  dispatch_async(dispatch_get_main_queue()) {
        //    self.collectionView.reloadItemsAtIndexPaths(self.collectionView.indexPathsForVisibleItems())
          //  }
            return cell
            }
        
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if(indexPath.row == 0){
            return 205
        }
        else if(indexPath.row == 1){
            if(arrNumberOfCard.count > 0){
                if(arrNumberOfCard.count < 3){
                    return  1 * self.collectionView.frame.size.width / 3
                }
                else{
                if arrNumberOfCard.count % 3 == 0 {
                    return CGFloat (arrNumberOfCard.count / 3) * self.collectionView.frame.size.width / 3 - 50
                }
                else{
                   return CGFloat (arrNumberOfCard.count / 3) * self.collectionView.frame.size.width / 3 + 50
                }
                }
                
            }
            else{
                return 350
            }
        }
        return 44
    }
    
    //MARK:- fullImage
    
    func imageFull(){
        isFullPressed = true
         UIView.animateWithDuration(0.4, animations: {
            self.viewFullImage.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height)
            self.imgFullImage.frame = CGRectMake(0, UIScreen.mainScreen().bounds.size.height/2 - UIScreen.mainScreen().bounds.size.width/2, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.width)
           
            self.viewFullImage.addSubview(self.imgFullImage)
            self.imgFullImage.hnk_setImageFromURL(NSURL(string: (self.fullImage))!)
        //    self.imgFullImage.contentMode = UIViewContentMode.ScaleAspectFit;
        //    self.imgFullImage.hidden = false
        })
    }
    
    func imageSmall(){
        UIView.animateWithDuration(0.4, animations: {
            self.viewFullImage.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width/2, 114, 1, 1)
            
            self.imgFullImage.frame = CGRectMake(self.viewFullImage.frame.size.width/2, self.viewFullImage.frame.size.height/2, 0, 0)
        })
    }
    
    //MARK:- ScrollView Delegates
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if(arrNumberOfCard.count > 0){
            if(isComplete == false){
           
                let offset = scrollView.contentOffset
                let bounds = scrollView.bounds
                let size = scrollView.contentSize
                let inset = scrollView.contentInset
                let y = offset.y + bounds.size.height - inset.bottom as CGFloat
                let h = size.height as CGFloat
                
                let reload_distance = 10.0 as CGFloat
                if(y > h + reload_distance) {
                    dispatch_async(dispatch_get_main_queue()) {
                    showProcessLoder(self.view)
                    self.performSelector(#selector(UserProfileViewController.serviceCall), withObject: nil, afterDelay: 0.2)
                    }
                }
         //       }
            }
            else{
                removeProcess()
            }
        }
    }
    
    func serviceCall(){
        
        self.webMoreCards()
    }

    
    //MARK:- followButtonPressed
    func followBtnPressed(sender : UIButton){
        if(isDescribe == false){
           navigationItem.rightBarButtonItem?.title = "B"
           isDescribe = true
        }
        else{
            navigationItem.rightBarButtonItem?.title = "A"
           isDescribe = false
        }
        tableView?.reloadData()
    }
    
    func followServiceCall(sender : UIButton){
        
        if (isConnectedToNetwork()){
        showLoader(self.view)
        if(isFollowPressed == false){
            
        let url = String(format: "%@%@%@", baseUrl,controllerFollowers,followMethod)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        var followedUserId = ""
            
        if(isUserInfo == true){
           followedUserId = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String
        }
        else{
           followedUserId = openProfileId
         }
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(followedUserId, forKey: "followedUserId")
       //     dispatch_async(dispatch_get_main_queue()) {
            webServiceCallingPost(url, parameters: params)
       //     }
      delegate = self
            isFollowPressed = true
        }
        else{
            let url = String(format: "%@%@%@", baseUrl,controllerFollowers,"unfollow")
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            var followedUserId = ""
            
            if(isUserInfo == true){
                followedUserId = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String
            }
            else{
                followedUserId = openProfileId
            }
            let params = NSMutableDictionary()
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(followedUserId, forKey: "followedUserId")
         //   dispatch_async(dispatch_get_main_queue()) {
            webServiceCallingPost(url, parameters: params)
        //    }
            delegate = self
            isFollowPressed = false
        }
        }
        else{
            internetMsg(view)
        }
        
        
    }
    
    //MARK:- WebService Delegates
    
    func webserviceForCards(){
    //    if(dictLocations.objectForKey("latitude") != nil){
        if (isConnectedToNetwork()){
            pageList = 1
            
        let url = String(format: "%@%@%@", baseUrl,controllerUsers,getprofileMethod)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        var followedUserId = ""
        if(isUserInfo == true){
            followedUserId = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String
        }
        else{
            followedUserId = openProfileId
        }
        let params = NSMutableDictionary()
            
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(followedUserId, forKey: "selectedUserId")
        params.setObject("1", forKey: "page")
        params.setObject("10", forKey: "recordCount")
//        params.setObject(dictLocations.valueForKey("latitude") as! NSNumber, forKey: "latitude")
//        params.setObject(dictLocations.valueForKey("longitute") as! NSNumber, forKey: "longitude")
            webServiceCallingPost(url, parameters: params)
        delegate = self
        }
        else{
            internetMsg(view)
        }
//        }
//        else{
//            let alertController = UIAlertController(
//                title: "Location Disabled",
//                message: "Please enable Location Services in your iPhone Setting to share photos of dishes and where to find them on FoodTalk.'",
//                preferredStyle: .Alert)
//            
//            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
//            alertController.addAction(cancelAction)
//            
//            let openAction = UIAlertAction(title: "Settings", style: .Default) { (action) in
//                if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
//                    UIApplication.sharedApplication().openURL(url)
//                }
//            }
//            alertController.addAction(openAction)
//            self.presentViewController(alertController, animated: true, completion: nil)
//        }
    }
    
    
    func webMoreCards(){
        if (isConnectedToNetwork()){
         //   showLoader(self.view)
            pageList += 1
            let url = String(format: "%@%@%@", baseUrl,controllerUsers,getRestaurantimagepostMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            var followedUserId = String()
            
            if(isUserInfo == true){
                followedUserId = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String
            }
            else{
                followedUserId = openProfileId
            }
            
            let params = NSMutableDictionary()
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject("", forKey: "exceptions")
            params.setObject("", forKey: "hashtag")
            params.setObject(followedUserId, forKey: "selectedUserId")
            params.setObject(pageList, forKey: "page")
            webServiceCallingPost(url, parameters: params)
            delegate = self

        }
    }
    
    func webReportUser(){
        if (isConnectedToNetwork()){
            showLoader(self.view)
            let url = String(format: "%@%@%@", baseUrl,controllerFlag,"user")
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(openProfileId, forKey: "userId")
        //    webServiceCallingPost(url, parameters: params)
            webServiceCallingPost(url, parameters: params)
          delegate = self
        }
    }
    
    func getDataFromWebService(dict : NSMutableDictionary){
        var arrValues = NSMutableArray()
        if(dict.objectForKey("api") as! String == "follower/follow"){
            if(dict.objectForKey("status") as! String == "OK"){
                btnFollow?.titleLabel?.text = "Following"
                isFollowPressed = true
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
            }
        }
        else if(dict.objectForKey("api") as! String == "flag/user"){
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
            }
        }
        else if(dict.objectForKey("api") as! String == "follower/unfollow"){
            if(dict.objectForKey("status") as! String == "OK"){
                btnFollow?.titleLabel?.text = "Follow"
                isFollowPressed = false
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
            }
        }
        else if(dict.objectForKey("api") as! String == "user/getProfile"){
            if(dict.objectForKey("status") as! String == "OK"){
                
//                let numberFormatter = NSNumberFormatter()
//                let number = numberFormatter.numberFromString((dict.objectForKey("profile")?.objectForKey("score") as? String)!)
//                let numberFloatValue = number!.floatValue
//                
//                let f = numberFloatValue
//                let y = Int(f)
//                
//                if(y == 0 || y == 1){
//                firstLabel.text = String(format: "%d Point", y)
//                }
//                else{
//                firstLabel.text = String(format: "%d Points", y)
//                }
//                pointsTap = y
                
                 arrValues = dict.objectForKey("imagePosts")?.mutableCopy() as! NSMutableArray
                
                for(var index : Int = 0; index < arrValues.count; index += 1){
                    arrNumberOfCard.addObject(arrValues.objectAtIndex(index))
                }
                
                dictProfileInfo = dict.objectForKey("profile") as! NSDictionary
                userImage = dictProfileInfo.objectForKey("image") as! String
                thumbImage = dictProfileInfo.objectForKey("image") as! String
                if(dictProfileInfo.objectForKey("iFollowedIt") as! String == "0"){
                    isFollowPressed = false
                }
                else{
                    isFollowPressed = true
                }
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
            }
        }
        else{
            if(dict.objectForKey("status") as! String == "OK"){
                if((dict.objectForKey("imagePosts")) != nil){
                 arrValues = dict.objectForKey("imagePosts")?.mutableCopy() as! NSMutableArray
                
                for(var index : Int = 0; index < arrValues.count; index += 1){
                    
                    arrNumberOfCard.addObject(arrValues.objectAtIndex(index))
                }
                self.collectionView.frame = CGRectMake(0, 0, view.frame.size.width,CGFloat (arrNumberOfCard.count/3) * self.collectionView.frame.size.width / 3)
                }
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
            }
        }
        if(arrNumberOfCard.count > 0){
            lblAlert.removeFromSuperview()
        }
        stopLoading(self.view)
        activityIndicator1.removeFromSuperview()
        self.tableView?.reloadData()
        
        if(arrValues.count > 0){
        self.collectionView.reloadData()
        
        self.performSelector(#selector(UserProfileViewController.removeProcess), withObject: nil, afterDelay: 0.5)
        }
        else{
            self.isComplete = true
            self.removeProcess()
            self.tabBarController?.tabBar.userInteractionEnabled = true
        }
        isResponseCome = true
        self.tabBarController?.tabBar.userInteractionEnabled = true
    }
    
    func removeProcess(){
        hideProcessLoader(self.view)
    }
    
    func serviceFailedWitherror(error : NSError){
        
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    // MARK:- UICollectionViewDelegate, UICollectionViewDataSource
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell : PackCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(kCellReuse, forIndexPath: indexPath) as! PackCollectionViewCell
      
        if(arrNumberOfCard.count < 31){
         dispatch_async(dispatch_get_main_queue()) {
        cell.packCellImage!.hnk_setImageFromURL(NSURL(string: (self.arrNumberOfCard.objectAtIndex(indexPath.row).objectForKey("postThumb") as! String))!)
        }
        }
        else{
          cell.packCellImage!.hnk_setImageFromURL(NSURL(string: (self.arrNumberOfCard.objectAtIndex(indexPath.row).objectForKey("postThumb") as! String))!)
        }
        return cell    // Create UICollectionViewCell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1  // Number of section
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return arrNumberOfCard.count
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: false)
        // Select operation
        selectedProfileIndex = indexPath.row
        arrDishList.removeAllObjects()
        if(self.arrNumberOfCard.count > 0){
        selectedDishHome = self.arrNumberOfCard.objectAtIndex(indexPath.row).objectForKey("dishName") as! String
        }
        arrDishList = self.arrNumberOfCard
        comingFrom = "Profile"
        comingToDish = (dictProfileInfo.objectForKey("userName") as? String)!
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("DishProfile") as! DishProfileViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return CGSize(width: collectionView.frame.size.width/3-2, height: collectionView.frame.size.width/3-2);
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.80
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0.80
    }
    

    //MARK:- TapGestureMethod
    
    func handleTap(gesture : UIGestureRecognizer){
        arrDishList.removeAllObjects()
        arrDishList.addObjectsFromArray(arrNumberOfCard.mutableCopy() as! [AnyObject])
        comingFrom = "Dish"
        var tbc : UITabBarController
        tbc = self.storyboard!.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController;
        tbc.selectedIndex=1;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(tbc, animated:true);
    }
    
    //MARK:- ReportDelete
    
    func reportDeleteMethod(sender : UIButton){
        let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Report")
        
        actionSheet.showInView(self.view)
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int)
    {
        switch (buttonIndex){
            
        case 0:
            print("Cancel")
        case 1:
            webReportUser()
        default:
            print("Default")
            
        }

    }
    
    //MARK:- stop back gesture
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    //MARK:- ShowingFollowersList
    
    func showFollowers(sender : UIButton){
  //      firstLabel.hidden = true
        userListType = "follower"
        if(isUserInfo == true){
            userIdForFollow = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String
        }
        else{
            userIdForFollow = openProfileId
        }
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("followers") as! FollowersViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    func showFollowing(sender : UIButton){
  //      firstLabel.hidden = true
        userListType = "following"
        if(isUserInfo == true){
            userIdForFollow = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String
        }
        else{
            userIdForFollow = openProfileId
        }
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("followers") as! FollowersViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    func showCheckIn(sender : UIButton){
    //    firstLabel.hidden = true
        userListType = "checkIn"
        if(isUserInfo == true){
            userIdForFollow = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String
        }
        else{
            userIdForFollow = openProfileId
        }
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("followers") as! FollowersViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if(isFullPressed == false){
        if let touch = touches.first {
            let currentPoint = touch.locationInView(conectivityMsg)
            // do something with your currentPoint
            if(isConnectedToNetwork()){
                conectivityMsg.removeFromSuperview()
                dispatch_async(dispatch_get_main_queue()) {
                    self.webserviceForCards()
                }
            }
        }
        }
        else{
            isFullPressed = false
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
