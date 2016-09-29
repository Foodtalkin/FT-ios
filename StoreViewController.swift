//
//  StoreViewController.swift
//  FoodTalk
//
//  Created by Ashish on 11/08/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit



class StoreViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, WebServiceCallingDelegate {

    @IBOutlet var storeTableView : UITableView?
    var storeArray = NSMutableArray()
    var adId = String()
    var scorePoints = Float()
    var lblPlaceHolder = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        storeTableView?.registerNib(UINib.init(nibName: "StoreTableViewCell", bundle: nil), forCellReuseIdentifier: "Store")
        
        let button: UIButton = UIButton(type: UIButtonType.Custom)
        button.setImage(UIImage(named: "redemed.png"), forState: UIControlState())
        button.addTarget(self, action: #selector(StoreViewController.rightButtonTabbed), forControlEvents: UIControlEvents.TouchUpInside)
        button.frame = CGRect(x: 15, y: 15, width: 20, height: 20)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.rightBarButtonItem = barButton
        
        let tblView =  UIView(frame: CGRect.zero)
        storeTableView!.tableFooterView = tblView
        storeTableView!.tableFooterView!.hidden = true
        storeTableView?.separatorColor = UIColor.lightGrayColor()
        
        showColorLoader(self.view)
        Flurry.logEvent("Store Screen")
        
        lblPlaceHolder.frame = CGRect(x: 0, y: self.view.frame.size.height/2 - 25, width: self.view.frame.size.width, height: 50)
        lblPlaceHolder.textAlignment = NSTextAlignment.Center
        lblPlaceHolder.text = "Nothing in your store :("
        lblPlaceHolder.textColor = UIColor.darkGrayColor()
        lblPlaceHolder.font = UIFont(name: fontBold, size: 16)
        self.view.addSubview(lblPlaceHolder)
        lblPlaceHolder.hidden = true
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      //  firstLabel.removeFromSuperview()
        cancelRequest()
        if (self.isMovingToParentViewController()){
            
            self.navigationController?.navigationBarHidden = true
        }
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        

        self.navigationController?.navigationBarHidden = false
        dispatch_async(dispatch_get_main_queue()){
            self.webCallStoreData()
        }
    }
    
    func rightButtonTabbed(){
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("BookStore") as! BookStoreViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    //MARK:- WebServiceCall
    
    func webCallStoreData(){
        if (isConnectedToNetwork()){
            
            let url = String(format: "%@%@%@", baseUrl, "adwords/", "list")
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            params.setObject(sessionId!, forKey: "sessionId" as NSCopying)
            
        //    webServiceCallingPost(url, parameters: params)
            webServiceCallingPost(url, parameters: params)
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
    }
    
    func webServiceForBooking(){
        if (isConnectedToNetwork()){
            
            let url = String(format: "%@%@%@", baseUrl, "adwords/", "bookslot")
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            params.setObject(sessionId!, forKey: "sessionId" as NSCopying)
            params.setObject(adId, forKey: "adId" as NSCopying)
            
        //    webServiceCallingPost(url, parameters: params)
            webServiceCallingPost(url, parameters: params)
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
    }
    
    func getDataFromWebService(dict : NSMutableDictionary){
        
        if(dict.objectForKey("api") as! String == "adwords/list"){
            if(dict.objectForKey("status") as! String == "OK"){
                if((dict.objectForKey("result") as! NSArray).count > 0){
                  storeArray = (dict.objectForKey("result") as! NSArray).mutableCopy() as! NSMutableArray
                }
                else{
                    storeArray = NSMutableArray()
                }
            }
            if(storeArray.count > 0){
               lblPlaceHolder.hidden = true
            }
            else{
               lblPlaceHolder.hidden = false
            }
        }
        else if(dict.objectForKey("api") as! String == "adwords/bookslot"){
            if(dict.objectForKey("status") as! String == "OK"){
                let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("BookStore") as! BookStoreViewController;
                self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            }
            else if(dict.objectForKey("errorCode") as! String == "106"){
                
            }
        }
        
        if(storeArray.count > 0){
        scorePoints = (((storeArray.objectAtIndex(0) as! NSDictionary).objectForKey("avilablePoints")?.floatValue))!
        self.title = String(format: "%.0f Points", scorePoints)
        }
        stopLoading(self.view)
        storeTableView?.reloadData()
    }
    
    func serviceFailedWitherror(_ error : NSError){
        internetMsg(self.view)
        stopLoading(self.view)
    }
    
    func serviceUploadProgress(_ myprogress : float_t){
        
    }

    //MARK:- TableViewDtasourceAndDelegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return storeArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
    //    let cell = tableView.dequeueReusableCell(withIdentifier: "Store", for: indexPath) as! StoreTableViewCell
     let  cell = tableView.dequeueReusableCellWithIdentifier("Store", forIndexPath: indexPath) as! StoreTableViewCell
        dispatch_async(dispatch_get_main_queue()){
          cell.imgStore!.hnk_setImageFromURL(NSURL(string: (self.storeArray.objectAtIndex(indexPath.row).objectForKey("adImage") as? String)!)!)
        }
    cell.lblRestaurant?.text = self.storeArray.objectAtIndex(indexPath .row).objectForKey("title") as? String
    cell.lblDescription1?.text = self.storeArray.objectAtIndex(indexPath .row).objectForKey("description") as? String
    cell.lblDescription2?.text = self.storeArray.objectAtIndex(indexPath .row) .objectForKey("description2") as? String
        
        if(self.storeArray.objectAtIndex(indexPath.row).objectForKey("points") as! String == "0"){
            cell.lblPoints?.hidden = true
        }
        else{
            cell.lblPoints?.text = String(format: "%@ Points", ((self.storeArray.objectAtIndex(indexPath.row) as! NSDictionary).objectForKey("points") as? String)!)
        }
        
    if((self.storeArray.objectAtIndex(indexPath .row) as! NSDictionary).objectForKey("type") as? String == "event"){
           cell.btnBookNow?.setTitle("BOOK NOW", forState: UIControlState())
        }
    else{
           cell.btnBookNow?.setTitle("REDEEM", forState: UIControlState())
        }
        
        cell.btnBookNow!.layer.cornerRadius = 2
        cell.btnBookNow!.clipsToBounds = true
        
        cell.selectionStyle = UITableViewCellSelectionStyle.None
    
        cell.btnBookNow?.tag = indexPath.row
        cell.btnBookNow!.addTarget(self, action: #selector(StoreViewController.bookEvent(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        if((storeArray.objectAtIndex(indexPath.row) as! NSDictionary).objectForKey("type") as! String == "event"){
        if((storeArray.objectAtIndex(indexPath.row) as! NSDictionary).objectForKey("iRedeemed") as! String == "0"){
          cell.btnBookNow?.setTitle("BOOK NOW", forState: UIControlState())
            cell.btnBookNow?.enabled = true
        }
        else{
          cell.btnBookNow?.setTitle("BOOKED", forState: UIControlState())
          //  cell.btnBookNow?.enabled = false
            cell.btnBookNow?.alpha = 0.6
        }
            cell.lblPoints?.hidden = false
        }
        else{
            if((storeArray.objectAtIndex(indexPath.row) as! NSDictionary).objectForKey("iRedeemed") as! String == "0"){
                cell.btnBookNow?.setTitle("REDEEM", forState: UIControlState())
                cell.btnBookNow?.enabled = true
                cell.btnBookNow?.alpha = 1.0
            }
            else{
                cell.btnBookNow?.setTitle("REDEEMED", forState: UIControlState())
               // cell.btnBookNow?.enabled = false
                cell.btnBookNow?.alpha = 0.6
            }
            cell.lblPoints?.hidden = true
        }
        
        if(scorePoints < ((self.storeArray.objectAtIndex(indexPath .row) as! NSDictionary).objectForKey("points")?.floatValue)){
            cell.btnBookNow?.alpha = 0.6
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
     
     return 135
    }
    
    //MARK:- Booking Start
    
    func bookEvent(_ sender : UIButton){
        if((storeArray.objectAtIndex(sender.tag) as! NSDictionary).objectForKey("iRedeemed") as! String == "0"){
        if(scorePoints > ((self.storeArray.objectAtIndex(sender.tag) as! NSDictionary).objectForKey("points")?.floatValue)){
            Flurry.logEvent("Redeem button tapped")
        adId = (storeArray.objectAtIndex(sender.tag) as! NSDictionary).objectForKey("id") as! String
       
            
            
            let alertController = UIAlertController(title: "", message: "", preferredStyle: .Alert)
            let attrubuted = NSMutableAttributedString(string: "Are you sure, you want to buy?")
            attrubuted.addAttribute(NSFontAttributeName, value: UIFont(name: fontBold, size: 17)!, range: NSMakeRange(0, 30))
            alertController.setValue(attrubuted, forKey: "attributedTitle")
            
            // Create the actions
            let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                
                showLoader(self.view)
                dispatch_async(dispatch_get_main_queue()) {
                    self.webServiceForBooking()
                }
                
            }
            let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) {
                UIAlertAction in
                
            }
            
            // Add the actions
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            
            // Present the controller
            self.presentViewController(alertController, animated: true, completion: nil)
            
            
        }
        else{
            
            let alertView = UIAlertView(title: "You don't have enough points.", message: nil, delegate: nil, cancelButtonTitle: "OK")
            alertView.show()
        }
        }
        else{
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("BookStore") as! BookStoreViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
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
