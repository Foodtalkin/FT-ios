//
//  LoginViewController.swift
//  FoodTalk
//
//  Created by Ashish on 02/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import FBSDKShareKit

var loginAllDetails = NSMutableDictionary()
var webViewCallingLegal : Bool = false
var arrayFacebookFriends = NSMutableArray()


class LoginViewController: UIViewController, UIScrollViewDelegate, WebServiceCallingDelegate {

    
    @IBOutlet var loginButton : UIButton?
    @IBOutlet var pageControl : UIPageControl?
    @IBOutlet var scrollView : UIScrollView?
    @IBOutlet var btnLegal : UIButton?
    var fbId : String?
    var fbUserName : String?
    var dict : NSDictionary?
    var webCall : WebServiceCallingViewController?
    var imgFirst = UIImageView()
    
    
    let totalPages = 4
    var arrayImages = NSMutableArray()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fbUserName = ""
        loginButton?.enabled = true
        if(self.view.frame.size.height < 500){
            arrayImages.addObject("landingIphone4.jpg")
            arrayImages.addObject("eatIphone4.jpg")
            arrayImages.addObject("shareIphone4.jpg")
            arrayImages.addObject("discoverIphone4.jpg")
        }
        else if(self.view.frame.size.height < 570){
            arrayImages.addObject("landingIphone5.jpg")
            arrayImages.addObject("eatIphone5.jpg")
            arrayImages.addObject("shareIphone5.jpg")
            arrayImages.addObject("discoverIphone5.jpg")
        }
        else if(self.view.frame.size.height < 670){
            arrayImages.addObject("landingIphone6.jpg")
            arrayImages.addObject("eatIphone6.jpg")
            arrayImages.addObject("shareIphone6.jpg")
            arrayImages.addObject("discoverIphone6.jpg")
        }
        else{
            arrayImages.addObject("landingIphone6.jpg")
            arrayImages.addObject("eatIphone6.jpg")
            arrayImages.addObject("shareIphone6.jpg")
            arrayImages.addObject("discoverIphone6.jpg")
        }
        
        
        self.view.backgroundColor = UIColor.whiteColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = true
        self.tabBarController?.tabBar.translucent = true
        self.navigationController?.navigationBarHidden = true
        loginButton?.hidden = false
        btnLegal?.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        configureScrollView()
        configurePageControl()
    }
    
    // Inisilize app and return delegate
    func appdelegate () -> AppDelegate{
        return  UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    // MARK: Custom method implementation
    
    func configureScrollView() {
        // Enable paging.
        scrollView!.pagingEnabled = true
        
        // Set the following flag values.
        scrollView!.showsHorizontalScrollIndicator = false
        scrollView!.showsVerticalScrollIndicator = false
        scrollView!.scrollsToTop = false
        self.automaticallyAdjustsScrollViewInsets = false;
        
        // Set the scrollview content size.
//        scrollView!.contentSize = CGSizeMake(scrollView!.frame.size.width * CGFloat(totalPages), scrollView!.frame.size.height)
        scrollView!.contentSize = CGSizeMake(scrollView!.frame.size.width * CGFloat(totalPages),0);
        
        // Set self as the delegate of the scrollview.
        scrollView!.delegate = self
        
        // Load the TestView view from the TestView.xib file and configure it properly.
        for var i=0; i<totalPages; ++i {
            // Load the TestView view.
            let testView = UIView()
            
            // Set its frame and the background color.
            testView.frame = CGRectMake(CGFloat(i) * scrollView!.frame.size.width, scrollView!.frame.origin.y, scrollView!.frame.size.width, scrollView!.frame.size.height)
            let imgView = UIImageView()
            imgView.frame = CGRectMake(0, 0, testView.frame.size.width, testView.frame.size.height)
            // Set the proper message to the test view's label.
            imgView.image = UIImage(named: arrayImages.objectAtIndex(i) as! String)
            testView.addSubview(imgView)
            // Add the test view as a subview to the scrollview.
            scrollView!.addSubview(testView)
        }
    }
    
    
    func configurePageControl() {
        // Set the total pages to the page control.
        pageControl!.numberOfPages = totalPages
        
        // Set the initial page.
        pageControl!.currentPage = 0
        pageControl!.pageIndicatorTintColor = UIColor.blackColor()
    }
    
    
    // MARK: UIScrollViewDelegate method implementation
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Calculate the new page index depending on the content offset.
        let currentPage = floor(scrollView.contentOffset.x / UIScreen.mainScreen().bounds.size.width);
        
        // Set the new page index to the page control.
        pageControl!.currentPage = Int(currentPage)
    }

    
    // MARK: IBAction method implementation
    
    @IBAction func changePage(sender: AnyObject) {
        // Calculate the frame that should scroll to based on the page control current page.
        var newFrame = scrollView!.frame
        newFrame.origin.x = newFrame.size.width * CGFloat(pageControl!.currentPage)
        
        scrollView!.scrollRectToVisible(newFrame, animated: true)
        
    }
    
    //MARK:- FBLoginButton Delegate
    @IBAction func btnFBLoginPressed(sender: AnyObject){
      
        Flurry.logEvent("LoginPressed")
        loginButton?.enabled = false
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.loginBehavior = FBSDKLoginBehavior.Native
        fbLoginManager .logInWithReadPermissions(["email","user_friends"], fromViewController: self, handler: { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                    fbLoginManager.logOut()
                }
                else{
                    
                    self.loginButton?.enabled = true
                    let alert = UIAlertController(title: "", message: "Please allow facebook to share your email address with us.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    let deletepermission = FBSDKGraphRequest(graphPath: "me/permissions/email", parameters: nil, HTTPMethod: "DELETE")
                    deletepermission.startWithCompletionHandler({(connection,result,error)-> Void in
                        print("the delete permission is \(result)")
                        
                    })
                }
            }
        })
        
    }
    
    func getFBUserData(){
        
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email,gender,friends"]).startWithCompletionHandler({ (connection, result, error) -> Void in
                if (error == nil){
                    
                    self.dict = result as? NSDictionary
                    
                    NSUserDefaults.standardUserDefaults().setObject(result, forKey: "FacebookDetails")
                    if((self.dict?.objectForKey("friends")) != nil){
                        if((((self.dict?.objectForKey( "friends"))! as! NSDictionary).objectForKey("data") as! NSArray).count > 0){
                            arrayFacebookFriends = ((self.dict?.objectForKey("friends"))! as! NSDictionary).objectForKey("data")?.mutableCopy() as! NSMutableArray
                            NSUserDefaults.standardUserDefaults().setObject(arrayFacebookFriends, forKey: "facebookFriends")
                            if((((self.dict?.objectForKey("friends"))! as! NSDictionary).objectForKey("paging")!.objectForKey("next")) != nil){
                                let nxtFb = ((self.dict?.objectForKey("friends"))! as! NSDictionary).objectForKey("paging")!.objectForKey("next") as! String
                                NSUserDefaults.standardUserDefaults().setObject(nxtFb, forKey: "nextFb")
                            }
                        }
                    }
                    self.fbId = self.dict?.valueForKey("id") as? String
                    let gender = self.dict?.valueForKey("gender") as? String
                    NSUserDefaults.standardUserDefaults().setObject(self.fbId, forKey: "fbId")
                    self.fbUserName = self.dict?.valueForKey("name") as? String
                    let picUrl = String(format: "https://graph.facebook.com/%@/picture?type=large", self.fbId!)
                    
                    
                    let deviceToken = NSUserDefaults.standardUserDefaults().objectForKey("DeviceToken")
                    
                    //   if(dictLocations.objectForKey("latitude") != nil){
                    let params = NSMutableDictionary()
                    params.setObject("F", forKey: "signInType" as NSCopying)
                    params.setObject(picUrl, forKey: "image" as NSCopying)
                    params.setObject(self.fbId!, forKey: "facebookId" as NSCopying)
                    params.setObject(self.fbUserName!, forKey: "fullName" as NSCopying)
                    
                    
                    params.setObject(deviceToken!, forKey: "deviceToken" as NSCopying)
                    params.setObject(gender!, forKey: "gender" as NSCopying)
                    
                    self.webServicecall(params)
                    
                }
            })
        }
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!){
        
    }
    
    //MARK:- Calling WebServices
    
    func webServicecall (params : NSMutableDictionary){
        if (isConnectedToNetwork() == true){
        let url = String(format: "%@%@%@", baseUrl,controllerAuth,signinMethod)
        webServiceCallingPost(url, parameters: params)
           
        loginAllDetails = params
        NSUserDefaults.standardUserDefaults().setObject(loginAllDetails, forKey: "AllLogindetails")
        delegate = self
        }
        else{
            internetMsg(view)
        }
    }
    
    //MARK:- WebService Delegates
    
    func getDataFromWebService(dict : NSMutableDictionary){
        
        let strChannel = dict.objectForKey("profile")!.objectForKey("channels") as! String
        let channelArray = strChannel.componentsSeparatedByString(",")
        
        NSUserDefaults.standardUserDefaults().setObject(channelArray, forKey: "channels")
        NSUserDefaults.standardUserDefaults().setObject(dict, forKey: "LoginDetails")
        
        let dictProfile = dict.objectForKey("profile") as! NSDictionary
        
        let currentInstallation = PFInstallation.currentInstallation()
        currentInstallation.setObject(dictProfile.objectForKey("cityId")!, forKey: "cityId")
        currentInstallation.setObject(dictProfile.objectForKey( "stateId")!, forKey: "stateId")
        currentInstallation.setObject(dictProfile.objectForKey( "regionId")!, forKey: "regionId")
        currentInstallation.saveInBackground()
        
        self.afterLogindetails(dict)
    }
    
    func serviceFailedWitherror(error : NSError){
        
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    
    //MARK:- Additional Action After Login
    
    func afterLogindetails(infoDict : NSDictionary){
       
        if(infoDict.objectForKey("status")!.isEqual("OK")){
            
            
            
            let sessionId = infoDict.objectForKey("sessionId") as! String
            let userId = infoDict.objectForKey("userId") as! String
            NSUserDefaults.standardUserDefaults().setObject(sessionId, forKey: "sessionId")
            NSUserDefaults.standardUserDefaults().setObject(userId, forKey: "userId")
            
            let currentInstallation = PFInstallation.currentInstallation()
                currentInstallation.setObject(userId, forKey: "userId")
                currentInstallation.saveInBackground()

            if(infoDict.objectForKey("isNewUser")?.intValue != 0){
                
                Parse.setApplicationId("RBOZIK8Vti138uqPIucaBherLAB16JFa3ITi4kDu",
                                       clientKey: "Kavc924t4PGsZzQdwUoLS6nz3q3Wm5PfRUjEDj9a")
                
            let searchScreen = self.storyboard!.instantiateViewControllerWithIdentifier("Unnamed") as! UnnamedViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(searchScreen, animated:true);
            }
            else{
                let region = infoDict.objectForKey("profile")?.objectForKey("cityName") as? String
                selectedCity = region!
                NSUserDefaults.standardUserDefaults().setObject(selectedCity, forKey: "citySelected")
                let currentInstallation = PFInstallation.currentInstallation()
                currentInstallation.setObject(region!, forKey: "cityName")
                currentInstallation.saveInBackground()
                
                let username = infoDict.objectForKey("userName")
                NSUserDefaults.standardUserDefaults().setObject(username, forKey: "userName")
                
                Flurry.setUserID(username as! String)
                var tbc : UITabBarController
                tbc = self.storyboard!.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController;
                tbc.selectedIndex=0;
                self.navigationController?.visibleViewController?.navigationController?.pushViewController(tbc, animated: true)
            }
        }
        else{
            
        }
    }
    
    @IBAction func legalButtonTapped(sender : UIButton){
        webViewCallingLegal = true
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("WebLink") as! WebLinkViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
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
