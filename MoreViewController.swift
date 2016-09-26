//
//  MoreViewController.swift
//  FoodTalk
//
//  Created by Ashish on 21/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit

var eventName = String()
var isSuggestion : Bool = false

class MoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate,  UITabBarControllerDelegate, UIGestureRecognizerDelegate, WebServiceCallingDelegate {
    
    @IBOutlet var tableView : UITableView?
    var moreArray : NSMutableArray = []
    
    var dict = NSDictionary()
    var refreshControl:UIRefreshControl!
    override func viewDidLoad() {
        super.viewDidLoad()
  //       delegate = self
        self.webserviceForCards()
        
        
        dict = (NSUserDefaults.standardUserDefaults().objectForKey("LoginDetails") as? NSMutableDictionary)!
        
        
        moreArray.addObject((dict.objectForKey("profile")?.objectForKey("userName") as? String)!)
        moreArray.addObject("Store")
        moreArray.addObject("Delhi-NCR")
        moreArray.addObject("City Guide")
        moreArray.addObject("Bookmark")
        moreArray.addObject("Find facebook friends")
        moreArray.addObject("Options")
        
        
        self.refreshControl = UIRefreshControl()
        let attr = [NSForegroundColorAttributeName:UIColor.grayColor()]
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh", attributes:attr)
        self.refreshControl.tintColor = UIColor.grayColor()
        
        self.refreshControl.addTarget(self, action: #selector(MoreViewController.refresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.tableView!.addSubview(refreshControl)
        
        Flurry.logEvent("More Screen")
        //  self.title = "More"
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        //     tableView!.backgroundColor = UIColor(red: 20/255, green: 29/255, blue: 45/255, alpha: 1.0)
        tableView?.backgroundColor = UIColor.whiteColor()
        tableView?.separatorColor = UIColor.lightGrayColor()
        let tblView =  UIView(frame: CGRectZero)
        tableView!.tableFooterView = tblView
        tableView!.tableFooterView!.hidden = true
        
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        
    }
    
    //MARK:- RefreshControl Method
    func refresh(_ sender:AnyObject)
    {
        moreArray = NSMutableArray()
        moreArray.addObject((dict.objectForKey("profile")?.objectForKey("userName") as? String)!)
        moreArray.addObject("Store")
        moreArray.addObject("Delhi-NCR")
        moreArray.addObject("City Guide")
        moreArray.addObject("Bookmark")
        moreArray.addObject("Find facebook friends")
        moreArray.addObject("Options")
        //        moreArray.addObject("Events and contests")
        dispatch_async(dispatch_get_main_queue()) {
            //        self.webServiceCallForEvents()
            self.refreshControl.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        selectedTabBarIndex = 4
        self.refreshControl.endRefreshing()
        self.navigationController?.navigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        cancelRequest()
        self.refreshControl.endRefreshing()
        super.viewWillDisappear(animated)
    }
    
    //MARK:- TableView Delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moreArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
        }
        
        self.addViewsOnCell(cell!, index: (indexPath as NSIndexPath).row)
        if((indexPath as NSIndexPath).row == 6){
            //            cell.backgroundColor = UIColor.blackColor()
            cell?.textLabel?.textColor = UIColor.blackColor()
            cell?.backgroundColor = UIColor.whiteColor()
            if(moreArray.count > 0){
                //   cell.textLabel?.text = moreArray.objectAtIndex(indexPath.row) as? String
            }
        }
        else{
            cell?.backgroundColor = UIColor.whiteColor()
        }
        cell?.selectionStyle = UITableViewCellSelectionStyle.None
        return cell!
    }

    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row == 4){
            return 58
        }
        return 58
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if((indexPath as NSIndexPath).row == 0){
            isUserInfo = true
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfile") as! UserProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
        else if((indexPath as NSIndexPath).row == 1){
            
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("Store") as! StoreViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
            
        else if((indexPath as NSIndexPath).row == 3){
            
            isSuggestion = true
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("FoodTalkSuggestions") as! FoodTalkSuggestionsViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            
        }
        else if((indexPath as NSIndexPath).row == 4){
            
            
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("Favorite") as! FavoriteViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            
        }
        else if((indexPath as NSIndexPath).row == 2){
            
        }
        else if((indexPath as NSIndexPath).row == 5){
            
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("FacebookFriends") as! FacebookFriendsViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
        else if((indexPath as NSIndexPath).row == 6){
            
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier( "Options") as! OptionsViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            
        }
        else{
            if(isConnectedToNetwork()){
                webViewCallingLegal = false
                if(self.moreArray.count > 0){
                    eventName = ((self.moreArray.objectAtIndex(indexPath.row) as! NSDictionary).objectForKey( "name") as? String)!
                    webViewLink = (self.moreArray.objectAtIndex(indexPath.row) as! NSDictionary).objectForKey("url") as! String
                    let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("WebLink") as! WebLinkViewController;
                    self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
                }
            }
        }
        
    }
    
    func addViewsOnCell(_ cell : UITableViewCell, index : Int){
        
        
        if(index == 0){
            let imgView = UIImageView()
            imgView.frame = CGRectMake(18, 9, 40, 40)
            imgView.contentMode = UIViewContentMode.ScaleAspectFit
            
            imgView.hnk_setImageFromURL(NSURL(string: (dict.objectForKey("profile")?.objectForKey("thumb") as? String)!)!)
            imgView.layer.cornerRadius = 20
            imgView.layer.masksToBounds = true
            cell.contentView.addSubview(imgView)
        }
        else{
            
            let optionIcon = UIImageView()
            let optionViewBook = UIView()
            let imgBookMark = UIImageView()
            imgBookMark.tag = 232323
            
            if(index == 2){
                optionViewBook.frame = CGRect(x: 18, y: 9, width: 40, height: 40)
                optionViewBook.backgroundColor = UIColor(red: 28/255, green: 103/255, blue: 204/255, alpha: 1.0)
                optionViewBook.layer.cornerRadius = 20
                optionIcon.layer.masksToBounds = true
                cell.contentView.addSubview(optionViewBook)
                
                imgBookMark.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
                imgBookMark.image = UIImage(named: "location.png")
                optionViewBook.addSubview(imgBookMark)
            }
            else if(index == 3){
                
                optionViewBook.frame = CGRect(x: 18, y: 9, width: 40, height: 40)
                optionViewBook.backgroundColor = UIColor.redColor()
                optionViewBook.layer.cornerRadius = 20
                optionIcon.layer.masksToBounds = true
                cell.contentView.addSubview(optionViewBook)
                
                imgBookMark.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
                imgBookMark.image = UIImage(named: "likeIcon.png")
                
                if((cell.contentView.viewWithTag(232323)) != nil){
                    cell.contentView.viewWithTag(232323)?.removeFromSuperview()
                }
                optionViewBook.addSubview(imgBookMark)
            }
            else if(index == 4){
                optionViewBook.frame = CGRect(x: 18, y: 9, width: 40, height: 40)
                optionViewBook.backgroundColor = UIColor(red: 255/255, green: 253/255, blue: 10/255, alpha: 1.0)
                optionViewBook.layer.cornerRadius = 20
                optionIcon.layer.masksToBounds = true
                cell.contentView.addSubview(optionViewBook)
                
                imgBookMark.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
                imgBookMark.image = UIImage(named: "bookmark (1).png")
                optionViewBook.addSubview(imgBookMark)
            }
            else if(index == 5){
                optionViewBook.frame = CGRect(x: 18, y: 9, width: 40, height: 40)
                optionViewBook.backgroundColor = UIColor(red: 65/255, green: 87/255, blue: 148/255, alpha: 1.0)
                optionViewBook.layer.cornerRadius = 20
                optionIcon.layer.masksToBounds = true
                cell.contentView.addSubview(optionViewBook)
                
                imgBookMark.frame = CGRect(x: 7, y: 8, width: 20, height: 20)
                imgBookMark.image = UIImage(named: "fb-logo.png")
                optionViewBook.addSubview(imgBookMark)
            }
            else if(index == 6){
                
                optionViewBook.frame = CGRect(x: 18, y: 9, width: 40, height: 40)
                optionViewBook.backgroundColor = UIColor(red: 65/255, green: 87/255, blue: 148/255, alpha: 1.0)
                optionViewBook.layer.cornerRadius = 20
                optionIcon.layer.masksToBounds = true
                cell.contentView.addSubview(optionViewBook)
                
                imgBookMark.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
                imgBookMark.image = UIImage(named: "settings.png")
                optionViewBook.addSubview(imgBookMark)
            }
            else if(index == 1){
                optionViewBook.frame = CGRect(x: 18, y: 9, width: 40, height: 40)
                optionViewBook.backgroundColor = UIColor(red: 37/255, green: 203/255, blue: 207/255, alpha: 1.0)
                optionViewBook.layer.cornerRadius = 20
                optionIcon.layer.masksToBounds = true
                cell.contentView.addSubview(optionViewBook)
                
                imgBookMark.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
                imgBookMark.image = UIImage(named: "store.png")
                optionViewBook.addSubview(imgBookMark)
            }
            
            
            
        }
        
        if(index == 0){
            let statuslabel = UILabel()
            statuslabel.frame = CGRectMake(74, 8, UIScreen.mainScreen().bounds.size.width - 128, 20)
            statuslabel.textColor = UIColor.blackColor()
            statuslabel.numberOfLines = 0
            statuslabel.font = UIFont(name:fontName, size: 16.0)
            if(moreArray.count > 0){
                statuslabel.text = moreArray.objectAtIndex(index) as? String
            }
            cell.contentView.addSubview(statuslabel)
            
            let statuslabel1 = UILabel()
            statuslabel1.frame = CGRectMake(74, 30, UIScreen.mainScreen().bounds.size.width - 128, 20)
            statuslabel1.textColor = UIColor.grayColor()
            statuslabel1.font = UIFont(name:fontName, size: 15.0)
            statuslabel1.numberOfLines = 0
            statuslabel1.text = (dict.objectForKey("profile")?.objectForKey("fullName") as? String)!
            cell.contentView.addSubview(statuslabel1)
            
        }
        else{
            let statuslabel = UILabel()
            statuslabel.tag = 3333
            statuslabel.frame = CGRectMake(74, 0, UIScreen.mainScreen().bounds.size.width - 128, 58)
            if(index == 2){
                if((dict.objectForKey( "profile")!.objectForKey("cityName")) != nil){
                    statuslabel.text = (dict.objectForKey("profile")!.objectForKey("cityName") as? String)
                }
                else{
                    statuslabel.text = (dict.objectForKey("profile")!.objectForKey("region") as? String)!
                }
                statuslabel.textColor = UIColor.grayColor()
            }
            else{
                statuslabel.textColor = UIColor.blackColor()
            }
            
            statuslabel.numberOfLines = 0
            statuslabel.font = UIFont(name:fontName, size: 18.0)
            if(index < 7){
                if(index != 2){
                    statuslabel.text = moreArray.objectAtIndex(index) as? String
                }
            }
            else{
                if(moreArray.count > 0){
                    if(moreArray.count > 5){
                        statuslabel.text = moreArray.objectAtIndex(index).objectForKey("name") as? String
                    }
                }
            }
            if((cell.contentView.viewWithTag(3333)) != nil){
                cell.contentView.viewWithTag(3333)?.removeFromSuperview()
            }
            cell.contentView.addSubview(statuslabel)
        }
    }
    
    //MARK:- CallWebServiceForEvents
    
    func webServiceCallForEvents(){
        if (isConnectedToNetwork()){
            
            let url = "http://api.foodtalkindia.com/getfeeds"
            
            webServiceGet(url)
            delegate = self
           
        }
        else{
            internetMsg(view)
            stopLoading(self.view)
            self.refreshControl.endRefreshing()
            self.tabBarController?.tabBar.userInteractionEnabled = true
        }
        self.refreshControl.endRefreshing()
    }
    
    func webserviceForCards(){
        //    if(dictLocations.objectForKey("latitude") != nil){
        if (isConnectedToNetwork()){
            
            let url = String(format: "%@%@%@", baseUrl,controllerUsers,getprofileMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            var followedUserId = ""
            
            followedUserId = NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String
            
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId" as NSCopying)
            params.setObject(followedUserId, forKey: "selectedUserId" as NSCopying)
            params.setObject("1", forKey: "page" as NSCopying)
            params.setObject("10", forKey: "recordCount" as NSCopying)
            
//            webServiceCallingPost(url, parameters: params)
            delegate = self
            webServiceCallingPost(url, parameters: params)
        }
        else{
            internetMsg(view)
        }
        
    }
    
    func getDataFromWebService(_ dict1 : NSMutableDictionary){
        if(dict1.objectForKey("api") as! String == "user/getProfile"){
            if(dict1.objectForKey("status") as! String == "OK"){
                NSUserDefaults.standardUserDefaults().setObject(dict1, forKey: "LoginDetails")
                dict = dict1
            }
        }
            
        else
        {
            
            if((dict1.objectForKey("code")) != nil){
                if(dict1.objectForKey("code") as! String == "200"){
                    var arr = NSArray()
                    arr = dict1.objectForKey("result")?.objectForKey("data") as! NSArray
                    for(var index : Int = 0; index < arr.count; index += 1){
                        moreArray.addObject(arr.objectAtIndex(index))
                    }
                }
            }
        }
        
        self.tabBarController?.tabBar.userInteractionEnabled = true
        
        tableView?.reloadData()
        self.refreshControl.endRefreshing()
        stopLoading(self.view)
    }
    
    func serviceFailedWitherror(_ error : NSError){
   //     internetMsg(self.view)
        stopLoading(self.view)
        self.tabBarController?.tabBar.userInteractionEnabled = true
    }
    
    func serviceUploadProgress(_ myprogress : float_t){
        
    }
    
    //MARK:- TabBarController Delegate
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        tableView!.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        self.navigationController?.popToRootViewControllerAnimated(false)
        selectedTabBarIndex = 4
    }
    
    //MARK:- stop back gesture
    
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
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
