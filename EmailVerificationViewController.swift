//
//  EmailVerificationViewController.swift
//  FoodTalk
//
//  Created by Ashish on 29/04/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit

class EmailVerificationViewController: UIViewController, UITextFieldDelegate, WebServiceCallingDelegate{
    
    var txtEmail = UITextField()
    @IBOutlet var btnSubmit : UIButton?
    var lblUser = UILabel()
    @IBOutlet var lblAlert : UILabel?
    @IBOutlet var btnBack : UIButton?
    var viewSuper = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
      
        
        btnSubmit?.enabled = false
        setViewUI()
        // Do any additional setup after loading the view.
        txtEmail.autocorrectionType = UITextAutocorrectionType.No
        txtEmail.keyboardAppearance = UIKeyboardAppearance.Alert;
        txtEmail.keyboardType = UIKeyboardType.EmailAddress
        txtEmail.delegate = self
        let dictName = (NSUserDefaults.standardUserDefaults().objectForKey("AllLogindetails") as? NSMutableDictionary)!
        print(dictName)
        let fullname = dictName.objectForKey("fullName")
        var token = (fullname! as! String).componentsSeparatedByString(" ")
        let firstname = token[0]
        lblUser.text = firstname
        
        lblAlert?.hidden = true
        
        if(isDirectOpen == true){
            btnBack?.hidden = true
            isDirectOpen = false
        }
        else{
            btnBack?.hidden = false
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(0.4, animations:  {
            self.viewSuper.frame = CGRect(x: 0, y: self.viewSuper.frame.origin.y, width: self.viewSuper.frame.size.width, height: self.viewSuper.frame.size.height)
            self.txtEmail.becomeFirstResponder()
        })
    }
    
    func setViewUI(){
        viewSuper.frame = CGRect(x: self.view.frame.size.width, y: 73, width: self.view.frame.size.width, height: 200)
        viewSuper.backgroundColor = UIColor.clearColor()
        self.view.addSubview(viewSuper)
        
        lblUser.frame = CGRect(x: 10, y: 0, width: self.view.frame.size.width - 20, height: 23)
        lblUser.textColor = UIColor.whiteColor()
        lblUser.font = UIFont(name: fontName, size: 18)
        viewSuper.addSubview(lblUser)
        
        let lblWelcome = UILabel()
        lblWelcome.frame = CGRect(x: 10, y: 47, width: self.view.frame.size.width - 20, height: 21)
        lblWelcome.text = "Next step is email"
        lblWelcome.textColor = UIColor.whiteColor()
        lblWelcome.font = UIFont(name: fontName, size: 16)
        viewSuper.addSubview(lblWelcome)
        
        let lblDescribe = UILabel()
        lblDescribe.frame = CGRect(x: 10, y: 64, width: self.view.frame.size.width - 20, height: 98)
        lblDescribe.numberOfLines = 3
        lblDescribe.text = "Don't worry we don't spam you. This is only required to make sure we can contact you if need be."
        lblDescribe.textColor = UIColor.whiteColor()
        lblDescribe.font = UIFont(name: fontName, size: 16)
        viewSuper.addSubview(lblDescribe)
        
        let imgUser = UIImageView()
        imgUser.frame = CGRect(x: 10, y: 177, width: 20, height: 17)
        imgUser.image = UIImage(named: "Mail Icon.png")
        viewSuper.addSubview(imgUser)
        
        txtEmail.frame = CGRect(x: 36, y: 169, width: self.view.frame.size.width - 36, height: 30)
        txtEmail.attributedPlaceholder = NSAttributedString(string:"Your email",
                                                            attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        let dictName = (NSUserDefaults.standardUserDefaults().objectForKey("FacebookDetails") as? NSMutableDictionary)!
        if((dictName.objectForKey("email")) != nil){
            txtEmail.text = dictName.objectForKey("email") as? String
            btnSubmit?.enabled = true
        }
        txtEmail.textColor = UIColor.whiteColor()
        txtEmail.font = UIFont(name: fontName, size: 15)
        txtEmail.delegate = self
        viewSuper.addSubview(txtEmail)
        
        let viewHr = UIView()
        viewHr.frame = CGRect(x: 10, y: 199, width: self.view.frame.size.width - 20, height: 1)
        viewHr.backgroundColor = UIColor.whiteColor()
        viewSuper.addSubview(viewHr)
    }
    
    override func viewWillDisappear(animated : Bool) {
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
//        
//        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        self.view.frame.origin.y += 90
    }
    
    @IBAction func submitClick(sender : UIButton){
        if(txtEmail.text?.characters.count > 0){
            if(isValidEmail((txtEmail.text)!)){
                let dictEmailValue = NSUserDefaults.standardUserDefaults().objectForKey("AllLogindetails")?.mutableCopy() as! NSMutableDictionary
                
                let email = txtEmail.text
                dictEmailValue.setObject(email!, forKey: "email")
                showLoader(self.view)
                self.webServicecall(dictEmailValue)
            }
            else{
                
                lblAlert?.hidden = false
            }
        }
        else{
            
        }
        emailIdEntered = txtEmail.text!
    }
    
    //MARK:- Calling WebServices
    
    func webServicecall (params : NSMutableDictionary){
        if (isConnectedToNetwork() == true){
            let url = String(format: "%@%@%@", baseUrl,controllerAuth,signinMethod)
        //    webServiceCallingPost(url, parameters: params)
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
        
        if(dict.objectForKey("status") as! String == "OK"){
            if((dict.objectForKey("profile")! as! NSDictionary).count != 0){
                let strChannel = dict.objectForKey("profile")!.objectForKey("channels") as! String
                let channelArray = strChannel.componentsSeparatedByString(",")
                
                NSUserDefaults.standardUserDefaults().setObject(channelArray, forKey: "channels")
            }
            NSUserDefaults.standardUserDefaults().setObject(dict, forKey: "LoginDetails")
            self.afterLogindetails(dict)
        }
        else{
            if((dict.objectForKey("errorCode")! as! String).isEqual(6)){
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "sessionId")
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userId")
                self.dismissViewControllerAnimated(true, completion: nil)
                
                let nav = (self.navigationController?.viewControllers)! as NSArray
                if(!(nav.objectAtIndex(0)).isKindOfClass(LoginViewController)){
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
            else if(dict.objectForKey("errorCode") as! String == "23000"){
                lblAlert?.text = "Email id already exist."
                lblAlert?.hidden = false
            }
        }
        stopLoading(self.view)
    }
    
    func serviceFailedWitherror(error : NSError){
        internetMsg(self.view)
        stopLoading(self.view)
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    
    //MARK:- Additional Action After Login
    
    func afterLogindetails(infoDict : NSDictionary){
        
        if((infoDict.objectForKey("status")! as! String).isEqual("OK")){
            
            let sessionId = infoDict.objectForKey("sessionId") as! String
            let userId = infoDict.objectForKey("userId") as! String
            NSUserDefaults.standardUserDefaults().setObject(sessionId, forKey: "sessionId")
            NSUserDefaults.standardUserDefaults().setObject(userId, forKey: "userId")
            
            let currentInstallation = PFInstallation.currentInstallation()
            currentInstallation.setObject(userId, forKey: "userId")
            currentInstallation.saveInBackground()
            
            if(infoDict.objectForKey("isNewUser")?.intValue != 0){
                let searchScreen = self.storyboard!.instantiateViewControllerWithIdentifier("Unnamed") as! UnnamedViewController;
                self.navigationController!.visibleViewController!.navigationController!.pushViewController(searchScreen, animated:true);
            }
            else{
                let username = infoDict.objectForKey("userName")
                NSUserDefaults.standardUserDefaults().setObject(username, forKey: "userName")
                NSUserDefaults.standardUserDefaults().setObject(txtEmail.text, forKey: "userEmail")
                let searchScreen = self.storyboard!.instantiateViewControllerWithIdentifier("SelectCity") as! SelectCityViewController;
                self.navigationController!.visibleViewController!.navigationController!.pushViewController(searchScreen, animated:false);
            }
        }
        else{
            
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
     //   textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    
        let str = textField.text
        if(str?.characters.count > 2){
            if(lblAlert?.hidden == false){
                lblAlert?.hidden = true
            }
            btnSubmit?.enabled = true
        }
        return true
    }
    
    func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y -= 90
    }
    
    func keyboardWillHide(sender: NSNotification) {
     //   self.view.frame.origin.y += 120
    }
    
    @IBAction func backBtn(sender : UIButton){
        self.navigationController?.popViewControllerAnimated(true)
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
