//
//  EMCallViewController.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 22/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DemoCallManager.h"
#import <Hyphenate/EMCallSession.h>
#import "UIImageView+EMWebCache.h"

@interface EMCallViewController : UIViewController

@property (nonatomic) BOOL isDismissing;
//#if DEMO_CALL == 1

@property (strong, nonatomic, readonly) EMCallSession *callSession;
@property (strong, nonatomic) NSDictionary *userInfo;



- (instancetype)initWithCallSession:(EMCallSession *)aCallSession;

- (void)stateToConnecting;

- (void)stateToConnected;

- (void)stateToAnswered;

- (void)setNetwork:(EMCallNetworkStatus)aStatus;

- (void)setStreamType:(EMCallStreamingStatus)aType;

- (void)clearData;

/**
 获取通话时长
 
 @return 格式化后的时间
 */
- (NSString *)getCurrentTime;

//#endif

@end
