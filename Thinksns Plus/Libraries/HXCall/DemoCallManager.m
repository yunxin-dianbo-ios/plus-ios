//
//  DemoCallManager.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 22/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import "DemoCallManager.h"

//#if DEMO_CALL == 1

//#import "EMVideoRecorderPlugin.h"
#import "EaseSDKHelper.h"
#import "EMCallViewController.h"

static DemoCallManager *callManager = nil;

@interface DemoCallManager()<EMChatManagerDelegate, EMCallManagerDelegate, EMCallBuilderDelegate>

@property (strong, nonatomic) NSObject *callLock;

@property (strong, nonatomic) NSTimer *timer;
/// 是否接通
@property (assign, nonatomic) BOOL isAccepted;

@property (strong, nonatomic) EMCallSession *currentSession;

@property (strong, nonatomic) EMCallViewController *currentController;

@end

//#endif

@implementation DemoCallManager

//#if DEMO_CALL == 1

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _initManager];
    }
    
    return self;
}

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        callManager = [[DemoCallManager alloc] init];
    });
    
    return callManager;
}

- (void)dealloc
{
    [[EMClient sharedClient].chatManager removeDelegate:self];
    [[EMClient sharedClient].callManager removeDelegate:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:KNOTIFICATION_CALL object:nil];
}

#pragma mark - private

- (void)_initManager
{
    _callLock = [[NSObject alloc] init];
    _currentSession = nil;
    _currentController = nil;
    
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].callManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].callManager setBuilderDelegate:self];
    
//    [EMVideoRecorderPlugin initGlobalConfig];
    
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"calloptions.data"];
    EMCallOptions *options = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:file]) {
        options = [NSKeyedUnarchiver unarchiveObjectWithFile:file];
    } else {
        options = [[EMClient sharedClient].callManager getCallOptions];
        options.isSendPushIfOffline = NO;
        options.videoResolution = EMCallVideoResolution640_480;
        options.isFixedVideoResolution = YES;
    }
    [[EMClient sharedClient].callManager setCallOptions:options];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(makeCall:) name:KNOTIFICATION_CALL object:nil];
}

- (void)_clearCurrentCallViewAndData
{
    @synchronized (_callLock) {
        self.currentSession = nil;
        
        self.currentController.isDismissing = YES;
        [self.currentController clearData];
        [self.currentController dismissViewControllerAnimated:NO completion:nil];
        self.currentController = nil;
    }
}

#pragma mark - private timer

- (void)_timeoutBeforeCallAnswered
{
    [self hangupCallWithReason:EMCallEndReasonNoResponse];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"call.autoHangup", @"No response and Hang up") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alertView show];
}

- (void)_startCallTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:50 target:self selector:@selector(_timeoutBeforeCallAnswered) userInfo:nil repeats:NO];
    self.isAccepted = NO;
}

- (void)_stopCallTimer
{
    if (self.timer == nil) {
        return;
    }
    
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - EMCallManagerDelegate

- (void)callDidReceive:(EMCallSession *)aSession
{
    if (!aSession || [aSession.callId length] == 0) {
        return ;
    }
    self.isAccepted = NO;
    NSString *callId = aSession.remoteName;
    if ([aSession.remoteName rangeOfString:@"/"].location != NSNotFound) {
        NSRange range = [aSession.remoteName rangeOfString:@"/"];
        NSLog(@"%lu",(unsigned long)range.location);
        callId = [aSession.remoteName substringToIndex:range.location];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(getUserInfo:session:)]) {
        [_delegate getUserInfo:callId session:aSession];
    }
//    if ([EaseSDKHelper shareHelper].isShowingimagePicker) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideImagePicker" object:nil];
//    }
//
//    if(self.isCalling || (self.currentSession && self.currentSession.status != EMCallSessionStatusDisconnected)){
//        [[EMClient sharedClient].callManager endCall:aSession.callId reason:EMCallEndReasonBusy];
//        return;
//    }
//
//    [[DemoCallManager sharedManager] setIsCalling:YES];
//    @synchronized (_callLock) {
//        [self _startCallTimer];
//
//        self.currentSession = aSession;
//        self.currentController = [[EMCallViewController alloc] initWithCallSession:self.currentSession];
//        self.currentController.modalPresentationStyle = UIModalPresentationOverFullScreen;
//
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (self.currentController) {
//                [self.mainController presentViewController:self.currentController animated:NO completion:nil];
//            }
//        });
//    }
}

- (void)callDidConnect:(EMCallSession *)aSession
{
    if ([aSession.callId isEqualToString:self.currentSession.callId]) {
        self.isAccepted = NO;
        [self.currentController stateToConnected];
    }
}

- (void)callDidAccept:(EMCallSession *)aSession
{
    if ([aSession.callId isEqualToString:self.currentSession.callId]) {
        [self _stopCallTimer];
        self.isAccepted = YES;
        [self.currentController stateToAnswered];
    }
}

- (void)callDidEnd:(EMCallSession *)aSession
            reason:(EMCallEndReason)aReason
             error:(EMError *)aError
{
    if ([aSession.callId isEqualToString:self.currentSession.callId]) {
        self.isCalling = NO;
        
        [self _stopCallTimer];
        
//        @synchronized (_callLock) {
//            self.currentSession = nil;
//            [self _clearCurrentCallViewAndData];
//        }
        NSString *resultTitle = @"通话结束";
        switch (aReason) {
            case EMCallEndReasonHangup:
            {
                if (self.isAccepted) {
                    resultTitle = [NSString stringWithFormat:@"通话时长 %@",[self.currentController getCurrentTime]];
                } else {
                    resultTitle = @"通话已挂断";
                    if (aSession.isCaller) {
                        resultTitle = @"通话已挂断";
                        if (!self.isTouchRejectButton) {
                            resultTitle = @"已挂断";
                        }
                    } else {
                        if (!self.isTouchRejectButton) {
                            resultTitle = @"已挂断";
                        }
                    }
                }
            }
                break;
            case EMCallEndReasonNoResponse:
            {
                resultTitle = @"未接听";//NSLocalizedString(@"call.noResponse", @"NO response");
            }
                break;
            case EMCallEndReasonDecline:
            {
                resultTitle = @"已拒绝";//NSLocalizedString(@"call.rejected", @"Reject the call");
            }
                break;
            case EMCallEndReasonBusy:
            {
                resultTitle = @"正在通话中";//NSLocalizedString(@"call.in", @"In the call...");
            }
                break;
            case EMCallEndReasonFailed:
            {
                resultTitle = @"连接失败";//NSLocalizedString(@"call.connectFailed", @"Connect failed");
            }
                break;
            case EMCallEndReasonUnsupported:
            {
                resultTitle = @"不支持";//NSLocalizedString(@"call.connectUnsupported", @"Unsupported");
            }
                break;
            case EMCallEndReasonRemoteOffline:
            {
                resultTitle = @"不在线";//NSLocalizedString(@"call.offline", @"Remote offline");
            }
                break;
            default:
                break;
        }
        
        NSString *callId = aSession.remoteName;
        if ([callId rangeOfString:@"/"].location != NSNotFound) {
            NSRange range = [callId rangeOfString:@"/"];
            NSLog(@"%lu",(unsigned long)range.location);
            callId = [callId substringToIndex:range.location];
        }
        /// 构造通知传递的数据
        NSString *isreadstring;//判断是否已读
        if (aSession.isCaller) {
            isreadstring = @"1";
        } else {
            //判断是不是在后台，在后台：判断是不是无反应或者呼叫方主挂断（未读）
            //不在后台：判断是不是在聊天室，在聊天室全部设置为已读；不在聊天室：接通了就已读，没接听或者无操作超时挂断或者对方挂断，未读
            /// 后继者再根据具体需求判断优化
            isreadstring = @"1";
        }
        NSDictionary *notiDic = @{@"type": @(aSession.type),
                                  @"callID": callId,
                                  @"isCaller": @(aSession.isCaller),
                                  @"reasonStr": resultTitle,
                                  @"isread":isreadstring};
        [self addLocalDataToDB:notiDic];
        
        if (aError) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:aError.errorDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
        }
        else{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:resultTitle delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alertView show];
        }
        
        /// 取消通话界面的点击反馈
        self.currentController.view.userInteractionEnabled = NO;
        
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC));
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            @synchronized (_callLock) {
                self.currentSession = nil;
                [self _clearCurrentCallViewAndData];
            }
        });
    }
}

- (void)callStateDidChange:(EMCallSession *)aSession
                      type:(EMCallStreamingStatus)aType
{
    if ([aSession.callId isEqualToString:self.currentSession.callId]) {
        [self.currentController setStreamType:aType];
    }
}

- (void)callNetworkDidChange:(EMCallSession *)aSession
                      status:(EMCallNetworkStatus)aStatus
{
    if ([aSession.callId isEqualToString:self.currentSession.callId]) {
        [self.currentController setNetwork:aStatus];
    }
}

#pragma mark - EMCallBuilderDelegate

- (void)callRemoteOffline:(NSString *)aRemoteName
{
    NSString *text = [[EMClient sharedClient].callManager getCallOptions].offlineMessageText;
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:text];
    NSString *fromStr = [EMClient sharedClient].currentUsername;
    EMMessage *message = [[EMMessage alloc] initWithConversationID:aRemoteName from:fromStr to:aRemoteName body:body ext:@{@"em_apns_ext":@{@"em_push_title":text}}];
    message.chatType = EMChatTypeChat;
    
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:nil];
}

#pragma mark - NSNotification

- (void)makeCall:(NSNotification*)notify
{
    if (notify.object) {
        EMCallType type = (EMCallType)[[notify.object objectForKey:@"type"] integerValue];
        [self makeCallWithUsername:[notify.object valueForKey:@"chatter"] type:type];
    }
}

#pragma mark - public

- (void)saveCallOptions
{
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"calloptions.data"];
    EMCallOptions *options = [[EMClient sharedClient].callManager getCallOptions];
    [NSKeyedArchiver archiveRootObject:options toFile:file];
}

- (void)makeCallWithUsername:(NSString *)aUsername
                        type:(EMCallType)aType
{
    
    if ([aUsername length] == 0) {
        return;
    }
    
    NSString *callId = aUsername;
    if ([aUsername rangeOfString:@"/"].location != NSNotFound) {
        NSRange range = [aUsername rangeOfString:@"/"];
        NSLog(@"%lu",(unsigned long)range.location);
        callId = [aUsername substringToIndex:range.location];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(getUserInfo:username:type:)]) {
        [_delegate getUserInfo:callId username:aUsername type:aType];
    }
    
//    __weak typeof(self) weakSelf = self;
//    void (^completionBlock)(EMCallSession *, EMError *) = ^(EMCallSession *aCallSession, EMError *aError){
//        DemoCallManager *strongSelf = weakSelf;
//        if (strongSelf) {
//            if (aError || aCallSession == nil) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"call.initFailed", @"Establish call failure") message:aError.errorDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
//                [alertView show];
//                return;
//            }
//
//            @synchronized (self.callLock) {
//                strongSelf.currentSession = aCallSession;
//                strongSelf.currentController = [[EMCallViewController alloc] initWithCallSession:strongSelf.currentSession];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    if (strongSelf.currentController) {
//                        [strongSelf.mainController presentViewController:self.currentController animated:NO completion:nil];
//                    }
//                });
//            }
//
//            [self _startCallTimer];
//        }
//        else {
//            [[EMClient sharedClient].callManager endCall:aCallSession.callId reason:EMCallEndReasonNoResponse];
//        }
//    };
//
//    [[EMClient sharedClient].callManager startCall:aType remoteName:aUsername ext:@"123" completion:^(EMCallSession *aCallSession, EMError *aError) {
//        completionBlock(aCallSession, aError);
//    }];
}

- (void)answerCall:(NSString *)aCallId
{
    if (!self.currentSession || ![self.currentSession.callId isEqualToString:aCallId]) {
        return ;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = [[EMClient sharedClient].callManager answerIncomingCall:weakSelf.currentSession.callId];
        if (error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error.code == EMErrorNetworkUnavailable) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"network.disconnection", @"Network disconnection") delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                    [alertView show];
                }
                else{
                    [weakSelf hangupCallWithReason:EMCallEndReasonFailed];
                }
            });
        }
    });
}

- (void)hangupCallWithReason:(EMCallEndReason)aReason
{
    self.isCalling = NO;
    [self _stopCallTimer];
    
    if (self.currentSession) {
        [[EMClient sharedClient].callManager endCall:self.currentSession.callId reason:aReason];
    }
//    [self _clearCurrentCallViewAndData];
}

- (void)setCurrentUserInfo:(NSDictionary *)currentUserInfo {
    _currentUserInfo = currentUserInfo;
}

- (void)makeCall:(NSDictionary *)userInfo session:(EMCallSession *)originSession {
    
    if ([EaseSDKHelper shareHelper].isShowingimagePicker) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"hideImagePicker" object:nil];
    }
    
    if(self.isCalling || (self.currentSession && self.currentSession.status != EMCallSessionStatusDisconnected)){
        [[EMClient sharedClient].callManager endCall:originSession.callId reason:EMCallEndReasonBusy];
        return;
    }
    
    [[DemoCallManager sharedManager] setIsCalling:YES];
    @synchronized (_callLock) {
        [self _startCallTimer];
        
        self.currentSession = originSession;
        self.currentController = [[EMCallViewController alloc] initWithCallSession:self.currentSession];
        self.currentController.modalPresentationStyle = UIModalPresentationOverFullScreen;
        self.currentController.userInfo = userInfo;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.currentController) {
                [self.mainController presentViewController:self.currentController animated:NO completion:nil];
            }
        });
    }
}

- (void)makeSendCall:(NSDictionary *)userInfo username:(NSString *)aUsername type:(EMCallType)aType {
    __weak typeof(self) weakSelf = self;
    void (^completionBlock)(EMCallSession *, EMError *) = ^(EMCallSession *aCallSession, EMError *aError){
        DemoCallManager *strongSelf = weakSelf;
        if (strongSelf) {
            if (aError || aCallSession == nil) {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"call.initFailed", @"Establish call failure") message:aError.errorDescription delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                [alertView show];
                return;
            }
            
            @synchronized (self.callLock) {
                self.currentSession = aCallSession;
                self.currentController = [[EMCallViewController alloc] initWithCallSession:self.currentSession];
                self.currentController.userInfo = userInfo;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (self.currentController) {
                        [self.mainController presentViewController:self.currentController animated:NO completion:nil];
                        self.isAccepted = NO;
                    }
                });
            }
            
            [self _startCallTimer];
        }
        else {
            [[EMClient sharedClient].callManager endCall:aCallSession.callId reason:EMCallEndReasonNoResponse];
        }
    };
    
    [[EMClient sharedClient].callManager startCall:aType remoteName:aUsername ext:@"123" completion:^(EMCallSession *aCallSession, EMError *aError) {
        completionBlock(aCallSession, aError);
    }];
}

- (void)addLocalDataToDB:(NSDictionary *)notice {
    NSDictionary *notiDic = notice;
    
    /// 构建一个消息体
    EMCallType type = [[notiDic objectForKey:@"type"] integerValue];
    BOOL isCaller = [[notiDic objectForKey:@"isCaller"] boolValue];
    
    NSString *conversationID = [notiDic objectForKey:@"callID"];
    
    /// 获取当前对话的单聊会话conversation
    EMConversation *conver = [[[EMClient sharedClient] chatManager] getConversation:conversationID type:EMConversationTypeChat createIfNotExist:YES];
    
    NSString *from = isCaller ? [[EMClient sharedClient] currentUsername] : [notiDic objectForKey:@"callID"];
    NSString *to = isCaller ? [notiDic objectForKey:@"callID"] : [[EMClient sharedClient] currentUsername];
    EMMessageBody *body =[[EMTextMessageBody alloc] initWithText:[notiDic objectForKey:@"reasonStr"]];
    NSString *calltype = type == EMCallTypeVoice ? @"voice" : @"video";
    NSDictionary *ext = @{@"callRecord":@"YES",
                          @"callType": calltype};
    EMMessage *message = [[EMMessage alloc] initWithConversationID:conversationID from:from to:to body:body ext:ext];
    message.direction = isCaller ? EMMessageDirectionSend : EMMessageDirectionReceive;
    message.status = EMMessageStatusSucceed;
    NSString *isreadString = [NSString stringWithFormat:@"%@",[notiDic objectForKey:@"isread"]];
    if ([isreadString isEqualToString:@"1"]) {
        message.isRead = YES;
    } else {
        message.isRead = NO;
    }
    
    /// 将这条消息添加到这个单聊会话里面去
    [conver insertMessage:message error:nil];
    /// 简单粗暴发通知 会话列表、聊天详情页刷新页面数据
    [[NSNotificationCenter defaultCenter] postNotificationName:@"callEndReloadData" object:nil];
}

//#endif

@end
