//
//  DishTagViewController.swift
//  FoodTalk
//
//  Created by Ashish on 22/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit

var dishNameSelected = String()
var isComingFromDishTag = false
var isDishSelect : Bool = false

class DishTagViewController: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate, UISearchBarDelegate {
    

    var filtered : NSArray = []
    var searchActive : Bool = false
    @IBOutlet var tableView : UITableView?
     let lblDishName = UILabel()
    let imgDish = UIImageView()
    var searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setu
        self.title = "Dish Name"
        Flurry.logEvent("Dish Tag Screen")
     
        
        UITextField.appearance().tintColor = UIColor.blackColor()
        self.tabBarController?.delegate = self
        
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
        searchBar.backgroundColor = UIColor.clearColor()
        searchBar.placeholder = "Search Dish"
        
        self.navigationItem.titleView = searchBar
        searchBar.delegate = self
        
        searchBar.returnKeyType = UIReturnKeyType.Go
        
        let textFieldInsideSearchBar = searchBar.valueForKey("searchField") as? UITextField
        
        textFieldInsideSearchBar?.textColor = colorSnow
        textFieldInsideSearchBar?.backgroundColor = UIColor.clearColor()
    }
    
    override func viewDidAppear(animated: Bool) {
   
    }
    
    func addTapped(){
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("RatingVC") as! RatingViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingToParentViewController()){
            
            isComingFromDishTag = true
            selectedRestaurantName = ""
            restaurantId = ""
        }
    }
    
    //MARK:- uitextfield delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(textField.text == ""){
            textField.text = ""
        }
        searchActive = false
        return true
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        //  searchBar.setShowsCancelButton(true, animated: true)
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
        searchBar.resignFirstResponder()
    }

    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        let searchPredicate = NSPredicate(format: "SELF CONTAINS[cd] %@", searchText)
        let array = (arrDishNameList).filteredArrayUsingPredicate(searchPredicate)
        //       filtered = array as! [String]
        
        self.filtered = []
        self.filtered = array as NSArray
        
        if(searchBar.text?.characters.count < 1){
            self.searchActive = false;
        }
        else{
            if(self.filtered.count == 0){
                self.searchActive = true;
                
            } else {
                
                self.searchActive = true;
            }
        }
        
       self.tableView!.reloadData()

    }
    
   
    //MARK:- tableViewDatasourceDelegates
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchActive == false){
            return arrDishNameList.count
        }
        else{
            if(filtered.count > 0){
               return filtered.count
            }
            else{
                return 1
            }
        
        }
    }
    
    func  tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
        if (cell == nil) {
            cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
        }
        
       
        lblDishName.frame = CGRectMake(53, 0, cell.frame.size.width - 43, 44)
        lblDishName.textColor = UIColor.darkGrayColor()
        lblDishName.lineBreakMode = NSLineBreakMode.ByWordWrapping
        lblDishName.numberOfLines = 0
        lblDishName.font = UIFont(name: fontName, size: 17)
        lblDishName.tag = 1101
        
        
        imgDish.frame = CGRectMake(20, 9, 25, 25)
        imgDish.tag = 1333
        imgDish.image = UIImage(named: "Add dish.png")
        imgDish.layer.cornerRadius = 5
        imgDish.layer.masksToBounds = true
        
        cell.textLabel?.textColor = colorBlack
        cell.textLabel?.font = UIFont(name: fontBold, size: 16)
        
        
        if(searchActive){
            if(filtered.count == 0){
                if(searchBar.text?.characters.count > 0){
                cell.textLabel?.text = ""
                lblDishName.text = String(format: "Add '%@'", (searchBar.text)!)
                
                if((cell.contentView.viewWithTag(1101)) != nil){
                    cell.contentView.viewWithTag(1101)?.removeFromSuperview()
                    cell.contentView.viewWithTag(1201)?.removeFromSuperview()
                    cell.contentView.viewWithTag(1333)?.removeFromSuperview()
                }
                
                cell.contentView.addSubview(lblDishName)
                    cell.contentView.addSubview(imgDish)
                }
            }
            else{
                lblDishName.removeFromSuperview()
                imgDish.removeFromSuperview()
                cell.textLabel?.text = filtered.objectAtIndex(indexPath.row) as? String
            }
          
        }
        else{
            
            if(searchBar.text?.characters.count == 0){
                cell.textLabel?.text = arrDishNameList.objectAtIndex(indexPath.row) as? String
            }
            
            else{
                
            if(filtered.count == 0){
                if(searchBar.text?.characters.count > 0){
                cell.textLabel?.text = ""
                    lblDishName.text = String(format: "Add '%@'", (searchBar.text)!)
                    
                
                cell.contentView.addSubview(lblDishName)
                    cell.contentView.addSubview(imgDish)
                }
            }
            }
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if(filtered.count > 0){
        dishNameSelected = filtered.objectAtIndex(indexPath.row) as! String
   
        }
        else{
            if(searchBar.text?.characters.count == 0){
              dishNameSelected = arrDishNameList.objectAtIndex(indexPath.row) as! String
            }
            else{
              dishNameSelected = (searchBar.text)!
            }

        }
        isDishSelect = true
        self.navigationController?.popViewControllerAnimated(false)
        navigationItem.rightBarButtonItem?.enabled = true
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
