//
//  DemoCallManager.h
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 22/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Hyphenate/Hyphenate.h>
#import "EMCallOptions+NSCoding.h"

@protocol DemoCallManagerDelegate <NSObject>

- (void)getUserInfo:(NSString *)userId session:(EMCallSession *)currentSession;
- (void)getUserInfo:(NSString *)userId username:(NSString *)aUsername type:(EMCallType)aType;

@end

@interface DemoCallManager : NSObject

//#if DEMO_CALL == 1

@property (nonatomic) BOOL isCalling;

@property (strong, nonatomic) UIViewController *mainController;
@property (assign, nonatomic) BOOL isTouchRejectButton;//是不是自己拒绝了通话
@property (strong, nonatomic) NSDictionary *currentUserInfo;//当前通话的对方的用户信息
@property (assign, nonatomic) id<DemoCallManagerDelegate> delegate;

+ (instancetype)sharedManager;

- (void)saveCallOptions;

- (void)makeCallWithUsername:(NSString *)aUsername
                        type:(EMCallType)aType;

- (void)answerCall:(NSString *)aCallId;

- (void)hangupCallWithReason:(EMCallEndReason)aReason;

// 收到通话
- (void)makeCall:(NSDictionary *)userInfo session:(EMCallSession *)originSession;
// 主动拨打
- (void)makeSendCall:(NSDictionary *)userInfo username:(NSString *)aUsername type:(EMCallType)aType;

//#endif

@end
