//
//  ListOfLikesViewController.swift
//  FoodTalk
//
//  Created by Ashish on 05/01/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

import UIKit

var openList = String()

class ListOfLikesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, WebServiceCallingDelegate {
    
    @IBOutlet var tableView : UITableView?
    var arrNumberOfActions : NSMutableArray = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        openList = "followers"
        if(openList == "followers"){
            dispatch_async(dispatch_get_main_queue()) {
             self.webServiceFollowers()
            }
        }
    }
    
    //WebServiceCallingForFollowers
    
    func webServiceFollowers(){
        if(isConnectedToNetwork()){
        showLoader(self.view)
        let url = String(format: "%@%@%@", baseUrl,controllerFollowers,restaurantListMethod)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")

            webServiceCallingPost(url, parameters: params)
        }
        else{
            internetMsg(view)
        }
        delegate = self
    }
    
    //WebServiceDelegates
    
    func getDataFromWebService(dict : NSMutableDictionary){
        
    }
    
    func serviceFailedWitherror(error : NSError){
        
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    //TableView Datasource and delegate methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNumberOfActions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
        }
        return cell
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
