//
//  IAAPushNoteView.m
//  TLV Airport
//
//  Created by Aviel Gross on 1/29/14.
//  Copyright (c) 2014 NGSoft. All rights reserved.
//

#import "AGPushNoteView.h"

#define APP [UIApplication sharedApplication].delegate
#define isIOS7 (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
#define PUSH_VIEW [AGPushNoteView sharedPushView]

#define CLOSE_PUSH_SEC 5
#define SHOW_ANIM_DUR 0.5
#define HIDE_ANIM_DUR 0.35

@interface AGPushNoteView()
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) NSTimer *closeTimer;
@property (strong, nonatomic) NSString *currentMessage;
@property (strong, nonatomic) NSMutableArray *pendingPushArr;

@property (strong, nonatomic) void (^messageTapActionBlock)(NSString *message);
@end


@implementation AGPushNoteView

//Singleton instance
static AGPushNoteView *_sharedPushView;

+ (instancetype)sharedPushView
{
	@synchronized([self class])
	{
		if (!_sharedPushView){
            NSArray *nibArr = [[NSBundle mainBundle] loadNibNamed: @"AGPushNoteView" owner:self options:nil];
            for (id currentObject in nibArr)
            {
                if ([currentObject isKindOfClass:[AGPushNoteView class]])
                {
                    _sharedPushView = (AGPushNoteView *)currentObject;
                    break;
                }
            }
            [_sharedPushView setUpUI];
		}
		return _sharedPushView;
	}
	// to avoid compiler warning
	return nil;
}

+ (void)setDelegateForPushNote:(id<AGPushNoteViewDelegate>)delegate {
    [PUSH_VIEW setPushNoteDelegate:delegate];
}

#pragma mark - Lifecycle (of sort)
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CGRect f = self.frame;
        CGFloat width = [UIApplication sharedApplication].keyWindow.bounds.size.width;
        self.frame = CGRectMake(f.origin.x, f.origin.y, width, f.size.height + 20);
    }
    return self;
}

- (void)setUpUI {
    CGRect f = self.frame;
    CGFloat width = [UIApplication sharedApplication].keyWindow.bounds.size.width;
    CGFloat height = isIOS7? 54: f.size.height;
    height = height + 15;
    self.frame = CGRectMake(f.origin.x, -height, width, height);
    
    CGRect cvF = self.containerView.frame;
    self.containerView.frame = CGRectMake(cvF.origin.x, cvF.origin.y, self.frame.size.width, cvF.size.height);
    
    //OS Specific:
    if (isIOS7) {
        self.barTintColor = nil;
        self.translucent = YES;
        self.barStyle = UIBarStyleBlack;
    } else {
        [self setTintColor:[UIColor colorWithRed:5 green:31 blue:75 alpha:1]];
        [self.messageLabel setTextAlignment:NSTextAlignmentCenter];
        self.messageLabel.shadowColor = [UIColor blackColor];
    }
    
    self.layer.zPosition = MAXFLOAT;
    self.backgroundColor = [UIColor clearColor];
    self.multipleTouchEnabled = NO;
    self.exclusiveTouch = YES;
    
    UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeGesture:)];
    [gesture setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.messageLabel addGestureRecognizer:gesture];
    
    UITapGestureRecognizer *msgTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(messageTapAction)];
    self.messageLabel.userInteractionEnabled = YES;
    [self.messageLabel addGestureRecognizer:msgTap];
    
    //:::[For debugging]:::
//                self.containerView.backgroundColor = [UIColor yellowColor];
//                self.closeButton.backgroundColor = [UIColor redColor];
//                self.messageLabel.backgroundColor = [UIColor greenColor];
    
    [APP.window addSubview:PUSH_VIEW];
    [APP.window bringSubviewToFront:PUSH_VIEW];
}

- (void)handleSwipeGesture:(UISwipeGestureRecognizer *) sender
{
    [AGPushNoteView close];
}

+ (void)awake {
    if (PUSH_VIEW.frame.origin.y == 0) {
        [APP.window addSubview:PUSH_VIEW];
        [APP.window bringSubviewToFront:PUSH_VIEW];
    }
}

+ (void)showWithNotificationMessage:(NSString *)message {
    [AGPushNoteView showWithNotificationMessage:message completion:^{
        //Nothing.
        [PUSH_VIEW.btnReload setHidden:YES];
        [PUSH_VIEW.btnStop setHidden:NO];
        
//        [PUSH_VIEW bringSubviewToFront:PUSH_VIEW.btnStop];
        
//        [PUSH_VIEW.messageLabel setFrame:CGRectMake(PUSH_VIEW.messageLabel.frame.origin.x-20, PUSH_VIEW.messageLabel.frame.origin.y, PUSH_VIEW.messageLabel.frame.size.width, PUSH_VIEW.messageLabel.frame.size.height)];
        
//        [PUSH_VIEW.messageLabel setTextAlignment:NSTextAlignmentLeft];
    }];
}


+ (void)showWithNotificationMessage:(NSString *)message methodName:(NSString *)strMethodName {
    [AGPushNoteView showWithNotificationMessage:message completion:^{
        //Nothing.
        [PUSH_VIEW.btnReload setHidden:NO];
        [PUSH_VIEW.btnStop setHidden:YES];
        
//        [PUSH_VIEW bringSubviewToFront:PUSH_VIEW.btnReload];
        
//        APP.window.windowLevel = UIWindowLevelStatusBar;
        
//        [PUSH_VIEW.messageLabel setFrame:CGRectMake(PUSH_VIEW.messageLabel.frame.origin.x-20, PUSH_VIEW.messageLabel.frame.origin.y, PUSH_VIEW.messageLabel.frame.size.width, PUSH_VIEW.messageLabel.frame.size.height)];
        
        [PUSH_VIEW.btnReload setAccessibilityHint:strMethodName];
    }];
}

+ (void)showWithNotificationMessage:(NSString *)message completion:(void (^)(void))completion {
    
    PUSH_VIEW.currentMessage = message;

    if (message) {
        [PUSH_VIEW.pendingPushArr addObject:message];
        
        PUSH_VIEW.messageLabel.text = message;
        APP.window.windowLevel = UIWindowLevelStatusBar;
        
        CGRect f = PUSH_VIEW.frame;
        PUSH_VIEW.frame = CGRectMake(f.origin.x, -f.size.height, f.size.width, f.size.height);
        [APP.window addSubview:PUSH_VIEW];
        [APP.window bringSubviewToFront:PUSH_VIEW];
        
        //Show
        [UIView animateWithDuration:SHOW_ANIM_DUR delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            CGRect f = PUSH_VIEW.frame;
            PUSH_VIEW.frame = CGRectMake(f.origin.x, 0, f.size.width, f.size.height);
        } completion:^(BOOL finished) {
            completion();
            if ([PUSH_VIEW.pushNoteDelegate respondsToSelector:@selector(pushNoteDidAppear)]) {
                [PUSH_VIEW.pushNoteDelegate pushNoteDidAppear];
            }
        }];
        
        //Start timer (Currently not used to make sure user see & read the push...)
//        PUSH_VIEW.closeTimer = [NSTimer scheduledTimerWithTimeInterval:CLOSE_PUSH_SEC target:[IAAPushNoteView class] selector:@selector(close) userInfo:nil repeats:NO];
    }
}


+ (void)closeWitCompletion:(void (^)(void))completion {
    if ([PUSH_VIEW.pushNoteDelegate respondsToSelector:@selector(pushNoteWillDisappear)]) {
        [PUSH_VIEW.pushNoteDelegate pushNoteWillDisappear];
    }
    
    [PUSH_VIEW.closeTimer invalidate];
    
    [UIView animateWithDuration:HIDE_ANIM_DUR delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect f = PUSH_VIEW.frame;
        PUSH_VIEW.frame = CGRectMake(f.origin.x, -f.size.height, f.size.width, f.size.height);
    } completion:^(BOOL finished) {
        [PUSH_VIEW handlePendingPushJumpWitCompletion:completion];
    }];
}

+ (void)close {
    [AGPushNoteView closeWitCompletion:^{
        //Nothing.
    }];
}

#pragma mark - Pending push managment
- (void)handlePendingPushJumpWitCompletion:(void (^)(void))completion {
    id lastObj = [self.pendingPushArr lastObject]; //Get myself
    if (lastObj) {
        [self.pendingPushArr removeObject:lastObj]; //Remove me from arr
        NSString *messagePendingPush = [self.pendingPushArr lastObject]; //Maybe get pending push
        if (messagePendingPush) { //If got something - remove from arr, - than show it.
            [self.pendingPushArr removeObject:messagePendingPush];
            [AGPushNoteView showWithNotificationMessage:messagePendingPush completion:completion];
        } else {
            APP.window.windowLevel = UIWindowLevelNormal;
        }
    }
}

- (NSMutableArray *)pendingPushArr {
    if (!_pendingPushArr) {
        _pendingPushArr = [[NSMutableArray alloc] init];
    }
    return _pendingPushArr;
}

#pragma mark - Actions
+ (void)setMessageAction:(void (^)(NSString *message))action {
    PUSH_VIEW.messageTapActionBlock = action;
}

- (void)messageTapAction {
    if (self.messageTapActionBlock) {
        self.messageTapActionBlock(self.currentMessage);
        [AGPushNoteView close];
    }
}

- (IBAction)closeActionItem:(id)sender {
    //    [AGPushNoteView close];
    [AGPushNoteView close];
}

- (IBAction)stopActionItem:(id)sender {
    
    [AGPushNoteView close];
}

- (IBAction)btnReloadTapped:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    [PUSH_VIEW.pushNoteDelegate reloadMethodWithName:btn.accessibilityHint];
}

@end
