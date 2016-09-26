//
//  DiscoverViewController.swift
//  FoodTalk
//
//  Created by Ashish on 13/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit
import CoreLocation

var arrDishList = NSMutableArray()
var comingFrom = String()
var selectedProfileIndex : Int = 0

class DiscoverViewController: UIViewController, iCarouselDataSource, iCarouselDelegate,  UITabBarControllerDelegate, UIActionSheetDelegate, CLLocationManagerDelegate, TTTAttributedLabelDelegate, UIGestureRecognizerDelegate, WebServiceCallingDelegate{
    
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
    
    var buttonLike : UIImageView?
    
    @IBOutlet var backButton : UIButton?
    var arrDiscoverValues : NSMutableArray = []
    var arrLikeList : NSMutableArray = []
    var arrFavList : NSMutableArray = []
    
    var imgLikeDubleTap : UIImageView?
    var carouselIndex : Int = 0
    var buttonFav : UIImageView?
    
    var likeLabel : UIImageView?
    
    var selectedReport = String()
    
    var locationManager : CLLocationManager?
    var currentLocation : CLLocation?
    
    var locationVal : NSMutableDictionary?
    var callInt : Int = 0
    
    var loaderView  = UIView()
    var searchingLabel = UILabel()
    var activityIndicator1 = UIActivityIndicatorView()
    var btnSettings = UIButton()
    
    var btnNext = UIButton()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
   delegate = self
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        
        self.tabBarController?.tabBar.userInteractionEnabled = false
        
        
        Flurry.logEvent("DiscoverScreen")
        
        selectedTabBarIndex = 1
        
        loaderView.frame = CGRectMake(0, 194, self.view.frame.size.width, 100)
        self.view.addSubview(loaderView)
        
        let imgView = UIImageView()
        imgView.frame = CGRectMake(self.view.frame.size.width/2 - 15, 0, 30, 30)
        imgView.image = UIImage(named: "DiscoverTap.png")
        loaderView.addSubview(imgView)
        
        searchingLabel = UILabel()
        searchingLabel.frame = CGRectMake(0, 32, self.view.frame.size.width, 60)
        searchingLabel.numberOfLines = 0
        searchingLabel.textAlignment = NSTextAlignment.Center
        searchingLabel.text = "Finding the best dishes around you."
        searchingLabel.textColor = UIColor.grayColor()
        searchingLabel.font = UIFont(name: fontBold, size: 14)
        loaderView.addSubview(searchingLabel)
        
                callInt = 0
                pageList = 0
                arrDiscoverValues = NSMutableArray()
                arrLikeList = NSMutableArray()
                arrFavList = NSMutableArray()
                locationVal = NSMutableDictionary()
        
        activityIndicator1 = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        activityIndicator1.frame = CGRect(x: self.view.frame.size.width/2 - 15, y: 74, width: 30, height: 30)
        activityIndicator1.startAnimating()
        loaderView.addSubview(activityIndicator1)
        
        loaderView.hidden = false
        
        loaderView.backgroundColor = UIColor.clearColor()
        
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        carousel.type = .Linear
        carousel.pagingEnabled = true
        carousel.scrollSpeed = 1.0
        
        //       self.title = "Discover"
        
        
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "moreWhite.png"), forState: UIControlState.Normal)
        button.addTarget(self, action: #selector(DiscoverViewController.reportDeleteMethod(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRectMake(0, 0, 25, 30)
        
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        barButton.enabled = false
         
        let tap = UITapGestureRecognizer(target: self, action: #selector(DiscoverViewController.handleTap(_:)))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        
    }

    
    override func viewWillAppear(animated: Bool) {
        callInt = 0
        self.tabBarController?.delegate = self
        self.navigationController?.navigationBarHidden = false
        self.navigationItem.backBarButtonItem = nil
    //    navigationItem.rightBarButtonItem?.enabled = true
        searchingLabel.text = "Finding the best dishes around you."
        activityIndicator1.startAnimating()
        
        self.addLocationManager()
        
        btnSettings.frame = CGRectMake(30, loaderView.frame.origin.y + loaderView.frame.size.height + 10, self.view.frame.size.width - 60, 30)
        btnSettings.setTitle("Go to Settings", forState: UIControlState.Normal)
        btnSettings.addTarget(self, action: #selector(CheckInViewController.openSettings), forControlEvents: UIControlEvents.TouchUpInside)
        btnSettings.backgroundColor = UIColor.blackColor()
        btnSettings.layer.cornerRadius = 2
        btnSettings.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        self.view.addSubview(btnSettings)
        btnSettings.hidden = true
        
        btnNext.frame = CGRectMake(self.view.frame.size.width - 30, self.view.frame.size.height/2 - 25, 30, 50)
        btnNext.setImage(UIImage(named : "next icon.png"), forState: UIControlState.Normal)
        btnNext.addTarget(self, action: #selector(DiscoverViewController.openNext), forControlEvents: UIControlEvents.TouchUpInside)
        btnNext.backgroundColor = UIColor.grayColor()
        btnNext.hidden = false
        self.view.addSubview(btnNext)
    }
    
    override func viewWillDisappear(animated: Bool) {
        cancelRequest()
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.Default
    }
    
    func backPressed(){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK:- open Settings Method
    
    func openSettings(){
        if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    //MARK:- nextCarousalIndex
    
    func openNext(){
        carousel.scrollToItemAtIndex(carousel.currentItemIndex + 1, animated: true)
        btnNext.hidden = true
    }
    
    //MARK:- CarousalDelegates
    
    func numberOfItemsInCarousel(carousel: iCarousel) -> Int
    {
        return arrDiscoverValues.count
    }
    
    func carousel(carousel: iCarousel, viewForItemAtIndex index: Int, reusingView view: UIView?) -> UIView
    {
        var itemView: UIView
        //create new view if no view is available for recycling
        if (view == nil)
        {
            //don't do anything specific to the index within
            
            if(UIScreen.mainScreen().bounds.size.height < 570){
              itemView = UIView(frame:CGRect(x:0, y:0, width:carousel.frame.size.width, height:carousel.frame.size.height))
              itemView.contentMode = .Top
            }
            else{
                itemView = UIView(frame:CGRect(x:0, y:0, width:carousel.frame.size.width, height:carousel.frame.size.height))
                itemView.contentMode = .Center
            }
            if(arrDiscoverValues.count > 0){
            self.addSubViewsOnCarousal(index,itemView: itemView)
            }
        }
        else
        {
            //get a reference to the label in the recycled view
            itemView = view!;
            if(arrDiscoverValues.count > 0){
            self.addSubViewsOnCarousal(index,itemView: itemView)
            }
        }
        
        
        return itemView
    }
    
    func carousel(carousel: iCarousel, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat
    {
        if (option == .Spacing)
        {
            return value * 1.03
        }
        return value
    }
    
    func carouselCurrentItemIndexDidChange(carousel: iCarousel) {
        
            if(arrDiscoverValues.count > 0){
                if(carousel.currentItemIndex != 0){
                    btnNext.hidden = true
                }
                else{
                 //   btnNext.hidden = false
                }
           if(carousel.currentItemIndex == arrDiscoverValues.count-1){
            dispatch_async(dispatch_get_main_queue()) {
            self.webCallDiscover()
            }
                }
          }
    }
    

    //MARK:- AddSubViewsOnCarousal
    
    func addSubViewsOnCarousal(index : Int, itemView : UIView){
        if(arrDiscoverValues.count > 0){
         
            //MARK:- upperView
        let upperView = UIView()
            if(UIScreen.mainScreen().bounds.size.height < 570){
        upperView.frame = CGRectMake(0, 0, itemView.frame.size.width, 65)
            }
            else{
         upperView.frame = CGRectMake(0, 0, itemView.frame.size.width, 80)
            }
            
        upperView.backgroundColor = UIColor.whiteColor()
        itemView.addSubview(upperView)
            
         let lblDish = UILabel()
            if(UIScreen.mainScreen().bounds.size.height < 570){
            lblDish.frame = CGRectMake(0, 3, itemView.frame.size.width, 20)
            }
            else{
            lblDish.frame = CGRectMake(0, 8, itemView.frame.size.width, 20)
            }
            lblDish.text = self.arrDiscoverValues.objectAtIndex(index).objectForKey("dishName") as? String
            lblDish.textAlignment = NSTextAlignment.Center
            lblDish.font = UIFont(name: fontBold, size : 18)
            lblDish.userInteractionEnabled = true
            lblDish.tag = index
            lblDish.textColor = UIColor(red: 20/255, green: 29/255, blue: 47/255, alpha: 1.0)
            itemView.addSubview(lblDish)
            
            let tapDish = UITapGestureRecognizer(target: self, action: #selector(DiscoverViewController.restaurantOpen(_:)))
            tapDish.numberOfTapsRequired = 1
            lblDish.tag = index
            lblDish.addGestureRecognizer(tapDish)
            
        let lblRestaurant = UILabel()
            lblRestaurant.frame = CGRectMake(0, upperView.frame.size.height/2 - 8, itemView.frame.size.width, 17)
            lblRestaurant.text = self.arrDiscoverValues.objectAtIndex(index).objectForKey("restaurantName") as? String
            lblRestaurant.tag = index
            lblRestaurant.userInteractionEnabled = true
            lblRestaurant.textAlignment = NSTextAlignment.Center
            lblRestaurant.font = UIFont(name: fontName, size : 15)
            lblRestaurant.textColor = UIColor(red: 20/255, green: 29/255, blue: 47/255, alpha: 1.0)
            itemView.addSubview(lblRestaurant)
            
            let tapRest = UITapGestureRecognizer(target: self, action: #selector(DiscoverViewController.restaurantOpen(_:)))
            tapRest.numberOfTapsRequired = 1
            lblRestaurant.tag = index
            lblRestaurant.addGestureRecognizer(tapRest)
            
            var distnce = self.arrDiscoverValues.objectAtIndex(index).objectForKey("restaurantDistance")?.floatValue
            distnce = distnce! / 1000
         //   distanceLabel.text = String(format: "%.2f KM", distnce!)
            
        let lblNumbers = UILabel()
            lblNumbers.frame = CGRectMake(0, upperView.frame.size.height - 25, itemView.frame.size.width, 17)
            lblNumbers.text = String(format: "%@ Likes | %.2f KM", (self.arrDiscoverValues.objectAtIndex(index).objectForKey("likeCount") as? String)!, distnce!)
            lblNumbers.textAlignment = NSTextAlignment.Center
            lblNumbers.font = UIFont(name: fontName, size : 13)
            lblNumbers.textColor = UIColor.grayColor()
            itemView.addSubview(lblNumbers)
        
        let imgView = UIImageView()
        imgView.frame = CGRectMake(0, upperView.frame.origin.y + upperView.frame.size.height, itemView.frame.size.width, itemView.frame.size.width)
        imgView.image = UIImage(named: "placeholder.png")
        imgView.userInteractionEnabled = true
        dispatch_async(dispatch_get_main_queue()) {
        if(self.arrDiscoverValues.count > 0){
            imgView.hnk_setImageFromURL(NSURL(string: self.arrDiscoverValues.objectAtIndex(index).objectForKey("postImage") as! String)!)
            }
            }
        itemView.addSubview(imgView)
            
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(DiscoverViewController.doubleTabMethod(_:)))
            tap.numberOfTapsRequired = 2
            imgView.tag = index
            imgView.addGestureRecognizer(tap)
            
                self.baseStar = UIView()
                self.baseStar?.frame = CGRectMake(0, imgView.frame.origin.y + imgView.frame.size.height - 60, imgView.frame.size.height, 50)
                itemView.addSubview(self.baseStar!)
                self.baseStar?.backgroundColor = UIColor.clearColor()
            
            let imageView = UIImageView()
            imageView.frame = CGRectMake(0, 0, (self.baseStar?.frame.size.width)!, 60)
            imageView.image = UIImage(named: "Untitled-1.png")
            self.baseStar?.addSubview(imageView)
            
                self.star1 = UIImageView()
                self.star1?.frame = CGRectMake(10, 23, 28, 28)
                self.baseStar?.addSubview(self.star1!)

                self.star2 = UIImageView()
                self.star2?.frame = CGRectMake(42, 23, 28, 28)
                self.baseStar?.addSubview(self.star2!)

                self.star3 = UIImageView()
                self.star3?.frame = CGRectMake(74, 23, 28, 28)
                self.baseStar?.addSubview(self.star3!)

                self.star4 = UIImageView()
                self.star4?.frame = CGRectMake(106, 23, 28, 28)
                self.baseStar?.addSubview(self.star4!)

                self.star5 = UIImageView()
                self.star5?.frame = CGRectMake(138, 23, 28, 28)
                self.baseStar?.addSubview(self.star5!)

            if(self.arrDiscoverValues.count > 0){
            let rateValue = self.arrDiscoverValues.objectAtIndex(index).objectForKey("rating") as! String
            if(rateValue == "1"){
                self.star1?.image = UIImage(named: "stars-01.png")
                self.star2?.image = UIImage(named: "stars-02.png")
                self.star3?.image = UIImage(named: "stars-02.png")
                self.star4?.image = UIImage(named: "stars-02.png")
                self.star5?.image = UIImage(named: "stars-02.png")
            }
            else if(rateValue == "2"){
                self.star1?.image = UIImage(named: "stars-01.png")
                self.star2?.image = UIImage(named: "stars-01.png")
                self.star3?.image = UIImage(named: "stars-02.png")
                self.star4?.image = UIImage(named: "stars-02.png")
                self.star5?.image = UIImage(named: "stars-02.png")
            }
            else if(rateValue == "3"){
                self.star1?.image = UIImage(named: "stars-01.png")
                self.star2?.image = UIImage(named: "stars-01.png")
                self.star3?.image = UIImage(named: "stars-01.png")
                self.star4?.image = UIImage(named: "stars-02.png")
                self.star5?.image = UIImage(named: "stars-02.png")
            }
            else if(rateValue == "4"){
                self.star1?.image = UIImage(named: "stars-01.png")
                self.star2?.image = UIImage(named: "stars-01.png")
                self.star3?.image = UIImage(named: "stars-01.png")
                self.star4?.image = UIImage(named: "stars-01.png")
                self.star5?.image = UIImage(named: "stars-02.png")
            }
            else if(rateValue == "5"){
                self.star1?.image = UIImage(named: "stars-01.png")
                self.star2?.image = UIImage(named: "stars-01.png")
                self.star3?.image = UIImage(named: "stars-01.png")
                self.star4?.image = UIImage(named: "stars-01.png")
                self.star5?.image = UIImage(named: "stars-01.png")
            }

            }
        let footerView = UIView()
        footerView.frame = CGRectMake(0, imgView.frame.origin.y + imgView.frame.size.height, itemView.frame.size.width, itemView.frame.size.height - (imgView.frame.origin.y + imgView.frame.size.height))
        footerView.backgroundColor = UIColor.whiteColor()
        itemView.addSubview(footerView)
        
        
        
        //MARK:- FooterSubview
        
            
        let openPostImage = UIImageView()
        openPostImage.frame = CGRectMake(itemView.frame.size.width/2 - 20,  footerView.frame.size.height/2 - 20, 40, 40)
        openPostImage.image = UIImage(named: "commentNew.png")
        openPostImage.userInteractionEnabled = true
        openPostImage.alpha = 1.0
        footerView.addSubview(openPostImage)
            
            
            let button: UIButton = UIButton(type: UIButtonType.Custom)
            button.addTarget(self, action: #selector(DiscoverViewController.singleTapOpenPost(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            button.tag = index
            button.frame = CGRectMake(itemView.frame.size.width/2 - 20, 10, 50, 50)
            footerView.addSubview(button)
      
            if(self.arrDiscoverValues.count > 0){
                self.likeLabel = UIImageView()
                self.likeLabel!.frame = CGRectMake(openPostImage.frame.origin.x / 2 - 20, footerView.frame.size.height/2 - 20, 40, 40)
                if(self.arrLikeList.objectAtIndex(index) as! String == "0"){
                    self.likeLabel!.image = UIImage(named: "likeNew.png")
                }
                else{
                    self.likeLabel!.image = UIImage(named: "LikePressed.png")
                }
                self.likeLabel!.userInteractionEnabled = true
                footerView.addSubview(self.likeLabel!)
                
                let tap1 = UITapGestureRecognizer(target: self, action: #selector(DiscoverViewController.singleTapLike(_:)))
                tap1.numberOfTapsRequired = 1
                self.likeLabel!.tag = index
                self.likeLabel!.addGestureRecognizer(tap1)
                
        
                let favLabel = UIImageView()
                favLabel.frame = CGRectMake((itemView.frame.size.width + openPostImage.frame.origin.x)/2 , footerView.frame.size.height/2 - 20, 40, 40)
                if(self.arrFavList.objectAtIndex(index) as! String == "0"){
                    favLabel.image = UIImage(named: "FavNew.png")
                }
                else{
                    favLabel.image = UIImage(named: "favPressed.png")
                }
                favLabel.userInteractionEnabled = true
                footerView.addSubview(favLabel)
                
                let tap2 = UITapGestureRecognizer(target: self, action: #selector(DiscoverViewController.singleTapFav(_:)))
                tap2.numberOfTapsRequired = 1
                favLabel.tag = index
                favLabel.addGestureRecognizer(tap2)
       
            }
        
        }
    }
    
    //MARK:- BAckCall
    
    @IBAction func backCall(sender : UIButton){
        arrDishList.removeAllObjects()
        self.webCallDiscover()
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
            arrLikeList.replaceObjectAtIndex((sender.view!.tag), withObject: "1")
            
            let imageName = UIImage(named: "likeNew.png")
            
            let carouselView = carousel.currentItemView! as UIView
            
            for view in carouselView.subviews {
                if view.isKindOfClass(UIView) {
                    
                    if(view.frame.origin.y > 300){
                        for view1 in view.subviews {
                            if view1.isKindOfClass(UIImageView) {
                            let imgData1 = UIImageJPEGRepresentation((view1 as! UIImageView).image!, 0)
                            let imgData2 = UIImageJPEGRepresentation(imageName!, 0)
                            
                            if(imgData1 == imgData2 ){
                                (view1 as! UIImageView).image = UIImage(named: "LikePressed.png")
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
            let postId = arrDiscoverValues.objectAtIndex(sender.view!.tag).objectForKey("id")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(postId!, forKey: "postId")
            webServiceCallingPost(url, parameters: params)
            
            delegate = self
        }
        else{
            self.performSelector(#selector(DiscoverViewController.removeDubleTapImage), withObject: nil, afterDelay: 1.0)
        }
    }
    
    func removeDubleTapImage(){
        UIView.animateWithDuration(0.2, animations: {
            //   self.imgLikeDubleTap?.frame = CGRectMake(160, 160, 0, 0)
            self.imgLikeDubleTap?.hidden = true
            
            self.imgLikeDubleTap?.removeFromSuperview()
        })
    }
    
    func singleTapLike(sender : UITapGestureRecognizer){
      //  showLoader(self.view)
        
        
        buttonLike = UIImageView()
        buttonLike = sender.view as? UIImageView
        
        carouselIndex = (sender.view?.tag)!
        Flurry.logEvent("Like Button Tabbed")
        
        let carouselView = carousel.currentItemView! as UIView
        
//        for view in carouselView.subviews {
//            if view.isKindOfClass(UIView) {
//                
//                if(view.frame.origin.y > 300){
//                    for view1 in view.subviews {
//                         if view1.isKindOfClass(UILabel){
//                            if((view1 as! UILabel).tag == 1099){
//                                if(arrLikeList.objectAtIndex(sender.view!.tag) as! String == "0"){
//                                (view1 as! UILabel).text = String(format: "%d", Int(((view1 as! UILabel).text!))! + 1)
//                                }
//                                else{
//                                 (view1 as! UILabel).text = String(format: "%d", Int(((view1 as! UILabel).text!))! - 1)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
        
        
        var methodName = String()
        if(arrLikeList.objectAtIndex(sender.view!.tag) as! String == "0"){
            methodName = addlikeMethod
            (sender.view as! UIImageView).image = UIImage(named: "LikePressed.png")
            arrLikeList.replaceObjectAtIndex((sender.view!.tag), withObject: "1")
        }
        else{
            methodName = deleteLikeMethod
            (sender.view as! UIImageView).image = UIImage(named: "likeNew.png")
            arrLikeList.replaceObjectAtIndex((sender.view!.tag), withObject: "0")
        }

        let url = String(format: "%@%@%@", baseUrl, controllerLike, methodName)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let postId = arrDiscoverValues.objectAtIndex(sender.view!.tag).objectForKey("id")
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(postId!, forKey: "postId")
        
        webServiceCallingPost(url, parameters: params)
        
        delegate = self
    }
    
    func singleTapFav(sender : UITapGestureRecognizer){
        
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
            buttonFav?.image = UIImage(named: "favPressed.png")
        }
        else{
            methodName = deleteLikeMethod
            buttonFav?.image = UIImage(named: "FavNew.png")
        }
        let url = String(format: "%@%@%@", baseUrl, controllerBookmark, methodName)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let postId = arrDiscoverValues.objectAtIndex(sender.view!.tag).objectForKey("id")
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(postId!, forKey: "postId")
        
        webServiceCallingPost(url, parameters: params)
       
        delegate = self
    }
    
    func singleTapOpenPost(sender : UIButton){
                postIdOpenPost = (arrDiscoverValues.objectAtIndex(sender.tag).objectForKey("id") as? String)!
        
                let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("OpenPost") as! OpenPostViewController;
                self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }

    
    //MARK:- WebService Delegates
    
    func webCallDiscover(){
        if(locationVal?.count > 0){
        if (isConnectedToNetwork()){
        pageList++
       // showLoader(self.view)
        let url = String(format: "%@%@%@", baseUrl, controllerPost, getImageCheckinPost)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(locationVal!.valueForKey("latitude") as! NSNumber, forKey: "latitude")
        params.setObject(locationVal!.valueForKey("longitute") as! NSNumber, forKey: "longitude")
        params.setObject("12", forKey: "recordCount")
        params.setObject(pageList, forKey: "page")
        
        webServiceCallingPost(url, parameters: params)
            
        delegate = self
            
 //           self.navigationItem.setHidesBackButton(true, animated: true)
        }
        else{
            internetMsg(self.view)
            stopLoading1(self.view)
            self.tabBarController?.tabBar.userInteractionEnabled = true
        }
        }
    }
    
    func webCallDiscoverDish(){
        if(locationVal?.count > 0){
        if (isConnectedToNetwork()){
            pageList++
           // showLoader(self.view)
            let url = String(format: "%@%@%@", baseUrl, controllerPost, getImageCheckinPost)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(locationVal!.objectForKey("latitude") as! NSNumber, forKey: "latitude")
            params.setObject(locationVal!.objectForKey("longitute") as! NSNumber, forKey: "longitude")
            params.setObject("12", forKey: "recordCount")
            params.setObject("", forKey: "exceptions")
            params.setObject("", forKey: "hashtag")
            params.setObject(pageList, forKey: "page")
            params.setObject(selectedDishHome, forKey: "search")
            
            webServiceCallingPost(url, parameters: params)
            
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
        }
    }
    
    func webServiceDiscoverProfile(){
        if (isConnectedToNetwork()){
        pageingDiscover++
     //   showLoader(self.view)
        let url = String(format: "%@%@%@", baseUrl, controllerUser, getRestaurantimagepostMethod)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let userId = NSUserDefaults.standardUserDefaults().objectForKey("userId")
        
        let params = NSMutableDictionary()
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(userId!, forKey: "selectedUserId")
        params.setObject(pageingDiscover, forKey: "page")

        webServiceCallingPost(url, parameters: params)
           
        delegate = self
        }
        else{
                internetMsg(self.view)
            }
    }
    
    func webserviceCallingForDishes(){
        if (isConnectedToNetwork()){
        //    showLoader(self.view)
            let url = String(format: "%@%@%@", baseUrl, controllerUser, getCheckInPostsMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let userId = NSUserDefaults.standardUserDefaults().objectForKey("userId")
            
            let params = NSMutableDictionary()
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(userId!, forKey: "selectedUserId")
            params.setObject("1", forKey: "page")
            params.setObject("10", forKey: "recordCount")
            
            webServiceCallingPost(url, parameters: params)
            
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
        
    }
    
    func webServiceForDelete(){
        
        if (isConnectedToNetwork()){
            showLoader(self.view)
            
            let url = String(format: "%@%@%@", baseUrl,controllerPost,deleteLikeMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            let postId = arrDiscoverValues.objectAtIndex(carousel.currentItemIndex).objectForKey("id") as! String
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(postId, forKey: "postId")
            
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
            
            let postId = arrDiscoverValues.objectAtIndex(carousel.currentItemIndex).objectForKey("id") as! String
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(postId, forKey: "postId")
            
            webServiceCallingPost(url, parameters: params)
            
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
        
    }


    
    func getDataFromWebService(dict : NSMutableDictionary){
        
        if(dict.objectForKey("api") as! String == "post/getImageCheckInPosts"){
            if(dict.objectForKey("status") as! String == "OK"){
                let arr = dict.objectForKey("posts")?.mutableCopy() as! NSArray
                for(var index : Int = 0; index < arr.count; index++){
                   arrDiscoverValues.addObject(arr.objectAtIndex(index))
                   arrLikeList.addObject(arr.objectAtIndex(index).objectForKey("iLikedIt") as! String)
                   arrFavList.addObject(arr.objectAtIndex(index).objectForKey("iBookark") as! String)
                }
                navigationItem.rightBarButtonItem?.enabled = true
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
            stopLoading(self.view)
            carousel.reloadData()
            self.tabBarController?.tabBar.userInteractionEnabled = true
        }
        else if(dict.objectForKey("api") as! String == "user/getImagePosts"){
            if(dict.objectForKey("status") as! String == "OK"){
                let arr = dict.objectForKey("imagePosts")?.mutableCopy() as! NSMutableArray
                
                for(var index : Int = 0; index < arr.count; index++){
                    arrDiscoverValues.addObjectsFromArray(arr.mutableCopy() as! [AnyObject])
                }
                navigationItem.rightBarButtonItem?.enabled = true
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
            stopLoading(self.view)
            carousel.reloadData()
            self.tabBarController?.tabBar.userInteractionEnabled = true
        }
        else if(dict.objectForKey("api") as! String == "dish/search"){
            if(dict.objectForKey("status") as! String == "OK"){
                let arr = dict.objectForKey("result")?.mutableCopy() as! NSMutableArray
                
                for(var index : Int = 0; index < arr.count; index++){
                    arrDiscoverValues.addObjectsFromArray(arr.mutableCopy() as! [AnyObject])
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
            stopLoading(self.view)
            carousel.reloadData()
        }
        else if(dict.objectForKey("api") as! String == "like/add"){
            if(dict.objectForKey("api") as! String == "like/add"){
          //      arrLikeList.replaceObjectAtIndex((buttonLike?.tag)!, withObject: "1")
            }
            else{
          //      arrLikeList.replaceObjectAtIndex((buttonLike?.tag)!, withObject: "0")
            }
            stopLoading(self.view)

            stopLoading(self.view)
            self.performSelector("removeDubleTapImage", withObject: nil, afterDelay: 1.0)

        }
        else if(dict.objectForKey("api") as! String == "like/delete"){
            if(dict.objectForKey("api") as! String == "like/add"){
          //      arrLikeList.replaceObjectAtIndex((buttonLike?.tag)!, withObject: "1")
            }
            else{
          //      arrLikeList.replaceObjectAtIndex((buttonLike?.tag)!, withObject: "0")
            }
            stopLoading(self.view)

            imgLikeDubleTap?.removeFromSuperview()
            
            stopLoading(self.view)
        }
        else if(dict.objectForKey("api") as! String == "bookmark/add"){
            
            if(dict.objectForKey("status") as! String == "OK"){
                arrFavList.replaceObjectAtIndex((buttonFav?.tag)!, withObject: "1")
                stopLoading(self.view)

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
            else if(dict.objectForKey("errorCode")!.isEqual(7)){
                let alertView = UIAlertView(title: "Report Successful", message: nil, delegate: nil, cancelButtonTitle: "OK")
                alertView.show()
                stopLoading(self.view)
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
                if(dict.objectForKey("errorCode")!.isEqual(7)){
                    let alertView = UIAlertView(title: "Report Successful", message: nil, delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                    stopLoading(self.view)
                }
            }
        }
            
        else if(dict.objectForKey("api") as! String == "post/delete"){
            if(dict.objectForKey("status") as! String == "OK"){
                stopLoading(self.view)
                arrDiscoverValues.removeObjectAtIndex(carousel.currentItemIndex)
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
            if((dict.objectForKey("result")) != nil){
            let arr = dict.objectForKey("result") as! NSMutableArray
            for(var index : Int = 0; index < arr.count; index++){
                arrDiscoverValues.addObject(arr.objectAtIndex(index))
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
            stopLoading(self.view)
            carousel.reloadData()
        }
       stopLoading1(self.view)
        loaderView.hidden = true
        btnSettings.hidden = true
      //  navigationItem.rightBarButtonItem?.enabled = true
    }
    
    func serviceFailedWitherror(error : NSError){
        stopLoading(self.view)
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    //MARK:-
    
    func reportDeleteMethod(sender : UIButton){
        
        let dict = (NSUserDefaults.standardUserDefaults().objectForKey("LoginDetails") as? NSMutableDictionary)!
        if(arrDiscoverValues.count > 0){
        if(dict.objectForKey("profile")?.objectForKey("userName") as? String == self.arrDiscoverValues.objectAtIndex(carousel.currentItemIndex).objectForKey("userName") as? String){
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Delete")
            
            actionSheet.showInView(self.view)
        }
        else{
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Report")
            
            actionSheet.showInView(self.view)
        }
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
                self.navigationController?.popViewControllerAnimated(true)
                
                self.webServiceForDelete()
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
                
                self.webServiceForReport()
            default:
                print("Default")
                //Some code here..
                
            }
        }
    }
    
    //MARK:- LocationManager
    func addLocationManager(){
        if(isConnectedToNetwork()){
        locationManager = CLLocationManager()
        locationManager!.delegate = self;
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.requestAlwaysAuthorization()
        locationManager!.startUpdatingLocation()
        }
        else{
            internetMsg(self.view)
            self.tabBarController?.tabBar.userInteractionEnabled = true
        }
    }
    
    //MARK:- UserLocations Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0]
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        //Do What ever you want with it
        
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
            
            NSUserDefaults.standardUserDefaults()
                self.performSelector(#selector(DiscoverViewController.webCallDiscover), withObject: nil, afterDelay: 0.1)
        }
        callInt += 1
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.Denied) {

            self.tabBarController?.tabBar.userInteractionEnabled = true
            searchingLabel.text = "Please allow location access to see nearby dishes."
            activityIndicator.stopAnimating()
            activityIndicator1.stopAnimating()
            

                self.searchingLabel.text = "Please enable location services in your privacy settings to discover best dishes around you"
                self.activityIndicator1.stopAnimating()
                self.btnSettings.hidden = false
                self.dismissViewControllerAnimated(true, completion: nil)

            
            
        } else if (status == CLAuthorizationStatus.AuthorizedAlways) {
            
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription)
    }

    //MARK:- TTTAttributedLabelDelegates
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if(url == NSURL(string: "action://users/\("userName")")){
            isUserInfo = false
                            postDictHome = self.arrDiscoverValues.objectAtIndex(label.tag) as! NSDictionary
                            openProfileId = (postDictHome.objectForKey("userId") as? String)!
                            postImageOrgnol = (postDictHome.objectForKey("userImage") as? String)!
                            postImagethumb = (postDictHome.objectForKey("userThumb") as? String)!
                            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfile") as! UserProfileViewController;
                            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
            
        else if(url == NSURL(string: "action://dish/\("dishName")")){
            self.pageList = 0
                            selectedDishHome = self.arrDiscoverValues.objectAtIndex(label.tag).objectForKey("dishName") as! String
                            arrDishList.removeAllObjects()
                            self.webCallDiscoverDish()
                            comingFrom = "HomeDish"
                            comingToDish = selectedDishHome
                       //     self.backButton?.hidden = false
                            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("DishProfile") as! DishProfileViewController;
                            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
            
        else if(url == NSURL(string: "action://restaurant/\("restaurantName")")){
            restaurantProfileId = (self.arrDiscoverValues.objectAtIndex(label.tag).objectForKey("checkedInRestaurantId") as? String)!
        
                            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("RestaurantProfile") as! RestaurantProfileViewController;
                            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
    }
    
    func restaurantOpen(sender : UITapGestureRecognizer){
        restaurantProfileId = (self.arrDiscoverValues.objectAtIndex((sender.view?.tag)!).objectForKey("checkedInRestaurantId") as? String)!
        
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("RestaurantProfile") as! RestaurantProfileViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }

    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        if(selectedTabBarIndex == 1){
            carousel.scrollToItemAtIndex(0, animated: true)
        }
        else{
            loaderView.hidden = false
            selectedTabBarIndex = 1
            callInt = 0
            pageList = 0
            arrDiscoverValues = NSMutableArray()
            arrLikeList = NSMutableArray()
            arrFavList = NSMutableArray()
            locationVal = NSMutableDictionary()
            carousel.reloadData()
        }
        self.navigationController?.popToRootViewControllerAnimated(false)
    }
    
    func handleTap(sender: UITapGestureRecognizer? = nil) {
        if(sender?.view != carousel){
            if(isConnectedToNetwork()){
                conectivityMsg.removeFromSuperview()
                callInt = 0
                self.addLocationManager()
            }
        }
    }
    



}
