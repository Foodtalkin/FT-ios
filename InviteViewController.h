//
//  InviteViewController.h
//  FoodTalk
//
//  Created by Ashish on 21/01/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface InviteViewController : UIViewController{
    
}

@property (nonatomic, copy) FBSDKAppInviteContent *content;
@property (nonatomic, weak) id<FBSDKAppInviteDialogDelegate> delegate;
//@property (nonatomic, retain) FBFriendPickerViewController *friendPickerController;

-(IBAction)skipMethod:(id)sender;
-(IBAction)inviteFriends:(id)sender;

@end
