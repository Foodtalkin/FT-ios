//
//  DishProfileViewController.swift
//  FoodTalk
//
//  Created by Ashish on 27/01/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit

var comingToDish = String()

class DishProfileViewController: UIViewController, iCarouselDataSource, iCarouselDelegate,  UIActionSheetDelegate, TTTAttributedLabelDelegate, WebServiceCallingDelegate {
    
    @IBOutlet var carousel : iCarousel!
    var pageList : Int = 0
    var nameString = NSMutableAttributedString()
    var pageingDiscover : Int = 1
    
    var baseStar : UIView?
    
    var star1 : UIImageView?
    var star2 : UIImageView?
    var star3 : UIImageView?
    var star4 : UIImageView?
    var star5 : UIImageView?
    
    var arrLikeList : NSMutableArray = []
    var arrFavList : NSMutableArray = []
    
    var carouselIndex : Int = 0
    var buttonFav : UIImageView?
    var buttonLike : UIImageView?
    var imgLikeDubleTap : UIImageView?
    
    var likeLabel : UIImageView?
    var selectedReport = String()
    
    var navTitleLabel = UILabel()
 //   var firstLabel = UILabel()
    
    var lblNoDish = UILabel()
    var btnNext = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
     //   self.title = comingToDish
        navigationItem.rightBarButtonItem?.enabled = false
        Flurry.logEvent("DishProfile Screen")
        carousel.type = .Linear
        carousel.scrollByNumberOfItems(0, duration: 0)
        carousel.pagingEnabled = true
        carousel.scrollSpeed = 1.0
        
        if(comingFrom.isEqual("HomeDish")){
            pageList = 0
            
            dispatch_async(dispatch_get_main_queue()){
                self.webCallDiscoverDish()
        }
        
            //   comingFrom = "Discover"
            let button: UIButton = UIButton(type: UIButtonType.Custom)
            button.setImage(UIImage(named: "moreWhite.png"), forState: UIControlState.Normal)
            button.addTarget(self, action: #selector(DishProfileViewController.reportDeleteMethod(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            button.frame = CGRectMake(0, 0, 25, 30)
            
            let barButton = UIBarButtonItem(customView: button)
            self.navigationItem.rightBarButtonItem = barButton
        }
        else{
            if(comingFrom == "Profile"){
                pageList = 1
                let button: UIButton = UIButton(type: UIButtonType.Custom)
                button.setImage(UIImage(named: "moreWhite.png"), forState: UIControlState.Normal)
                button.addTarget(self, action: #selector(DishProfileViewController.reportDeleteMethod(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                button.frame = CGRectMake(0, 0, 25, 30)
                
                let barButton = UIBarButtonItem(customView: button)
                self.navigationItem.rightBarButtonItem = barButton
            }
            else if(comingFrom == "Restaurant"){
                
                let button: UIButton = UIButton(type: UIButtonType.Custom)
                button.frame = CGRectMake(0, 0, 90, 30)
                
                let barButton = UIBarButtonItem(customView: button)
                self.navigationItem.rightBarButtonItem = barButton
                
                var distnce = restaurantDistance
                distnce = distnce / 1000
                let dist = String(format: "%.2f KM", distnce)
                button.titleLabel?.font = UIFont(name: fontName, size: 14)
                button.titleLabel?.textAlignment = NSTextAlignment.Right
                button.setTitle(dist, forState: UIControlState.Normal)
                
                if(restaurantDistance > 0){
                    
                }
                else{
                    button.hidden = true
                }
                
                if(dictLocations.valueForKey("latitude") != nil){
                    button.hidden = false
                }
                else{
                    button.hidden = true
                }
                
            }
            for(var index : Int = 0; index < arrDishList.count; index += 1){
                arrLikeList.addObject(arrDishList.objectAtIndex(index).objectForKey("iLikedIt") as! String)
                arrFavList.addObject(arrDishList.objectAtIndex(index).objectForKey("iBookark") as! String)
            }
        }
        
        if(arrDishList.count > 0){
            navigationItem.rightBarButtonItem?.enabled = true
        }
        else{
            navigationItem.rightBarButtonItem?.enabled = false
        }
        
        if let navigationBar = self.navigationController?.navigationBar {

            navTitleLabel = UILabel()
            navTitleLabel.frame = CGRectMake(0, 0, 0, 18)
            navTitleLabel.textColor = UIColor.whiteColor()
            navTitleLabel.text = comingToDish
            navTitleLabel.font = UIFont(name: fontBold, size: 15)
            navigationItem.titleView = navTitleLabel
           
        }
        
        if let navigationBar = self.navigationController?.navigationBar {
            let firstFrame = CGRect(x: 0, y: 28, width: navigationBar.frame.size.width , height: 17)
            
//            firstLabel = UILabel(frame: firstFrame)
//            
//            firstLabel.textColor = UIColor(red: 4/255.0, green: 209/255.0, blue: 205/255.0, alpha: 1)
//            firstLabel.textAlignment = NSTextAlignment.Center
//            firstLabel.font = UIFont(name: fontName, size: 10)
//            firstLabel.text = String(format: "%d Points", pointsTap)
//            navigationBar.addSubview(firstLabel)
        }
        
//        if(comingFrom == "Profile"){
//            firstLabel.hidden = false
//        }
//        else{
//           firstLabel.hidden = true
//        }
        
        lblNoDish.frame = CGRectMake(0, 200, self.view.frame.size.width, 15)
        lblNoDish.text = "No result :("
        lblNoDish.textAlignment = NSTextAlignment.Center
        lblNoDish.textColor = UIColor.grayColor()
        lblNoDish.font = UIFont(name: fontBold, size: 14)
        self.view.addSubview(lblNoDish)
        lblNoDish.hidden = true
        
    //    carousel.reloadData()
        self.performSelector(#selector(DishProfileViewController.loadLater), withObject: nil, afterDelay: 0.2)
    }
    
    override func viewWillAppear(animated: Bool) {
        
//        if(comingFrom == "Profile"){
//            firstLabel.hidden = false
//        }
//        else{
//            firstLabel.hidden = true
//        }
        navTitleLabel.hidden = false
       self.navigationController?.navigationBarHidden = false
       
        btnNext.frame = CGRectMake(self.view.frame.size.width - 30, self.view.frame.size.height/2 - 25, 30, 50)
        btnNext.setImage(UIImage(named : "next icon.png"), forState: UIControlState.Normal)
        btnNext.addTarget(self, action: #selector(DiscoverViewController.openNext), forControlEvents: UIControlEvents.TouchUpInside)
        btnNext.backgroundColor = UIColor.grayColor()
        btnNext.hidden = false
        self.view.addSubview(btnNext)
    }
    
    func loadLater(){
        carousel.scrollToItemAtIndex(selectedProfileIndex, animated: false)
    }
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
    //   firstLabel.hidden = true
        navTitleLabel.hidden = true
            cancelRequest()
           
        
        if (self.isMovingFromParentViewController()){
            carousel.hidden = true
        }
        
    }
    
    //MARK:- WebService Call n Delegates
    func webCallDiscoverDish(){
      //  if(dictLocations.objectForKey("latitude") != nil){
        if (isConnectedToNetwork()){
            pageList += 1
            showLoader(self.view)
            let url = String(format: "%@%@%@", baseUrl, controllerPost, getImageCheckinPost)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            if(dictLocations.objectForKey("latitude") != nil){
            params.setObject(dictLocations.valueForKey("latitude") as! NSNumber, forKey: "latitude")
            params.setObject(dictLocations.valueForKey("longitute") as! NSNumber, forKey: "longitude")
            }
            if(searchDishCity.characters.count > 0){
             params.setObject(searchDishCity, forKey: "region")
            }
            params.setObject("12", forKey: "recordCount")
            params.setObject("", forKey: "exceptions")
            params.setObject("", forKey: "hashtag")
            params.setObject(pageList, forKey: "page")
            params.setObject(selectedDishHome, forKey: "search")
            
        
            webServiceCallingPost(url, parameters: params)
            delegate = self
           // searchDishCity = ""
        }
        else{
            internetMsg(self.view)
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
    
    func webServiceForDelete(){
        
        if (isConnectedToNetwork()){
            showLoader(self.view)
            
            let url = String(format: "%@%@%@", baseUrl,controllerPost,deleteLikeMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            let postId = arrDishList.objectAtIndex(carousel.currentItemIndex).objectForKey("id") as! String
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(postId, forKey: "postId")
            
     //       webServiceCallingPost(url, parameters: params)
            webServiceCallingPost(url, parameters: params)
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
    }
    
    func webServiceForReport(){
        //flag/add
        if (isConnectedToNetwork()){
            showLoader(self.view)
            
            let url = String(format: "%@%@%@", baseUrl,controllerFlag,addlikeMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            let postId = arrDishList.objectAtIndex(carousel.currentItemIndex).objectForKey("id") as! String
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(postId, forKey: "postId")
            
       //     webServiceCallingPost(url, parameters: params)
            webServiceCallingPost(url, parameters: params)
      delegate = self
        }
        else{
            internetMsg(self.view)
        }
        
    }
    
    func webMoreCards(){
        if (isConnectedToNetwork()){
            showLoader(self.view)
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
            if(dictLocations.objectForKey("latitude") != nil){
                params.setObject(dictLocations.valueForKey("latitude") as! NSNumber, forKey: "latitude")
                params.setObject(dictLocations.valueForKey("longitute") as! NSNumber, forKey: "longitude")
            }
            if(searchDishCity.characters.count > 0){
                params.setObject(searchDishCity, forKey: "region")
            }
       //     webServiceCallingPost(url, parameters: params)
            webServiceCallingPost(url, parameters: params)
       delegate = self
            searchDishCity = ""
        }
        else{
            internetMsg(self.view)
        }
    }

    
    func getDataFromWebService(dict : NSMutableDictionary){
        if(dict.objectForKey("api") as! String == "post/getImageCheckInPosts"){
            if(dict.objectForKey("status") as! String == "OK"){
                
                let arr = dict.objectForKey("posts")?.mutableCopy() as! NSArray
                arrDishList = NSMutableArray()
                arrDishList = NSMutableArray()
                arrDishList = NSMutableArray()
                for(var index : Int = 0; index < arr.count; index += 1){
                    arrDishList.addObject(arr.objectAtIndex(index))
                    arrLikeList.addObject(arr.objectAtIndex(index).objectForKey("iLikedIt") as! String)
                    arrFavList.addObject(arr.objectAtIndex(index).objectForKey("iBookark") as! String)
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
            stopLoading1(self.view)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2), dispatch_get_main_queue()) {
            self.carousel.reloadData()
            }
            
        }
        else if(dict.objectForKey("api") as! String == "user/getImagePosts"){
            if(dict.objectForKey("status") as! String == "OK"){
                let arr = dict.objectForKey("imagePosts")?.mutableCopy() as! NSMutableArray
                
                for(var index : Int = 0; index < arr.count; index += 1){
                    arrDishList.addObject(arr.objectAtIndex(index))
                    arrLikeList.addObject(arr.objectAtIndex(index).objectForKey("iLikedIt") as! String)
                    arrFavList.addObject(arr.objectAtIndex(index).objectForKey("iBookark") as! String)
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
            stopLoading1(self.view)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2), dispatch_get_main_queue()) {
            self.carousel.reloadData()
            }
            
        }
        else if(dict.objectForKey("api") as! String == "dish/search"){
            if(dict.objectForKey("status") as! String == "OK"){
                let arr = dict.objectForKey("result")?.mutableCopy() as! NSMutableArray
                
                for(var index : Int = 0; index < arr.count; index += 1){
                    arrDishList.addObjectsFromArray(arr.mutableCopy() as! [AnyObject])
                    arrLikeList.addObject(arr.objectAtIndex(index).objectForKey("iLikedIt") as! String)
                    arrFavList.addObject(arr.objectAtIndex(index).objectForKey("iBookark") as! String)
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
            stopLoading1(self.view)
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2), dispatch_get_main_queue()) {
            self.carousel.reloadData()
            }
            
        }
        else if(dict.objectForKey("api") as! String == "like/add"){
            if(dict.objectForKey("api") as! String == "like/add"){
                arrLikeList.replaceObjectAtIndex((buttonLike?.tag)!, withObject: "1")
            }
            else{
                arrLikeList.replaceObjectAtIndex((buttonLike?.tag)!, withObject: "0")
            }
            stopLoading(self.view)
            
            self.performSelector(#selector(DishProfileViewController.removeDubleTapImage), withObject: nil, afterDelay: 1.0)
            
            pageList = 0
          //  carousel.reloadData()
            stopLoading(self.view)
        }
        else if(dict.objectForKey("api") as! String == "like/delete"){
            if(dict.objectForKey("api") as! String == "like/add"){
                arrLikeList.replaceObjectAtIndex((buttonLike?.tag)!, withObject: "1")
            }
            else{
                arrLikeList.replaceObjectAtIndex((buttonLike?.tag)!, withObject: "0")
            }
            stopLoading(self.view)
            
            self.performSelector(#selector(DishProfileViewController.removeDubleTapImage), withObject: nil, afterDelay: 1.0)
            
            pageList = 0
            
            stopLoading(self.view)
        }
            
        else if(dict.objectForKey("api") as! String == "bookmark/add"){
            
            if(dict.objectForKey("status") as! String == "OK"){
                arrFavList.replaceObjectAtIndex((buttonFav?.tag)!, withObject: "1")
                stopLoading(self.view)
                
                pageList = 0
                
                stopLoading(self.view)
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
            
        else if(dict.objectForKey("api") as! String == "bookmark/delete"){
            if(dict.objectForKey("status") as! String == "OK"){
                arrFavList.replaceObjectAtIndex((buttonFav?.tag)!, withObject: "0")
                stopLoading(self.view)
                
                pageList = 0
               
                stopLoading(self.view)
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
            
        else if(dict.objectForKey("api") as! String == "flag/add"){
            
                if(dict.objectForKey("status") as! String == "OK"){
                    let alertView = UIAlertView(title: "Report Successful", message: nil, delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                    stopLoading(self.view)
                
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
                else if(dict.objectForKey("errorCode")!.isEqual(7)){
                    let alertView = UIAlertView(title: "Report Successful", message: nil, delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                    stopLoading(self.view)
                    }
            }
            
        }
            
        else if(dict.objectForKey("api") as! String == "post/delete"){
            if(dict.objectForKey("status") as! String == "OK"){
                stopLoading(self.view)
                arrDishList.removeObjectAtIndex(carousel.currentItemIndex)
                carousel.reloadData()
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
                //    arrDishList.addObject(dict.objectForKey("result") as! NSArray)
                if((dict.objectForKey("result")) != nil){
                let arr = dict.objectForKey("result") as! NSMutableArray
                for(var index : Int = 0; index < arr.count; index += 1){
                    arrDishList.addObject(arr.objectAtIndex(index))
                }
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
            stopLoading1(self.view)
            
            self.carousel.reloadData()
            
        }
        
        if(arrDishList.count > 0){
            navigationItem.rightBarButtonItem?.enabled = true
            lblNoDish.hidden = true
        }
        else{
            navigationItem.rightBarButtonItem?.enabled = false
            lblNoDish.hidden = false
        }


    //    carousel.scrollToItemAtIndex(selectedProfileIndex, animated: false)
    }
    
    func serviceFailedWitherror(error : NSError){
        stopLoading(self.view)
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }

    
    //MARK:- CarousalDelegates
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int
    {
        return arrDishList.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView
    {
        var itemView: UIView
        //create new view if no view is available for recycling
        if (view == nil)
        {
            //don't do anything specific to the index within
            if(UIScreen.mainScreen().bounds.size.height < 570){
                itemView = UIView(frame:CGRect(x:0, y:0, width:self.view.frame.size.width, height:carousel.frame.size.height))
                itemView.contentMode = .Top
            }
            else{
                itemView = UIView(frame:CGRect(x:0, y:0, width:self.view.frame.size.width, height:carousel.frame.size.height))
                itemView.contentMode = .Center
            }
            self.addSubViewsOnCarousal(index,itemView: itemView)
        }
        else
        {
            //get a reference to the label in the recycled view
            itemView = view!;
            self.addSubViewsOnCarousal(index,itemView: itemView)
        }
        
        return itemView
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
        if (option == .Spacing)
        {
            return value * 1.05
        }
        return value
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
        if(comingFrom == "Profile"){
            if(carousel.currentItemIndex == arrDishList.count-2){
                if(arrDishList.count > 9){
            dispatch_async(dispatch_get_main_queue()) {
            self.webMoreCards()
            }
                }
                else{
                    searchDishCity = ""
                }
            }
            else{
                searchDishCity = ""
            }
        }
        else if(comingFrom == "HomeDish"){
            if(carousel.currentItemIndex == arrDishList.count-2){
                if(arrDishList.count > 9){
                    dispatch_async(dispatch_get_main_queue()) {
                        self.webMoreCards()
                    }
                }
                else{
                    searchDishCity = ""
                }
            }
            else{
               // searchDishCity = ""
            }
        }
        if(carousel.currentItemIndex != 0){
            btnNext.hidden = true
        }
        else{
            //   btnNext.hidden = false
        }
    }
    
    
    //MARK:- nextCarousalIndex
    
    func openNext(){
        carousel.scrollToItemAtIndex(carousel.currentItemIndex + 1, animated: true)
        btnNext.hidden = true
    }
    
//    func carousel(carousel: iCarousel, didSelectItemAtIndex index: Int) {
//        postIdOpenPost = (arrDishList.objectAtIndex(index).objectForKey("id") as? String)!
//        
//        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("OpenPostVC") as! OpenPostViewController;
//        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
//    }
    
    
    //MARK:- AddSubViewsOnCarousal
    
    func addSubViewsOnCarousal(index : Int, itemView : UIView){
       
        //MARK:- upperView
        let upperView = UIView()
        if(UIScreen.mainScreen().bounds.size.height < 570){
            upperView.frame = CGRectMake(0, 0, itemView.frame.size.width, 60)
        }
        else{
            upperView.frame = CGRectMake(0, 0, itemView.frame.size.width, 60)
        }
        
        upperView.backgroundColor = UIColor.whiteColor()
        itemView.addSubview(upperView)
        
        let tapDish = UITapGestureRecognizer(target: self, action: #selector(DishProfileViewController.dishNameTapped(_:)))
        tapDish.numberOfTapsRequired = 1
        upperView.tag = index
        upperView.addGestureRecognizer(tapDish)
        
        
            let imgView = UIImageView()
            imgView.frame = CGRectMake(0, upperView.frame.origin.y + upperView.frame.size.height, itemView.frame.size.width, itemView.frame.size.width)
            imgView.image = UIImage(named: "placeholder.png")
            imgView.userInteractionEnabled = true
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2), dispatch_get_main_queue()) {
             //   loadImageAndCache(imgView,url: arrDishList.objectAtIndex(index).objectForKey("postImage") as! String)
                imgView.hnk_setImageFromURL(NSURL(string: (arrDishList.objectAtIndex(index).objectForKey("postImage") as! String))!)
            }
            itemView.addSubview(imgView)
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(DishProfileViewController.doubleTabMethod(_:)))
            tap.numberOfTapsRequired = 2
            imgView.tag = index
            imgView.addGestureRecognizer(tap)
            
            self.baseStar = UIView()
            self.baseStar?.frame = CGRectMake(0, imgView.frame.origin.y + imgView.frame.size.height - 40, imgView.frame.size.height, 40)
            itemView.addSubview(self.baseStar!)
            self.baseStar?.backgroundColor = UIColor.clearColor()
            
            let imageView = UIImageView()
            imageView.frame = CGRectMake(0, 0, (self.baseStar?.frame.size.width)!, 40)
            imageView.image = UIImage(named: "Untitled-1.png")
            self.baseStar?.addSubview(imageView)
            
            self.star1 = UIImageView()
            self.star1?.frame = CGRectMake(10, 7, 28, 28)
            self.baseStar?.addSubview(self.star1!)
            
            self.star2 = UIImageView()
            self.star2?.frame = CGRectMake(42, 7, 28, 28)
            self.baseStar?.addSubview(self.star2!)
            
            self.star3 = UIImageView()
            self.star3?.frame = CGRectMake(74, 7, 28, 28)
            self.baseStar?.addSubview(self.star3!)
            
            self.star4 = UIImageView()
            self.star4?.frame = CGRectMake(106, 7, 28, 28)
            self.baseStar?.addSubview(self.star4!)
            
            self.star5 = UIImageView()
            self.star5?.frame = CGRectMake(138, 7, 28, 28)
            self.baseStar?.addSubview(self.star5!)
            
            
            let rateValue = arrDishList.objectAtIndex(index).objectForKey("rating") as! String
            if(rateValue == "1"){
                self.star1?.image = UIImage(named: "stars-02.png")
                self.star2?.image = UIImage(named: "stars-01.png")
                self.star3?.image = UIImage(named: "stars-01.png")
                self.star4?.image = UIImage(named: "stars-01.png")
                self.star5?.image = UIImage(named: "stars-01.png")
            }
            else if(rateValue == "2"){
                self.star1?.image = UIImage(named: "stars-02.png")
                self.star2?.image = UIImage(named: "stars-02.png")
                self.star3?.image = UIImage(named: "stars-01.png")
                self.star4?.image = UIImage(named: "stars-01.png")
                self.star5?.image = UIImage(named: "stars-01.png")
            }
            else if(rateValue == "3"){
                self.star1?.image = UIImage(named: "stars-02.png")
                self.star2?.image = UIImage(named: "stars-02.png")
                self.star3?.image = UIImage(named: "stars-02.png")
                self.star4?.image = UIImage(named: "stars-01.png")
                self.star5?.image = UIImage(named: "stars-01.png")
            }
            else if(rateValue == "4"){
                self.star1?.image = UIImage(named: "stars-02.png")
                self.star2?.image = UIImage(named: "stars-02.png")
                self.star3?.image = UIImage(named: "stars-02.png")
                self.star4?.image = UIImage(named: "stars-02.png")
                self.star5?.image = UIImage(named: "stars-01.png")
            }
            else if(rateValue == "5"){
                self.star1?.image = UIImage(named: "stars-02.png")
                self.star2?.image = UIImage(named: "stars-02.png")
                self.star3?.image = UIImage(named: "stars-02.png")
                self.star4?.image = UIImage(named: "stars-02.png")
                self.star5?.image = UIImage(named: "stars-02.png")
            }
            
            let footerView = UIView()
            footerView.frame = CGRectMake(0, imgView.frame.origin.y + imgView.frame.size.height, itemView.frame.size.width, 40)
            footerView.backgroundColor = UIColor.whiteColor()
            itemView.addSubview(footerView)
            
            //upperView's Subview
        
        let lblDishName = UILabel()
        lblDishName.frame = CGRectMake(0, 0, self.view.frame.size.width, 25)
        lblDishName.font = UIFont(name: fontName, size: 20)
        lblDishName.textAlignment = NSTextAlignment.Center
        lblDishName.text = arrDishList.objectAtIndex(index).objectForKey("dishName") as? String
        lblDishName.userInteractionEnabled = true
        lblDishName.textColor = UIColor.blackColor()
        lblDishName.tag = index
        upperView.addSubview(lblDishName)
        
        let lengthRestaurantname = (arrDishList.objectAtIndex(index).objectForKey("restaurantName") as! String).characters.count
        
        let lblRestaurantName = UILabel()
        lblRestaurantName.frame = CGRectMake(0, lblDishName.frame.origin.y + lblDishName.frame.size.height - 4, self.view.frame.size.width, 20)
        lblRestaurantName.font = UIFont(name: fontName, size: 15)
        lblRestaurantName.textAlignment = NSTextAlignment.Center
     //   print(arrDishList)
        if(lengthRestaurantname > 0){
        lblRestaurantName.text = String(format: "at %@", (arrDishList.objectAtIndex(index).objectForKey("restaurantName") as? String)!)
        }
        
        lblRestaurantName.textColor = UIColor.grayColor()
        lblRestaurantName.tag = index
        upperView.addSubview(lblRestaurantName)
        
        let lblUserName = UILabel()
        if(lengthRestaurantname > 0){
           lblUserName.frame = CGRectMake(0, lblRestaurantName.frame.origin.y + lblRestaurantName.frame.size.height, self.view.frame.size.width, 15)
        }
        else{
            lblUserName.frame = CGRectMake(0, lblDishName.frame.origin.y + lblDishName.frame.size.height, self.view.frame.size.width, 15)
        }
       
        lblUserName.textAlignment = NSTextAlignment.Center
        lblUserName.font = UIFont(name: fontName, size: 12)
        lblUserName.text = String(format: "by %@", (arrDishList.objectAtIndex(index).objectForKey("userName") as? String)!)
       
        lblUserName.textColor = UIColor.grayColor()
        lblUserName.tag = index
        upperView.addSubview(lblUserName)

//
            let timeLabel = UILabel()
            timeLabel.frame = CGRectMake(upperView.frame.size.width - 30, 0, 30, 50)
            timeLabel.text = differenceDate((arrDishList.objectAtIndex(index).objectForKey("createDate") as? String)!)
            timeLabel.textColor = UIColor.grayColor()
            timeLabel.font = UIFont(name: fontName, size: 12)
            upperView.addSubview(timeLabel)
        
            //FooterSubview
            
            self.likeLabel = UIImageView()
            self.likeLabel!.frame = CGRectMake(10, 10, 30, 30)
            if(self.arrLikeList.objectAtIndex(index) as! String == "0"){
                self.likeLabel!.image = UIImage(named: "Like Heart.png")
            }
            else{
                self.likeLabel!.image = UIImage(named: "Heart Liked.png")
            }
            self.likeLabel!.userInteractionEnabled = true
            footerView.addSubview(self.likeLabel!)
            
            let tap1 = UITapGestureRecognizer(target: self, action: #selector(DishProfileViewController.singleTapLike(_:)))
            tap1.numberOfTapsRequired = 1
            self.likeLabel!.tag = index
            self.likeLabel!.addGestureRecognizer(tap1)
            
            let numbrLike = UILabel()
            numbrLike.frame = CGRectMake(50, 14, 22, 22)
            numbrLike.tag = 1099
            numbrLike.text = arrDishList.objectAtIndex(index).objectForKey("likeCount") as? String
            numbrLike.font = UIFont(name: fontName, size: 18)
            footerView.addSubview(numbrLike)
            
            let favLabel = UIImageView()
            favLabel.frame = CGRectMake(85, 10, 30, 30)
            if(self.arrFavList.objectAtIndex(index) as! String == "0"){
                favLabel.image = UIImage(named: "bookmark (1).png")
            }
            else{
                favLabel.image = UIImage(named: "bookmark_red.png")
            }
            favLabel.userInteractionEnabled = true
            footerView.addSubview(favLabel)
            
            let tap2 = UITapGestureRecognizer(target: self, action: #selector(DishProfileViewController.singleTapFav(_:)))
            tap2.numberOfTapsRequired = 1
            favLabel.tag = index
            favLabel.addGestureRecognizer(tap2)
            
            let numbrFav = UILabel()
            numbrFav.frame = CGRectMake(122, 12, 28, 28)
            numbrFav.tag = 1029
            numbrFav.text = arrDishList.objectAtIndex(index).objectForKey("bookmarkCount") as? String
            numbrFav.font = UIFont(name: fontName, size: 20)
            footerView.addSubview(numbrFav)
            
            let openPostImage = UIImageView()
            openPostImage.frame = CGRectMake(160, 10, 30, 30)
            openPostImage.image = UIImage(named: "Comment Message.png")
            openPostImage.userInteractionEnabled = true
            footerView.addSubview(openPostImage)
            openPostImage.alpha = 1.0
        
        let numbrcom = UILabel()
        numbrcom.frame = CGRectMake(200, 12, 28, 28)
        numbrcom.tag = 1030
        numbrcom.text = arrDishList.objectAtIndex(index).objectForKey("commentCount") as? String
        numbrcom.font = UIFont(name: fontName, size: 20)
        footerView.addSubview(numbrcom)
        
          //  if((arrDishList.objectAtIndex(index).objectForKey("tip") as! String).characters.count < 1){
          //      openPostImage.hidden = true
         //   }
            
//            let tap3 = UITapGestureRecognizer(target: self, action: "singleTapOpenPost:")
//            tap3.numberOfTapsRequired = 1
//            openPostImage.tag = index
//            openPostImage.addGestureRecognizer(tap3)
        
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.addTarget(self, action: #selector(DishProfileViewController.singleTapOpenPost(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        button.tag = index
        button.frame = CGRectMake(145, 0, 50, 50)
        footerView.addSubview(button)
        
            if(comingFrom == "Restaurant"){
                
                let button: UIButton = UIButton(type: UIButtonType.Custom)
                button.setImage(UIImage(named: "more-3.png"), forState: UIControlState.Normal)
                button.addTarget(self, action: #selector(DishProfileViewController.reportDeleteMethod(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                button.frame = CGRectMake(footerView.frame.size.width - 30, 10, 5, 20)
                button.alpha = 0.7
                
                footerView.addSubview(button)
                
                let button1: UIButton = UIButton(type: UIButtonType.Custom)
                
                button1.addTarget(self, action: #selector(DishProfileViewController.reportDeleteMethod(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                button1.frame = CGRectMake(footerView.frame.size.width - 50, 0, 50, 40)
                
                footerView.addSubview(button1)
            }
            else{
                
            if(arrDishList.objectAtIndex(index).objectForKey("restaurantDistance")?.floatValue != nil){
            let distanceLabel = UILabel()
            distanceLabel.frame = CGRectMake(footerView.frame.size.width - 70, 0, 70, 40)
            var distnce = arrDishList.objectAtIndex(index).objectForKey("restaurantDistance")?.floatValue
            distnce = distnce! / 1000
            distanceLabel.text = String(format: "%.2f KM", distnce!)
            distanceLabel.textColor = UIColor.grayColor()
            distanceLabel.font = UIFont(name: fontName, size: 15)
            footerView.addSubview(distanceLabel)
                
                if(dictLocations.valueForKey("latitude") != nil){
                    distanceLabel.hidden = false
                }
                else{
                    distanceLabel.hidden = true
                }
                
            }
            }
    }

    //MARK:- Double Tab Method Of like
    
    func doubleTabMethod(sender : UITapGestureRecognizer){
        Flurry.logEvent("Like Button Tabbed")
        var methodName = String()
        if(imgLikeDubleTap == nil){
        imgLikeDubleTap = UIImageView()
        }
        self.imgLikeDubleTap?.frame = CGRectMake(160, 160, 0, 0)
        imgLikeDubleTap?.image = UIImage(named: "heart.png")
        
        imgLikeDubleTap?.backgroundColor = UIColor.clearColor()
        sender.view?.addSubview((imgLikeDubleTap)!)
        
        UIView.animateWithDuration(0.2, animations: {
            self.imgLikeDubleTap?.hidden = false
            self.imgLikeDubleTap?.frame = CGRectMake(70, 70, (sender.view?.frame.size.width)! - 140, (sender.view?.frame.size.height)! - 140)
        })
        
        if(arrLikeList.objectAtIndex((sender.view?.tag)!) as! String == "0"){
            
            carouselIndex = (sender.view?.tag)!
            
            let imageName = UIImage(named: "Like Heart.png")
            
            let carouselView = carousel.currentItemView! as UIView
            
            for view in carouselView.subviews {
                if view.isKindOfClass(UIView) {
                    
                    if(view.frame.origin.y > 300){
                        for view1 in view.subviews {
                            if view1.isKindOfClass(UIImageView) {
                                let imgData1 = UIImageJPEGRepresentation((view1 as! UIImageView).image!, 0)
                                let imgData2 = UIImageJPEGRepresentation(imageName!, 0)
                                
                                if(imgData1 == imgData2 ){
                                    (view1 as! UIImageView).image = UIImage(named: "Heart Liked.png")
                                }
                            }
                            else if view1.isKindOfClass(UILabel){
                                if((view1 as! UILabel).tag == 1099){
                                    (view1 as! UILabel).text = String(format: "%d", Int(((view1 as! UILabel).text!))! + 1)
                                }
                            }
                        }
                    }
                }
            }
            
            methodName = addlikeMethod
            buttonLike = UIImageView()
            buttonLike?.tag = (sender.view?.tag)!
            let url = String(format: "%@%@%@", baseUrl, controllerLike, methodName)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let postId = arrDishList.objectAtIndex(sender.view!.tag).objectForKey("id")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(postId!, forKey: "postId")
       //     webServiceCallingPost(url, parameters: params)
            webServiceCallingPost(url, parameters: params)
            delegate = self
        }
        else{
            self.performSelector(#selector(DishProfileViewController.removeDubleTapImage), withObject: nil, afterDelay: 1.0)
        }
    }
    
    func removeDubleTapImage(){
        UIView.animateWithDuration(0.5, animations: {
            //   self.imgLikeDubleTap?.frame = CGRectMake(160, 160, 0, 0)
            self.imgLikeDubleTap?.hidden = true
            
            self.imgLikeDubleTap?.removeFromSuperview()
        })
    }
    
    func singleTapLike(sender : UITapGestureRecognizer){
        //  showLoader(self.view)
        
        Flurry.logEvent("Like Button Tabbed")
        buttonLike = UIImageView()
        buttonLike = sender.view as? UIImageView
        
        carouselIndex = (sender.view?.tag)!
        
        
        let carouselView = carousel.currentItemView! as UIView
        
        for view in carouselView.subviews {
            if view.isKindOfClass(UIView) {
                
                if(view.frame.origin.y > 300){
                    for view1 in view.subviews {
                        if view1.isKindOfClass(UILabel){
                            if((view1 as! UILabel).tag == 1099){
                                if(arrLikeList.objectAtIndex(sender.view!.tag) as! String == "0"){
                                    (view1 as! UILabel).text = String(format: "%d", Int(((view1 as! UILabel).text!))! + 1)
                                }
                                else{
                                    (view1 as! UILabel).text = String(format: "%d", Int(((view1 as! UILabel).text!))! - 1)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        var methodName = String()
        if(arrLikeList.objectAtIndex(sender.view!.tag) as! String == "0"){
            methodName = addlikeMethod
            (sender.view as! UIImageView).image = UIImage(named: "Heart Liked.png")
        }
        else{
            methodName = deleteLikeMethod
            (sender.view as! UIImageView).image = UIImage(named: "Like Heart.png")
        }
        
        let url = String(format: "%@%@%@", baseUrl, controllerLike, methodName)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let postId = arrDishList.objectAtIndex(sender.view!.tag).objectForKey("id")
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(postId!, forKey: "postId")
        
   //     webServiceCallingPost(url, parameters: params)
        webServiceCallingPost(url, parameters: params)
        delegate = self
    }
    
    func singleTapFav(sender : UITapGestureRecognizer){
        Flurry.logEvent("Bookmark Tabbed")
        buttonFav = UIImageView()
        buttonFav = sender.view as? UIImageView
        
        carouselIndex = (sender.view?.tag)!
        
        let carouselView = carousel.currentItemView! as UIView
        
        for view in carouselView.subviews {
            if view.isKindOfClass(UIView) {
                
                if(view.frame.origin.y > 300){
                    for view1 in view.subviews {
                        if view1.isKindOfClass(UILabel){
                            if((view1 as! UILabel).tag == 1029){
                                if(arrFavList.objectAtIndex(sender.view!.tag) as! String == "0"){
                                    (view1 as! UILabel).text = String(format: "%d", Int(((view1 as! UILabel).text!))! + 1)
                                }
                                else{
                                    (view1 as! UILabel).text = String(format: "%d", Int(((view1 as! UILabel).text!))! - 1)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        var methodName = String()
        if(arrFavList.objectAtIndex(sender.view!.tag) as! String == "0"){
            methodName = addlikeMethod
            buttonFav?.image = UIImage(named: "bookmark_red.png")
        }
        else{
            methodName = deleteLikeMethod
            buttonFav?.image = UIImage(named: "bookmark (1).png")
        }
        let url = String(format: "%@%@%@", baseUrl, controllerBookmark, methodName)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let postId = arrDishList.objectAtIndex(sender.view!.tag).objectForKey("id")
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(postId!, forKey: "postId")
        
    //    webServiceCallingPost(url, parameters: params)
        webServiceCallingPost(url, parameters: params)
        delegate = self
    }
    
    func singleTapOpenPost(sender : UIButton){
        postIdOpenPost = (arrDishList.objectAtIndex(sender.tag).objectForKey("id") as? String)!
        
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("OpenPost") as! OpenPostViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    func dishNameTapped(sender : UITapGestureRecognizer){
        if(comingFrom == "HomeDish"){
            if((arrDishList.objectAtIndex(sender.view!.tag).objectForKey("restaurantName") as? String)?.characters.count > 0){
            comingToDish = (arrDishList.objectAtIndex(sender.view!.tag).objectForKey("restaurantName") as? String)!
            restaurantProfileId = (arrDishList.objectAtIndex(sender.view!.tag).objectForKey("checkedInRestaurantId") as? String)!
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("RestaurantProfile") as! RestaurantProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            }
        }
        else{
        self.pageList = 0
        
        selectedProfileIndex = 0
        selectedDishHome = arrDishList.objectAtIndex(sender.view!.tag).objectForKey("dishName") as! String
        comingToDish =  selectedDishHome
        // self.title = comingToDish
        
        comingFrom = "HomeDish"
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("DishLink") as! DishLinkViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
    }
    
    //MARK:-
    
    func reportDeleteMethod(sender : UIButton){
        
        let dict = (NSUserDefaults.standardUserDefaults().objectForKey("LoginDetails") as? NSMutableDictionary)!
        if(dict.objectForKey("profile")?.objectForKey("userName") as? String == arrDishList.objectAtIndex(carousel.currentItemIndex).objectForKey("userName") as? String){
            selectedReport = "delete"
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Delete")
            
            actionSheet.showInView(self.view)
        }
        else{
            selectedReport = "report"
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Report")
            
            actionSheet.showInView(self.view)
        }
        
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int)
    {
        if(selectedReport == "delete"){
            
            switch (buttonIndex){
                
            case 0:
                print("Cancel")
            case 1:
                print("delete")
                
             //   self.webServiceForDelete()
                
                let alertController = UIAlertController(title: "", message: "", preferredStyle: .Alert)
                let attrubuted = NSMutableAttributedString(string: "Are you sure ?")
                attrubuted.addAttribute(NSFontAttributeName, value: UIFont(name: fontBold, size: 17)!, range: NSMakeRange(0, 14))
                alertController.setValue(attrubuted, forKey: "attributedTitle")
                
                // Create the actions
                let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                   
                    Flurry.logEvent("Delete post Tapped")
                    
                    showLoader(self.view)
                    self.webServiceForDelete()
                    
                }
                let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) {
                    UIAlertAction in
                    
                }
                
                // Add the actions
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                
                // Present the controller
                self.presentViewController(alertController, animated: true, completion: nil)
                
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
                
                let alertController = UIAlertController(title: "", message: "", preferredStyle: .Alert)
                let attrubuted = NSMutableAttributedString(string: "Are you sure ?")
                attrubuted.addAttribute(NSFontAttributeName, value: UIFont(name: fontBold, size: 17)!, range: NSMakeRange(0, 14))
                alertController.setValue(attrubuted, forKey: "attributedTitle")
                
                // Create the actions
                let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    
                    
                }
                let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) {
                    UIAlertAction in
                    
                }
                
                // Add the actions
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                
                // Present the controller
                self.presentViewController(alertController, animated: true, completion: nil)
                
             //   self.webServiceForReport()
            default:
                print("Default")
                //Some code here..
                
            }
        }
    }

    //MARK:- TTTAttributedLabelDelegates
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if(url == NSURL(string: "action://users/\("userName")")){
           
            isUserInfo = false
                            postDictHome = arrDishList.objectAtIndex(label.tag) as! NSDictionary
             comingToDish = (postDictHome.objectForKey("userName") as? String)!
                            openProfileId = (postDictHome.objectForKey("userId") as? String)!
                            postImageOrgnol = (postDictHome.objectForKey("userImage") as? String)!
                            postImagethumb = (postDictHome.objectForKey("userThumb") as? String)!
                            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfile") as! UserProfileViewController;
                            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);

        }
            
        else if(url == NSURL(string: "action://dish/\("dishName")")){
            self.pageList = 0
            
                            selectedProfileIndex = 0
                            selectedDishHome = arrDishList.objectAtIndex(label.tag).objectForKey("dishName") as! String
                            comingToDish =  selectedDishHome
                           // self.title = comingToDish
            
                            comingFrom = "HomeDish"
                                let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("DishLink") as! DishLinkViewController;
                                self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
                          //  self.webCallDiscoverDish()
        }
            
        else if(url == NSURL(string: "action://restaurant/\("restaurantName")")){
            comingToDish = (arrDishList.objectAtIndex(label.tag).objectForKey("restaurantName") as? String)!
            restaurantProfileId = (arrDishList.objectAtIndex(label.tag).objectForKey("checkedInRestaurantId") as? String)!
                            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("RestaurantProfile") as! RestaurantProfileViewController;
                            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.locationInView(conectivityMsg)
            // do something with your currentPoint
            if(isConnectedToNetwork()){
                conectivityMsg.removeFromSuperview()
                dispatch_async(dispatch_get_main_queue()) {
                    if(comingFrom.isEqual("HomeDish")){
//                        self.pageList = 0
//                        self.webCallDiscoverDish()
                    }
                }
            }
        }
        
        for var view : UIView in self.view.subviews {
            if(view == conectivityMsg){
                if(isConnectedToNetwork()){
                    conectivityMsg.removeFromSuperview()
                    dispatch_async(dispatch_get_main_queue()) {
                        
                       
                        
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
