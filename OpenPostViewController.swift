//
//  OpenPostViewController.swift
//  FoodTalk
//
//  Created by Ashish on 17/12/15.
//  Copyright © 2015 FoodTalkIndia. All rights reserved.
//

import UIKit


var postIdOpenPost = String()

class OpenPostViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, UIActionSheetDelegate, TTTAttributedLabelDelegate, UIGestureRecognizerDelegate, WebServiceCallingDelegate {
    
    @IBOutlet var tableView : UITableView?
    var arrCommentsList : NSMutableArray = []
    var dictInfoPost = NSDictionary()
    var nameString = NSMutableAttributedString()
    var anotherNameString = NSMutableAttributedString()
    
    var _kbCtrl = BDMessagesKeyboardController()
    
    var keyView : UIView?
    @IBOutlet var sendBtn : UIButton?
    @IBOutlet var keyText : UITextView?
    
    var commentText = String()
    var selectedReport = String()
    
    var imgLikeDubleTap : UIImageView?
    
    var numberLikes = UILabel()
    
    var numberFav = UILabel()
    
    var numberCommnets = UILabel()
    
    var isLiked : Bool = false
    var isfav : Bool = false
    var btnLike = UIButton()
    
    var activityIndicater = UIActivityIndicatorView()
    var deleteIndex = NSIndexPath()
    var action = "Something"
    var userFriendsList = NSArray()
    
    var commentLabel : TTTAttributedLabel?
    var arrUserMention : NSArray?
    var lblTip = UILabel()
    var heightTip : Int = 0
    var heightComment : Int = 0
    var lineCount = 0;
    var lineCount1 = 0;
    var viewBottom = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        dispatch_async(dispatch_get_main_queue()) {
        self.webserviceData()
        }
        
        arrCommentsList = NSMutableArray()
        self.performSelector(#selector(OpenPostViewController.webServiceCallComments), withObject: nil, afterDelay: 0.0)
     
        keyText?.layer.cornerRadius = 5
        sendBtn?.layer.cornerRadius = 5
        
        self.tabBarController?.tabBar.hidden = true
        self.tabBarController?.tabBar.userInteractionEnabled = false
        
        self.navigationController?.interactivePopGestureRecognizer!.delegate = self
        
        self.navigationController?.navigationBarHidden = false
        self.navigationController!.navigationBar.barTintColor = colorNavigation
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        activityIndicater = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        activityIndicater.color = UIColor.blackColor()
        activityIndicater.frame = CGRect(x: self.view.frame.size.width/2 - 15, y: 250, width: 30, height: 30)
        activityIndicater.startAnimating()
        self.view.addSubview(activityIndicater)
        
        
        if(self.tabBarController?.tabBar == nil){
            
        }
        
        keyView = UIView()
        keyView?.frame = CGRectMake(0, UIScreen.mainScreen().bounds.size.height - 52, UIScreen.mainScreen().bounds.size.width, 52)
        keyView?.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(keyView!)
        
        let hView = UIView()
        hView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 1)
        hView.backgroundColor = UIColor.darkGrayColor()
        keyView?.addSubview(hView)
        
        let txtView = UITextView()
        txtView.frame = CGRectMake(6, 6, (keyView?.frame.size.width)! - 68, 40)
        txtView.layer.cornerRadius = 5
        txtView.font = UIFont(name: fontName, size: 17)
        txtView.text = "Type your comments here."
        txtView.textColor = UIColor.lightGrayColor()
        keyView?.addSubview(txtView)
        
        let btnSend = UIButton()
        btnSend.frame = CGRectMake(txtView.frame.origin.x + txtView.frame.size.width + 3, 12, 57, 30)
        btnSend.setTitle("Send", forState: UIControlState.Normal)
        btnSend.layer.cornerRadius = 5
        btnSend.backgroundColor = UIColor.clearColor()
        btnSend.titleLabel?.font = UIFont(name: fontBold, size: 14)
        btnSend.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        keyView?.addSubview(btnSend)
        
        let btnKey = UIButton(type : .Custom)
        btnKey.frame = CGRectMake(0, 0, (keyView?.frame.size.width)!, (keyView?.frame.size.height)!)
        btnKey.setTitle("", forState: UIControlState.Normal)
        btnKey.backgroundColor = UIColor.clearColor()
        btnKey.titleLabel?.font = UIFont(name: fontBold, size: 14)
        btnKey.addTarget(self, action: #selector(OpenPostViewController.openKeyPad(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        keyView?.addSubview(btnKey)
        
        Flurry.logEvent("PostDisplay")
        
        
        dispatch_async(dispatch_get_main_queue()) {
            print("function Called friendList")
        self.webServiceForFriendList()
        }
        
        self.tableView!.contentInset = UIEdgeInsetsMake(0, 0, 80, 0);
        tableView!.registerNib(UINib(nibName: "CardViewCell", bundle: nil), forCellReuseIdentifier: "CardCell")
        //      tableView?.backgroundColor = UIColor(red: 20/255, green: 29/255, blue: 46/255, alpha: 1.0)
        tableView?.separatorColor = UIColor.clearColor()
        tableView?.showsHorizontalScrollIndicator = false
        tableView?.showsVerticalScrollIndicator = false
        tableView?.allowsMultipleSelectionDuringEditing = true
        
        tableView!.estimatedRowHeight = 300.0
        tableView!.rowHeight = UITableViewAutomaticDimension
        tableView!.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func viewDidAppear(animated: Bool) {
      //  _kbCtrl.showOnViewController(self, adjustingScrollView: self.tableView, xforScrollViewSubview: nil)
    }
    
    override func viewWillDisappear(animated : Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.hidden = false
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
        
        if (self.isMovingFromParentViewController()){
          //  self.tabBarController?.selectedIndex = 0
            self.navigationController?.navigationBarHidden = true
        }
        
            cancelRequest()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.navigationBarHidden = true
        viewBottom.removeFromSuperview()
        self.tabBarController?.tabBar.hidden = true
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OpenPostViewController.keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(OpenPostViewController.keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil);
      //  showLoader(self.view)
        self.navigationController?.navigationBarHidden = false
        tableView?.reloadData()
    }

    //MARK:- Gesture delegates
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    func callServiceWithDelay(){
        self.webserviceData()
    }
    
    @IBAction func openKeyPad(sender : UIButton){
      //  keyView?.hidden = true
        
        _kbCtrl.setText("")
      //  let indexpath = NSIndexPath(forRow: 2, inSection: 0)
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "keyString")
        _kbCtrl.showOnViewController(self, adjustingScrollView: self.tableView, forScrollViewSubview: nil)
    }
    
    override func viewDidLayoutSubviews() {
        
        
    }
    
    //MARK:- Set Values On all Views
    
    func setvaluesOnViews(){
        
    }
    
    //MARK:-
    
    func reportDeleteMethod(sender : UIButton){
        if(dictInfoPost.objectForKey("userId") as! String == NSUserDefaults.standardUserDefaults().objectForKey("userId") as! String){
            
            selectedReport = "delete"
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Delete")
            
            actionSheet.showInView(self.view)
            
        }
        else{
            
            selectedReport = "report"
            
            let actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Report")
            
            actionSheet.showInView(self.view)
        }
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int)
    {
        if(selectedReport == "delete"){
            
            switch (buttonIndex){
                
            case 0:
                print("Cancel")
            case 1:
                print("delete")
                showColorLoader(self.view)
                self.navigationController?.popViewControllerAnimated(true)
                self.webServiceForDelete()
            default:
                print("Default")
                //Some code here..
            }
        }
        else{
            switch (buttonIndex){
                
            case 0:
                print("Cancel")
            case 1:
                print("Report")
                self.webServiceForReport()
            default:
                print("Default")
                //Some code here..
                
            }
        }
    }

    
    //MARK:- TableView DataSource and Delegate Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if(dictInfoPost.count > 0){
        if( (dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
        return arrCommentsList.count + 2
        }
        else{
        return arrCommentsList.count + 1
        }
        }
        else{
            return 0
        }
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
//        var cell = tableView.dequeueReusableCellWithIdentifier("CELL") as UITableViewCell!
//        if (cell == nil) {
//            cell = UITableViewCell(style:.Default, reuseIdentifier: "CELL")
//        }
        
        
        if(indexPath.row == 0){
          var cell = tableView.dequeueReusableCellWithIdentifier("CardCell") as! CardViewCell!
            if (cell == nil) {
                cell = CardViewCell(style:.Default, reuseIdentifier: "CardCell")
            }
          cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
            cell.blackLabel?.backgroundColor  = UIColor.whiteColor()
            cell.btnLike?.hidden = true
            cell.numberOfLikes?.hidden = true
            cell.btnComment?.hidden = true
            cell.numberOfComments?.hidden = true
            cell.btnFavorite?.hidden = true
            cell.numberOfFav?.hidden = true
            cell.btnMore?.hidden = true
            
            if(dictInfoPost.count != 0){
                cell.btnComment?.hidden = true
                cell.btnFavorite?.hidden = true
                cell.btnLike?.hidden = true
                cell.btnMore?.hidden = true
                cell.numberOfFav?.hidden = true
                
            let userPicUrl = dictInfoPost.objectForKey("userThumb") as! String
                cell.imageProfilePicture!.hnk_setImageFromURL(NSURL(string: userPicUrl)!)
            
            let userPostImage = dictInfoPost.objectForKey("postImage") as! String
            let userPostImage1 = NSURL(string: dictInfoPost.objectForKey("postImage") as! String)
            let pathExtention = userPostImage1!.pathExtension
              //  print(pathExtention)
                if(pathExtention == "gif"){
                dispatch_async(dispatch_get_main_queue()) {
           
                    cell.imageDishPost?.image = UIImage.gifWithURL(userPostImage)
                }
                }
                else{
                    cell.imageDishPost!.hnk_setImageFromURL(NSURL(string: userPostImage)!)
                }
                
            cell.imageProfilePicture?.layer.cornerRadius = 19
            cell.imageProfilePicture?.layer.masksToBounds = true
                
                
                var status = String(format: "%@ is having %@ at %@", dictInfoPost.objectForKey("userName") as! String,dictInfoPost.objectForKey("dishName") as! String,dictInfoPost.objectForKey("restaurantName") as! String)
                
                let lengthRestaurantname = (dictInfoPost.objectForKey("restaurantName") as! String).characters.count
                
                if(lengthRestaurantname < 1){
                    status = String(format: "%@ is having %@ %@", dictInfoPost.objectForKey("userName") as! String,dictInfoPost.objectForKey("dishName") as! String,dictInfoPost.objectForKey("restaurantName") as! String)
                }
                else{
                   status = String(format: "%@ is having %@ at %@, %@", dictInfoPost.objectForKey("userName") as! String,dictInfoPost.objectForKey("dishName") as! String,dictInfoPost.objectForKey("restaurantName") as! String, dictInfoPost.objectForKey("restaurantRegion") as! String)
                }
                
                
                cell.labelStatus?.text = status
                
                cell.labelStatus?.attributedTruncationToken = NSAttributedString(string: dictInfoPost.objectForKey("userName") as! String, attributes: nil)
                let nsString = status as NSString
                let range = nsString.rangeOfString(dictInfoPost.objectForKey("userName") as! String)
                let url = NSURL(string: "action://users/\("userName")")!
                cell.labelStatus!.addLinkToURL(url, withRange: range)
                
                cell.labelStatus?.attributedTruncationToken = NSAttributedString(string: dictInfoPost.objectForKey("dishName") as! String, attributes: nil)
                let nsString1 = status as NSString
                let range1 = nsString1.rangeOfString(dictInfoPost.objectForKey("dishName") as! String)
                let trimmedString = "dishName"
                
                let url1 = NSURL(string: "action://dish/\(trimmedString)")!
                cell.labelStatus!.addLinkToURL(url1, withRange: range1)
                
                if(dictInfoPost.objectForKey("restaurantIsActive") as! String == "1"){
                cell.labelStatus?.attributedTruncationToken = NSAttributedString(string: dictInfoPost.objectForKey("restaurantName") as! String, attributes: nil)
                let nsString2 = status as NSString
                let range2 = nsString2.rangeOfString(dictInfoPost.objectForKey("restaurantName") as! String)
                let trimmedString1 = "restaurantName"
                let url2 = NSURL(string: "action://restaurant/\(trimmedString1)")!
                cell.labelStatus!.addLinkToURL(url2, withRange: range2)
            }
                cell.labelStatus?.delegate = self
                cell.labelStatus?.tag = indexPath.row
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(OpenPostViewController.doubleTabMethod(_:)))
                tap.numberOfTapsRequired = 2
                cell.imageDishPost?.tag = indexPath.row
                cell.imageDishPost!.addGestureRecognizer(tap)

                
                cell.labelTimeOfPost?.text = dictInfoPost.objectForKey("timeElapsed") as? String
                
                
                cell.selectionStyle = UITableViewCellSelectionStyle.None
                
                createActionsView(cell)
                
            }
            else{
                viewBottom.removeFromSuperview()
            }
            
            return cell
        }
        else{
            
            lblTip = UILabel()
            var cell = tableView.dequeueReusableCellWithIdentifier("SomeId") as UITableViewCell!
            if (cell == nil) {
                cell = UITableViewCell(style:.Default, reuseIdentifier: "")
                
                for v in cell.subviews{
                    if v.tag == 2223{
                        v.removeFromSuperview()
                    }
                }
            }
        
           cell.contentView.clipsToBounds = true
            
        if(indexPath.row == 1 && (dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
            
            lblTip.frame = CGRectMake(10, 0, cell.frame.size.width - 12, CGFloat (heightTip))
            lblTip.tag = 233
            lblTip.backgroundColor = UIColor.whiteColor()
            lblTip.textColor = UIColor(red: 16/255, green: 21/255, blue: 31/255, alpha: 1.0)
            lblTip.lineBreakMode = NSLineBreakMode.ByWordWrapping
            lblTip.numberOfLines = 0
            lblTip.font = UIFont(name: fontName, size: 20)
            
            if((dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0 && indexPath.row == 1){
                
                lblTip.text = dictInfoPost.objectForKey("tip") as? String
               
            }
            else{
                lblTip.text = ""
            }
            
            let textSize = CGSizeMake(lblTip.frame.size.width, CGFloat(Float.infinity));
            let rHeight = lroundf(Float(lblTip.sizeThatFits(textSize).height))
            let charSize = lroundf(Float(lblTip.font.lineHeight));
            lineCount = rHeight/charSize
            
            if(lineCount == 4){
                heightTip = 110
                lblTip.frame = CGRectMake(10, 0, cell.frame.size.width - 12, CGFloat (heightTip))
            }
            else if(lineCount == 3){
                heightTip = 100
                lblTip.frame = CGRectMake(10, 0, cell.frame.size.width - 12, CGFloat (heightTip))
            }
            else if(lineCount == 2){
                heightTip = 70
                lblTip.frame = CGRectMake(10, 0, cell.frame.size.width - 12, CGFloat (heightTip))
            }
            else if(lineCount == 1){
                heightTip = 60
                lblTip.frame = CGRectMake(10, 0, cell.frame.size.width - 12, CGFloat (heightTip))
            }
            else if(lineCount == 0){
                heightTip = 60
                lblTip.frame = CGRectMake(10, 0, cell.frame.size.width - 12, CGFloat (heightTip))
            }
        }
        else{
           
            for v in cell.subviews{
                if v.tag == 2223{
                    v.removeFromSuperview()
                }
            }
            
            var userPicUrl = String()
            if(self.arrCommentsList.count > 0){
            if((dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
                userPicUrl = self.arrCommentsList.objectAtIndex(indexPath.row - 2).objectForKey("userImage") as! String
            }
            else{
                userPicUrl = self.arrCommentsList.objectAtIndex(indexPath.row - 1).objectForKey("userImage") as! String
            }
            
//            let imgUser = UIImageView()
//            imgUser.frame = CGRectMake(12, 10, 39, 39)
//            imgUser.tag = 13334
//            dispatch_async(dispatch_get_main_queue()) {
//            imgUser.hnk_setImageFromURL(NSURL(string: userPicUrl)!)
//            }
//            
//            
//            imgUser.layer.cornerRadius = 19
//            imgUser.layer.masksToBounds = true
            
            
//            let btnUserName = UIButton()
//            btnUserName.frame = CGRectMake(12, 10, 70, 16)
//            btnUserName.titleLabel?.font = UIFont(name: fontBold, size: 16)
//            if((dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
//            btnUserName.tag = 111112
//            }
//            else{
//            btnUserName.tag = 111112
//            }
//            btnUserName.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
//            btnUserName.setTitleColor(UIColor(red: 3/255, green: 105/255, blue: 219/255, alpha: 1.0), forState: UIControlState.Normal)
//            btnUserName.titleLabel?.textAlignment = NSTextAlignment.Left
//            
//            if((dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
//                btnUserName.setTitle(arrCommentsList.objectAtIndex(indexPath.row - 2).objectForKey("userName") as? String, forState: UIControlState.Normal)
//            }
//            else{
//                btnUserName.setTitle(arrCommentsList.objectAtIndex(indexPath.row - 1).objectForKey("userName") as? String, forState: UIControlState.Normal)
//            }
           
            
            
//            let btnFullName = UIButton()
//            btnFullName.frame = CGRectMake(60, 30, 150, 14)
//            btnFullName.titleLabel?.font = UIFont(name: fontName, size: 15)
//            if((dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
//            btnFullName.tag = 222223
//            }
//            else{
//            btnFullName.tag = 222223
//            }
//            btnFullName.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Left
//            btnFullName.setTitleColor(UIColor(red: 3/255, green: 105/255, blue: 219/255, alpha: 1.0), forState: UIControlState.Normal)
//            if((dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
//            btnFullName.setTitle(arrCommentsList.objectAtIndex(indexPath.row - 2).objectForKey("fullName") as? String, forState: UIControlState.Normal)
//            }
//            else{
//            btnFullName.setTitle(arrCommentsList.objectAtIndex(indexPath.row - 1).objectForKey("fullName") as? String, forState: UIControlState.Normal)
//            }
            
//            let lblTime = UILabel()
//            lblTime.frame = CGRectMake(tableView.frame.size.width - 30, 10, 30, 20)
//            lblTime.textColor = UIColor.grayColor()
//            lblTime.font = UIFont(name: fontName, size: 13)
//          
            var commentTime = String()
            if((dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
            commentTime = differenceDate((arrCommentsList.objectAtIndex(indexPath.row - 2).objectForKey("createDate") as? String)!)
            }
            else{
             commentTime = differenceDate((arrCommentsList.objectAtIndex(indexPath.row - 1).objectForKey("createDate") as? String)!)
            }
//            lblTime.tag = 10234
            
            let btnTapUser = UIButton(type: UIButtonType.Custom)
            btnTapUser.frame = CGRectMake(10, 5, 40, 20)
            btnTapUser.backgroundColor = UIColor.clearColor()
            if((dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
                btnTapUser.tag = indexPath.row - 2
            }
            else{
                btnTapUser.tag = indexPath.row - 1
            }
             btnTapUser.addTarget(self, action: #selector(OpenPostViewController.userBtnTap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
            
            var comnt = String()
                
            if((dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
            comnt = String(format: "%@ %@", (arrCommentsList.objectAtIndex(indexPath.row - 2).objectForKey("userName") as? String)!,arrCommentsList.objectAtIndex(indexPath.row-2).objectForKey("comment") as! String)
            }
            else{
            comnt = String(format: "%@ %@", (arrCommentsList.objectAtIndex(indexPath.row - 1).objectForKey("userName") as? String)!,arrCommentsList.objectAtIndex(indexPath.row-1).objectForKey("comment") as! String)
            }
            comnt = comnt.stringByReplacingOccurrencesOfString("\\", withString: "")
            
            commentLabel = TTTAttributedLabel(frame: CGRectMake(0, 0, cell.contentView.frame.size.width - 30, 70))
            
            commentLabel?.tag = 2223
            commentLabel?.font = UIFont(name: fontName,size: 16)
            commentLabel?.numberOfLines = 0
            commentLabel?.delegate = self
       
            let nsString = comnt as NSString
            commentLabel?.text = ""
            commentLabel?.text = nsString as String
                
            commentLabel?.backgroundColor = UIColor.clearColor()
            commentLabel!.clipsToBounds = true
            commentLabel?.sizeToFit()
            
            
            let textSize = CGSizeMake(commentLabel!.frame.size.width, CGFloat(Float.infinity));
            let rHeight = lroundf(Float(commentLabel!.sizeThatFits(textSize).height))
            let charSize = lroundf(Float(commentLabel!.font.lineHeight));
            lineCount1 = rHeight/charSize
            
            if(lineCount1 == 0){
                
                   commentLabel?.frame = CGRectMake(10, 0, cell.contentView.frame.size.width - 10, 20)
                
                
            }
            else if(lineCount1 == 1){
               
                    commentLabel?.frame = CGRectMake(10, 0, cell.contentView.frame.size.width - 10, 55)
               
                
            }
            else if(lineCount1 == 2){
               
                    commentLabel?.frame = CGRectMake(10, 0, cell.contentView.frame.size.width - 10, 65)
               
                
            }
            else if(lineCount1 == 3){
               
                   commentLabel?.frame = CGRectMake(10, 0, cell.contentView.frame.size.width - 10, 100)
                
            }
            else if(lineCount1 == 4){
               
                    commentLabel?.frame = CGRectMake(10, 0, cell.contentView.frame.size.width - 10, 100)
               
                
            }
            else if(lineCount1 == 5){
              
                    commentLabel?.frame = CGRectMake(10, 0, cell.contentView.frame.size.width - 10, 120)
               
                
            }
            else if(lineCount1 == 6){
               
                    commentLabel?.frame = CGRectMake(10, 0, cell.contentView.frame.size.width - 10, 140)
               
                
            }
            else{
               
                    commentLabel?.frame = CGRectMake(10, 0, cell.contentView.frame.size.width - 10, 150)
               
            }
            
            arrUserMention = NSArray()
            if((dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
            arrUserMention = arrCommentsList.objectAtIndex(indexPath.row - 2).objectForKey("userMentioned") as? NSArray
            }
            else{
            arrUserMention = arrCommentsList.objectAtIndex(indexPath.row - 1).objectForKey("userMentioned") as? NSArray
            }
            
            for(var index = 0; index < arrUserMention!.count; index += 1){
                commentLabel!.attributedTruncationToken = NSAttributedString(string: String(format: "@%@", arrUserMention!.objectAtIndex(index).objectForKey("userName") as! String) , attributes: nil)
                let nsString =  NSString(format: "%@", comnt)
                
              
                let mystr = nsString
                let searchstr = String(format:"@%@",arrUserMention!.objectAtIndex(index).objectForKey("userName") as! String)
                let ranges: [NSRange]
                
                do {
                    // Create the regular expression.
                    let regex = try NSRegularExpression(pattern: searchstr, options: [])
                    
                    // Use the regular expression to get an array of NSTextCheckingResult.
                    // Use map to extract the range from each result.
                    ranges = regex.matchesInString(mystr as String, options: [], range: NSMakeRange(0, mystr.length)).map {$0.range}
                }
                catch {
                    // There was a problem creating the regular expression
                    ranges = []
                }
                
              
                for(var indexing = 0; indexing < ranges.count; indexing++){
                    let range = ranges[indexing] as NSRange
                    let url = NSURL(string: String(format: "action://users/mentionUserName%d",index))!
                   
                    commentLabel!.addLinkToURL(url, withRange: range)
                }
                commentLabel!.adjustsFontSizeToFitWidth  = true;
               // commentLabel?.sizeToFit()
            }
            var range = NSRange()
                if((dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
                    commentLabel?.attributedTruncationToken = NSAttributedString(string: (arrCommentsList.objectAtIndex(indexPath.row - 2).objectForKey("userName") as? String)!, attributes: nil)
                    range = nsString.rangeOfString((arrCommentsList.objectAtIndex(indexPath.row - 2).objectForKey("userName") as? String)!)
                }
                else{
                   commentLabel?.attributedTruncationToken = NSAttributedString(string: (arrCommentsList.objectAtIndex(indexPath.row - 1).objectForKey("userName") as? String)!, attributes: nil)
                    range = nsString.rangeOfString((arrCommentsList.objectAtIndex(indexPath.row - 1).objectForKey("userName") as? String)!)
                }
                    
                    let url = NSURL(string: "action://users/\("userTap")")!
                    commentLabel!.addLinkToURL(url, withRange: range)
                
            
            if((cell.contentView.viewWithTag(13334)) != nil){
               cell.contentView.viewWithTag(13334)!.removeFromSuperview()
            }
            
            if((cell.contentView.viewWithTag(111112)) != nil){
                cell.contentView.viewWithTag(111112)!.removeFromSuperview()
            }
            
            if((cell.contentView.viewWithTag(222223)) != nil){
                cell.contentView.viewWithTag(222223)!.removeFromSuperview()
            }
            
            
            if((cell.contentView.viewWithTag(2223)) != nil){
                cell.contentView.viewWithTag(2223)!.removeFromSuperview()
            }
            
            if((cell.contentView.viewWithTag(10234)) != nil){
                cell.contentView.viewWithTag(10234)!.removeFromSuperview()
            }
            
            for v in cell.subviews{
                if v.tag == 2223{
                    v.removeFromSuperview()
                }
            }
            
            cell.contentView.addSubview(commentLabel!)
            
            let lineH = UIView()
            lineH.frame = CGRectMake(0, commentLabel!.frame.origin.y + commentLabel!.frame.size.height - 2, tableView.frame.size.width, 1)
            lineH.tag = 10001
            lineH.backgroundColor = UIColor.clearColor()
            
            if((cell.contentView.viewWithTag(10001)) != nil){
                cell.contentView.viewWithTag(10001)!.removeFromSuperview()
            }
            
        //    cell.contentView.addSubview(imgUser)
        //    cell.contentView.addSubview(btnUserName)
       //     cell.contentView.addSubview(btnFullName)
       //     cell.contentView.addSubview(lblTime)
            cell.contentView.addSubview(lineH)
            cell.contentView.addSubview(btnTapUser)
            }
        }
            
            if((cell.contentView.viewWithTag(233)) != nil){
                cell.contentView.viewWithTag(233)!.removeFromSuperview()
            }
            
            
            cell.contentView.addSubview(lblTip)
           
            cell.selectionStyle = UITableViewCellSelectionStyle.None
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
      
        if(indexPath.row != 0) {
           // return UITableViewAutomaticDimension
            if(indexPath.row == 1){
                
                    return 200
                
            }
            else{
                return 200
            }
        }
        return 430
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if(indexPath.row == 0){
            if(UIScreen.mainScreen().bounds.size.height > 570 && UIScreen.mainScreen().bounds.size.height < 1140){
                let lineCount = numberOfLinesStatus(indexPath)
                
                
                if(UIScreen.mainScreen().bounds.size.height < 730){
                    if(lineCount == 1.0){
                        return 480
                    }
                    else if(lineCount == 2.0){
                        return 480
                    }
                    else if(lineCount == 3.0){
                        return 510
                    }
                    else if(lineCount == 4.0){
                        return 520
                    }
                    else if(lineCount == 100){
                        return 480
                    }
                    else {
                        return 540
                    }
                }
                else{
                    if(lineCount == 1.0){
                        return 520
                    }
                    else if(lineCount == 2.0){
                        return 520
                    }
                    else if(lineCount == 3.0){
                        return 530
                    }
                    else if(lineCount == 4.0){
                        return 560
                    }
                    else if(lineCount == 100){
                        return 520
                    }
                    else {
                        return 580
                    }
                }

            }
            else{
                let lineCount = numberOfLinesStatus(indexPath)
                
                
                if(lineCount == 1.0){
                    return 420
                }
                else if(lineCount == 2.0){
                    return 420
                }
                else if(lineCount == 3.0){
                    return 440
                }
                else if(lineCount == 4.0){
                    return 460
                }
                else if(lineCount == 100.0){
                    return 420
                }
                else {
                    return 480
                }
            }
        }
        else if(indexPath.row == 1){
           if( (dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
            
            let textSize = CGSizeMake(lblTip.frame.size.width, CGFloat(Float.infinity));
            let rHeight = lroundf(Float(lblTip.sizeThatFits(textSize).height))
            let charSize = lroundf(Float(lblTip.font.lineHeight));
            lineCount = rHeight/charSize
            
            if(lineCount == 4){
                heightTip = 110
                return 110
            }
            else if(lineCount == 3){
                heightTip = 100
                return 100
            }
            else if(lineCount == 2){
                heightTip = 70
                return 70
            }
            else if(lineCount == 1){
                heightTip = 60
                return 60
            }
            else if(lineCount == 0){
                heightTip = 60
                return 60
            }
            else{
                return UITableViewAutomaticDimension
            }
            }
            
           
           else{
            var lineCount = 0;
            let textSize = CGSizeMake(commentLabel!.frame.size.width, CGFloat(Float.infinity));
            let rHeight = lroundf(Float(commentLabel!.sizeThatFits(textSize).height))
            let charSize = lroundf(Float(commentLabel!.font.lineHeight));
            lineCount = rHeight/charSize
            
            if(lineCount1 == 5){
                heightComment = 130
                
                    return 120
                
            }
            else if(lineCount1 == 4){
                heightComment = 110
                   return 110
                
            }
            else if(lineCount1 == 3){
                heightComment = 90
               
                   return 80
               
                
            }
            else if(lineCount1 == 2){
                heightComment = 70
               
                    return 70
                
                
            }
            else if(lineCount1 == 1){
                heightComment = 40
               
                    return 40
               
                
            }
            else if(lineCount1 == 0){
                
                heightComment = 40
              
                    return 40
               
                
            }
            else{
                heightComment = 130
               
                    return 140
                
            }
            }
        }
        else{
            
            var lineCount = 0;
            let textSize = CGSizeMake(commentLabel!.frame.size.width, CGFloat(Float.infinity));
            let rHeight = lroundf(Float(commentLabel!.sizeThatFits(textSize).height))
            let charSize = lroundf(Float(commentLabel!.font.lineHeight));
            lineCount = rHeight/charSize
            
            if(lineCount1 == 5){
                heightComment = 130
                
                    return 120
               
            }
            else if(lineCount1 == 4){
                heightComment = 110
                
                    return 110
               
            }
            else if(lineCount1 == 3){
                heightComment = 90
               
                    return 80
               
                
            }
            else if(lineCount1 == 2){
                heightComment = 70
              
                    return 70
              
                
            }
            else if(lineCount1 == 1){
                heightComment = 40
               
                    return 40
               
                
            }
            else if(lineCount1 == 0){
                
                heightComment = 40
               
                    return 40
               
                
            }
            else{
                heightComment = 130
               
                    return 140
               
            }
        }
        return CGFloat (heightComment)
    }
    
    func numberLinesLabel(indexPath : NSIndexPath) -> CGFloat{
        if(dictInfoPost.count > 0){
            let labelText = UILabel()
            labelText.font = UIFont(name: fontName, size: 16)
            labelText.frame = CGRectMake(10, 0, self.view.frame.size.width - 10, 70)
            labelText.numberOfLines = 0
            
            labelText.lineBreakMode = NSLineBreakMode.ByWordWrapping
            var status = ""
            var lengthRestaurantname = 0
            lengthRestaurantname = (dictInfoPost.objectForKey("restaurantName") as! String).characters.count
            if(dictInfoPost.count > 0){
                if(lengthRestaurantname > 1){
                    status = String(format: "%@ is having %@ at %@, %@", dictInfoPost.objectForKey("userName") as! String,dictInfoPost.objectForKey("dishName") as! String,dictInfoPost.objectForKey("restaurantName") as! String, dictInfoPost.objectForKey("restaurantRegion") as! String)
                }
                
                if(lengthRestaurantname < 1){
                    status = String(format: "%@ is having %@", dictInfoPost.objectForKey("userName") as! String,dictInfoPost.objectForKey("dishName") as! String)
                }
                labelText.text = status
                labelText.sizeToFit()
                
                let textSize = CGSizeMake(labelText.frame.size.width, CGFloat(Float.infinity));
                let rHeight = lroundf(Float(labelText.sizeThatFits(textSize).height))
                let charSize = lroundf(Float(labelText.font.lineHeight));
                let lineCount1 = rHeight/charSize
                
                let myCGFloat = CGFloat(lineCount1)
                
                return myCGFloat
            }
            return 100
        }
        else{
            return 100
        }
    }
    
    func numberOfLinesStatus(indexPath : NSIndexPath) -> CGFloat{
        if(dictInfoPost.count > 0){
            let labelText = UILabel()
            labelText.font = UIFont(name: fontName, size: 16)
            labelText.frame = CGRectMake(47, 0, self.view.frame.size.width - 47-39, 70)
            labelText.numberOfLines = 0
            
            labelText.lineBreakMode = NSLineBreakMode.ByWordWrapping
            var status = ""
            var lengthRestaurantname = 0
            lengthRestaurantname = (dictInfoPost.objectForKey("restaurantName") as! String).characters.count
            if(dictInfoPost.count > 0){
                if(lengthRestaurantname > 1){
                    status = String(format: "%@ is having %@ at %@, %@", dictInfoPost.objectForKey("userName") as! String,dictInfoPost.objectForKey("dishName") as! String,dictInfoPost.objectForKey("restaurantName") as! String, dictInfoPost.objectForKey("restaurantRegion") as! String)
                }
                
                if(lengthRestaurantname < 1){
                    status = String(format: "%@ is having %@", dictInfoPost.objectForKey("userName") as! String,dictInfoPost.objectForKey("dishName") as! String)
                }
                labelText.text = status
                labelText.sizeToFit()
                
                let textSize = CGSizeMake(labelText.frame.size.width, CGFloat(Float.infinity));
                let rHeight = lroundf(Float(labelText.sizeThatFits(textSize).height))
                let charSize = lroundf(Float(labelText.font.lineHeight));
                let lineCount1 = rHeight/charSize
                
                let myCGFloat = CGFloat(lineCount1)
                
                return myCGFloat
            }
            return 100
        }
        else{
            return 100
        }
    }


    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
      //  self.tableView?.bringSubviewToFront(btnCommentView)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if( (dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
        if(indexPath.row != 0 && indexPath.row != 1){
            return true
        }
        }
        else{
            if(indexPath.row != 0){
                return true
            }
        }
        return false
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            if( (dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
            if(arrCommentsList.objectAtIndex(indexPath.row - 2).objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String) && (dictInfoPost.objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String){
                
                let alertController = UIAlertController(title: "Report Comment?", message: "", preferredStyle: .Alert)
                
                // Create the actions
                let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                   self.webServiceForCommentReport(indexPath.row)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
                    UIAlertAction in
                    
                }
                
                // Add the actions
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                
                // Present the controller
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            else{
                
                let alertController = UIAlertController(title: "Delete Comment ?", message: "", preferredStyle: .Alert)
                
                // Create the actions
                let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
                    UIAlertAction in
                    self.webServiceForCommentDelete(indexPath.row)
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
                    UIAlertAction in
                    
                }
                
                // Add the actions
                alertController.addAction(okAction)
                alertController.addAction(cancelAction)
                
                // Present the controller
                self.presentViewController(alertController, animated: true, completion: nil)
            }
            }
            else{
                if(arrCommentsList.objectAtIndex(indexPath.row - 1).objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String) && (dictInfoPost.objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String){
                    
                    let alertController = UIAlertController(title: "Report Comment?", message: "", preferredStyle: .Alert)
                    
                    // Create the actions
                    let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
                        UIAlertAction in
                        self.webServiceForCommentReport(indexPath.row)
                    }
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
                        UIAlertAction in
                        
                    }
                    
                    // Add the actions
                    alertController.addAction(okAction)
                    alertController.addAction(cancelAction)
                    
                    // Present the controller
                    self.presentViewController(alertController, animated: true, completion: nil)
                }
                else{
                    
                    let alertController = UIAlertController(title: "Delete Comment ?", message: "", preferredStyle: .Alert)
                    
                    // Create the actions
                    let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) {
                        UIAlertAction in
                        self.webServiceForCommentDelete(indexPath.row)
                    }
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
                        UIAlertAction in
                        
                    }
                    
                    // Add the actions
                    alertController.addAction(okAction)
                    alertController.addAction(cancelAction)
                    
                    // Present the controller
                    self.presentViewController(alertController, animated: true, completion: nil)
                }

            }
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        userLoginAllInfo =  (NSUserDefaults.standardUserDefaults().objectForKey("LoginDetails") as? NSMutableDictionary)!
        deleteIndex = indexPath
        if( (dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
        if(arrCommentsList.objectAtIndex(indexPath.row - 2).objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String) && (dictInfoPost.objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String){
            
        let deleteButton = UITableViewRowAction(style: .Default, title: "Report", handler: { (action, indexPath) in
            self.tableView!.dataSource?.tableView?(
                self.tableView!,
                commitEditingStyle: .Delete,
                forRowAtIndexPath: indexPath
            )
            
            return
        })
        
        deleteButton.backgroundColor = UIColor(red: 4/255.0, green: 121/255.0, blue: 251/255.0, alpha: 1.0)
        
        return [deleteButton]
        }
        else if(dictInfoPost.objectForKey("userName") as? String == userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String){
            
            let deleteButton = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action, indexPath) in
                self.tableView!.dataSource?.tableView?(
                    self.tableView!,
                    commitEditingStyle: .Delete,
                    forRowAtIndexPath: indexPath
                )
                
                return
            })
            
            deleteButton.backgroundColor = UIColor.redColor()
            
            return [deleteButton]
        }
        else{
            let deleteButton = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action, indexPath) in
                self.tableView!.dataSource?.tableView?(
                    self.tableView!,
                    commitEditingStyle: .Delete,
                    forRowAtIndexPath: indexPath
                )
                
                return
            })
            
            deleteButton.backgroundColor = UIColor.redColor()
            
            return [deleteButton]
        }
        }
        else{
            if(arrCommentsList.objectAtIndex(indexPath.row - 1).objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String) && (dictInfoPost.objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String){
                
                let deleteButton = UITableViewRowAction(style: .Default, title: "Report", handler: { (action, indexPath) in
                    self.tableView!.dataSource?.tableView?(
                        self.tableView!,
                        commitEditingStyle: .Delete,
                        forRowAtIndexPath: indexPath
                    )
                    
                    return
                })
                
                deleteButton.backgroundColor = UIColor(red: 4/255.0, green: 121/255.0, blue: 251/255.0, alpha: 1.0)
                
                return [deleteButton]
            }
            else if(dictInfoPost.objectForKey("userName") as? String == userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String){
                
                let deleteButton = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action, indexPath) in
                    self.tableView!.dataSource?.tableView?(
                        self.tableView!,
                        commitEditingStyle: .Delete,
                        forRowAtIndexPath: indexPath
                    )
                    
                    return
                })
                
                deleteButton.backgroundColor = UIColor.redColor()
                
                return [deleteButton]
            }
            else{
                let deleteButton = UITableViewRowAction(style: .Default, title: "Delete", handler: { (action, indexPath) in
                    self.tableView!.dataSource?.tableView?(
                        self.tableView!,
                        commitEditingStyle: .Delete,
                        forRowAtIndexPath: indexPath
                    )
                    
                    return
                })
                
                deleteButton.backgroundColor = UIColor.redColor()
                
                return [deleteButton]
            }
 
        }
        
    }
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        userLoginAllInfo =  (NSUserDefaults.standardUserDefaults().objectForKey("LoginDetails") as? NSMutableDictionary)!
        if( (dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
        if(arrCommentsList.objectAtIndex(indexPath.row - 2).objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String){
            
        return "Report"
        }
        }
        else{
            if(arrCommentsList.objectAtIndex(indexPath.row - 1
                ).objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String){
                
                return "Report"
            }
        }
        return "Delete"
    }
    
    
    //MARK:- cellActionButtons and Values
    
    func createActionsView(cell : CardViewCell){
      
        viewBottom.removeFromSuperview()
        viewBottom = UIView()
            if(UIScreen.mainScreen().bounds.size.height < 570){
                print("cell height",cell.contentView.frame.size.height)
        viewBottom.frame = CGRectMake(0, cell.imageDishPost!.frame.origin.y + self.view.frame.size.width, UIScreen.mainScreen().bounds.size.width, 40)
            }
            else{
             viewBottom.frame = CGRectMake(0, cell.imageDishPost!.frame.origin.y + self.view.frame.size.width + 10, UIScreen.mainScreen().bounds.size.width, 45)
            }

        viewBottom.backgroundColor = UIColor.whiteColor()
        cell.contentView.addSubview(viewBottom)
        
        
        btnLike = UIButton()
        btnLike.frame = CGRectMake(10, 10, 21, 21)
        btnLike.backgroundColor = UIColor.clearColor()
        btnLike.tag = 22
        if(isLiked == false){
        btnLike.setImage(UIImage(named: "Like Heart.png"), forState: UIControlState.Normal)
        }
        else{
        btnLike.setImage(UIImage(named: "Heart Liked.png"), forState: UIControlState.Normal)
        }
        btnLike.addTarget(self, action: #selector(OpenPostViewController.likeBtnPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        viewBottom.addSubview(btnLike)
        
        numberLikes = UILabel()
        numberLikes.frame = CGRectMake(btnLike.frame.size.width+12, 4, 35, 35)
        numberLikes.textColor = UIColor.blackColor()
        numberLikes.font = UIFont(name: fontBold, size: 18)
        numberLikes.textAlignment = NSTextAlignment.Center
        numberLikes.text = dictInfoPost.objectForKey("like_count") as? String
        viewBottom.addSubview(numberLikes)
        
        
        let btnFav = UIButton()
        btnFav.frame = CGRectMake(95, 10, 24, 21)
        btnFav.backgroundColor = UIColor.whiteColor()
        btnFav.tag = 22
        if(isfav == false){
        btnFav.setImage(UIImage(named: "bookmark (1).png"), forState: UIControlState.Normal)
        }
        else{
        btnFav.setImage(UIImage(named: "bookmark_red.png"), forState: UIControlState.Normal)
        }
        btnFav.addTarget(self, action: #selector(OpenPostViewController.favoriteBtnPressed(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        viewBottom.addSubview(btnFav)
        
        numberFav = UILabel()
        numberFav.frame = CGRectMake(btnFav.frame.origin.x + btnFav.frame.size.width + 3, 4, 35, 35)
        numberFav.textColor = UIColor.blackColor()
        numberFav.font = UIFont(name: fontBold, size: 18)
        numberFav.textAlignment = NSTextAlignment.Center
        numberFav.text = dictInfoPost.objectForKey("bookmarkCount") as? String
        viewBottom.addSubview(numberFav)
        
        let imgComment = UIImageView()
        imgComment.frame = CGRectMake(numberFav.frame.origin.x + numberFav.frame.size.width + 35, 10, 22, 22)
        imgComment.image = UIImage(named: "Comment Message.png")
        viewBottom.addSubview(imgComment)
        
        numberCommnets = UILabel()
        numberCommnets.frame = CGRectMake(imgComment.frame.origin.x+25, 4, 35, 35)
        numberCommnets.textColor = UIColor.blackColor()
        numberCommnets.font = UIFont(name: fontBold, size: 18)
        numberCommnets.textAlignment = NSTextAlignment.Center
        numberCommnets.text = String(format: "%d", arrCommentsList.count)
        viewBottom.addSubview(numberCommnets)
        
        let btnMore = UIButton()
        btnMore.frame = CGRectMake( UIScreen.mainScreen().bounds.size.width - 30, 11, 4, 16)
        btnMore.setImage(UIImage(named: "more-3.png"), forState: UIControlState.Normal)
        btnMore.addTarget(self, action: #selector(OpenPostViewController.reportDeleteMethod(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        btnMore.backgroundColor = UIColor.whiteColor()
        btnMore.alpha = 0.4
        btnMore.tag = 22
        btnMore.titleLabel?.textAlignment = NSTextAlignment.Center
        viewBottom.addSubview(btnMore)
        
        let btnMore1 = UIButton(type: UIButtonType.Custom) as UIButton
        btnMore1.frame = CGRectMake( UIScreen.mainScreen().bounds.size.width - 50, 10, 50, 50)
        btnMore1.addTarget(self, action: #selector(OpenPostViewController.reportDeleteMethod(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        btnMore1.backgroundColor = UIColor.clearColor()
        btnMore1.tag = 22
        btnMore1.titleLabel?.textAlignment = NSTextAlignment.Center
        viewBottom.addSubview(btnMore1)
     //   }
        self.setRatings(cell)
    }

    
    //MARK:- ScrollViewDelegates
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
    
    //MARK:- cellActionButtons and Values
    
    //MARK:- Set Ratings
    
    func setRatings(cell : CardViewCell){
        if(dictInfoPost.count > 0){
        let rateValue = dictInfoPost.objectForKey("rating") as! String
            if(rateValue == "1"){
                cell.star1?.image = UIImage(named: "stars-01.png")
                cell.star2?.image = UIImage(named: "stars-02.png")
                cell.star3?.image = UIImage(named: "stars-02.png")
                cell.star4?.image = UIImage(named: "stars-02.png")
                cell.star5?.image = UIImage(named: "stars-02.png")
            }
            else if(rateValue == "2"){
                cell.star1?.image = UIImage(named: "stars-01.png")
                cell.star2?.image = UIImage(named: "stars-01.png")
                cell.star3?.image = UIImage(named: "stars-02.png")
                cell.star4?.image = UIImage(named: "stars-02.png")
                cell.star5?.image = UIImage(named: "stars-02.png")
            }
            else if(rateValue == "3"){
                cell.star1?.image = UIImage(named: "stars-01.png")
                cell.star2?.image = UIImage(named: "stars-01.png")
                cell.star3?.image = UIImage(named: "stars-01.png")
                cell.star4?.image = UIImage(named: "stars-02.png")
                cell.star5?.image = UIImage(named: "stars-02.png")
            }
            else if(rateValue == "4"){
                cell.star1?.image = UIImage(named: "stars-01.png")
                cell.star2?.image = UIImage(named: "stars-01.png")
                cell.star3?.image = UIImage(named: "stars-01.png")
                cell.star4?.image = UIImage(named: "stars-01.png")
                cell.star5?.image = UIImage(named: "stars-02.png")
            }
            else if(rateValue == "5"){
                cell.star1?.image = UIImage(named: "stars-01.png")
                cell.star2?.image = UIImage(named: "stars-01.png")
                cell.star3?.image = UIImage(named: "stars-01.png")
                cell.star4?.image = UIImage(named: "stars-01.png")
                cell.star5?.image = UIImage(named: "stars-01.png")
            }
        }
    }
    
    //MARK:- commentSend Action
    
    func sendbuttonAction(sender : UIButton){
        
    }
    
    //MARK:- DubleTabMethodTabbed
    
    func doubleTabMethod(sender : UITapGestureRecognizer){
        if(imgLikeDubleTap == nil){
        imgLikeDubleTap = UIImageView()
        }
        self.imgLikeDubleTap?.frame = CGRectMake(self.view.frame.size.width/2, self.view.frame.size.width/2, 0, 0)
        imgLikeDubleTap?.image = UIImage(named: "heart.png")
        imgLikeDubleTap?.backgroundColor = UIColor.clearColor()
        sender.view?.addSubview((imgLikeDubleTap)!)
        
        UIView.animateWithDuration(0.2, animations: {
            self.imgLikeDubleTap?.hidden = false
            self.imgLikeDubleTap?.frame = CGRectMake(self.view.frame.size.width/2 - 100, self.view.frame.size.width/2 - 100, 200, 200)
        })
        
    var methodName = String()
    if(isLiked == false){
    
    methodName = addlikeMethod
    let url = String(format: "%@%@%@", baseUrl, controllerLike, methodName)
    let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
    let postId = dictInfoPost.objectForKey("id")
    let params = NSMutableDictionary()
    btnLike.setImage(UIImage(named: "Heart Liked.png"), forState: UIControlState.Normal)
    numberLikes.text = String(format: "%d", Int((numberLikes.text!))! + 1)
        
    params.setObject(sessionId!, forKey: "sessionId")
    params.setObject(postId!, forKey: "postId")
    dispatch_async(dispatch_get_main_queue()) {
    //  webServiceCallingPost(url, parameters: params)
        webServiceCallingPost(url, parameters: params)
        delegate = self
    }
        delegate = self
        isLiked = true
    }
    else{
        self.performSelector(#selector(OpenPostViewController.removeDubleTapImage), withObject: nil, afterDelay: 1)
        }
    }
    
    func removeDubleTapImage(){
        UIView.animateWithDuration(0.2, animations: {
            //   self.imgLikeDubleTap?.frame = CGRectMake(160, 160, 0, 0)
            self.imgLikeDubleTap?.hidden = true
            
            self.imgLikeDubleTap?.removeFromSuperview()
        })
    }

    
    //MARK:- webService Calling
    
    func webServiceCallComments(){
        action = "Something"

        if (isConnectedToNetwork()){
        //showLoader(self.view)
        let url = String(format: "%@%@%@", baseUrl, controllerComment, postListMethod)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        
        let postId = postIdOpenPost
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(postId, forKey: "postId")
        
   //     webServiceCallingPost(url, parameters: params)
            
            webServiceCallingPost(url, parameters: params)
            
        delegate = self
        }
        else{
           internetMsg(self.view)
        }
    }
    
    func webServiceForCommentDelete(index : Int){
        action = "Delete"
        if (isConnectedToNetwork()){
            showColorLoader(self.view)
            let url = "http://52.74.136.146/index.php/service/comment/delete"
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            
            var commentId = String()
            if( (dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
                commentId = arrCommentsList.objectAtIndex(index-2).objectForKey("id") as! String
            }
            else{
                commentId = arrCommentsList.objectAtIndex(index-1).objectForKey("id") as! String
            }
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(commentId, forKey: "commentId")
            
         //   webServiceCallingPost(url, parameters: params)
            webServiceCallingPost(url, parameters: params)
            
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
    }
    
    func webServiceForCommentReport(index : Int){
        action = "Report"
        if (isConnectedToNetwork()){
            showColorLoader(self.view)
            let url = "http://52.74.136.146/index.php/service/flag/comment"
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            
            var commentId = String()
            if( (dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
            commentId = arrCommentsList.objectAtIndex(index-2).objectForKey("id") as! String
            }
            else{
             commentId = arrCommentsList.objectAtIndex(index-1).objectForKey("id") as! String
            }
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(commentId, forKey: "commentId")
            
            
    //        webServiceCallingPost(url, parameters: params)
            
            webServiceCallingPost(url, parameters: params)
            
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
    }
    
    func webserviceData(){
        if (isConnectedToNetwork()){
        
        let url = String(format: "%@%@%@", baseUrl, controllerPost, "get")
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let postId = postIdOpenPost
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(postId, forKey: "postId")
        
            
  //      webServiceCallingPost(url, parameters: params)
            
            webServiceCallingPost(url, parameters: params)
            
        delegate = self
        }
        else{
            internetMsg(self.view)
        }
    }
    
    func webServiceAddComment(){
        action = "Add"
        if (isConnectedToNetwork()){
        showColorLoader(self.view)
        let url = String(format: "%@%@%@", baseUrl, controllerComment, addFlagMethod)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let postId = postIdOpenPost
        let params = NSMutableDictionary()
        let userMention = NSMutableArray()
        let userNameArray = NSUserDefaults.standardUserDefaults().objectForKey("userNames")?.mutableCopy() as! NSMutableArray
        let userIdArray = NSUserDefaults.standardUserDefaults().objectForKey("userIds")?.mutableCopy() as! NSMutableArray
        
        let strbase64 = toBase64(commentText)
        
            
            for(var index = 0; index < userNameArray.count; index += 1){
                let dict = NSMutableDictionary()
                dict.setObject(userNameArray.objectAtIndex(index), forKey: "userName")
                dict.setObject(userIdArray.objectAtIndex(index), forKey: "userId")
                userMention.addObject(dict)
            }
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(postId, forKey: "postId")
        params.setObject(strbase64, forKey: "comment")
            if(userNameArray.count > 0){
        params.setObject(userMention, forKey: "userMentioned")
            }
        
            
     //   webServiceCallingPost(url, parameters: params)
            
            webServiceCallingPost(url, parameters: params)
            
        delegate = self
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userIds")
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "userNames")
        }
        else{
            internetMsg(self.view)
        }
    }
    
    
    func webServiceForDelete(){
            if (isConnectedToNetwork()){
            showColorLoader(self.view)
            
            let url = String(format: "%@%@%@", baseUrl,controllerPost,deleteLikeMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(postIdOpenPost, forKey: "postId")
            
                
            webServiceCallingPost(url, parameters: params)
                
                
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
        
    }
    
    func webServiceForReport(){
        //flag/add
        if (isConnectedToNetwork()){
            showColorLoader(self.view)
            
            let url = String(format: "%@%@%@", baseUrl,controllerFlag,addlikeMethod)
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(postIdOpenPost, forKey: "postId")
            
            
        //    webServiceCallingPost(url, parameters: params)
            
            webServiceCallingPost(url, parameters: params)
            
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
        
    }
    
    func webServiceForFriendList(){
        if (isConnectedToNetwork()){
          //  showColorLoader(self.view)
            
            let url = String(format: "%@%@%@", baseUrl,"follower","/listFollowed")
            let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
            let params = NSMutableDictionary()
            let strUserId = NSUserDefaults.standardUserDefaults().objectForKey("userId")
            
            params.setObject(sessionId!, forKey: "sessionId")
            params.setObject(strUserId!, forKey: "selectedUserId")
            
            
        //    webServiceCallingPost(url, parameters: params)
            
            webServiceCallingPost(url, parameters: params)
            
            delegate = self
        }
        else{
            internetMsg(self.view)
        }
    }

    
    //MARK:- WebService Delegates
    
    func getDataFromWebService(dict : NSMutableDictionary){
       
        if(dict.objectForKey("api") as! String == "comment/add"){
           
            if(dict.objectForKey("status") as! String == "OK"){
                
              //  self.webServiceCallComments()
               var dict1 = NSDictionary()
                dict1 = (dict.objectForKey("comment")?.mutableCopy() as? NSDictionary)!
               arrCommentsList.addObject(dict1)
               
                self.performSelectorOnMainThread(#selector(tableView?.reloadData), withObject: nil, waitUntilDone: false)

                
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
            
        else if(dict.objectForKey("api") as! String == "comment/delete"){
            if(dict.objectForKey("status") as! String == "OK"){
                dispatch_async(dispatch_get_main_queue()) {
                self.webServiceCallComments()
                }
            }
        }
            
        else if(dict.objectForKey("api") as! String == "follower/listFollowed"){
            print("response came of friendList")
            if(dict.objectForKey("status") as! String == "OK"){
               userFriendsList = dict.objectForKey("followedUsers") as! NSArray
            }
            NSUserDefaults.standardUserDefaults().setObject(userFriendsList, forKey: "friendList")
        }
            
        else if(dict.objectForKey("api") as! String == "flag/comment"){
            if(dict.objectForKey("status") as! String == "OK"){
                let refreshAlert = UIAlertController(title: "Report Successful", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                
                refreshAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
                    
                }))
                
                presentViewController(refreshAlert, animated: true, completion: nil)
                tableView?.reloadData()
            }
            else{
               tableView?.reloadData()
            }
        }
            
        else if(dict.objectForKey("api") as! String == "post/get"){
            
            if(dict.objectForKey("status") as! String == "OK"){
               
                dictInfoPost = dict.objectForKey("post") as! NSDictionary
                if(dictInfoPost.objectForKey("iLikedIt") as! String == "0"){
                   isLiked = false
                }
                else{
                    isLiked = true
                }
                
                if(dictInfoPost.objectForKey("iBookark") as! String == "0"){
                    isfav = false
                }
                else{
                    isfav = true
                }
                
              //  self.title = String(format: "%@'s post", dictInfoPost.objectForKey("userName") as! String)
                let frame = CGRectMake(0, 0, 0, 44);
                let label = UILabel()
                label.frame = frame
                label.backgroundColor = UIColor.clearColor()
                label.textColor = UIColor.whiteColor()
              //  label.textAlignment = NSTextAlignment.Center
                label.font = UIFont(name: fontBold, size: 15)
                label.text = String(format: "%@'s post", dictInfoPost.objectForKey("userName") as! String)
                self.navigationItem.titleView = label;
                
                let item = self.navigationItem // (Current navigation item)
                item.titleView?.center = CGPointMake(160, 22)
                
                
                tableView?.reloadData()
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
                else if(dict.objectForKey("errorCode")!.isEqual(3)){
//                    let indexPath = NSIndexPath(forRow: 0, inSection: 0)
//                    let cell = tableView?.cellForRowAtIndexPath(indexPath) as! CardViewCell
                    let lblAlert = UILabel()
                    lblAlert.frame = CGRectMake(0, self.view.frame.size.height/2, self.view.frame.size.width, 30)
                    lblAlert.text = "This Post is not available."
                    lblAlert.textAlignment = NSTextAlignment.Center
                    lblAlert.font = UIFont(name: fontBold, size: 18)
                    self.view.addSubview(lblAlert)
                }
                
            }
        }
        else if(dict.objectForKey("api") as! String == "flag/add"){
            if(dict.objectForKey("status") as! String == "OK"){
                stopLoading(self.view)
                stopLoading(self.view)
                let refreshAlert = UIAlertController(title: "Report Successful", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                
                refreshAlert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction!) in
                    
                }))
                
                presentViewController(refreshAlert, animated: true, completion: nil)
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
                else if(dict.objectForKey("errorCode")!.isEqual(7)){
                    let alertView = UIAlertView(title: "Report Successful", message: nil, delegate: nil, cancelButtonTitle: "OK")
                    alertView.show()
                    stopLoading(self.view)
                }
            }
            
        }
        else if(dict.objectForKey("api") as! String == "post/delete"){
            if(dict.objectForKey("status") as! String == "OK"){
                stopLoading(self.view)
                self.navigationController?.popViewControllerAnimated(true)
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
        else if(dict.objectForKey("api") as! String == "like/add"){
            if(dict.objectForKey("status") as! String == "OK"){
                arrCommentsList = NSMutableArray()
                self.performSelector(#selector(OpenPostViewController.removeDubleTapImage), withObject: nil, afterDelay: 1)
            }
        }
        else if(dict.objectForKey("api") as! String == "like/delete"){
            
        }
        else if(dict.objectForKey("api") as! String == "bookmark/add"){
            
        }
        else if(dict.objectForKey("api") as! String == "bookmark/delete"){
            
        }
        else{
        if(dict.objectForKey("status") as! String == "OK"){
            if((dict.objectForKey("comments")) != nil){
            arrCommentsList.removeAllObjects()
            stopLoading1(self.view)
            arrCommentsList = dict.objectForKey("comments")?.mutableCopy() as! NSMutableArray
                
            if(action != "Delete"){
                
              
                    self.tableView?.reloadData()
                
            }
            else{
                let indexPath = NSIndexPath(forRow: deleteIndex.row, inSection: 0)
                self.tableView!.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            }
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
        }
        
        stopLoading(self.view)
        activityIndicater.removeFromSuperview()
        self.tabBarController?.tabBar.userInteractionEnabled = true
    }
    
    func serviceFailedWitherror(error : NSError){
        stopLoading(self.view)
    }
    
    func serviceUploadProgress(myprogress : float_t){
        
    }
    
    //MARK:- Reload
    
    func reloadData(){
        stopLoading(self.view)
        self.tableView?.reloadData()
    }
    
    //MARK:- TextView Delegate
    
    
    func textViewDidBeginEditing(textView: UITextView) {
        
    }
    
    func textViewDidChange(textView: UITextView) {
        
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return textView.text.characters.count + (text.characters.count - range.length) <= 140
    }
    
    func textViewDidChangeSelection(textView: UITextView) {
        textView.scrollRangeToVisible(textView.selectedRange)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        
    }
    
    func keyboardWillShow(sender: NSNotification) {
        var yOffset = CGFloat();
        yOffset = 260
         NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "keyString")
        if (self.tableView!.contentSize.height > self.tableView!.bounds.size.height) {
            yOffset = self.tableView!.contentSize.height - self.tableView!.bounds.size.height + 260;
        }
        tableView?.setContentOffset(CGPointMake(0, yOffset), animated: true)
    }
    
    func keyboardWillHide(sender: NSNotification) {
        if (self.tableView!.contentSize.height > self.tableView!.bounds.size.height) {
        tableView?.setContentOffset(CGPointMake(0, self.tableView!.contentSize.height - self.tableView!.bounds.size.height + 60), animated: true)
        }
        else{
          tableView?.setContentOffset(CGPointMake(0, 0), animated: true)
        }
        if ((NSUserDefaults.standardUserDefaults().objectForKey("keyString")) != nil) 
        {
        commentText = NSUserDefaults.standardUserDefaults().objectForKey("keyString") as! String
             NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "keyString")
        
        if(commentText.characters.count > 1){
            
             showColorLoader(self.view)
            
             self.webServiceAddComment()
            
            showColorLoader(self.view)
            
            }
        }
        
    }
    
    
    //MARK:- LikePressed
    func likeBtnPressed(sender : UIButton){
        //   showLoader(self.view)
    Flurry.logEvent("Like Button Tabbed")
        var methodName = String()
        if(isLiked == false){
            methodName = addlikeMethod
            sender.setImage(UIImage(named: "Heart Liked.png"), forState: UIControlState.Normal)
            numberLikes.text = String(format: "%d", Int((numberLikes.text!))! + 1)
            isLiked = true
        }
        else{
            methodName = deleteLikeMethod
            sender.setImage(UIImage(named: "Like Heart.png"), forState: UIControlState.Normal)
            numberLikes.text = String(format: "%d", Int((numberLikes.text!))! - 1)
            isLiked = false
        }
        let url = String(format: "%@%@%@", baseUrl, controllerLike, methodName)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let postId = dictInfoPost.objectForKey("id")
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(postId!, forKey: "postId")
        
        dispatch_async(dispatch_get_main_queue()) {
    //    webServiceCallingPost(url, parameters: params)
            webServiceCallingPost(url, parameters: params)
        }
        delegate = self
    }
    
    
    func favoriteBtnPressed(sender : UIButton){
        Flurry.logEvent("Bookmark Tabbed")
        var methodName = String()
        if(isfav == false){
            methodName = addlikeMethod
            numberFav.text = String(format: "%d", Int((numberFav.text!))! + 1)
            sender.setImage(UIImage(named: "bookmark_red.png"), forState: UIControlState.Normal)
            isfav = true
        }
        else{
            methodName = deleteLikeMethod
            numberFav.text = String(format: "%d", Int((numberFav.text!))! - 1)
            sender.setImage(UIImage(named: "bookmark (1).png"), forState: UIControlState.Normal)
            isfav = false
        }
        let url = String(format: "%@%@%@", baseUrl, controllerBookmark, methodName)
        let sessionId = NSUserDefaults.standardUserDefaults().objectForKey("sessionId")
        let postId = dictInfoPost.objectForKey("id")
        let params = NSMutableDictionary()
        
        params.setObject(sessionId!, forKey: "sessionId")
        params.setObject(postId!, forKey: "postId")
        
        dispatch_async(dispatch_get_main_queue()) {
    //    webServiceCallingPost(url, parameters: params)
            
            webServiceCallingPost(url, parameters: params)
        }
        delegate = self
    }
    
    //MARK:- TTTAttributedLabelDelegates
    
    func attributedLabel(label: TTTAttributedLabel!, didSelectLinkWithURL url: NSURL!) {
        if(url == NSURL(string: "action://users/\("userName")")){
            isUserInfo = false
            postDictHome = self.dictInfoPost
            openProfileId = (postDictHome.objectForKey("userId") as? String)!
            postImageOrgnol = (postDictHome.objectForKey("userImage") as? String)!
            postImagethumb = (postDictHome.objectForKey("userThumb") as? String)!
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfile") as! UserProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
           
        }
            
        else if(url == NSURL(string: "action://users/\("commentUserName")")){
            var indexPath: NSIndexPath!
            
            
            if let superview = label.superview {
                if let cell = superview.superview as? UITableViewCell {
                    indexPath = tableView!.indexPathForCell(cell)
                }
            }

            if(arrCommentsList.objectAtIndex(indexPath.row - 2).objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String){
                isUserInfo = false
            }
            else{
                isUserInfo = true
            }
            postDictHome = arrCommentsList.objectAtIndex(indexPath.row - 2) as! NSDictionary
            
            openProfileId = (postDictHome.objectForKey("userId") as? String)!
            postImageOrgnol = (postDictHome.objectForKey("userImage") as? String)!
            postImagethumb = (postDictHome.objectForKey("userThumb") as? String)!
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfile") as! UserProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
            
        else if(url == NSURL(string: "action://users/\("mentionUserName0")")){
            
            var indexPath: NSIndexPath!
            
            
                if let superview = label.superview {
                    if let cell = superview.superview as? UITableViewCell {
                        indexPath = tableView!.indexPathForCell(cell)
                    }
                }
           
            
                isUserInfo = false
            var arr = NSArray()
            if((dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
               arr = arrCommentsList.objectAtIndex(indexPath.row-2).objectForKey("userMentioned") as! NSArray
            }
            else{
               arr = arrCommentsList.objectAtIndex(indexPath.row-1).objectForKey("userMentioned") as! NSArray
            }
                postDictHome = arr.objectAtIndex(0) as! NSDictionary
                openProfileId = arr.objectAtIndex(0).objectForKey("userId") as! String
                let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfile") as! UserProfileViewController;
                self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            
        }
            
        else if(url == NSURL(string: "action://users/\("mentionUserName1")")){
            
            var indexPath: NSIndexPath!
            
            
            if let superview = label.superview {
                if let cell = superview.superview as? UITableViewCell {
                    indexPath = tableView!.indexPathForCell(cell)
                }
            }
           
            
            isUserInfo = false
            var arr = NSArray()
            if((dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
                arr = arrCommentsList.objectAtIndex(indexPath.row-2).objectForKey("userMentioned") as! NSArray
            }
            else{
                arr = arrCommentsList.objectAtIndex(indexPath.row-1).objectForKey("userMentioned") as! NSArray
            }
            postDictHome = arr.objectAtIndex(1) as! NSDictionary
            openProfileId = arr.objectAtIndex(1).objectForKey("userId") as! String
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfile") as! UserProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            
        }
            
        else if(url == NSURL(string: "action://users/\("mentionUserName2")")){
            
            var indexPath: NSIndexPath!
            
            
            if let superview = label.superview {
                if let cell = superview.superview as? UITableViewCell {
                    indexPath = tableView!.indexPathForCell(cell)
                }
            }
           
            isUserInfo = false
            var arr = NSArray()
            if((dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
                arr = arrCommentsList.objectAtIndex(indexPath.row-2).objectForKey("userMentioned") as! NSArray
            }
            else{
                arr = arrCommentsList.objectAtIndex(indexPath.row-1).objectForKey("userMentioned") as! NSArray
            }
            postDictHome = arr.objectAtIndex(2) as! NSDictionary
            openProfileId = arr.objectAtIndex(2).objectForKey("userId") as! String
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfile") as! UserProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            
        }
            
        else if(url == NSURL(string: "action://users/\("mentionUserName3")")){
            
            var indexPath: NSIndexPath!
            
            
            if let superview = label.superview {
                if let cell = superview.superview as? UITableViewCell {
                    indexPath = tableView!.indexPathForCell(cell)
                }
            }
           
            isUserInfo = false
            var arr = NSArray()
            if((dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
                arr = arrCommentsList.objectAtIndex(indexPath.row-2).objectForKey("userMentioned") as! NSArray
            }
            else{
                arr = arrCommentsList.objectAtIndex(indexPath.row-1).objectForKey("userMentioned") as! NSArray
            }
            postDictHome = arr.objectAtIndex(3) as! NSDictionary
            openProfileId = arr.objectAtIndex(3).objectForKey("userId") as! String
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfile") as! UserProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            
        }
            
        else if(url == NSURL(string: "action://users/\("mentionUserName4")")){
            
            var indexPath: NSIndexPath!
            
            
            if let superview = label.superview {
                if let cell = superview.superview as? UITableViewCell {
                    indexPath = tableView!.indexPathForCell(cell)
                }
            }
           
            isUserInfo = false
            var arr = NSArray()
            if((dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
                arr = arrCommentsList.objectAtIndex(indexPath.row-2).objectForKey("userMentioned") as! NSArray
            }
            else{
                arr = arrCommentsList.objectAtIndex(indexPath.row-1).objectForKey("userMentioned") as! NSArray
            }
            postDictHome = arr.objectAtIndex(4) as! NSDictionary
            openProfileId = arr.objectAtIndex(4).objectForKey("userId") as! String
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfile") as! UserProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            
        }
            
        else if(url == NSURL(string: "action://users/\("mentionUserName5")")){
            
            var indexPath: NSIndexPath!
            
            
            if let superview = label.superview {
                if let cell = superview.superview as? UITableViewCell {
                    indexPath = tableView!.indexPathForCell(cell)
                }
            }
            
            isUserInfo = false
            var arr = NSArray()
            if((dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
                arr = arrCommentsList.objectAtIndex(indexPath.row-2).objectForKey("userMentioned") as! NSArray
            }
            else{
                arr = arrCommentsList.objectAtIndex(indexPath.row-1).objectForKey("userMentioned") as! NSArray
            }
            postDictHome = arr.objectAtIndex(5) as! NSDictionary
            openProfileId = arr.objectAtIndex(5).objectForKey("userId") as! String
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfile") as! UserProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
            
        }
            
        else if(url == NSURL(string: "action://dish/\("dishName")")){
            arrDishList.removeAllObjects()
            selectedDishHome = self.dictInfoPost.objectForKey("dishName") as! String
            comingFrom = "HomeDish"
            comingToDish = selectedDishHome
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("DishProfile") as! DishProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
            
        else if(url == NSURL(string: "action://restaurant/\("restaurantName")")){
            restaurantProfileId = (self.dictInfoPost.objectForKey("checkedInRestaurantId") as? String)!
            
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("RestaurantProfile") as! RestaurantProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
        else if(url == NSURL(string: "action://users/\("userTap")")){
            var indexPath: NSIndexPath!
            
            
            if let superview = label.superview {
                if let cell = superview.superview as? UITableViewCell {
                    indexPath = tableView!.indexPathForCell(cell)
                }
            }
            
            if((dictInfoPost.objectForKey("tip") as? String)?.characters.count > 0){
            if(arrCommentsList.objectAtIndex(indexPath.row - 2).objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String){
                isUserInfo = false
            }
            else{
                isUserInfo = true
            }
            postDictHome = arrCommentsList.objectAtIndex(indexPath.row - 2) as! NSDictionary
            }
            else{
                if(arrCommentsList.objectAtIndex(indexPath.row - 1).objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String){
                    isUserInfo = false
                }
                else{
                    isUserInfo = true
                }
                postDictHome = arrCommentsList.objectAtIndex(indexPath.row - 1) as! NSDictionary
            }
            
            openProfileId = (postDictHome.objectForKey("userId") as? String)!
            postImageOrgnol = (postDictHome.objectForKey("userImage") as? String)!
            postImagethumb = (postDictHome.objectForKey("userThumb") as? String)!
            let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfile") as! UserProfileViewController;
            self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
        }
    }
    
    func userBtnTap(sender : UIButton){
        if(arrCommentsList.objectAtIndex(sender.tag).objectForKey("userName") as? String != userLoginAllInfo.objectForKey("profile")?.objectForKey("userName") as? String){
            isUserInfo = false
        }
        else{
        isUserInfo = true
        }
        postDictHome = arrCommentsList.objectAtIndex(sender.tag) as! NSDictionary
       
        openProfileId = (postDictHome.objectForKey("userId") as? String)!
        postImageOrgnol = (postDictHome.objectForKey("userImage") as? String)!
        postImagethumb = (postDictHome.objectForKey("userThumb") as? String)!
        let openPost = self.storyboard!.instantiateViewControllerWithIdentifier("UserProfile") as! UserProfileViewController;
        self.navigationController!.visibleViewController!.navigationController!.pushViewController(openPost, animated:true);
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let currentPoint = touch.locationInView(conectivityMsg)
            // do something with your currentPoint
            if(isConnectedToNetwork()){
                conectivityMsg.removeFromSuperview()
                dispatch_async(dispatch_get_main_queue()) {
                    self.webserviceData()
                }
                
                self.performSelector(#selector(OpenPostViewController.webServiceCallComments), withObject: nil, afterDelay: 0.0)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.webServiceForFriendList()
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
