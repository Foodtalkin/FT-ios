//
//  FavoriteViewController.swift
//  FoodTalk
//
//  Created by Ashish on 15/01/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit

class FavoriteViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, WebServiceCallingDelegate {
    
    @IBOutlet var favTableView : UITableView?
    var arrFavList : NSMutableArray = []
    var pageList : Int = 0
    
    var lblNoFav = UILabel()
    var imgNoFav = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "My Bucket List"
        Flurry.logEvent("Favorite Screen")
        
        imgNoFav.frame = CGRectMake(self.view.frame.size.width / 2 - 11, 150, 22, 26)
        imgNoFav.image = UIImage(named: "bookmark (1).png")
        self.view.addSubview(imgNoFav)
        
        lblNoFav.frame = CGRectMake(0, 200, self.view.frame.size.width, 20)
        lblNoFav.text = "Nothing in your bucket list."
        lblNoFav.textColor = UIColor.grayColor()
        lblNoFav.textAlignment = NSTextAlignment.Center
        lblNoFav.font = UIFont(name: fontBold, size: 15)
        self.view.addSubview(lblNoFav)
        
        imgNoFav.hidden = true
        lblNoFav.hidden = true
        
        favTableView?.backgroundColor = UIColor.whiteColor()
        favTableView?.separatorColor = UIColor.lightGrayColor()
        let tblView =  UIView(frame: CGRectZero)
        favTableView!.tableFooterView = tblView
        favTableView!.tableFooterView!.hidden = true
        dispatch_async(dispatch_get_main_queue()) {
          self.callWebServiceMethods()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = false
    }
    
    //MARK:- WebServices and Delegates
    
    func callWebServiceMethods(){
        if(isConnectedToNetwork()){
            pageList += 1
            showLoader(self.view)
            let url = String(format: "%@%@%@", baseUrl,controllerBookmark,postListMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(pageList, forKey: "page")
       //     webServiceCallingPost(url, parameters: params)
            webServiceCallingPost(url, parameters: params)
            delegate = self
        }
        else{
            internetMsg(view)
        }
    }
    
    func getDataFromWebService(dict : NSMutableDictionary){
        stopLoading(self.view)
        
        if(dict.objectForKey("status") as! String == "OK"){
            let arr = dict.objectForKey("dish")?.mutableCopy() as! NSMutableArray
            for(var index: Int = 0; index < arr.count; index += 1){
                arrFavList.addObject(arr.objectAtIndex(index))
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
        hideProcessLoader(self.view)
        if(arrFavList.count < 1){
            imgNoFav.hidden = false
            lblNoFav.hidden = false
        }
         favTableView?.reloadData()
    }
    
    func serviceFailedWitherror(error : NSError){
        
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    //MARK:- Tableview datasource and delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFavList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        cell.backgroundColor = UIColor.clearColor()
        
        if(arrFavList.count > 0){
         dispatch_async(dispatch_get_main_queue()) {
        let iconView = UIView()
        iconView.frame = CGRectMake(20, 10, 34, 34)
        iconView.backgroundColor = UIColor(red: 255/255, green: 253/255, blue: 10/255, alpha: 1.0)
        iconView.tag = 29
        iconView.layer.cornerRadius = iconView.frame.size.width/2
        iconView.clipsToBounds = true
        
        
        let cellIcon = UIImageView()
        cellIcon.frame = CGRectMake(7, 7, 20, 20)
        cellIcon.layer.cornerRadius = cellIcon.frame.size.width/2
            dispatch_async(dispatch_get_main_queue()) {
        cellIcon.image = UIImage(named: "bookmark (1).png")
            }
        cellIcon.clipsToBounds = true
        iconView.addSubview(cellIcon)
        
        let favName = UILabel()
        favName.frame = CGRectMake(70, 5, cell.frame.size.width - 60, 20)
        favName.tag = 1022
           
        favName.text = self.arrFavList.objectAtIndex(indexPath.row).objectForKey("dishName") as? String
            
            favName.font = UIFont(name: fontName, size: 16)
        favName.textColor = UIColor.blackColor()
        cell.contentView.addSubview(iconView)
        
            let favRest = UILabel()
            favRest.frame = CGRectMake(70, 26, cell.frame.size.width - 60, 20)
            favRest.tag = 1023
            if((self.arrFavList.objectAtIndex(indexPath.row).objectForKey("restaurantName") as? String)?.characters.count > 0){
                
            favRest.text = self.arrFavList.objectAtIndex(indexPath.row).objectForKey("restaurantName") as? String
                
            }
            favRest.font = UIFont(name: fontName, size: 14)
            favRest.textColor = UIColor.grayColor()
            
        
            if((cell.contentView.viewWithTag(1022)) != nil){
                cell.contentView.viewWithTag(1022)?.removeFromSuperview()
                cell.contentView.viewWithTag(1023)?.removeFromSuperview()
            }
            cell.contentView.addSubview(favName)
            cell.contentView.addSubview(favRest)
            }
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 54
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        postIdOpenPost = arrFavList.objectAtIndex(indexPath.row).objectForKey("id") as! String
        
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("OpenPost") as! OpenPostViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    //MARK:- ScrollView Delegates
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
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
               self.callWebServiceMethods()
                
            }
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       
        
        for var view : UIView in self.view.subviews {
            if(view == conectivityMsg){
                if(isConnectedToNetwork()){
                    conectivityMsg.removeFromSuperview()
                    dispatch_async(dispatch_get_main_queue()) {
                        self.pageList = 0
                        self.callWebServiceMethods()
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
