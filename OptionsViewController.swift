//
//  OptionsViewController.swift
//  FoodTalk
//
//  Created by Ashish on 24/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit
import MessageUI

class OptionsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate, WebServiceCallingDelegate {
    
    @IBOutlet var tableView : UITableView?
    var optionsArray : NSMutableArray = ["Push Notifications","Invite facebook friends","Contact us","Legal","Logout"]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView?.separatorColor = UIColor.lightGrayColor()
        let tblView =  UIView(frame: CGRectZero)
        tableView!.tableFooterView = tblView
        tableView!.tableFooterView!.hidden = true
        self.title = "Options"
    }
    
    //MARK:- TableView delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return optionsArray.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
        }
        
        cell.backgroundColor = UIColor.whiteColor()
        cell.textLabel?.textColor = UIColor.blackColor()
        cell.textLabel?.text = optionsArray.objectAtIndex(indexPath.row) as? String
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        
        if(indexPath.row == 0){
            let switchO = UISwitch()
            switchO.frame = CGRectMake(cell.frame.size.width - 60, 7, 60, 30)
            switchO.setOn(false, animated: true)
            switchO.backgroundColor = UIColor.clearColor()
            switchO.onTintColor = UIColor.blackColor()
            switchO.addTarget(self, action: #selector(OptionsViewController.switchOnOff(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            cell.contentView.addSubview(switchO)
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
         if(indexPath.row == 1){
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("Invite") as! InviteViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
        
        if(indexPath.row == 2){
            
            let emailTitle = "Contact Us"
            let messageBody = ""
            let toRecipents = ["info@foodtalkindia.com"]
            let mc: MFMailComposeViewController = MFMailComposeViewController()
            if (MFMailComposeViewController.canSendMail()) {
            mc.mailComposeDelegate = self
            mc.setSubject(emailTitle)
            mc.setMessageBody(messageBody, isHTML: true)
            mc.setToRecipients(toRecipents)
            
            self.presentViewController(mc, animated: true, completion: nil)
            }
        }
        
        if(indexPath.row == 4){
            let alertController = UIAlertController(title: "", message: "", preferredStyle: .Alert)
            
            let attrubuted = NSMutableAttributedString(string: "Are you sure want to logout?")
            attrubuted.addAttribute(NSFontAttributeName, value: UIFont(name: fontBold, size: 17)!, range: NSMakeRange(0, 28))
            alertController.setValue(attrubuted, forKey: "attributedTitle")

            let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                self.webserviceCallingLogout()
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "facebookFriends")
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userName")
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "citySelected")
                PFUser.logOut()
                PFInstallation.currentInstallation().deleteEventually()
                Flurry.logEvent("Logout User Tabbed")
                NSLog("OK Pressed")
            }
            let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel) {
                UIAlertAction in
                NSLog("Cancel Pressed")
            }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)

            self.presentViewController(alertController, animated: true, completion: nil)
        }
        if(indexPath.row == 3){
            if(isConnectedToNetwork()){
            webViewCallingLegal = true
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("WebLink") as! WebLinkViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            }
            else{
                internetMsg(self.view)
            }
        }
    }
    
    //MARK:- WebService Calling and Delegates
    
    func webserviceCallingLogout(){
        if(isConnectedToNetwork()){
        showLoader(self.view)
        let url = String(format: "%@%@%@", baseUrl,controllerUser,logoutMethod)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
    //    webServiceCallingPost(url, parameters: params)
            webServiceCallingPost(url, parameters: params)
        delegate = self
        }
        else{
            internetMsg(view)
        }
    }
    
    func webServiceCallingDelete(){
        if(isConnectedToNetwork()){
        showLoader(self.view)
        let url = String(format: "%@%@%@", baseUrl,controllerUser,commentDeleteMethod)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
    //    webServiceCallingPost(url, parameters: params)
            webServiceCallingPost(url, parameters: params)
        delegate = self
        }
        else{
            internetMsg(view)
        }
    }
    
    func getDataFromWebService(dict : NSMutableDictionary){
        
        if(dict.objectForKey("api") as! String == "user/logout"){
            if(dict.objectForKey("status") as! String == "OK"){
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
        else if(dict.objectForKey("api") as! String == "user/delete"){
            if(dict.objectForKey("status") as! String == "OK"){
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "sessionId")
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userId")
                self.dismissViewControllerAnimated(true, completion: nil)
                self.navigationController?.popToRootViewControllerAnimated(true)
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
        
        stopLoading(self.view)
    }
    
    func serviceFailedWitherror(error : NSError){
        
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    
    //MARK:- AlertButton Methods
    
    func okAction(){
        
    }
    
    func cancelAction(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func deleteAction(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func deleteCancel(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func switchOnOff(sender : UISwitch){
        
    }
    
    //MARK:- mailComposer delegate
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        switch result.rawValue {
        case MFMailComposeResultCancelled.rawValue:
            print("Mail cancelled")
        case MFMailComposeResultSaved.rawValue:
            print("Mail saved")
        case MFMailComposeResultSent.rawValue:
            print("Mail sent")
        case MFMailComposeResultFailed.rawValue:
            print("Mail sent failure: \(error!.localizedDescription)")
        default:
            break
        }
        self.dismissViewControllerAnimated(true, completion: nil)
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
