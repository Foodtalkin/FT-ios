//
//  FacebookFriendsViewController.swift
//  FoodTalk
//
//  Created by Ashish on 27/05/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit

class FacebookFriendsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WebServiceCallingDelegate {
    
    @IBOutlet var tableView : UITableView?
    var arrFbIds = NSMutableArray()
    var strFb = String()
    var arrResponseArray = NSMutableArray()
    var nextFbString = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        strFb = ""
        if(NSUserDefaults.standardUserDefaults().objectForKey("facebookFriends") != nil){
        arrayFacebookFriends = NSUserDefaults.standardUserDefaults().objectForKey("facebookFriends") as! NSMutableArray
        }
        // Do any additional setup after loading the view.
        if(arrayFacebookFriends.count > 0){
        for(var index = 0;index < arrayFacebookFriends.count; index++){
            arrFbIds.addObject(arrayFacebookFriends.objectAtIndex(index).objectForKey("id") as! String)
            let ids = String(format: "%@,",arrayFacebookFriends.objectAtIndex(index).objectForKey("id") as! String)
            strFb = strFb.stringByAppendingString(ids)
        }
        strFb = strFb.substringToIndex(strFb.endIndex.predecessor())
        
        if(NSUserDefaults.standardUserDefaults().objectForKey("nextFb") != nil){
        nextFbString = NSUserDefaults.standardUserDefaults().objectForKey("nextFb") as! String
        }
        
        self.title = "Find facebook friends"
        
        if(isConnectedToNetwork()){
         showLoader(self.view)
         webServiceCalling()
    delegate = self
        }
        else{
           internetMsg(self.view)
        }
        }
        self.tableView!.backgroundColor = UIColor.whiteColor()
        let tblView =  UIView(frame: CGRectZero)
        tableView!.tableFooterView = tblView
        tableView!.tableFooterView!.hidden = true
        tableView?.separatorColor = UIColor.lightGrayColor()
    }
    
    
    
    //MARK:- Create FBids and string
    
    func convertArray(arrarFB : NSMutableArray){
        
    }
    
    //MARK:- webservice methods
    
    func webServiceCalling(){
        if (isConnectedToNetwork()){
            
                let url = String(format: "%@%@%@", baseUrl, controllerUser, "getUsersByFacebookIds")
                let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
                let params = NSMutableDictionary()
                params.setObject(sessionId!, forKey: "sessionId")
                params.setObject(strFb, forKey: "facebookIds")
            
          //      webServiceCallingPost(url, parameters: params)
            webServiceCallingPost(url, parameters: params)
            delegate = self
            }
    }
    
    func webServiceForNext(){
        if (isConnectedToNetwork()){
            
            let url = nextFbString
         webServiceGet(url)
           }
    }
    
    //MARK:- ScrollView Delegates
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if(nextFbString != ""){
        let offset = scrollView.contentOffset
        let bounds = scrollView.bounds
        let size = scrollView.contentSize
        let inset = scrollView.contentInset
        let y = offset.y + bounds.size.height - inset.bottom as CGFloat
        let h = size.height as CGFloat
        let reload_distance = 0.0 as CGFloat
        if(y > h + reload_distance) {
             showProcessLoder(self.view)
            dispatch_async(dispatch_get_main_queue()) {
                    self.webServiceForNext()
                
            }
        }
        }
    }
    
    //MARK:- webServiceDelegates
    
    func getDataFromWebService(dict: NSMutableDictionary) {
        
        if((dict.objectForKey("api")) != nil){
            hideProcessLoader(self.view)
        if(dict.objectForKey("api") as! String == "user/getUsersByFacebookIds"){
        if(dict.objectForKey("status") as! String == "OK"){
            arrResponseArray = (dict.objectForKey("users") as! NSArray).mutableCopy() as! NSMutableArray
            stopLoading(self.view)
            tableView?.reloadData()
        }
        }
        }
        else{
           let arrFbIdArray = NSMutableArray()
          let arrayFbId = (dict.objectForKey("data") as! NSArray).mutableCopy() as! NSMutableArray
            for(var index = 0;index < arrayFbId.count; index++){
                arrFbIdArray.addObject(arrayFbId.objectAtIndex(index).objectForKey("id") as! String)
                let ids = String(format: "%@,",arrayFbId.objectAtIndex(index).objectForKey("id") as! String)
                strFb = strFb.stringByAppendingString(ids)
            }
            strFb = strFb.substringToIndex(strFb.endIndex.predecessor())
            webServiceCalling()
            if((dict.objectForKey("paging")?.objectForKey("next")) != nil){
            nextFbString = (dict.objectForKey("paging") as! NSDictionary).objectForKey("next") as! String
            
            }
            else{
             nextFbString = ""
            }
        }
    }
    
    func serviceFailedWitherror(error : NSError){
        
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    //MARK:- tableViewDatasource and Delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrResponseArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.backgroundColor = UIColor.clearColor()
        
        let iconView = UIView()
        iconView.frame = CGRectMake(15, 10, 34, 34)
        iconView.backgroundColor = UIColor(red: 236/255, green: 237/255, blue: 238/255, alpha: 1.0)
        iconView.tag = 29
        iconView.layer.cornerRadius = iconView.frame.size.width/2
        iconView.clipsToBounds = true
        
        
        let cellIcon = UIImageView()
        cellIcon.frame = CGRectMake(0, 0, 34, 34)
        cellIcon.layer.cornerRadius = cellIcon.frame.size.width/2
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
        
        let cellFollow = UILabel()
        cellFollow.frame = CGRectMake(tableView.frame.size.width - 140, 15, 120, 20)
        cellFollow.font = UIFont(name: fontName, size: 15)
        cellFollow.textAlignment = NSTextAlignment.Right
        cellFollow.textColor = UIColor.grayColor()
        cellFollow.tag = 234
        
        
        if(arrResponseArray.count > 0){
            cellText.text = arrResponseArray.objectAtIndex(indexPath.row).objectForKey("userName") as? String
            cellSubText.text = arrResponseArray.objectAtIndex(indexPath.row).objectForKey("fullName") as? String
            dispatch_async(dispatch_get_main_queue()) {
            cellIcon.hnk_setImageFromURL(NSURL(string: (self.arrResponseArray.objectAtIndex(indexPath.row).objectForKey("thumb") as? String)!)!)
            }
            if(self.arrResponseArray.objectAtIndex(indexPath.row).objectForKey("iFollowedIt") as? String == "1"){
                cellFollow.textColor = UIColor.grayColor()
                cellFollow.text = "Following"
            }
            else{
                cellFollow.textColor = UIColor.greenColor()
                cellFollow.text = "Follow"
            }
        }
        
        if((cell.contentView.viewWithTag(22)) != nil){
            cell.contentView.viewWithTag(22)?.removeFromSuperview()
            cell.contentView.viewWithTag(28)?.removeFromSuperview()
            cell.contentView.viewWithTag(29)?.removeFromSuperview()
            cell.contentView.viewWithTag(234)?.removeFromSuperview()
        }
        
        cell.contentView.addSubview(cellText)
        iconView.addSubview(cellIcon)
        cell.contentView.addSubview(iconView)
        cell.contentView.addSubview(cellFollow)
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 58
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       
        
        for var view : UIView in self.view.subviews {
            if(view == conectivityMsg){
                if(isConnectedToNetwork()){
                    conectivityMsg.removeFromSuperview()
                    dispatch_async(dispatch_get_main_queue()) {
                        showLoader(self.view)
                        self.webServiceCalling()
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
