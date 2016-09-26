//
//  UnnamedViewController.swift
//  FoodTalk
//
//  Created by Ashish on 23/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit

var userNameEntered = String()
var emailIdEntered = String()

class UnnamedViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, WebServiceCallingDelegate {
    
    @IBOutlet var btnCheck : UIButton?
    @IBOutlet var btnCityName : UIButton?
    var txtName = UITextField()
    @IBOutlet var lblAlreadyTakenname : UILabel?
    @IBOutlet var btnCity : UIButton?
    var lblUser = UILabel()
    
    var viewSuper = UIView()
    
    
    var charactesAllowed = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_."
    var arrCityList = NSMutableArray()
    
    var selectedCity = String()
    var typePickerView: UIPickerView = UIPickerView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewUI()
        
        txtName.autocorrectionType = UITextAutocorrectionType.No
        
        txtName.keyboardAppearance = UIKeyboardAppearance.Alert;
        
        let dictName = NSUserDefaults.standardUserDefaults().objectForKey("AllLogindetails") as? NSMutableDictionary!
        let fullname = dictName!.objectForKey("fullName") as! String
        
        var token = fullname.componentsSeparatedByString(" ")
        let firstname = token[0]
        lblUser.text = String(format: "Hi %@", firstname)
        
        self.btnCityName?.frame = CGRect(x: 0, y: btnCheck!.frame.origin.y - 70, width: self.view.frame.size.width/2, height: 30)
        self.btnCity?.frame = CGRect(x: self.view.frame.size.width/2, y: btnCheck!.frame.origin.y - 70, width: self.view.frame.size.width/2, height: 30)
        self.btnCity?.setTitleColor(UIColor.blueColor(), forState: UIControlState())
        // Do any additional setup after loading the view.
        self.btnCheck?.enabled = false
        
        lblAlreadyTakenname?.hidden = true
        Flurry.logEvent("Enter Username Screen")
        self.navigationController?.navigationBarHidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UnnamedViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UnnamedViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
        
        self.typePickerView.hidden = true
        self.typePickerView.dataSource = self
        self.typePickerView.delegate = self
        self.typePickerView.frame = CGRectMake(0, self.view.frame.size.height - 150, self.view.frame.size.width, 150)
        self.typePickerView.backgroundColor = UIColor.whiteColor()
        self.typePickerView.layer.borderColor = UIColor.lightGrayColor().CGColor
        self.typePickerView.layer.borderWidth = 1
        self.view.addSubview(self.typePickerView)
    }
    
    override func viewWillDisappear(animated : Bool) {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        UIView.animateWithDuration(0.4, animations:  {
            self.viewSuper.frame = CGRect(x: 0, y: self.viewSuper.frame.origin.y, width: self.viewSuper.frame.size.width, height: self.viewSuper.frame.size.height)
            self.txtName.becomeFirstResponder()
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
        lblWelcome.text = "Welcome to Food Talk"
        lblWelcome.textColor = UIColor.whiteColor()
        lblWelcome.font = UIFont(name: fontName, size: 16)
        viewSuper.addSubview(lblWelcome)
        
        let lblDescribe = UILabel()
        lblDescribe.frame = CGRect(x: 10, y: 64, width: self.view.frame.size.width - 20, height: 98)
        lblDescribe.numberOfLines = 3
        lblDescribe.text = "Let's create a username for you, Your username  should be unique & will be used to identify you on Food Talk."
        lblDescribe.textColor = UIColor.whiteColor()
        lblDescribe.font = UIFont(name: fontName, size: 16)
        viewSuper.addSubview(lblDescribe)
        
        let imgUser = UIImageView()
        imgUser.frame = CGRect(x: 10, y: 175, width: 20, height: 20)
        imgUser.image = UIImage(named: "User Icon.png")
        viewSuper.addSubview(imgUser)
        
        txtName.frame = CGRect(x: 36, y: 169, width: self.view.frame.size.width - 36, height: 30)
        // txtName.placeholder = "Username"
        txtName.attributedPlaceholder = NSAttributedString(string:"Username",
                                                           attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        txtName.textColor = UIColor.whiteColor()
        txtName.font = UIFont(name: fontName, size: 15)
        txtName.delegate = self
        viewSuper.addSubview(txtName)
        
        let viewHr = UIView()
        viewHr.frame = CGRect(x: 10, y: 199, width: self.view.frame.size.width - 20, height: 1)
        viewHr.backgroundColor = UIColor.whiteColor()
        viewSuper.addSubview(viewHr)
    }

    
    @IBAction func moveToNew(sender : UIButton){
        showLoader(self.view)
        var dictV = NSMutableDictionary()
        dictV = NSUserDefaults.standardUserDefaults().objectForKey("AllLogindetails")?.mutableCopy() as! NSMutableDictionary
        let deviceToken = NSUserDefaults.standardUserDefaults().objectForKey("DeviceToken")
        dispatch_async(dispatch_get_main_queue()){
            dictV.setObject((self.txtName.text)!, forKey: "userName" as NSCopying)
            dictV.setObject(deviceToken!, forKey: "deviceToken" as NSCopying)
            self.webServicecall(dictV)
        }
        
        userNameEntered = self.txtName.text!
    }
    
    
    //MARK:- WebService Calling
    func webServicecall (params : NSMutableDictionary){
        if (isConnectedToNetwork()){
            let url = String(format: "%@%@%@", baseUrl,controllerAuth,signinMethod)
//            webServiceCallingPost(url, parameters: params)
            delegate = self
            webServiceCallingPost(url, parameters: params)
        }
        else{
            internetMsg(self.view)
        }
        delegate = self
    }
    
    func webServiceForRegion(){
        if (isConnectedToNetwork()){
            let url = String(format: "%@%@%@", baseUrl, "region/", "list")
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            
            let params = NSMutableDictionary()
            params.setObject(sessionId!, forKey: "sessionId")
            
         //   webServiceCallingPost(url, parameters: params)
            webServiceCallingPost(url, parameters: params)
            
        }
        else{
            internetMsg(self.view)
        }
      delegate = self
    }
    
    //MARK:- WebService Delegates
    
    func getDataFromWebService(dict : NSMutableDictionary){
        
        if(dict.objectForKey("api") as! String == "region/list"){
            if(dict.objectForKey("status") as! String == "OK"){
                arrCityList = dict.objectForKey("regions") as! NSMutableArray
            }
        }
        else{
            if(dict.objectForKey("status") as! String == "OK"){
                NSUserDefaults.standardUserDefaults().setObject(dict, forKey: "LoginDetails")
                self.afterLogindetails(dict)
            }
            else{
                txtName.text = ""
                btnCheck?.enabled = false
                lblAlreadyTakenname?.hidden = false
            }
        }
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
            NSUserDefaults.standardUserDefaults().setObject(txtName.text, forKey: "userName")
            
            
            let currentInstallation = PFInstallation.currentInstallation()
            currentInstallation.setObject(userId, forKey: "userId")
            currentInstallation.saveInBackground()
            
            Flurry.setUserID(txtName.text)
            
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier(
                "EmailVerification") as! EmailVerificationViewController;
            self.navigationController!.pushViewController(openPost, animated:false);
        }
        else{
            
        }
    }

    
    //MARK:- TextField Delegates
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if(range.length + range.location < 16){
            if(lblAlreadyTakenname?.hidden == false){
                lblAlreadyTakenname?.hidden = true
            }
            let aSet = NSCharacterSet(charactersInString:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_.").invertedSet
            let compSepByCharInSet = string.componentsSeparatedByCharactersInSet(aSet)
            let numberFiltered = compSepByCharInSet.joinWithSeparator("")
            if((range.length + range.location > 3) || (range.length + range.location < 16)){
                btnCheck?.enabled = true
            }
            return string == numberFiltered
        }
        return false
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    func keyboardWillShow(sender: NSNotification) {
        
        
        
    }
    
    func keyboardWillHide(sender: NSNotification) {
       
    }

    //MARK:- cityButtonAction
    
    @IBAction func cityButtonTapped(sender : UIButton){
        typePickerView.hidden = false
        txtName.resignFirstResponder()
        typePickerView.reloadAllComponents()
    }
    
    
    //MARK:- pickerView Delegates methods
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return arrCityList.count
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        btnCity?.setTitle((arrCityList.objectAtIndex(row).objectForKey("name") as? String)?.uppercaseString, forState: UIControlState.Normal)
        selectedCity = (arrCityList.objectAtIndex(row).objectForKey("name") as? String)!
        typePickerView.hidden = true
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        let view = UIView(frame: CGRectMake(5,0, pickerView.frame.size.width - 10,44))
        let label = UILabel(frame:CGRectMake(5,0, pickerView.frame.size.width - 10, 44))
        label.textAlignment = NSTextAlignment.Center
        view.addSubview(label)
        label.text = (arrCityList.objectAtIndex(row).objectForKey("name") as? String)?.uppercaseString
        return view
    }
    
    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 36.0
    }
    
    func pickerView(pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 36.0
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
