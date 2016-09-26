//
//  InviteViewController.m
//  FoodTalk
//
//  Created by Ashish on 21/01/16.
//  Copyright © 2016 FoodTalkIndia. All rights reserved.
//

#import "InviteViewController.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "Flurry/Flurry.h"
#import "FlurryWatch.h"

@interface InviteViewController ()<FBSDKAppInviteDialogDelegate>

@end

NSMutableArray *facebookFriendsArray;


@implementation InviteViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Facebook Invites";
}


-(IBAction)skipMethod:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)inviteFriends:(id)sender{
    
    FBSDKAppInviteContent *content =[[FBSDKAppInviteContent alloc] init];
    content.appLinkURL = [NSURL URLWithString:@"https://fb.me/1698490917038374"];
    content.appInvitePreviewImageURL = [NSURL URLWithString:@"http://res.cloudinary.com/digital-food-talk-pvt-ltd/image/upload/q_60,f_jpg/v1455196794/12722101_10206664827312884_2103895114_n_ag6m3g.jpg"];
    
    [FBSDKAppInviteDialog showFromViewController:self withContent:content delegate:self];
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didCompleteWithResults:(NSDictionary *)results{
//    UITabBarController *tbc = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBarVC"];
//    tbc.selectedIndex=0;
//    [self.navigationController pushViewController:tbc animated:YES];
    [self.tabBarController setSelectedIndex:0];
}

- (void)appInviteDialog:(FBSDKAppInviteDialog *)appInviteDialog didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
