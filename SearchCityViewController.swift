//
//  SearchCityViewController.swift
//  FoodTalk
//
//  Created by Ashish on 23/08/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit

var selectedRegion = String()

class SearchCityViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, WebServiceCallingDelegate {
    
    @IBOutlet var searchBar : UISearchBar?
    @IBOutlet var btnCancel : UIButton?
    @IBOutlet var searchtable : UITableView?
    var arrLocations = NSMutableArray()
    var myTimer : NSTimer?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        
        var str = NSString()
        str = searchBar.text! as NSString
        if(str.length > 0){
            self.arrLocations = []
            searchtable?.reloadData()
            
            activityIndicator.hidden = false
            if(searchBar.text != ""){
                
                if (myTimer != nil) {
                    if ((myTimer?.valid) != nil)
                    {
                        myTimer!.invalidate();
                    }
                    myTimer = nil;
                }
                cancelRequest()
//                myTimer = myTimer.scheduledTimer(timeInterval: 0.20, target: self, selector: #selector(SearchCityViewController.webSearchService(_:)), userInfo: searchText, repeats: false)
                myTimer = NSTimer.scheduledTimerWithTimeInterval(0.20, target: self, selector: #selector(SearchCityViewController.webSearchService(_:)), userInfo: searchText, repeats: false)
            }
            else{
                cancelRequest()
                myTimer?.invalidate()
                self.arrLocations = []
                activityIndicator.hidden = true
                
                searchtable?.reloadData()
            }
        }
        else{
            cancelRequest()
            myTimer?.invalidate()
            self.arrLocations = []
            activityIndicator.hidden = true
            
            searchtable?.reloadData()
        }

        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrLocations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "CELL") as UITableViewCell!
         if (cell == nil) {
        cell = UITableViewCell(style:.default, reuseIdentifier: "CELL")
        
        }
        cell?.textLabel?.numberOfLines = 0
        cell?.textLabel?.font = UIFont(name: fontName, size: 14)
        
        cell?.textLabel?.text = (arrLocations.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "description") as? String
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        selectedRegion = ((arrLocations.object(at: (indexPath as NSIndexPath).row) as AnyObject).object(forKey: "description") as? String)!
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 54
    }
    
    //MARK:- WebService Calling
    
    func webSearchService(_ timer : Timer){
        
        let searchText = timer.userInfo as! String
        self.webServiceCalling(searchText)
    }
    
    func webServiceCalling(_ text : String){
        if (isConnectedToNetwork()){
            let urlString = String(format: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&types=(cities)&key=AIzaSyCkhfzw_JLdFtJkwkHEUNBtsHm_GRNF59Y",text)
            webServiceGet(urlString)
            delegate = self
        }
    }
    
    func getDataFromWebService(_ dict : NSMutableDictionary){
        
        if(dict.objectForKey("status") as! String == "OK"){
          arrLocations = dict.objectForKey("predictions") as! NSMutableArray
        }
        searchtable?.reloadData()
    }
    
    func serviceFailedWitherror(_ error : NSError){
        internetMsg(self.view)
        stopLoading(self.view)
    }
    
    func serviceUploadProgress(_ myprogress : float_t){
        stopLoading(self.view)
    }
    
    @IBAction func cancelBtn(_ sender : UIButton){
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
