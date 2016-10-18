//
//  FollowersViewController.swift
//  FoodTalk
//
//  Created by Ashish on 06/05/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit

class FollowersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, WebServiceCallingDelegate {
    
    @IBOutlet var tblView : UITableView?
    var arrFollowers : NSMutableArray?
    var pageList : Int = 0
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        arrFollowers = NSMutableArray()
        showColorLoader(self.view)
        if(userListType == "follower"){
            self.title = "Followers"
        dispatch_async(dispatch_get_main_queue()) {
        self.webServiceCallFollowers()
        }
        }
        else if(userListType == "following"){
            self.title = "Following"
            dispatch_async(dispatch_get_main_queue()) {
                self.webServiceCallFollowing()
            }
        }
        else{
            self.title = "CheckIn"
            dispatch_async(dispatch_get_main_queue()) {
                self.webServiceCallCheckin()
            }
        }
    }
    
    //MARK:- WebServiceCall
    
    func webServiceCallFollowers(){
        if (isConnectedToNetwork()){
            let url = String(format: "%@%@%@", baseUrl,controllerFollowers,listFollowersMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(userIdForFollow, forKey: "selectedUserId")
            
//            webServiceCallingPost(url, parameters: params)
            delegate = self
            
            webServiceCallingPost(url, parameters: params)
        }
        else{
            internetMsg(view)
            stopLoading(self.view)
        }
    }
    
    func webServiceCallFollowing(){
        if (isConnectedToNetwork()){
            let url = String(format: "%@%@%@", baseUrl,controllerFollowers,follwedlist)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(userIdForFollow, forKey: "selectedUserId")
            
//            webServiceCallingPost(url, parameters: params)
            delegate = self
            
            webServiceCallingPost(url, parameters: params)
        }
        else{
            internetMsg(view)
            stopLoading(self.view)
        }
    }
    
    func webServiceCallCheckin(){
        if (isConnectedToNetwork()){
            pageList += 1
            let url = String(format: "%@%@%@", baseUrl,controllerUsers,"getCheckIn")
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(userIdForFollow, forKey: "selectedUserId")
            params.setObject(pageList, forKey: "page")
            
//            webServiceCallingPost(url, parameters: params)
            delegate = self
            
            webServiceCallingPost(url, parameters: params)
        }
        else{
            internetMsg(view)
            stopLoading(self.view)
        }
    }
    
    func serviceFailedWitherror(error : NSError){
        
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    func getDataFromWebService(dict : NSMutableDictionary){
        
        stopLoading(self.view)
        if(dict.objectForKey("api") as! String == "follower/listFollowers"){
            arrFollowers = dict.objectForKey("followers")?.mutableCopy() as? NSMutableArray
        }
        else if(dict.objectForKey("api") as! String == "follower/listFollowed"){
            arrFollowers = dict.objectForKey("followedUsers")?.mutableCopy() as? NSMutableArray
        }
        else if(dict.objectForKey("api") as! String == "user/getCheckIn"){
           // arrFollowers = dict.objectForKey("checkIn") as? NSMutableArray
            
            let arr = dict.objectForKey("checkIn")?.mutableCopy() as? NSMutableArray
            if(arr?.count > 0){
            for(var index  = 0; index < arr!.count; index += 1){
               let dict1 = arr!.objectAtIndex(index) as! NSMutableDictionary
               arrFollowers!.addObject(dict1)
            }
            }
        }
        
        tblView?.reloadData()
        hideProcessLoader(self.view)
    }
    
    //MARK:- tableViewDelegates
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (arrFollowers?.count)!
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
        }
        
        let iconView = UIView()
        iconView.frame = CGRectMake(15, 10, 34, 34)
        iconView.backgroundColor = UIColor(red: 236/255, green: 237/255, blue: 238/255, alpha: 1.0)
        iconView.tag = 29
        iconView.layer.cornerRadius = iconView.frame.size.width/2
        iconView.clipsToBounds = true
        
        
        let cellIcon = UIImageView()
        cellIcon.frame = CGRectMake(2, 2, 32, 32)
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
        cell.contentView.addSubview(cellSubText)
        
        if(userListType == "checkIn"){
            cellText.text = arrFollowers![indexPath.row].objectForKey("restaurantName") as? String
            cellSubText.text = arrFollowers![indexPath.row].objectForKey("area") as? String
            cellIcon.image = UIImage(named: "reatronIcon.png")
        }
        else{
            cellText.text = arrFollowers![indexPath.row].objectForKey("userName") as? String
            cellSubText.text = arrFollowers![indexPath.row].objectForKey("fullName") as? String
            
            dispatch_async(dispatch_get_main_queue()) {
                cellIcon.hnk_setImageFromURL(NSURL(string: (self.arrFollowers!.objectAtIndex(indexPath.row).objectForKey("thumb") as? String)!)!)
            }
        }
        
        if((cell.contentView.viewWithTag(22)) != nil){
            cell.contentView.viewWithTag(22)?.removeFromSuperview()
            cell.contentView.viewWithTag(28)?.removeFromSuperview()
            cell.contentView.viewWithTag(29)?.removeFromSuperview()
            cell.contentView.viewWithTag(2223)?.removeFromSuperview()
        }
        cell.contentView.addSubview(cellText)
        iconView.addSubview(cellIcon)
        cell.contentView.addSubview(iconView)
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 54
    }
    
    //MARK:- ScrollView Delegates
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if(userListType == "checkIn"){
        if(arrFollowers!.count > 0){
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
                        self.performSelector(#selector(FollowersViewController.webServiceCallCheckin), withObject: nil, afterDelay: 0.2)
                    }
                }
          }
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.locationInView(conectivityMsg)
            // do something with your currentPoint
            if(isConnectedToNetwork()){
                conectivityMsg.removeFromSuperview()
                dispatch_async(dispatch_get_main_queue()) {
                    if(userListType == "follower"){
                        self.title = "Followers"
                        dispatch_async(dispatch_get_main_queue()) {
                            self.webServiceCallFollowers()
                        }
                    }
                    else if(userListType == "following"){
                        self.title = "Following"
                        dispatch_async(dispatch_get_main_queue()) {
                            self.webServiceCallFollowing()
                        }
                    }
                    else{
                        self.title = "CheckIn"
                        dispatch_async(dispatch_get_main_queue()) {
                            self.webServiceCallCheckin()
                        }
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
