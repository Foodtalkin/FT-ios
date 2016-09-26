//
//  IAAPushNoteView.h
//  TLV Airport
//
//  Created by Aviel Gross on 1/29/14.
//  Copyright (c) 2014 NGSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AGPushNoteViewDelegate <NSObject>
@optional
- (void)pushNoteDidAppear; // Called after the view has been fully transitioned onto the screen. (equel to completion block).
- (void)pushNoteWillDisappear; // Called before the view is hidden, after the message action block.
- (void)reloadMethodWithName:(NSString *)strName;
@end

@interface AGPushNoteView : UIToolbar
+ (void)showWithNotificationMessage:(NSString *)message;
+ (void)showWithNotificationMessage:(NSString *)message methodName:(NSString *)strMethodName;
+ (void)showWithNotificationMessage:(NSString *)message completion:(void (^)(void))completion;
+ (void)close;
+ (void)closeWitCompletion:(void (^)(void))completion;
+ (void)awake;

+ (void)setMessageAction:(void (^)(NSString *message))action;
+ (void)setDelegateForPushNote:(id<AGPushNoteViewDelegate>)delegate;
@property (strong, nonatomic) IBOutlet UIButton *btnReload;
@property (strong, nonatomic) IBOutlet UIButton *btnStop;
@property (strong, nonatomic) IBOutlet UIButton *btnStopit;

@property (nonatomic, weak) id<AGPushNoteViewDelegate> pushNoteDelegate;

@end
