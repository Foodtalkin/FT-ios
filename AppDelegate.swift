

//
//  AppDelegate.swift
//  FoodTalk
//
//  Created by Ashish on 02/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import CoreLocation

import Parse
import Bolts

var dictLocations = NSMutableDictionary()
var badgeNumber : Int = 0
var isDirectOpen : Bool = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, UITabBarDelegate,UIAlertViewDelegate, UITabBarControllerDelegate, WebServiceCallingDelegate {

    var window: UIWindow?
    var locationManager : CLLocationManager?
    var currentLocation : CLLocation?
    var currentAppVarsion = String()
    var tab = UITabBarController()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor(red: 18/255, green: 47/255, blue: 65/255, alpha: 1.0)], forState:UIControlState())
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.whiteColor()], forState:.Selected)
        
        let storyBoard = self.window!.rootViewController!.storyboard;
        
        tab = storyBoard?.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController
        tab.delegate = self
        
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
        if let remoteNotification = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey] as? NSDictionary {
            
            var dictLoginInfo = NSMutableDictionary()
            
            if((NSUserDefaults.standardUserDefaults().objectForKey("LoginDetails")) != nil){
                dictLoginInfo = (NSUserDefaults.standardUserDefaults().objectForKey("LoginDetails") as? NSMutableDictionary)!
            }
            
            if(NSUserDefaults.standardUserDefaults().objectForKey("sessionId") == nil){
                let storyBoard = self.window!.rootViewController!.storyboard;
                let nav = self.window!.rootViewController as! UINavigationController;
                var tbc : UIViewController
                tbc = storyBoard!.instantiateViewControllerWithIdentifier("Login") as! LoginViewController;
                
                nav.visibleViewController?.navigationController?.pushViewController(tbc, animated: false)
            }
            else if(dictLoginInfo.objectForKey("profile")!.objectForKey("userName") as! String == ""){
                let storyBoard = self.window!.rootViewController!.storyboard;
                let nav = self.window!.rootViewController as! UINavigationController;
                var tbc : UIViewController
                tbc = storyBoard!.instantiateViewControllerWithIdentifier("Unnamed") as! LoginViewController;
                
                nav.visibleViewController?.navigationController?.pushViewController(tbc, animated: false)
            }
            else if((dictLoginInfo.objectForKey("profile")!.objectForKey("email")) == nil)
            {
                
                let storyBoard = self.window!.rootViewController!.storyboard;
                let nav = self.window!.rootViewController as! UINavigationController;
                let tab = storyBoard?.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController
                tab.selectedIndex = 0
                
                
            }
            else if(dictLoginInfo.objectForKey("profile")!.objectForKey("email") as! String == ""){
                isDirectOpen = true
                let storyBoard = self.window!.rootViewController!.storyboard;
                let nav = self.window!.rootViewController as! UINavigationController;
                var tbc : UIViewController
                tbc = storyBoard!.instantiateViewControllerWithIdentifier("EmailVerification");
                
                nav.visibleViewController?.navigationController?.pushViewController(tbc, animated: false)
            }
            else if((dictLoginInfo.objectForKey("profile")!.objectForKey("cityName")) != nil){
                
                let storyBoard = self.window!.rootViewController!.storyboard;
                let nav = self.window!.rootViewController as! UINavigationController;
                let tab = storyBoard?.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController
                tab.selectedIndex = 0
                
                
            }
            else if(dictLoginInfo.objectForKey("profile")!.objectForKey("cityName") as! String == ""){
                isDirectOpen = true
                let storyBoard = self.window!.rootViewController!.storyboard;
                let nav = self.window!.rootViewController as! UINavigationController;
                var tbc : UIViewController
                tbc = storyBoard!.instantiateViewControllerWithIdentifier("SelectCity") as! SelectCityViewController;
                
                nav.visibleViewController?.navigationController?.pushViewController(tbc, animated: false)
            }
            else{
            
            self.addLocationManager()
            self.application(application, didReceiveRemoteNotification: remoteNotification as NSDictionary as [NSObject : AnyObject])
            
            FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
            NSUserDefaults.standardUserDefaults().setObject("98087765412342562728", forKey: "DeviceToken")
//            
            window?.frame = UIScreen.mainScreen().bounds
            UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
            
            let barAppearace = UIBarButtonItem.appearance()
            barAppearace.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics:UIBarMetrics.Default)
            
            let navigationItem = UINavigationItem()
            let myBackButton:UIButton = UIButton(type: UIButtonType.Custom) as UIButton
            myBackButton.frame = CGRectMake(20, 20, 30, 30)
            myBackButton.addTarget(self, action: #selector(AppDelegate.popToRoot(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            myBackButton.setImage(UIImage(named: "Back icon.png"), forState: UIControlState.Normal)
            myBackButton.setTitle("", forState: UIControlState.Normal)
            myBackButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
            myBackButton.sizeToFit()
            let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
            navigationItem.leftBarButtonItem  = myCustomBackButtonItem
            
                let userName = NSUserDefaults.standardUserDefaults().objectForKey("userName") as! String
            Flurry.setUserID(userName)
                
            
            Parse.setApplicationId("RBOZIK8Vti138uqPIucaBherLAB16JFa3ITi4kDu",
                clientKey: "Kavc924t4PGsZzQdwUoLS6nz3q3Wm5PfRUjEDj9a")
                
            
            let oldPushHandlerOnly = !self.respondsToSelector(#selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
            let noPushPayload: AnyObject? = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey]
            
            if oldPushHandlerOnly || noPushPayload != nil {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
            }
            
            let notificationType: UIUserNotificationType = [.Alert, .Badge, .Sound]
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: notificationType, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
        
        }
       else{
            
            var dictLoginInfo = NSMutableDictionary()
            
            if((NSUserDefaults.standardUserDefaults().objectForKey("LoginDetails")) != nil){
                dictLoginInfo = (NSUserDefaults.standardUserDefaults().objectForKey("LoginDetails") as? NSMutableDictionary)!
            }
            
            self.addLocationManager()
            FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
            NSUserDefaults.standardUserDefaults().setObject("98087765412342562728", forKey: "DeviceToken")
            
            let notificationType: UIUserNotificationType = [.Alert, .Badge, .Sound]
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: notificationType, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
            UIApplication.sharedApplication().registerForRemoteNotifications()
            
            let oldPushHandlerOnly = !self.respondsToSelector(#selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
            let noPushPayload: AnyObject? = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey]
            
            if oldPushHandlerOnly || noPushPayload != nil {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }

            
            window?.frame = UIScreen.mainScreen().bounds
            UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
            
            let barAppearace = UIBarButtonItem.appearance()
            barAppearace.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics:UIBarMetrics.Default)
            
            let navigationItem = UINavigationItem()
            let myBackButton:UIButton = UIButton(type: UIButtonType.Custom) as UIButton
            myBackButton.frame = CGRectMake(20, 20, 30, 30)
            myBackButton.addTarget(self, action: #selector(AppDelegate.popToRoot(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            myBackButton.setImage(UIImage(named: "Back icon.png"), forState: UIControlState.Normal)
            myBackButton.setTitle("", forState: UIControlState.Normal)
            myBackButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
            myBackButton.sizeToFit()
            let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
            navigationItem.leftBarButtonItem  = myCustomBackButtonItem
            
            if(NSUserDefaults.standardUserDefaults().objectForKey("sessionId") == nil){
                let storyBoard = self.window!.rootViewController!.storyboard;
                let nav = self.window!.rootViewController as! UINavigationController;
                var tbc : UIViewController
                tbc = storyBoard!.instantiateViewControllerWithIdentifier("Login") as! LoginViewController;
                
                nav.visibleViewController!.navigationController?.pushViewController(tbc, animated: false)
            }
            else if(dictLoginInfo.objectForKey("profile")!.objectForKey("userName") as! String == ""){
                let storyBoard = self.window!.rootViewController!.storyboard;
                let nav = self.window!.rootViewController as! UINavigationController;
                var tbc : UIViewController
                tbc = storyBoard!.instantiateViewControllerWithIdentifier("Unnamed") as! UnnamedViewController;
                
                nav.visibleViewController?.navigationController?.pushViewController(tbc, animated: false)
            }
            else if((dictLoginInfo.objectForKey("profile")!.objectForKey("email")) == nil)
            {
                
                let storyBoard = self.window!.rootViewController!.storyboard;
                let nav = self.window!.rootViewController as! UINavigationController;
                let tab = storyBoard?.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController
                tab.selectedIndex = 0
                
                
            }
            else if(dictLoginInfo.objectForKey("profile")!.objectForKey("email") as! String == ""){
                isDirectOpen = true
                let storyBoard = self.window!.rootViewController!.storyboard;
                let nav = self.window!.rootViewController as! UINavigationController;
                var tbc : UIViewController
                tbc = storyBoard!.instantiateViewControllerWithIdentifier("EmailVerification") as! EmailVerificationViewController;
                
                nav.visibleViewController?.navigationController?.pushViewController(tbc, animated: false)
            }
            else if((dictLoginInfo.objectForKey("profile")!.objectForKey("cityName")) == nil){
                
                let storyBoard = self.window!.rootViewController!.storyboard;
                let nav = self.window!.rootViewController as! UINavigationController;
                let tab = storyBoard?.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController
                tab.selectedIndex = 0
                
                
            }
            else if(dictLoginInfo.objectForKey("profile")!.objectForKey("cityName") as! String == ""){
                isDirectOpen = true
                let storyBoard = self.window!.rootViewController!.storyboard;
                let nav = self.window!.rootViewController as! UINavigationController;
                var tbc : UIViewController
                tbc = storyBoard!.instantiateViewControllerWithIdentifier("SelectCity") as! SelectCityViewController;
                
                nav.visibleViewController?.navigationController?.pushViewController(tbc, animated: false)
            }
            else{
            
            self.addLocationManager()
            
            
            let barAppearace = UIBarButtonItem.appearance()
            barAppearace.setBackButtonTitlePositionAdjustment(UIOffsetMake(0, -60), forBarMetrics:UIBarMetrics.Default)
                
                let navigationItem = UINavigationItem()
                let myBackButton:UIButton = UIButton(type: UIButtonType.Custom) as UIButton
                myBackButton.frame = CGRectMake(20, 20, 30, 30)
                myBackButton.addTarget(self, action: #selector(AppDelegate.popToRoot(_:)), forControlEvents: UIControlEvents.TouchUpInside)
                myBackButton.setImage(UIImage(named: "Back icon.png"), forState: UIControlState.Normal)
                myBackButton.setTitle("", forState: UIControlState.Normal)
                myBackButton.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
                myBackButton.sizeToFit()
                let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
                navigationItem.leftBarButtonItem  = myCustomBackButtonItem
                
                if((NSUserDefaults.standardUserDefaults().objectForKey("userName")) != nil){
                let userName = NSUserDefaults.standardUserDefaults().objectForKey("userName") as! String
                Flurry.setUserID(userName)
                }
            
            Parse.setApplicationId("RBOZIK8Vti138uqPIucaBherLAB16JFa3ITi4kDu",
                clientKey: "Kavc924t4PGsZzQdwUoLS6nz3q3Wm5PfRUjEDj9a")
            
            
            
            let oldPushHandlerOnly = !self.respondsToSelector(#selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
            let noPushPayload: AnyObject? = launchOptions?[UIApplicationLaunchOptionsRemoteNotificationKey]
            
            if oldPushHandlerOnly || noPushPayload != nil {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
            }
        }
        
        Flurry.setCrashReportingEnabled(true)
        Flurry.startSession("KNCBBSX6RCMBNV8FP2TQ")
        Flurry.setShowErrorInLogEnabled(true)
        Flurry.setDebugLogEnabled(true)
        Flurry.setBackgroundSessionEnabled(false)
        
        return true
    }
    
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.All
    }
    
    //MARK:- checkForNewVersion
    
    func newUpdates() -> Bool{
        let infoDict = NSBundle.mainBundle().infoDictionary! as NSDictionary
        
        let appId = infoDict.objectForKey("CFBundleIdentifier") as! String
        let url = NSURL(string: String(format: "http://itunes.apple.com/lookup?bundleId=%@", appId))
        let data = NSData(contentsOfURL: url!)
        
        do {
            let lookUp = try NSJSONSerialization.JSONObjectWithData(data!, options: .MutableContainers) as? NSMutableDictionary
            if(lookUp?.objectForKey("resultCount")?.integerValue == 1){
                let appStoreVersion = lookUp?.objectForKey("results")?.objectAtIndex(0).objectForKey("version") as! String
                currentAppVarsion = infoDict.objectForKey("CFBundleShortVersionString") as! String
                if (appStoreVersion == currentAppVarsion){
                    return true;
                }
            }
            else{
                
            }
        } catch {
            
        }
        return false
    }
    
    func updateCall(){
        currentAppVarsion = "1.0"
        let url = String(format: "http://52.74.136.146/index.php/service/auth/appversion")
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let params = NSMutableDictionary()
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(currentAppVarsion, forKey: "app_version")
        if (isConnectedToNetwork()){
            showLoader(self.window!)
        webServiceCallingPost(url, parameters: params)
           delegate = self
        }
        else{
            internetMsg(window!)
            stopLoading(window!)
        }
    }
    
    
    func popToRoot(sender : UIButton){
        let navigationController = UINavigationController()
        navigationController.popViewControllerAnimated(true)
    }
    
    func addLocationManager(){
        locationManager = CLLocationManager()
        
        locationManager!.delegate = self;
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.requestAlwaysAuthorization()
        locationManager!.startUpdatingLocation()
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        FBSDKAppEvents.activateApp()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    //MARK:- UserLocations Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0] 
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        //Do What ever you want with it
        
        dictLocations.setObject(long, forKey: "longitute")
        dictLocations.setObject(lat, forKey: "latitude")
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.Denied) {

            
        } else if (status == CLAuthorizationStatus.AuthorizedAlways) {
            
        } 
    }
    
    //MARK:- Push Notification Delegate Methods
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        
        badgeNumber = badgeNumber + 1
   
        let state = application.applicationState;
        if (state == UIApplicationState.Active) {
            dispatch_async(dispatch_get_main_queue()) {
             NSNotificationCenter.defaultCenter().postNotificationName("addBadge", object: nil)
                
            }
        }
        else{
        if application.applicationState == UIApplicationState.Inactive {
           // PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
            PFPush.handlePush(userInfo)
            let currentInstallation = PFInstallation.currentInstallation()
            if (currentInstallation.badge != 0) {
                currentInstallation.badge = 0
                currentInstallation.saveEventually()
            }
            
            if application.applicationState == .Inactive  {
                PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
            }
            
            
            let dict = (userInfo as NSDictionary)
            self.performSelector(#selector(AppDelegate.singleFunctionForNotification(_:)), withObject: dict, afterDelay: 4)
          //  singleFunctionForNotification(dict)
        }
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {

        let userId = NSUserDefaults.standardUserDefaults().objectForKey("userId")
        
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        if(userId != nil){
        currentInstallation.setObject(userId!, forKey: "userId")
        }
        currentInstallation.setObject("development", forKey: "work")
        if(NSUserDefaults.standardUserDefaults().objectForKey("channels") != nil){
            let chanelArray = NSUserDefaults.standardUserDefaults().objectForKey("channels")
            
            if(chanelArray?.count == 1){
               currentInstallation.addUniqueObject((chanelArray?.objectAtIndex(0))!, forKey: "channels")
            }
            else{
                currentInstallation.addUniqueObject((chanelArray?.objectAtIndex(0))!, forKey: "channels")
                currentInstallation.addUniqueObject((chanelArray?.objectAtIndex(1))!, forKey: "channels")
            }
            
        }
        currentInstallation.saveInBackground()
     //   print(currentInstallation)
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    @available(iOS 8.0, *)
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        
    }
    
    //MARK:- ClosePushAction
    
    func closePush(pushBtn : UIButton){
        let superView = pushBtn.superview! as UIView
        UIView.animateWithDuration(0.5, delay: 1.0, options: UIViewAnimationOptions.TransitionNone, animations: { () -> Void in
            
            superView.frame = CGRectMake(0, -64, pushBtn.frame.size.width, pushBtn.frame.size.height)
            
            }, completion: { (finished: Bool) -> Void in
                
        })
    }
    
    //MARK:- OpenAllPosts
    
    func singleFunctionForNotification(dict : NSDictionary){
        let storyBoard = self.window!.rootViewController!.storyboard;
        let nav = self.window!.rootViewController as! UINavigationController;
        nav.tabBarController?.tabBar.hidden = false
        
        stopLoading(self.window!)
        if(dict.objectForKey("class") as? String == "Home"){
            
        }
        else if(dict.objectForKey("class") as? String == "Discover"){
            let tab = storyBoard?.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController
            tab.selectedIndex = 1
            nav.visibleViewController?.navigationController?.pushViewController(tab, animated:true);
        }
        else if(dict.objectForKey("class") as? String == "CheckIn"){
            let tab = storyBoard?.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController
            tab.selectedIndex = 2
            nav.visibleViewController?.navigationController?.pushViewController(tab, animated:true);
        }
        else if(dict.objectForKey("class") as? String == "Notifications"){
            let tab = storyBoard?.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController
            tab.selectedIndex = 3
            nav.visibleViewController?.navigationController?.pushViewController(tab, animated:true);
        }
        else if(dict.objectForKey("class") as? String == "More"){
            let tab = storyBoard?.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController
            tab.selectedIndex = 4
            nav.visibleViewController?.navigationController?.pushViewController(tab, animated:true);
        }
        else{
            if(dict.objectForKey("eventType") as! String == "52"){
               isUserInfo = true
               openProfileId = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String
            }
            else{
               isUserInfo = false
                openProfileId = (dict.objectForKey("elementId") as? String)!
            }
        
        postIdOpenPost = (dict.objectForKey("elementId") as? String)!
        
        restaurantProfileId = (dict.objectForKey("elementId") as? String)!
        let className = (dict.objectForKey("class") as? String)!
        let openPost = storyBoard!.instantiateViewControllerWithIdentifier(className) as UIViewController
        nav.visibleViewController?.navigationController?.pushViewController(openPost, animated:true);
        }
    }
    
    func openOpenPostScreen(dict : NSDictionary){
        let storyBoard = self.window!.rootViewController!.storyboard;
        let nav = self.window!.rootViewController as! UINavigationController;
        nav.tabBarController?.tabBar.hidden = false
        
        
        if((nav.visibleViewController?.isKindOfClass(OpenPostViewController)) != nil){
            
            let viewControllers = nav.viewControllers
            for viewController in viewControllers {
                // some process
                if viewController.isKindOfClass(OpenPostViewController) {
                    nav.visibleViewController?.navigationController?.popToViewController(viewController, animated: false)
                }
            }
        }
        
        stopLoading(self.window!)
        postIdOpenPost = (dict.objectForKey("elementId") as? String)!
        let openPost = storyBoard!.instantiateViewControllerWithIdentifier("OpenPost") as! OpenPostViewController;
        nav.visibleViewController?.navigationController?.pushViewController(openPost, animated:true);
    }
    
    func openUserProfile(dict : NSDictionary){
        
        let storyBoard = self.window!.rootViewController!.storyboard;
        let nav = self.window!.rootViewController as! UINavigationController;
        
        if((nav.visibleViewController?.isKindOfClass(UserProfileViewController)) != nil){
            
            let viewControllers = nav.viewControllers
            for viewController in viewControllers {
                // some process
                if viewController.isKindOfClass(UserProfileViewController) {
                    nav.visibleViewController?.navigationController?.popToViewController(viewController, animated: false)
                }
            }
        }
        isUserInfo = false
        stopLoading(self.window!)
        openProfileId = (dict.objectForKey("elementId") as? String)!
        
        let openPost = storyBoard!.instantiateViewControllerWithIdentifier("UserProfile") as! UserProfileViewController;
        nav.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    func openUserProfile1(dict : NSDictionary){
        let storyBoard = self.window!.rootViewController!.storyboard;
        let nav = self.window!.rootViewController as! UINavigationController;
        
        if((nav.visibleViewController?.isKindOfClass(UserProfileViewController)) != nil){
            
            let viewControllers = nav.viewControllers
            for viewController in viewControllers {
                // some process
                if viewController.isKindOfClass(UserProfileViewController) {
                    nav.visibleViewController?.navigationController?.popToViewController(viewController, animated: false)
                }
            }
        }
        isUserInfo = false
        stopLoading(self.window!)
        openProfileId = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String
        
        let openPost = storyBoard!.instantiateViewControllerWithIdentifier("UserProfile") as! UserProfileViewController;
        nav.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    func openRestaurantProfile(dict : NSDictionary){
        let storyBoard = self.window!.rootViewController!.storyboard;
        let nav = self.window!.rootViewController as! UINavigationController;
        if((nav.visibleViewController?.isKindOfClass(RestaurantProfileViewController)) != nil){
            
            let viewControllers = nav.viewControllers
            for viewController in viewControllers {
                // some process
                if viewController.isKindOfClass(RestaurantProfileViewController) {
                    nav.visibleViewController?.navigationController?.popToViewController(viewController, animated: false)
                }
            }
        }
        
        restaurantProfileId = (dict.objectForKey("elementId") as? String)!
        let openPost = storyBoard!.instantiateViewControllerWithIdentifier("RestaurantProfile") as! RestaurantProfileViewController;
        nav.visibleViewController?.navigationController?.pushViewController(openPost, animated:true);
    }
    
    func openDiscoverProfile(dict : NSDictionary){
        let storyBoard = self.window!.rootViewController!.storyboard;
        let nav = self.window!.rootViewController as! UINavigationController;
        if((nav.visibleViewController?.isKindOfClass(DiscoverViewController)) != nil){
            
            let viewControllers = nav.viewControllers
            for viewController in viewControllers {
                // some process
                if viewController.isKindOfClass(DiscoverViewController) {
                    nav.visibleViewController?.navigationController?.popToViewController(viewController, animated: false)
                }
            }
        }
        
       // restaurantProfileId = (dict.objectForKey("elementId") as? String)!
        let tab = storyBoard?.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController
        tab.selectedIndex = 1
        nav.visibleViewController?.navigationController?.pushViewController(tab, animated:true);
    }
    
    //MARK:- DishWebService
    func webServiceForDishDetails(){
       if (isConnectedToNetwork()){
        let url = String(format: "%@%@%@", baseUrl, controllerDish, restaurantListMethod)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let params = NSMutableDictionary()
        params.setObject(sessionId!, forKey: "sessionId")
        
        webServiceCallingPost(url, parameters: params)
        delegate = self
        }
       else{
        internetMsg(window!)
        stopLoading(window!)
        }
    }
    
    func getDataFromWebService(dict : NSMutableDictionary){
        if(dict.objectForKey("api") as! String == "auth/appversion"){
          let minimumVersion = dict.objectForKey("app_version")?.objectForKey("allowed") as! Float
            let numberFormatter = NSNumberFormatter()
            let number = numberFormatter.numberFromString(currentAppVarsion)
            let numberFloatValue = number!.floatValue
            if((numberFloatValue) < minimumVersion){
                let storyBoard = self.window!.rootViewController!.storyboard;
                let nav = self.window!.rootViewController as! UINavigationController;
                
                let openPost = storyBoard!.instantiateViewControllerWithIdentifier("UpdateVersion") as! UpdateVersionViewController;
                nav.visibleViewController?.navigationController?.pushViewController(openPost, animated:true);
                openPost.updateLabel?.text = dict.objectForKey("app_version")?.objectForKey("text") as? String
            }
        }
        else{
        var dishnameArray = NSArray()
        let dishNames = NSMutableArray()
        if(dict.objectForKey("status") as! String == "OK"){
            dishnameArray = dict.objectForKey("result") as! NSArray
        }
        
        for(var index : Int = 0; index < dishnameArray.count; index += 1){
            dishNames.addObject(dishnameArray.objectAtIndex(index).objectForKey("name") as! String)
        }
            
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        let path = (paths as NSString).stringByAppendingPathComponent("DishName.plist")

        
        if let plistArray = NSMutableArray(contentsOfFile: path) {

            for(var indx : Int = 0; indx < dishNames.count; indx++){
               plistArray.addObject(dishNames.objectAtIndex(indx))
            }
            plistArray.writeToFile(path, atomically: false)
        }
        loadDataPlist()
        }
    }
    
    func loadDataPlist(){
        var myArray = NSMutableArray()
        let rootPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, .UserDomainMask, true)[0]
        // 2
        let plistPathInDocument = rootPath.stringByAppendingString("/DishName.plist")
        if !NSFileManager.defaultManager().fileExistsAtPath(plistPathInDocument){
            let plistPathInBundle = NSBundle.mainBundle().pathForResource("DishName", ofType: "plist") as String!
            // 3
            do {
                try NSFileManager.defaultManager().copyItemAtPath(plistPathInBundle, toPath: plistPathInDocument)
                myArray = NSMutableArray(contentsOfFile: plistPathInDocument)!
               
            }catch{
                print("Error occurred while copying file to document \(error)")
            }
        }
    }
    
    func serviceFailedWitherror(error : NSError){
        stopLoading(self.window!)
    }
    
    func serviceUploadProgress(myprogress : float_t){
        stopLoading(self.window!)
    }
    
    //MARK:- Parse delegates

    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        let nav = UINavigationController()
        nav.popToRootViewControllerAnimated(true)
    }
    

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        let currentInstallation = PFInstallation.currentInstallation()
        if (currentInstallation.badge != 0) {
            currentInstallation.badge = 0
            currentInstallation.saveEventually()
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

