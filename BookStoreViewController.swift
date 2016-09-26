//
//  BookStoreViewController.swift
//  FoodTalk
//
//  Created by Ashish on 12/08/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit

var isBuyNowOn : Bool = false

class BookStoreViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, WebServiceCallingDelegate {
    
    @IBOutlet var bookStoreTable : UITableView?
    var arrayBookingHistory = NSMutableArray()
    var lblPlaceHolder = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Purchases"
        Flurry.logEvent("Purchases Screen")
        // Do any additional setup after loading the view.
     //   bookStoreTable.register(UINib(nibName: "BookStoreTableViewCell", bundle: nil), forCellReuseIdentifier: "BookStore")
        bookStoreTable?.registerNib(UINib.init(nibName: "BookStoreTableViewCell", bundle: nil), forCellReuseIdentifier: "BookStore")
        // Do any additional setup after loading the view.
        showColorLoader(self.view)
        dispatch_async(dispatch_get_main_queue()){
        self.webServiceBookHistory()
        }
        
        let tblView =  UIView(frame: CGRect.zero)
        bookStoreTable!.tableFooterView = tblView
        bookStoreTable!.tableFooterView!.hidden = true
        bookStoreTable?.separatorColor = UIColor.lightGrayColor()
        
        lblPlaceHolder.frame = CGRect(x: 0, y: self.view.frame.size.height/2 - 25, width: self.view.frame.size.width, height: 50)
        lblPlaceHolder.textAlignment = NSTextAlignment.Center
        lblPlaceHolder.text = "No event has been booked :("
        lblPlaceHolder.textColor = UIColor.blackColor()
        self.view.addSubview(lblPlaceHolder)
        lblPlaceHolder.hidden = true
    }
    
    func webServiceBookHistory(){
        if (isConnectedToNetwork()){
            
            let url = String(format: "%@%@%@", baseUrl, "adwords/", "redeedmed")
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            params.setObject(sessionId!, forKey: "sessionId" as NSCopying)
            
            webServiceCallingPost(url, parameters: params)
           
            
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
    }
    
    //MARK:- WebService Delegates
    
    func getDataFromWebService(_ dict : NSMutableDictionary){
        
        if(dict.objectForKey("api") as! String == "adwords/redeedmed"){
            if((dict.objectForKey("status")! as! String).isEqual("OK")){
           arrayBookingHistory = dict.objectForKey("result")?.mutableCopy() as! NSMutableArray
            }
            else if((dict.objectForKey("status")! as! String).isEqual("error")){
                if((dict.objectForKey("errorCode") as! NSNumber).isEqual(6)){
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "sessionId")
                    NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userId")
                    self.dismissViewControllerAnimated(true, completion: nil)
                    
                    let nav = (self.navigationController?.viewControllers)! as NSArray
                    if(!(nav.objectAtIndex(0) as! UIViewController).isKindOfClass(LoginViewController)){
                        for viewController in nav {
                            // some process
                            if (viewController as! UIViewController).isKindOfClass(LoginViewController) {
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
        if(arrayBookingHistory.count > 0){
            lblPlaceHolder.hidden = true
        }
        else{
            lblPlaceHolder.hidden = false
        }
        stopLoading(self.view)
        bookStoreTable?.reloadData()
    }
    
    func serviceFailedWitherror(_ error : NSError){
        internetMsg(self.view)
        stopLoading(self.view)
    }
    
    func serviceUploadProgress(_ myprogress : float_t){
        
    }
    
    //MARK:- TableView Delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayBookingHistory.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
       // let cell = tableView.dequeueReusableCell(withIdentifier: "BookStore", for: indexPath) as! BookStoreTableViewCell
        
        let cell = tableView.dequeueReusableCellWithIdentifier("BookStore", forIndexPath: indexPath) as! BookStoreTableViewCell
        
        cell.lblPurchaseLabel?.text = String(format: "   Purchased on %@", ((arrayBookingHistory.objectAtIndex(indexPath .row) as! NSMutableDictionary).objectForKey("bookedOn") as? String)!)
        cell.lblTitle?.text = arrayBookingHistory.objectAtIndex(indexPath.row).objectForKey("title") as? String
        cell.lblPoint?.text = String(format: "%@ Point paid", ((arrayBookingHistory.objectAtIndex(indexPath.row).objectForKey("points") as? String))!)
        
        if((arrayBookingHistory.objectAtIndex(indexPath.row) as! NSMutableDictionary).objectForKey("type") as? String == "event"){
        cell.lblDiscription?.text = "Your name will be on our guestlist."
            cell.lblPoint?.hidden = false
            cell.lblCouponCode?.hidden = true
            cell.btnBuy?.hidden = true
            cell.lblTap?.hidden = true
        }
        else{
            
        cell.lblDiscription?.text = (arrayBookingHistory.objectAtIndex(indexPath.row) as! NSMutableDictionary).objectForKey("description2") as? String
            cell.lblPoint?.hidden = true
            cell.lblCouponCode?.hidden = false
            cell.btnBuy?.hidden = false
            cell.lblTap?.hidden = false
            cell.lblCouponCode?.text = String(format: "Code : %@", ((arrayBookingHistory.objectAtIndex(indexPath.row) as! NSMutableDictionary).objectForKey("couponCode") as? String)!)
            cell.btnCupon?.tag = (indexPath as NSIndexPath).row
            cell.btnBuy?.tag = (indexPath as NSIndexPath).row
            cell.btnCupon!.addTarget(self, action: #selector(BookStoreViewController.copyCupon(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.btnBuy!.addTarget(self, action: #selector(BookStoreViewController.openBrowser(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        }
    
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if((arrayBookingHistory.objectAtIndex(indexPath.row) as! NSMutableDictionary).objectForKey("type") as? String == "event"){
        return 94
        }
        else{
            return 128
        }
    }
    
    //MARK:- CopyCupon Code
    
    func copyCupon(_ sender : UIButton){
        self.navigationController?.view.makeToast("copied..")
        
        UIPasteboard.init(name: (arrayBookingHistory.objectAtIndex(sender.tag).objectForKey("couponCode") as? String)!, create: true)
    }
    
    //MARK:- OpenInAppBrowser
    
    func openBrowser(_ sender : UIButton){
        isBuyNowOn = true
        webViewLink = ((arrayBookingHistory.objectAtIndex(sender.tag) as! NSMutableDictionary).objectForKey("paymentUrl") as? String)!
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("WebLink") as! WebLinkViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
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
