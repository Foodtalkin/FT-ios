//
//  AddRestaurantViewController.swift
//  FoodTalk
//
//  Created by Ashish on 22/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit

class AddRestaurantViewController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, WebServiceCallingDelegate {
    
    @IBOutlet var txtRestaurantName : UITextField?
    @IBOutlet var txtAddress : UITextField?
    @IBOutlet var lblTop1 : UILabel?
    @IBOutlet var lblTop2 : UILabel?
    var viewHr = UIView()
    var searchtable = UITableView()
    var myTimer : NSTimer?
    @IBOutlet var viewH1 : UIView?
    @IBOutlet var viewH2 : UIView?
    @IBOutlet var viewAll : UIView?
    @IBOutlet var viewCity : UIView?
    @IBOutlet var txtCity : UITextField?
    @IBOutlet var txtCty : UITextField?
    
    var arrLocations = NSMutableArray()
    
    var params = NSMutableDictionary()
    var activeTextField = UITextField()
    
    var arrCityList = NSMutableArray()
    
    var selectedCity = String()
    var typePickerView: UIPickerView = UIPickerView()
    
    var locationManager : CLLocationManager?
    var currentLocation : CLLocation?
    var callInt : Int = 0
    var googleId = String()
    var activityIndicator1 = UIActivityIndicatorView()
    var btnCheckIn = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Add Place"
        Flurry.logEvent("AddRestaurant Screen")
        //        lblImage?.layer.cornerRadius = 17
        //        lblImage?.layer.masksToBounds = true
        
        UITextField.appearance().tintColor = UIColor.blackColor()
        
        txtRestaurantName?.keyboardType = UIKeyboardType.ASCIICapable
        txtRestaurantName?.becomeFirstResponder()
        
        
        searchtable.frame = CGRect(x: 0, y: 114, width: self.view.frame.size.width, height: 206)
        searchtable.dataSource = self
        searchtable.delegate = self
        self.view.addSubview(searchtable)
        searchtable.hidden = true
        
        
        btnCheckIn.frame = CGRect(x: 0, y: self.view.frame.size.height - 256, width: self.view.frame.size.width, height: 40)
        btnCheckIn.setTitle("Add Restaurant", forState: UIControlState())
        btnCheckIn.setTitleColor(UIColor.whiteColor(), forState: UIControlState())
        btnCheckIn.backgroundColor = colorActive
        btnCheckIn.addTarget(self, action: #selector(AddRestaurantViewController.addTapped), forControlEvents: UIControlEvents.TouchUpInside)
        btnCheckIn.enabled = false
        btnCheckIn.alpha = 0.6
        self.view.addSubview(btnCheckIn)
        
        txtRestaurantName?.autocorrectionType = UITextAutocorrectionType.No
        txtAddress?.autocorrectionType = UITextAutocorrectionType.No
        txtCty?.autocorrectionType = UITextAutocorrectionType.No
        txtCity?.autocorrectionType = UITextAutocorrectionType.No
        
        viewCity?.hidden = true
        
        txtCty!.clearButtonMode = UITextFieldViewMode.Always
        
        txtCty!.clearsOnBeginEditing = true;
        
        let myBackButton:UIButton = UIButton(type : .Custom) as UIButton
        
        myBackButton.addTarget(self, action: #selector(AddRestaurantViewController.popToRoot(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        myBackButton.setImage(UIImage(named: "Back icon.png"), forState: UIControlState())
        myBackButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        let myCustomBackButtonItem:UIBarButtonItem = UIBarButtonItem(customView: myBackButton)
        self.navigationItem.leftBarButtonItem = myCustomBackButtonItem
    }
    
    func popToRoot(sender:UIBarButtonItem){
        if(viewCity?.hidden == false){
            viewCity?.hidden = true
            viewAll?.hidden = false
            searchtable.hidden = true
            lblTop2?.hidden = false
        }
        else{
            self.navigationController?.popToRootViewControllerAnimated(true)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        cancelRequest()
        if (self.isMovingFromParentViewController()){
            
            self.navigationController?.navigationBarHidden = true
            
        }
        super.viewWillDisappear(animated)
    }
    
    
    //MARK:- webServiceCall & Delegate
    
    func webServiceCall(){
        var restaurantName = txtRestaurantName?.text
        if (isConnectedToNetwork()){
            showLoader(self.view)
            let url = String(format: "%@%@%@", baseUrl, controllerRestaurant, addlikeMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            restaurantName = restaurantName!.stringByReplacingOccurrencesOfString("\"", withString: "")
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(restaurantName!, forKey: "restaurantName")
            
            if((txtAddress?.text?.characters.count)! > 0){
                params.setObject((txtAddress?.text)!, forKey: "address")
                
            }
            params.setObject(googleId, forKey: "google_place_id" as NSCopying)
            webServiceCallingPost(url, parameters: params)
            delegate = self
            
        }
        else{
            internetMsg(view)
            stopLoading(self.view)
        }
        
    }
    
    func webSearchService(timer : NSTimer){
        if (isConnectedToNetwork()){
            //  showLoader(self.view)
            let searchText = timer.userInfo as! String
            let escapedAddress  = searchText.stringByAddingPercentEncodingWithAllowedCharacters( NSCharacterSet.URLQueryAllowedCharacterSet())!
            self.webServiceCalling(escapedAddress)
        }
        else{
            internetMsg(self.view)
        }
    }
    
    func webServiceCalling(text : String){
        if (isConnectedToNetwork()){
            let urlString = String(format: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=(cities)&key=AIzaSyCkhfzw_JLdFtJkwkHEUNBtsHm_GRNF59Y",text)
             dispatch_async(dispatch_get_main_queue()){
            webServiceGet(urlString)
            }
           
      delegate = self
        }
        else{
            internetMsg(self.view)
        }
    }
    
    
    func getDataFromWebService(dict : NSMutableDictionary){
        
        if((dict.objectForKey("api")) != nil){
        if(dict.objectForKey("api") as! String == "region/list"){
            if(dict.objectForKey("status") as! String == "OK"){
                arrCityList = dict.objectForKey("regions") as! NSMutableArray
            }
        }
        else{
            if(dict.objectForKey("status") as! String == "OK"){
                restaurantId = dict.objectForKey("restaurantId") as! String
                selectedRestaurantName = (txtRestaurantName?.text)!
                isRestaurantSelect = true
                self.navigationController?.popToRootViewControllerAnimated(false)
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
        }
        else{
    if(dict.objectForKey("status") as! String == "OK"){
      stopLoading(self.view)
    arrLocations = (dict.objectForKey("predictions") as! NSArray).mutableCopy() as! NSMutableArray
    }
        }
    
    searchtable.reloadData()
    stopLoading(self.view)
    activityIndicator.hidden = true
    }
    
    func serviceFailedWitherror(error : NSError){
        
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    //MARK:- Table Delegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrLocations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
            
        }
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.font = UIFont(name: fontName, size: 14)
        
        cell?.textLabel?.text = arrLocations.objectAtIndex(indexPath .row) .objectForKey( "description") as? String
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    
        googleId = (arrLocations.objectAtIndex(indexPath .row) .objectForKey("place_id") as? String)!
        UIView.animateWithDuration(0.4, animations:  {
            self.viewAll?.hidden = false
            self.viewCity?.hidden = true
            self.lblTop2?.hidden = false
        })
        txtCity!.text = arrLocations.objectAtIndex(indexPath.row) .objectForKey("description") as? String
        searchtable.hidden = true
        if((txtRestaurantName?.text?.characters.count)! > 2){
            
            if((txtCity?.text?.characters.count)! > 2){
                btnCheckIn.enabled = true
                btnCheckIn.alpha = 1.0
            }
        }
    }

    
    func addTapped(){
        
        if(txtRestaurantName?.text?.characters.count > 1){
            self.webServiceCall()
        }
    }
    
    func textFieldShouldClear(textField: UITextField) -> Bool {
        if(txtCty!.text?.characters.count > 0){
            lblTop2?.hidden = false
            searchtable.hidden = true
            viewAll?.hidden = false
            viewCity?.hidden = true
        }
        return true
    }
    
    func showTableDelay(){
        self.searchtable.hidden = false
    }
    
    //MARK:- textfield delegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        //   activeTextField = textField
        if(textField === txtCity){
            UIView.animateWithDuration(0.4, animations:  {
                self.viewAll?.hidden = true
                self.viewCity?.hidden = false
                self.lblTop2?.hidden = true
                self.txtCty?.becomeFirstResponder()
                self.view.bringSubviewToFront(self.viewCity!)
            })
        }
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if ((txtRestaurantName!.text?.characters.count)! < 2){
            btnCheckIn.enabled = false;
            btnCheckIn.alpha = 0.6
        }
            
        else if (txtCity!.text!.characters.count < 2){
            btnCheckIn.enabled = false;
            btnCheckIn.alpha = 0.6
        }
        else{
            btnCheckIn.enabled = true;
            btnCheckIn.alpha = 1.0
        }
        
        if(textField === txtCty){
            var str = NSString()
            str = textField.text! as NSString
            if(str.length > 0){
                if(range.length + range.location < 32){
                    if(str.length < 2){
                        
                        //                self.perform(#selector(AddRestaurantViewController.showTableDelay), with: nil, afterDelay: 0.5)
                        
                        self.performSelector(#selector(AddRestaurantViewController.showTableDelay), withObject: nil, afterDelay: 0.5)
                    }
                    self.arrLocations = []
                    searchtable.reloadData()
                    
                    //   activityIndicator.hidden = false
                    
                    if(textField.text != ""){
                        
                        if (myTimer != nil) {
                            if ((myTimer?.valid) != nil)
                            {
                                myTimer!.invalidate();
                            }
                            myTimer = nil;
                        }
                        cancelRequest()
                        
                        myTimer = NSTimer.scheduledTimerWithTimeInterval( 0.20, target: self, selector: #selector(AddRestaurantViewController.webSearchService(_:)), userInfo: textField.text, repeats: false)
                    }
                    else{
                        cancelRequest()
                        myTimer?.invalidate()
                        self.arrLocations = []
                        //     activityIndicator.hidden = true
                       
                        
                        searchtable.reloadData()
                    }
                }
            }
            else{
                cancelRequest()
                myTimer?.invalidate()
                self.arrLocations = []
                //   activityIndicator.hidden = true
               
                searchtable.reloadData()
            }
            
        }
         return true
    }
    
    func keyboardWillShow(sender: NSNotification) {
        if(activeTextField == txtAddress){
          self.view.frame.origin.y -= 120
        }
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if(activeTextField == txtAddress){
            
          self.view.frame.origin.y += 120
        }
    }
    
    @IBAction func cityButtonTapped(sender : UIButton){
        txtRestaurantName?.resignFirstResponder()
        typePickerView.hidden = false
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
    
    //Location Manager
    
    //MARK:- LocationManager
    func addLocationManager(){
        locationManager = CLLocationManager()
        locationManager!.delegate = self;
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.requestAlwaysAuthorization()
        locationManager!.startUpdatingLocation()
    }
    
    //MARK:- UserLocations Methods
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        let userLocation:CLLocation = locations[0]
        let long = userLocation.coordinate.longitude;
        let lat = userLocation.coordinate.latitude;
        //Do What ever you want with it
        dictLocations = NSMutableDictionary()
        dictLocations.setObject(long, forKey: "longitute")
        dictLocations.setObject(lat, forKey: "latitude")
        
        
//        if(callInt == 0){
//            dispatch_async(dispatch_get_main_queue()){
//                self.setUsersClosestCity()
//            }
//            
//        }
//        callInt += 1
        
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: " + error.localizedDescription)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.Denied) {
          //  self.moving?.on = false
            dictLocations = NSMutableDictionary()
        }
        else if (status == CLAuthorizationStatus.AuthorizedAlways) {
            
        }
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       
        
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
