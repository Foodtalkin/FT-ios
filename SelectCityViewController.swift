//
//  SelectCityViewController.swift
//  FoodTalk
//
//  Created by Ashish on 23/08/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit

var selectedRegion = String()

class SelectCityViewController: UIViewController, UITextFieldDelegate,  UITableViewDataSource, UITableViewDelegate, WebServiceCallingDelegate{
    
    var txtCity = UITextField()
    @IBOutlet var btnOK : UIButton?
    var viewSuper = UIView()
    var searchtable : UITableView?
    var arrLocations = NSMutableArray()
    var myTimer : NSTimer?
    var lblDescribe = UILabel()
   // @IBOutlet var backBtn : UIButton?
    @IBOutlet var btnBack : UIButton?
    var activityIndicator1 = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewUI()
        txtCity.autocorrectionType = UITextAutocorrectionType.No
        txtCity.keyboardAppearance = UIKeyboardAppearance.Alert;
        // Do any additional setup after loading the view.
        btnOK?.enabled = false
        searchtable = UITableView()
        searchtable!.frame = CGRect(x: 10, y: 84, width: self.view.frame.size.width - 20, height: 200)
        searchtable!.dataSource = self
        searchtable!.delegate = self
        self.view.addSubview(searchtable!)
        searchtable!.hidden = true
        
        if(isDirectOpen == true){
            btnBack?.hidden = true
            isDirectOpen = false
        }
        else{
            btnBack?.hidden = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        UIView.animateWithDuration(0.4, animations:  {
            self.viewSuper.frame = CGRect(x: 0, y: self.viewSuper.frame.origin.y, width: self.viewSuper.frame.size.width, height: self.viewSuper.frame.size.height)
        })
    }
    
    func setViewUI(){
        viewSuper.frame = CGRect(x: self.view.frame.size.width, y: 73, width: self.view.frame.size.width, height: 200)
        viewSuper.backgroundColor = UIColor.clearColor()
        self.view.addSubview(viewSuper)
        
        let lblUser = UILabel()
        lblUser.frame = CGRect(x: 10, y: 0, width: self.view.frame.size.width - 20, height: 23)
        lblUser.textColor = UIColor.whiteColor()
        lblUser.text = "One last step"
        lblUser.font = UIFont(name: fontName, size: 18)
        viewSuper.addSubview(lblUser)
        
        let lblWelcome = UILabel()
        lblWelcome.frame = CGRect(x: 10, y: 47, width: self.view.frame.size.width - 20, height: 21)
        lblWelcome.text = "Where do you live ?"
        lblWelcome.textColor = UIColor.whiteColor()
        lblWelcome.font = UIFont(name: fontName, size: 16)
        viewSuper.addSubview(lblWelcome)
        
      //  let lblDescribe = UILabel()
        lblDescribe.frame = CGRect(x: 10, y: 64, width: self.view.frame.size.width - 20, height: 98)
        lblDescribe.numberOfLines = 3
        lblDescribe.text = "We will customize your experience based on where you live. Great food is now just few steps away."
        lblDescribe.textColor = UIColor.whiteColor()
        lblDescribe.font = UIFont(name: fontName, size: 16)
        viewSuper.addSubview(lblDescribe)
        
        let imgUser = UIImageView()
        imgUser.frame = CGRect(x: 10, y: 177, width: 20, height: 17)
        imgUser.image = UIImage(named: "Location Icon.png")
        viewSuper.addSubview(imgUser)
        
        txtCity.frame = CGRect(x: 36, y: 169, width: self.view.frame.size.width - 36, height: 30)
        txtCity.attributedPlaceholder = NSAttributedString(string:"Your Hometown",
                                                           attributes:[NSForegroundColorAttributeName: UIColor.whiteColor()])
        
        txtCity.textColor = UIColor.whiteColor()
        txtCity.font = UIFont(name: fontName, size: 16)
        txtCity.delegate = self
        viewSuper.addSubview(txtCity)
        
        let viewHr = UIView()
        viewHr.frame = CGRect(x: 10, y: 199, width: self.view.frame.size.width - 20, height: 1)
        viewHr.backgroundColor = UIColor.whiteColor()
        viewSuper.addSubview(viewHr)
    }
    
    func showTableDelay(){
        self.searchtable!.hidden = false
    }
    
    //MARK:- TextField Delegates
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
       self.view.bringSubviewToFront(self.btnBack!)
        UIView.animateWithDuration( 0.4, animations: {
            self.viewSuper.frame = CGRect(x: 0, y: self.viewSuper.frame.origin.y - 190, width: self.viewSuper.frame.size.width, height: self.viewSuper.frame.size.height)
            
            self.lblDescribe.hidden = true
        })
    }
    
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
            
        var str = NSString()
        str = textField.text! as NSString
        if(str.length > 0){
            if(str.length < 2){
                
                self.performSelector(#selector(SelectCityViewController.showTableDelay), withObject: nil, afterDelay: 0.5)
            }
            self.arrLocations = []
            searchtable!.reloadData()
            
          //  activityIndicator.hidden = false
            showActivity()
            if(textField.text != ""){
                
                if (myTimer != nil) {
                    if ((myTimer?.valid) != nil)
                    {
                        myTimer!.invalidate();
                    }
                    myTimer = nil;
                }
                cancelRequest()
                myTimer = NSTimer.scheduledTimerWithTimeInterval(0.20, target: self, selector: #selector(SelectCityViewController.webSearchService(_:)), userInfo: textField.text, repeats: false)
            }
            else{
                cancelRequest()
                myTimer?.invalidate()
                self.arrLocations = []
             //   activityIndicator.hidden = true
                stopActivity()
                searchtable!.reloadData()
            }
        }
        else{
            cancelRequest()
            myTimer?.invalidate()
            self.arrLocations = []
         //   activityIndicator.hidden = true
            stopActivity()
            searchtable!.reloadData()
        }
        return true
    }
    
    //MARK:- WebService Calling
    
    func webSearchService(_ timer : NSTimer){
         if (isConnectedToNetwork()){
        let searchText = timer.userInfo as! String
        let escapedAddress = searchText.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())!
        self.webServiceCalling(escapedAddress)
        }
         else{
            internetMsg(self.view)
        }
    }
    
    func webServiceCalling(_ text : String){
        if (isConnectedToNetwork()){
            let urlString = String(format: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=(cities)&key=AIzaSyCkhfzw_JLdFtJkwkHEUNBtsHm_GRNF59Y",text)
            webServiceGet(urlString)
           
       delegate = self
        }
        else{
            internetMsg(self.view)
        }
    }
    
    //MARK:- WebService Calling
    func webServicecall (_ params : NSMutableDictionary){
        if (isConnectedToNetwork()){
            let url = String(format: "%@%@%@", baseUrl,controllerAuth,signinMethod)
       //     webServiceCallingPost(url, parameters: params)
            webServiceCallingPost(url, parameters: params)
       delegate = self
        }
        else{
            internetMsg(self.view)
        }
    }
    
    func getDataFromWebService(dict : NSMutableDictionary){
       
        if((dict.objectForKey("api")) != nil){
            if(dict.objectForKey("api") as! String == "auth/signin"){
         if(dict.objectForKey("status") as! String == "OK"){
            NSUserDefaults.standardUserDefaults().setObject(txtCity.text, forKey: "userCity")
            NSUserDefaults.standardUserDefaults().setObject(dict, forKey: "LoginDetails")
            let tab = self.storyboard?.instantiateViewControllerWithIdentifier("tabBarVC") as! UITabBarController
            tab.selectedIndex = 0
            self.navigationController!.visibleViewController?.navigationController?.pushViewController(tab, animated:true);
                }
            }
        }
        else{
        if(dict.objectForKey("status") as! String == "OK"){
            arrLocations = (dict.objectForKey("predictions") as! NSArray).mutableCopy() as! NSMutableArray
        }
        }
        searchtable!.reloadData()
        stopActivity()
    }
    
    func serviceFailedWitherror(_ error : NSError){
     //   internetMsg(self.view)
    //    stopLoading(self.view)
    }
    
    func serviceUploadProgress(_ myprogress : float_t){
        stopLoading(self.view)
    }
    
    //MARK:- Table Delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrLocations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "MyTestCell")
       
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.font = UIFont(name: fontName, size: 14)
        
        cell.textLabel?.text = arrLocations.objectAtIndex(indexPath.row).objectForKey("description") as? String
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
   
        selectedRegion = (arrLocations.objectAtIndex(indexPath.row).objectForKey("place_id") as? String)!
        UIView.animateWithDuration(0.4, animations: {
            self.viewSuper.frame = CGRect(x: 0, y: 73, width: self.viewSuper.frame.size.width, height: self.viewSuper.frame.size.height)
        })
        txtCity.text = arrLocations.objectAtIndex(indexPath.row) .objectForKey("description") as? String
        searchtable!.hidden = true
        lblDescribe.hidden = false
        btnOK?.setImage(UIImage(named: "Next Button.png"), forState: UIControlState())
        btnOK?.enabled = true
        txtCity.resignFirstResponder()
    }
    
    func tableView(tableView: UITableView, heightForRowAt indexPath: NSIndexPath) -> CGFloat {
        return 44
    }
    
    @IBAction func okBtnTapped(sender : UIButton){
        
                showLoader(self.view)
        
                var dictV = NSMutableDictionary()
                dictV = NSUserDefaults.standardUserDefaults().objectForKey("AllLogindetails")?.mutableCopy() as! NSMutableDictionary
                let dictLoginInfo = NSUserDefaults.standardUserDefaults().objectForKey("LoginDetails")?.mutableCopy() as? NSMutableDictionary
                let deviceToken = NSUserDefaults.standardUserDefaults().objectForKey("DeviceToken")
        
                dictV.setObject((NSUserDefaults.standardUserDefaults().objectForKey("userName") as! String), forKey: "userName" as NSCopying)
                dictV.setObject((((dictLoginInfo?.objectForKey("profile")!)! as! NSDictionary).objectForKey("email") as! String), forKey: "email" as NSCopying)
                dictV.setObject(deviceToken!, forKey: "deviceToken" as NSCopying)
                dictV.setObject((selectedRegion), forKey: "google_place_id" as NSCopying)
        
                dispatch_async(dispatch_get_main_queue()){
                self.webServicecall(dictV)
                }
        
    }
    
    @IBAction func backBtn(sender : UIButton){
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    //MARK:- ShowActivity MAethod
    
    func showActivity(){
        activityIndicator1.frame = CGRect(x: self.view.frame.size.width/2 - 20, y: self.view.frame.size.height/2 - 40, width: 40, height: 40)
        activityIndicator1.center = CGPoint(x: self.view.bounds.width / 2, y: self.view.bounds.height / 2)
        activityIndicator1.activityIndicatorViewStyle = .Gray
        self.view.addSubview(activityIndicator1)
        
       // view.userInteractionEnabled = false
        activityIndicator1.startAnimating()
    }
    
    func stopActivity(){
        activityIndicator1.stopAnimating()
    //    activityIndicator1.removeFromSuperview()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.locationInView(conectivityMsg)
            // do something with your currentPoint
            if(isConnectedToNetwork()){
                conectivityMsg.removeFromSuperview()
            }
        }
        
        for var view : UIView in self.view.subviews {
            if(view == conectivityMsg){
                if(isConnectedToNetwork()){
                    conectivityMsg.removeFromSuperview()
                    
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
