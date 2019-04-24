/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "EaseMessageViewController.h"

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "NSDate+Category.h"
#import "EaseUsersListViewController.h"
#import "EaseMessageReadManager.h"
#import "EaseEmotionManager.h"
#import "EaseEmoji.h"
#import "EaseEmotionEscape.h"
#import "EaseCustomMessageCell.h"
#import "UIImage+EMGIF.h"
#import "EaseLocalDefine.h"
#import "EaseSDKHelper.h"
#import "ThinkSNSPlus-Swift.h"
#import "IMMessageSourceTool.h"
#import "EaseMessageActionStringCell.h"
#import <TZImagePickerController/TZImagePickerController.h>
#import "TSMessageShareInfoCell.h"

#define KHintAdjustY    50

#define IOS_VERSION [[UIDevice currentDevice] systemVersion]>=9.0

typedef enum : NSUInteger {
    EMRequestRecord,
    EMCanRecord,
    EMCanNotRecord,
} EMRecordResponse;


@implementation EaseAtTarget
- (instancetype)initWithUserId:(NSString*)userId andNickname:(NSString*)nickname
{
    if (self = [super init]) {
        _userId = [userId copy];
        _nickname = [nickname copy];
    }
    return self;
}
@end

@interface EaseMessageViewController ()<EaseMessageCellDelegate>
{
    UIMenuItem *_copyMenuItem;
    UIMenuItem *_deleteMenuItem;
    UILongPressGestureRecognizer *_lpgr;
    NSMutableArray *_atTargets;
    
    dispatch_queue_t _messageQueue;
    BOOL _isRecording;
}

@property (strong, nonatomic) id<IMessageModel> playingVoiceModel;
@property (nonatomic) BOOL isKicked;
@property (nonatomic) BOOL isPlayingAudio;
@property (nonatomic, strong) NSMutableArray *atTargets;

@end

@implementation EaseMessageViewController

@synthesize conversation = _conversation;
@synthesize deleteConversationIfNull = _deleteConversationIfNull;
@synthesize messageCountOfPage = _messageCountOfPage;
@synthesize timeCellHeight = _timeCellHeight;
@synthesize messageTimeIntervalTag = _messageTimeIntervalTag;

- (instancetype)initWithConversationChatter:(NSString *)conversationChatter
                           conversationType:(EMConversationType)conversationType
{
    if ([conversationChatter length] == 0) {
        return nil;
    }
    
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _conversation = [[EMClient sharedClient].chatManager getConversation:conversationChatter type:conversationType createIfNotExist:YES];
        
        _messageCountOfPage = 10;
        _timeCellHeight = 30;
        _deleteConversationIfNull = YES;
        _scrollToBottomWhenAppear = YES;
        _messsagesSource = [NSMutableArray array];
        
        [_conversation markAllMessagesAsRead:nil];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:248 / 255.0 green:248 / 255.0 blue:248 / 255.0 alpha:1.0];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cleanAllMassage) name:@"reloadChatDetailVCMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callEndReloadData) name:@"callEndReloadData" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideImagePicker) name:@"hideImagePicker" object:nil];
    
    //Initialization
    CGFloat chatbarHeight = [EaseChatToolbar defaultHeight];
    // 限制为群聊
    // 单聊也暂时不要视频、音频聊天
//    EMChatToolbarType barType = self.conversation.type == EMConversationTypeChat ? EMChatToolbarTypeChat : EMChatToolbarTypeGroup;
    EMChatToolbarType barType = EMChatToolbarTypeGroup;

    self.chatToolbar = [[EaseChatToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - chatbarHeight - iPhoneX_BOTTOM_HEIGHT, self.view.frame.size.width, chatbarHeight) type:barType];
    self.chatToolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    //Initializa the gesture recognizer
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyBoardHidden:)];
    [self.view addGestureRecognizer:tap];
    
    _lpgr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    _lpgr.minimumPressDuration = 0.5;
    [self.tableView addGestureRecognizer:_lpgr];
    
    _messageQueue = dispatch_queue_create("hyphenate.com", NULL);
    
    //Register the delegate
    [EMCDDeviceManager sharedInstance].delegate = self;
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    [[EMClient sharedClient].roomManager addDelegate:self delegateQueue:nil];
    
    if (self.conversation.type == EMConversationTypeChatRoom)
    {
        [self joinChatroom:self.conversation.conversationId];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    
//    [[EaseBaseMessageCell appearance] setSendBubbleBackgroundImage:[[UIImage imageNamed:@"IMG_bg_chat_blue"] stretchableImageWithLeftCapWidth:5 topCapHeight:35]];//EaseUIResource.bundle/chat_sender_bg
//    [[EaseBaseMessageCell appearance] setRecvBubbleBackgroundImage:[[UIImage imageNamed:@"IMG_bg_chat_grey"] stretchableImageWithLeftCapWidth:35 topCapHeight:35]];//EaseUIResource.bundle/chat_receiver_bg
    [[EaseBaseMessageCell appearance] setSendBubbleBackgroundImage:[[UIImage imageNamed:@"IMG_bg_chat_blue"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12) resizingMode:UIImageResizingModeStretch]];//EaseUIResource.bundle/chat_sender_bg
    [[EaseBaseMessageCell appearance] setRecvBubbleBackgroundImage:[[UIImage imageNamed:@"IMG_bg_chat_grey"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12) resizingMode:UIImageResizingModeStretch]];//EaseUIResource.bundle/chat_receiver_bg
//    [[EaseBaseMessageCell appearance] setSendMessageVoiceAnimationImages:@[[UIImage imageNamed:@"EaseUIResource.bundle/chat_sender_audio_playing_full"], [UIImage imageNamed:@"EaseUIResource.bundle/chat_sender_audio_playing_000"], [UIImage imageNamed:@"EaseUIResource.bundle/chat_sender_audio_playing_001"], [UIImage imageNamed:@"EaseUIResource.bundle/chat_sender_audio_playing_002"], [UIImage imageNamed:@"EaseUIResource.bundle/chat_sender_audio_playing_003"]]];
//    [[EaseBaseMessageCell appearance] setRecvMessageVoiceAnimationImages:@[[UIImage imageNamed:@"EaseUIResource.bundle/chat_receiver_audio_playing_full"],[UIImage imageNamed:@"EaseUIResource.bundle/chat_receiver_audio_playing000"], [UIImage imageNamed:@"EaseUIResource.bundle/chat_receiver_audio_playing001"], [UIImage imageNamed:@"EaseUIResource.bundle/chat_receiver_audio_playing002"], [UIImage imageNamed:@"EaseUIResource.bundle/chat_receiver_audio_playing003"]]];
    
    [[EaseBaseMessageCell appearance] setAvatarSize:40.f];
    [[EaseBaseMessageCell appearance] setAvatarCornerRadius:20.f];
    
    [[EaseChatBarMoreView appearance] setMoreViewBackgroundColor:[UIColor colorWithRed:240 / 255.0 green:242 / 255.0 blue:247 / 255.0 alpha:1.0]];
    
    [self tableViewDidTriggerHeaderRefresh];
    self.showRefreshHeader = YES;
//    [self setupEmotion];
    
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
}

/*!
 @method
 @brief 设置表情
 @discussion 加载默认表情，如果子类实现了dataSource的自定义表情回调，同时会加载自定义表情
 @result
 */
- (void)setupEmotion
{
    if ([self.dataSource respondsToSelector:@selector(emotionFormessageViewController:)]) {
        NSArray* emotionManagers = [self.dataSource emotionFormessageViewController:self];
        [self.faceView setEmotionManagers:emotionManagers];
    } else {
        NSMutableArray *emotions = [NSMutableArray array];
        for (NSString *name in [EaseEmoji allEmoji]) {
            EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:name emotionThumbnail:name emotionOriginal:name emotionOriginalURL:@"" emotionType:EMEmotionDefault];
            [emotions addObject:emotion];
        }
        EaseEmotion *emotion = [emotions objectAtIndex:0];
        EaseEmotionManager *manager= [[EaseEmotionManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:emotions tagImage:[UIImage imageNamed:emotion.emotionId]];
        [self.faceView setEmotionManagers:@[manager]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [EMCDDeviceManager sharedInstance].delegate = nil;
    
    if (_imagePicker){
        [_imagePicker dismissViewControllerAnimated:NO completion:nil];
        _imagePicker = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.isViewDidAppear = YES;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
    
//    if (self.scrollToBottomWhenAppear) {
//        [self _scrollViewToBottom:NO];
//    }
//    self.scrollToBottomWhenAppear = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.isViewDidAppear = NO;
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [[EaseMessageReadManager defaultManager] stopMessageAudioModel];
    [self.tableView reloadData];
    self.isPlayingAudio = NO;
    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
}

#pragma mark - chatroom

- (void)saveChatroom:(EMChatroom *)chatroom
{
    NSString *chatroomName = chatroom.subject ? chatroom.subject : @"";
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString *key = [NSString stringWithFormat:@"OnceJoinedChatrooms_%@", [[EMClient sharedClient] currentUsername]];
    NSMutableDictionary *chatRooms = [NSMutableDictionary dictionaryWithDictionary:[ud objectForKey:key]];
    if (![chatRooms objectForKey:chatroom.chatroomId])
    {
        [chatRooms setObject:chatroomName forKey:chatroom.chatroomId];
        [ud setObject:chatRooms forKey:key];
        [ud synchronize];
    }
}

/*!
 @method
 @brief 加入聊天室
 @discussion
 @result
 */
- (void)joinChatroom:(NSString *)chatroomId
{
    __weak typeof(self) weakSelf = self;
    [self showHudInView:self.view hint:NSEaseLocalizedString(@"chatroom.joining",@"Joining the chatroom")];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EMError *error = nil;
        EMChatroom *chatroom = [[EMClient sharedClient].roomManager joinChatroom:chatroomId error:&error];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (weakSelf) {
                EaseMessageViewController *strongSelf = weakSelf;
                [strongSelf hideHud];
                if (error != nil) {
                    [strongSelf showHint:[NSString stringWithFormat:NSEaseLocalizedString(@"chatroom.joinFailed",@"join chatroom \'%@\' failed"), chatroomId]];
                } else {
                    strongSelf.isJoinedChatroom = YES;
                    [strongSelf saveChatroom:chatroom];
                }
            }  else {
                if (!error || (error.code == EMErrorChatroomAlreadyJoined)) {
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        EMError *leaveError;
                        [[EMClient sharedClient].roomManager leaveChatroom:chatroomId error:&leaveError];
                        [[EMClient sharedClient].chatManager deleteConversation:chatroomId isDeleteMessages:YES completion:nil];
                    });
                }
            }
        });
    });
}

#pragma mark - EMChatManagerChatroomDelegate

- (void)didReceiveUserJoinedChatroom:(EMChatroom *)aChatroom
                            username:(NSString *)aUsername
{
    CGRect frame = self.chatToolbar.frame;
    [self showHint:[NSString stringWithFormat:NSEaseLocalizedString(@"chatroom.join", @"\'%@\'join chatroom\'%@\'"), aUsername, aChatroom.chatroomId] yOffset:-frame.size.height + KHintAdjustY];
}

- (void)didReceiveUserLeavedChatroom:(EMChatroom *)aChatroom
                            username:(NSString *)aUsername
{
    CGRect frame = self.chatToolbar.frame;
    [self showHint:[NSString stringWithFormat:NSEaseLocalizedString(@"chatroom.leave.hint", @"\'%@\'leave chatroom\'%@\'"), aUsername, aChatroom.chatroomId] yOffset:-frame.size.height + KHintAdjustY];
}

- (void)didReceiveKickedFromChatroom:(EMChatroom *)aChatroom
                              reason:(EMChatroomBeKickedReason)aReason
{
    if ([_conversation.conversationId isEqualToString:aChatroom.chatroomId])
    {
        _isKicked = YES;
        CGRect frame = self.chatToolbar.frame;
        [self showHint:[NSString stringWithFormat:NSEaseLocalizedString(@"chatroom.remove", @"be removed from chatroom\'%@\'"), aChatroom.chatroomId] yOffset:-frame.size.height + KHintAdjustY];
        [self.navigationController popToViewController:self animated:NO];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - getter

- (UIImagePickerController *)imagePicker
{
    if (_imagePicker == nil) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.modalPresentationStyle= UIModalPresentationOverFullScreen;
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}

- (NSMutableArray*)atTargets
{
    if (!_atTargets) {
        _atTargets = [NSMutableArray array];
    }
    return _atTargets;
}

#pragma mark - setter

//- (void)setIsViewDidAppear:(BOOL)isViewDidAppear
//{
//    _isViewDidAppear =isViewDidAppear;
//    if (_isViewDidAppear)
//    {
//        NSMutableArray *unreadMessages = [NSMutableArray array];
//        for (EMMessage *message in self.messsagesSource)
//        {
//            if ([self shouldSendHasReadAckForMessage:message read:NO])
//            {
//                [unreadMessages addObject:message];
//            }
//        }
//        if ([unreadMessages count])
//        {
//            [self _sendHasReadResponseForMessages:unreadMessages isRead:YES];
//        }
//        
//        [_conversation markAllMessagesAsRead:nil];
//    }
//}

- (void)setChatToolbar:(EaseChatToolbar *)chatToolbar
{
    [_chatToolbar removeFromSuperview];
    
    _chatToolbar = chatToolbar;
    if (_chatToolbar) {
        [self.view addSubview:_chatToolbar];
    }
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = self.view.frame.size.height - _chatToolbar.frame.size.height - iPhoneX_BOTTOM_HEIGHT;
    self.tableView.frame = tableFrame;
    if ([chatToolbar isKindOfClass:[EaseChatToolbar class]]) {
        [(EaseChatToolbar *)self.chatToolbar setDelegate:self];
        self.chatBarMoreView = (EaseChatBarMoreView*)[(EaseChatToolbar *)self.chatToolbar moreView];
        self.faceView = (EaseFaceView*)[(EaseChatToolbar *)self.chatToolbar faceView];
        self.recordView = (EaseRecordView*)[(EaseChatToolbar *)self.chatToolbar recordView];
    }
}

- (void)setDataSource:(id<EaseMessageViewControllerDataSource>)dataSource
{
    _dataSource = dataSource;
    
//    [self setupEmotion];
}

- (void)setDelegate:(id<EaseMessageViewControllerDelegate>)delegate
{
    _delegate = delegate;
}

#pragma mark - private helper

/*!
 @method
 @brief tableView滑动到底部
 @discussion
 @result
 */
- (void)_scrollViewToBottom:(BOOL)animated
{
    if (self.tableView.contentSize.height > self.tableView.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tableView.contentSize.height - self.tableView.frame.size.height);
        [self.tableView setContentOffset:offset animated:animated];
    }
}

/*!
 @method
 @brief 当前设备是否可以录音
 @discussion
 @param aCompletion 判断结果
 @result
 */
- (void)_canRecordCompletion:(void(^)(EMRecordResponse))aCompletion
{
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (videoAuthStatus == AVAuthorizationStatusNotDetermined) {
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (aCompletion) {
                aCompletion(granted ? EMCanRecord : EMRequestRecord);
            }
        }];
    }
    else if(videoAuthStatus == AVAuthorizationStatusRestricted || videoAuthStatus == AVAuthorizationStatusDenied) {
        aCompletion(EMCanNotRecord);
    }
    else{
        aCompletion(EMCanRecord);
    }
}

- (void)showMenuViewController:(UIView *)showInView
                  andIndexPath:(NSIndexPath *)indexPath
                   messageType:(EMMessageBodyType)messageType
{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    
    if (_deleteMenuItem == nil) {
        _deleteMenuItem = [[UIMenuItem alloc] initWithTitle:NSEaseLocalizedString(@"delete", @"Delete") action:@selector(deleteMenuAction:)];
    }
    
    if (_copyMenuItem == nil) {
        _copyMenuItem = [[UIMenuItem alloc] initWithTitle:NSEaseLocalizedString(@"copy", @"Copy") action:@selector(copyMenuAction:)];
    }
    
    if (messageType == EMMessageBodyTypeText) {
        [_menuController setMenuItems:@[_copyMenuItem, _deleteMenuItem]];
    } else {
        [_menuController setMenuItems:@[_deleteMenuItem]];
    }
    [_menuController setTargetRect:showInView.frame inView:showInView.superview];
    [_menuController setMenuVisible:YES animated:YES];
}

- (void)_stopAudioPlayingWithChangeCategory:(BOOL)isChange
{
    //停止音频播放及播放动画
    [[EMCDDeviceManager sharedInstance] stopPlaying];
    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
    [EMCDDeviceManager sharedInstance].delegate = nil;
}

/*!
 @method
 @brief mov格式视频转换为MP4格式
 @discussion
 @param movUrl   mov视频路径
 @result  MP4格式视频路径
 */
- (NSURL *)_convert2Mp4:(NSURL *)movUrl
{
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]initWithAsset:avAsset
                                                                              presetName:AVAssetExportPresetHighestQuality];
        NSString *mp4Path = [NSString stringWithFormat:@"%@/%d%d.mp4", [EMCDDeviceManager dataPath], (int)[[NSDate date] timeIntervalSince1970], arc4random() % 100000];
        mp4Url = [NSURL fileURLWithPath:mp4Path];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"completed.");
                } break;
                default: {
                    NSLog(@"others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"timeout.");
        }
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return mp4Url;
}

/*!
 @method
 @brief 通过当前会话类型，返回消息聊天类型
 @discussion
 @result
 */
- (EMChatType)_messageTypeFromConversationType
{
    EMChatType type = EMChatTypeChat;
    switch (self.conversation.type) {
        case EMConversationTypeChat:
            type = EMChatTypeChat;
            break;
        case EMConversationTypeGroupChat:
            type = EMChatTypeGroupChat;
            break;
        case EMConversationTypeChatRoom:
            type = EMChatTypeChatRoom;
            break;
        default:
            break;
    }
    return type;
}

- (void)_customDownloadMessageFile:(EMMessage *)aMessage
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"message.autoTransfer", @"Please customize the  transfer attachment method") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
    });
}

/*!
 @method
 @brief 下载消息附件
 @discussion
 @param message  待下载附件的消息
 @result
 */
- (void)_downloadMessageAttachments:(EMMessage *)message
{
    __weak typeof(self) weakSelf = self;
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        if (!error)
        {
            [weakSelf _reloadTableViewDataWithMessage:message];
        }
        else
        {
            [weakSelf showHint:NSEaseLocalizedString(@"message.thumImageFail", @"thumbnail for failure!")];
        }
    };
    
    BOOL isCustomDownload = !([EMClient sharedClient].options.isAutoTransferMessageAttachments);
    BOOL isAutoDownloadThumbnail = ([EMClient sharedClient].options.isAutoDownloadThumbnail);
    EMMessageBody *messageBody = message.body;
    if ([messageBody type] == EMMessageBodyTypeImage) {
        EMImageMessageBody *imageBody = (EMImageMessageBody *)messageBody;
        if (imageBody.thumbnailDownloadStatus > EMDownloadStatusSuccessed)
        {
            //download the message thumbnail
            if (isCustomDownload) {
                [self _customDownloadMessageFile:message];
            } else {
                if (isAutoDownloadThumbnail) {
                    [[[EMClient sharedClient] chatManager] downloadMessageThumbnail:message progress:nil completion:completion];
                }
            }
        }
    }
    else if ([messageBody type] == EMMessageBodyTypeVideo)
    {
        EMVideoMessageBody *videoBody = (EMVideoMessageBody *)messageBody;
        if (videoBody.thumbnailDownloadStatus > EMDownloadStatusSuccessed)
        {
            //download the message thumbnail
            if (isCustomDownload) {
                [self _customDownloadMessageFile:message];
            } else {
                if (isAutoDownloadThumbnail) {
                    [[[EMClient sharedClient] chatManager] downloadMessageThumbnail:message progress:nil completion:completion];
                }
            }
        }
    }
    else if ([messageBody type] == EMMessageBodyTypeVoice)
    {
        EMVoiceMessageBody *voiceBody = (EMVoiceMessageBody*)messageBody;
        if (voiceBody.downloadStatus > EMDownloadStatusSuccessed)
        {
            //download the message attachment
            if (isCustomDownload) {
                [self _customDownloadMessageFile:message];
            } else {
                if (isAutoDownloadThumbnail) {
                    [[EMClient sharedClient].chatManager downloadMessageAttachment:message progress:nil completion:^(EMMessage *message, EMError *error) {
                        if (!error) {
                            [weakSelf _reloadTableViewDataWithMessage:message];
                        }
                        else {
                            [weakSelf showHint:NSEaseLocalizedString(@"message.voiceFail", @"voice for failure!")];
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"com.ts-plus.notification.name.chat.showNotice" object:@{@"msg":@"语音获取失败,请稍后重试!"}];
                        }
                    }];
                }
            }
        }
    }
}

/*!
 @method
 @brief 传入消息是否需要发动已读回执
 @discussion
 @param message  待判断的消息
 @param read     消息是否已读
 @result
 */
- (BOOL)shouldSendHasReadAckForMessage:(EMMessage *)message
                                  read:(BOOL)read
{
    if (message.chatType != EMChatTypeChat || message.isReadAcked || message.direction == EMMessageDirectionSend || ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || !self.isViewDidAppear)
    {
        return NO;
    }
    
    EMMessageBody *body = message.body;
    if (((body.type == EMMessageBodyTypeVideo) ||
         (body.type == EMMessageBodyTypeVoice) ||
         (body.type == EMMessageBodyTypeImage)) &&
        !read)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

/*!
 @method
 @brief 为传入的消息发送已读回执
 @discussion
 @param messages  待发送已读回执的消息数组
 @param isRead    是否已读
 @result
 */
- (void)_sendHasReadResponseForMessages:(NSArray*)messages
                                 isRead:(BOOL)isRead
{
    NSMutableArray *unreadMessages = [NSMutableArray array];
    for (NSInteger i = 0; i < [messages count]; i++)
    {
        EMMessage *message = messages[i];
        BOOL isSend = YES;
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:shouldSendHasReadAckForMessage:read:)]) {
            isSend = [_dataSource messageViewController:self
                         shouldSendHasReadAckForMessage:message read:isRead];
        }
        else{
            isSend = [self shouldSendHasReadAckForMessage:message
                                                     read:isRead];
        }
        
        if (isSend)
        {
            [unreadMessages addObject:message];
        }
    }
    
    if ([unreadMessages count])
    {
        for (EMMessage *message in unreadMessages)
        {
            [[EMClient sharedClient].chatManager sendMessageReadAck:message completion:nil];
        }
    }
}

- (BOOL)_shouldMarkMessageAsRead
{
    BOOL isMark = YES;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewControllerShouldMarkMessagesAsRead:)]) {
        isMark = [_dataSource messageViewControllerShouldMarkMessagesAsRead:self];
    }
    else{
        if (([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) || !self.isViewDidAppear)
        {
            isMark = NO;
        }
    }
    
    return isMark;
}

/*!
 @method
 @brief 位置消息被点击选择
 @discussion
 @param model 消息model
 @result
 */
- (void)_locationMessageCellSelected:(id<IMessageModel>)model
{
    _scrollToBottomWhenAppear = NO;
    EaseLocationViewController *locationController = [[EaseLocationViewController alloc] initWithLocation:CLLocationCoordinate2DMake(model.latitude, model.longitude)];
    [self.navigationController pushViewController:locationController animated:YES];
}

/*!
 @method
 @brief 视频消息被点击选择
 @discussion
 @param model 消息model
 @result
 */
- (void)_videoMessageCellSelected:(id<IMessageModel>)model
{
    _scrollToBottomWhenAppear = NO;
    
    EMVideoMessageBody *videoBody = (EMVideoMessageBody*)model.message.body;
    
    NSString *localPath = [model.fileLocalPath length] > 0 ? model.fileLocalPath : videoBody.localPath;
    if ([localPath length] == 0) {
        [self showHint:NSEaseLocalizedString(@"message.videoFail", @"video for failure!")];
        return;
    }
    
    dispatch_block_t block = ^{
        //send the acknowledgement
        [self _sendHasReadResponseForMessages:@[model.message]
                                       isRead:YES];
        
        NSURL *videoURL = [NSURL fileURLWithPath:localPath];
        MPMoviePlayerViewController *moviePlayerController = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
        [moviePlayerController.moviePlayer prepareToPlay];
        moviePlayerController.moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        [self presentMoviePlayerViewControllerAnimated:moviePlayerController];
    };
    
    BOOL isCustomDownload = !([EMClient sharedClient].options.isAutoTransferMessageAttachments);
    __weak typeof(self) weakSelf = self;
    void (^completion)(EMMessage *aMessage, EMError *error) = ^(EMMessage *aMessage, EMError *error) {
        if (!error)
        {
            [weakSelf _reloadTableViewDataWithMessage:aMessage];
        }
        else
        {
            [weakSelf showHint:NSEaseLocalizedString(@"message.thumImageFail", @"thumbnail for failure!")];
        }
    };
    
    if (videoBody.thumbnailDownloadStatus == EMDownloadStatusFailed || ![[NSFileManager defaultManager] fileExistsAtPath:videoBody.thumbnailLocalPath]) {
        [self showHint:@"begin downloading thumbnail image, click later"];
        if (isCustomDownload) {
            [self _customDownloadMessageFile:model.message];
        } else {
            [[EMClient sharedClient].chatManager downloadMessageThumbnail:model.message progress:nil completion:completion];
        }
        return;
    }
    
    if (videoBody.downloadStatus == EMDownloadStatusSuccessed && [[NSFileManager defaultManager] fileExistsAtPath:localPath])
    {
        block();
        return;
    }
    
    [self showHudInView:self.view hint:NSEaseLocalizedString(@"message.downloadingVideo", @"downloading video...")];
    if (isCustomDownload) {
        [self _customDownloadMessageFile:model.message];
    } else {
        [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
            [weakSelf hideHud];
            if (!error) {
                block();
            }else{
                [weakSelf showHint:NSEaseLocalizedString(@"message.videoFail", @"video for failure!")];
            }
        }];
    }
}

/*!
 @method
 @brief 图片消息被点击选择
 @discussion
 @param model 消息model
 @result
 */
- (void)_imageMessageCellSelected:(EaseMessageCell *)cell data:(id<IMessageModel>)model
{
    /// 需要判断是否是定位
    /// 目前扩展字段中有内容及为定位卡片
    if (model.message.ext.count > 0 && [model.message.ext[@"image"] boolValue] == YES) {
        // 定位卡片
        if (model.image.size.width > 0) {
              [self messageViewController:self didTapLocationCardInfo:model.message.ext image:model.image];
        } else {
            if (cell.bubbleView.imageView.image.size.width > 0) {
                [self messageViewController:self didTapLocationCardInfo:model.message.ext image:cell.bubbleView.imageView.image];
            } else {
                 [ self showHint:@"图片加载中.."];
            }
        }
    } else {
        // 普通图片
        if (model.image.size.width > 0) {
            UIWindow* desWindow=[UIApplication sharedApplication].keyWindow;
            CGRect smallImageFrame = [cell.bubbleView.imageView convertRect:cell.bubbleView.imageView.bounds toView:desWindow];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"com.ts-plus.notification.name.chat.tapChatDetailImage" object:@[@{@"image":model.image,@"frame":NSStringFromCGRect(smallImageFrame)}]];
        } else {
            if (cell.bubbleView.imageView.image.size.width > 0) {
                UIWindow* desWindow=[UIApplication sharedApplication].keyWindow;
                CGRect smallImageFrame = [cell.bubbleView.imageView convertRect:cell.bubbleView.imageView.bounds toView:desWindow];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"com.ts-plus.notification.name.chat.tapChatDetailImage" object:@[@{@"image":cell.bubbleView.imageView.image,@"frame":NSStringFromCGRect(smallImageFrame)}]];
            } else {
                [ self showHint:@"图片加载中.."];
            }
        }
    }
}

/*!
 @method
 @brief 语音消息被点击选择
 @discussion
 @param model 消息model
 @result
 */
- (void)_audioMessageCellSelected:(id<IMessageModel>)model
{
    _scrollToBottomWhenAppear = NO;
    EMVoiceMessageBody *body = (EMVoiceMessageBody*)model.message.body;
    EMDownloadStatus downloadStatus = [body downloadStatus];
    if (downloadStatus == EMDownloadStatusDownloading) {
        [self showHint:NSEaseLocalizedString(@"message.downloadingAudio", @"downloading voice, click later")];
        return;
    }
    else if (downloadStatus == EMDownloadStatusFailed || downloadStatus == EMDownloadStatusPending)
    {
        [self showHint:NSEaseLocalizedString(@"message.downloadingAudio", @"downloading voice, click later")];
        BOOL isCustomDownload = !([EMClient sharedClient].options.isAutoTransferMessageAttachments);
        if (isCustomDownload) {
            [self _customDownloadMessageFile:model.message];
        } else {
            [[EMClient sharedClient].chatManager downloadMessageAttachment:model.message progress:nil completion:nil];
        }
        
        return;
    }
    
    // play the audio
    if (model.bodyType == EMMessageBodyTypeVoice) {
        //send the acknowledgement
        [self _sendHasReadResponseForMessages:@[model.message] isRead:YES];
        __weak EaseMessageViewController *weakSelf = self;
        BOOL isPrepare = [[EaseMessageReadManager defaultManager] prepareMessageAudioModel:model updateViewCompletion:^(EaseMessageModel *prevAudioModel, EaseMessageModel *currentAudioModel) {
            if (prevAudioModel || currentAudioModel) {
                [weakSelf.tableView reloadData];
            }
        }];
        
        if (isPrepare) {
            _isPlayingAudio = YES;
            __weak EaseMessageViewController *weakSelf = self;
            [[EMCDDeviceManager sharedInstance] enableProximitySensor];
            [[EMCDDeviceManager sharedInstance] asyncPlayingWithPath:model.fileLocalPath completion:^(NSError *error) {
                [[EaseMessageReadManager defaultManager] stopMessageAudioModel];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                    weakSelf.isPlayingAudio = NO;
                    [[EMCDDeviceManager sharedInstance] disableProximitySensor];
                });
            }];
        }
        else{
            _isPlayingAudio = NO;
        }
    }
}

#pragma mark - pivate data

/*!
 @method
 @brief 加载历史消息
 @discussion
 @param messageId 参考消息的ID
 @param count     获取条数
 @param isAppend  是否在dataArray直接添加
 @result
 */
- (void)_loadMessagesBefore:(NSString*)messageId
                      count:(NSInteger)count
                     append:(BOOL)isAppend
{
    __weak typeof(self) weakSelf = self;
    void (^refresh)(NSArray *messages) = ^(NSArray *messages) {
        dispatch_async(_messageQueue, ^{
            //Format the message
            NSArray *formattedMessages = [weakSelf formatMessages:messages];
            
            //Refresh the page
            dispatch_async(dispatch_get_main_queue(), ^{
                EaseMessageViewController *strongSelf = weakSelf;
                if (strongSelf) {
                    NSInteger scrollToIndex = 0;
                    if (isAppend) {
                        [strongSelf.messsagesSource insertObjects:messages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [messages count])]];
                        
                        //Combine the message
                        id object = [strongSelf.dataArray firstObject];
                        if ([object isKindOfClass:[NSString class]]) {
                            NSString *timestamp = object;
                            [formattedMessages enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id model, NSUInteger idx, BOOL *stop) {
                                if ([model isKindOfClass:[NSString class]] && [timestamp isEqualToString:model]) {
                                    [strongSelf.dataArray removeObjectAtIndex:0];
                                    *stop = YES;
                                }
                            }];
                        }
                        scrollToIndex = [strongSelf.dataArray count];
                        [strongSelf.dataArray insertObjects:formattedMessages atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [formattedMessages count])]];
                    }
                    else {
                        [strongSelf.messsagesSource removeAllObjects];
                        [strongSelf.messsagesSource addObjectsFromArray:messages];
                        
                        [strongSelf.dataArray removeAllObjects];
                        [strongSelf.dataArray addObjectsFromArray:formattedMessages];
                    }
                    
                    EMMessage *latest = [strongSelf.messsagesSource lastObject];
                    strongSelf.messageTimeIntervalTag = latest.timestamp;
                    
                    [strongSelf.tableView reloadData];
                    
                    [strongSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArray count] - scrollToIndex - 1 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                }
            });
            
            //re-download all messages that are not successfully downloaded
            for (EMMessage *message in messages)
            {
                [weakSelf _downloadMessageAttachments:message];
            }
            
            //send the read acknoledgement
            [weakSelf _sendHasReadResponseForMessages:messages
                                               isRead:NO];
        });
    };
    
    [self.conversation loadMessagesStartFromId:messageId count:(int)count searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
        if (!aError && [aMessages count]) {
            refresh(aMessages);
        }
    }];
}

#pragma mark - GestureRecognizer

-(void)keyBoardHidden:(UITapGestureRecognizer *)tapRecognizer
{
    if (tapRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.chatToolbar endEditing:YES];
    }
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan && [self.dataArray count] > 0)
    {
        CGPoint location = [recognizer locationInView:self.tableView];
        NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
        BOOL canLongPress = NO;
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:canLongPressRowAtIndexPath:)]) {
            canLongPress = [_dataSource messageViewController:self
                                   canLongPressRowAtIndexPath:indexPath];
        }
        
        if (!canLongPress) {
            return;
        }
        
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:didLongPressRowAtIndexPath:)]) {
            [_dataSource messageViewController:self
                    didLongPressRowAtIndexPath:indexPath];
        }
        else{
            id object = [self.dataArray objectAtIndex:indexPath.row];
            if (![object isKindOfClass:[NSString class]]) {
                EaseMessageCell *cell = (EaseMessageCell *)[self.tableView cellForRowAtIndexPath:indexPath];
                [cell becomeFirstResponder];
                _menuIndexPath = indexPath;
                [self showMenuViewController:cell.bubbleView andIndexPath:indexPath messageType:cell.model.bodyType];
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    
    //time cell
    if ([object isKindOfClass:[NSString class]]) {
        NSString *TimeCellIdentifier = [EaseMessageTimeCell cellIdentifier];
        EaseMessageTimeCell *timeCell = (EaseMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
        
        if (timeCell == nil) {
            timeCell = [[EaseMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier];
            timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        timeCell.title = object;
        return timeCell;
    }
    else{
        id<IMessageModel> model = object;
        if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:cellForMessageModel:)]) {
            UITableViewCell *cell = [_delegate messageViewController:tableView cellForMessageModel:model];
            if (cell) {
                if ([cell isKindOfClass:[EaseMessageCell class]]) {
                    EaseMessageCell *emcell= (EaseMessageCell*)cell;
                    if (emcell.delegate == nil) {
                        emcell.delegate = self;
                    }
                }
                return cell;
            }
        }
        
        /// 管理员
        if ([model.message.from isEqualToString:@"admin"]) {
            if ([model.text isEqualToString:@"快速编辑群名称，开启群聊"] == YES) {
                // 这条消息是自己创建的讨论组，直接发一条快速编辑入口的消息
                EaseMessageActionStringCell *cell = (EaseMessageActionStringCell*)[tableView dequeueReusableCellWithIdentifier:[EaseMessageActionStringCell cellIdentifier]];
                if (cell == nil) {
                    cell = [[EaseMessageActionStringCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[EaseMessageActionStringCell cellIdentifier]];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                return cell;
            } else {
                NSString *TimeCellIdentifier = [EaseMessageTimeCell cellIdentifier];
                EaseMessageTimeCell *timeCell = (EaseMessageTimeCell *)[tableView dequeueReusableCellWithIdentifier:TimeCellIdentifier];
                if (timeCell == nil) {
                    timeCell = [[EaseMessageTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TimeCellIdentifier];
                    timeCell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                CGSize  nameSize = [model.text boundingRectWithSize:CGSizeMake(1000, 15) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size;
                CGFloat width = nameSize.width + 20;
                timeCell.bgLabel.frame = CGRectMake((self.view.frame.size.width - width ) / 2, 0, width, nameSize.height * 2);
                timeCell.title = model.text;
                return timeCell;
            }
        } else if(model.message.ext[@"letter"]) {
            // 自定义的cell
            TSMessageShareInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TSMessageShareInfoCell"];
            if (!cell) {
                cell = [[TSMessageShareInfoCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TSMessageShareInfoCell"];
                [cell creatUI];
            }
            [cell updataInfoModel:model];
            return cell;
        }
        
        if (_dataSource && [_dataSource respondsToSelector:@selector(isEmotionMessageFormessageViewController:messageModel:)]) {
            BOOL flag = [_dataSource isEmotionMessageFormessageViewController:self messageModel:model];
            if (flag) {
                NSString *CellIdentifier = [EaseCustomMessageCell cellIdentifierWithModel:model];
                //send cell
                EaseCustomMessageCell *sendCell = (EaseCustomMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                // Configure the cell...
                if (sendCell == nil) {
                    sendCell = [[EaseCustomMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:model];
                    sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                
                if (_dataSource && [_dataSource respondsToSelector:@selector(emotionURLFormessageViewController:messageModel:)]) {
                    EaseEmotion *emotion = [_dataSource emotionURLFormessageViewController:self messageModel:model];
                    if (emotion) {
                        model.image = [UIImage sd_animatedGIFNamed:emotion.emotionOriginal];
                        model.fileURLPath = emotion.emotionOriginalURL;
                    }
                }
                sendCell.model = model;
                sendCell.delegate = self;
                return sendCell;
            }
        }
        /// 视屏/语音通话记录cell
        if (model.message.ext.count && [model.message.ext objectForKey:@"callRecord"] && [[model.message.ext objectForKey:@"callRecord"] isEqualToString:@"YES"]) {
            
            NSString *callRecordCellIdentifier = model.isSender ? @"callCellSender" : @"callCellReceived";
            
            EaseCallRecordMessageCell *callRecordCell = (EaseCallRecordMessageCell *)[tableView dequeueReusableCellWithIdentifier:callRecordCellIdentifier];
            if (!callRecordCell) {
                callRecordCell = [[EaseCallRecordMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:callRecordCellIdentifier model:model];
                callRecordCell.delegate = self;
            }
            callRecordCell.model = model;
            return callRecordCell;
        }
        
        NSString *CellIdentifier = [EaseMessageCell cellIdentifierWithModel:model];
        
        EaseBaseMessageCell *sendCell = (EaseBaseMessageCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        if (sendCell == nil) {
            sendCell = [[EaseBaseMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier model:model];
            sendCell.selectionStyle = UITableViewCellSelectionStyleNone;
            sendCell.delegate = self;
        }
        sendCell.sendMessageVoiceAnimationImages = [IMMessageSourceTool sendMessageVoiceAnimationImages];
        sendCell.recvMessageVoiceAnimationImages = [IMMessageSourceTool recvMessageVoiceAnimationImages];
        
        sendCell.model = model;
        return sendCell;
    }
}

#pragma mark - Table view delegate
- (CGFloat)stringHeightWithConstrainedWidth:(CGFloat)maxWidth sting:(NSString *)string font:(UIFont*)font{
    CGSize constraintRect = CGSizeMake(maxWidth, MAXFLOAT);
    CGRect boundingBox = [string boundingRectWithSize:constraintRect options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: font} context:nil];
    return boundingBox.size.height;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if ([object isKindOfClass:[NSString class]]) {
        NSString *title = object;
        // 系统通知的左右最远位置为头像的X轴中心点
        CGFloat stringHeight = [self stringHeightWithConstrainedWidth:([UIScreen mainScreen].bounds.size.width - (10 + 40 / 2.0 + 5) * 2) sting:title font:[UIFont systemFontOfSize:10]];
        return stringHeight + (3 + 5) * 2;
    }
    else{
        id<IMessageModel> model = object;
        if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:heightForMessageModel:withCellWidth:)]) {
            CGFloat height = [_delegate messageViewController:self heightForMessageModel:model withCellWidth:tableView.frame.size.width];
            if (height) {
                return height;
            }
        }
        
        // 系统消息
        if ([model.message.from isEqualToString:@"admin"]) {
            NSString *title = model.text;
            // 系统通知的左右最远位置为头像的X轴中心点
            CGFloat stringHeight = [self stringHeightWithConstrainedWidth:([UIScreen mainScreen].bounds.size.width - (10 + 40 / 2.0 + 5) * 2) sting:title font:[UIFont systemFontOfSize:10]];
            return stringHeight + (3 + 5) * 2;
        }
        
        if (_dataSource && [_dataSource respondsToSelector:@selector(isEmotionMessageFormessageViewController:messageModel:)]) {
            BOOL flag = [_dataSource isEmotionMessageFormessageViewController:self messageModel:model];
            if (flag) {
                return [EaseCustomMessageCell cellHeightWithModel:model];
            }
        }
        
        return [EaseBaseMessageCell cellHeightWithModel:model];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        // video url:
        // file:///private/var/mobile/Applications/B3CDD0B2-2F19-432B-9CFA-158700F4DE8F/tmp/capture-T0x16e39100.tmp.9R8weF/capturedvideo.mp4
        // we will convert it to mp4 format
        NSURL *mp4 = [self _convert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        [self sendVideoMessageWithURL:mp4];
        
    }else{
        
        NSURL *url = info[UIImagePickerControllerReferenceURL];
        if (url == nil) {
            UIImage *orgImage = info[UIImagePickerControllerOriginalImage];
            [self sendImageMessage:orgImage];
        } else {
            if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0f) {
                PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
                [result enumerateObjectsUsingBlock:^(PHAsset *asset , NSUInteger idx, BOOL *stop){
                    if (asset) {
                        [[PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData *data, NSString *uti, UIImageOrientation orientation, NSDictionary *dic){
                            if (data != nil) {
                                [self sendImageMessageWithData:data];
                            } else {
                                [self showHint:NSEaseLocalizedString(@"message.smallerImage", @"The image size is too large, please choose another one")];
                            }
                        }];
                    }
                }];
            } else {
                ALAssetsLibrary *alasset = [[ALAssetsLibrary alloc] init];
                [alasset assetForURL:url resultBlock:^(ALAsset *asset) {
                    if (asset) {
                        ALAssetRepresentation* assetRepresentation = [asset defaultRepresentation];
                        Byte* buffer = (Byte*)malloc((size_t)[assetRepresentation size]);
                        NSUInteger bufferSize = [assetRepresentation getBytes:buffer fromOffset:0.0 length:(NSUInteger)[assetRepresentation size] error:nil];
                        NSData* fileData = [NSData dataWithBytesNoCopy:buffer length:bufferSize freeWhenDone:YES];
                        [self sendImageMessageWithData:fileData];
                    }
                } failureBlock:NULL];
            }
        }
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    self.isViewDidAppear = YES;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self.imagePicker dismissViewControllerAnimated:YES completion:nil];
    
    self.isViewDidAppear = YES;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:NO];
}

//MARK: - 替换为TZ


#pragma mark - EaseMessageCellDelegate

- (void)messageCellSelected:(id<IMessageModel>)model
{
    if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didSelectMessageModel:)]) {
        BOOL flag = [_delegate messageViewController:self didSelectMessageModel:model];
        if (flag) {
            [self _sendHasReadResponseForMessages:@[model.message] isRead:YES];
            return;
        }
    }
    
    switch (model.bodyType) {
        case EMMessageBodyTypeImage:
        {
//            _scrollToBottomWhenAppear = NO;
//            [self _imageMessageCellSelected:model];
            NSLog(@"\n\nwarming\n\n _imageMessageCellSelected not found");
        }
            break;
        case EMMessageBodyTypeLocation:
        {
            [self _locationMessageCellSelected:model];
        }
            break;
        case EMMessageBodyTypeVoice:
        {
            [self _audioMessageCellSelected:model];
        }
            break;
        case EMMessageBodyTypeVideo:
        {
            [self _videoMessageCellSelected:model];
            
        }
            break;
        case EMMessageBodyTypeFile:
        {
            _scrollToBottomWhenAppear = NO;
            [self showHint:@"Custom implementation!"];
        }
            break;
        default:
            break;
    }
}

// 图片消息被点击
- (void)imageMessageCellSelected:(EaseMessageCell *)cell data:(id<IMessageModel>)model {
    _scrollToBottomWhenAppear = NO;
    [self _imageMessageCellSelected:cell data:model];

}
- (void)statusButtonSelcted:(id<IMessageModel>)model withMessageCell:(EaseMessageCell*)messageCell
{
    if ((model.messageStatus != EMMessageStatusFailed) && (model.messageStatus != EMMessageStatusPending))
    {
        return;
    }
    
    __weak typeof(self) weakself = self;
    [[[EMClient sharedClient] chatManager] resendMessage:model.message progress:nil completion:^(EMMessage *message, EMError *error) {
        if (!error) {
            [weakself refreshAfterSentMessage:message];
        }
        else {
            [weakself.tableView reloadData];
        }
    }];
    
    [self.tableView reloadData];
}

- (void)avatarViewSelcted:(id<IMessageModel>)model
{
    if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didSelectAvatarMessageModel:)]) {
        [_delegate messageViewController:self didSelectAvatarMessageModel:model];
        
        return;
    }
    
    _scrollToBottomWhenAppear = NO;
}

#pragma mark - EMChatToolbarDelegate

- (void)chatToolbarDidChangeFrameToHeight:(CGFloat)toHeight
{
    [UIView animateWithDuration:0.3 animations:^{
        CGRect rect = self.tableView.frame;
        rect.origin.y = 0;
        rect.size.height = self.view.frame.size.height - toHeight - iPhoneX_BOTTOM_HEIGHT;
        self.tableView.frame = rect;
    }];
    
    [self _scrollViewToBottom:NO];
}

- (void)inputTextViewWillBeginEditing:(EaseTextView *)inputTextView
{
    if (_menuController == nil) {
        _menuController = [UIMenuController sharedMenuController];
    }
    [_menuController setMenuItems:nil];
}

- (void)didSendText:(NSString *)text
{
    if (text && text.length > 0) {
        [self sendTextMessage:text];
        [self.atTargets removeAllObjects];
    }
}

- (BOOL)didInputAtInLocation:(NSUInteger)location
{
    if ([self.delegate respondsToSelector:@selector(messageViewController:selectAtTarget:)] && self.conversation.type == EMConversationTypeGroupChat) {
        location += 1;
        __weak typeof(self) weakSelf = self;
        [self.delegate messageViewController:self selectAtTarget:^(EaseAtTarget *target) {
            __strong EaseMessageViewController *strongSelf = weakSelf;
            if (strongSelf && target) {
                if ([target.userId length] || [target.nickname length]) {
                    [strongSelf.atTargets addObject:target];
                    NSString *insertStr = [NSString stringWithFormat:@"%@ ", target.nickname ? target.nickname : target.userId];
                    EaseChatToolbar *toolbar = (EaseChatToolbar*)strongSelf.chatToolbar;
                    NSMutableString *originStr = [toolbar.inputTextView.text mutableCopy];
                    NSUInteger insertLocation = location > originStr.length ? originStr.length : location;
                    [originStr insertString:insertStr atIndex:insertLocation];
                    toolbar.inputTextView.text = originStr;
                    toolbar.inputTextView.selectedRange = NSMakeRange(insertLocation + insertStr.length, 0);
                    [toolbar.inputTextView becomeFirstResponder];
                }
            }
            else if (strongSelf) {
                EaseChatToolbar *toolbar = (EaseChatToolbar*)strongSelf.chatToolbar;
                [toolbar.inputTextView becomeFirstResponder];
            }
        }];
        EaseChatToolbar *toolbar = (EaseChatToolbar*)self.chatToolbar;
        toolbar.inputTextView.text = [NSString stringWithFormat:@"%@@", toolbar.inputTextView.text];
        [toolbar.inputTextView resignFirstResponder];
        return YES;
    }
    else {
        return NO;
    }
}

- (BOOL)didDeleteCharacterFromLocation:(NSUInteger)location
{
    EaseChatToolbar *toolbar = (EaseChatToolbar*)self.chatToolbar;
    if ([toolbar.inputTextView.text length] == location + 1) {
        //delete last character
        NSString *inputText = toolbar.inputTextView.text;
        NSRange range = [inputText rangeOfString:@"@" options:NSBackwardsSearch];
        if (range.location != NSNotFound) {
            if (location - range.location > 1) {
                NSString *sub = [inputText substringWithRange:NSMakeRange(range.location + 1, location - range.location - 1)];
                for (EaseAtTarget *target in self.atTargets) {
                    if ([sub isEqualToString:target.userId] || [sub isEqualToString:target.nickname]) {
                        inputText = range.location > 0 ? [inputText substringToIndex:range.location] : @"";
                        toolbar.inputTextView.text = inputText;
                        toolbar.inputTextView.selectedRange = NSMakeRange(inputText.length, 0);
                        [self.atTargets removeObject:target];
                        return YES;
                    }
                }
            }
        }
    }
    return NO;
}

- (void)didSendText:(NSString *)text withExt:(NSDictionary*)ext
{
    if ([ext objectForKey:EASEUI_EMOTION_DEFAULT_EXT]) {
        EaseEmotion *emotion = [ext objectForKey:EASEUI_EMOTION_DEFAULT_EXT];
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(emotionExtFormessageViewController:easeEmotion:)]) {
            NSDictionary *ext = [self.dataSource emotionExtFormessageViewController:self easeEmotion:emotion];
            [self sendTextMessage:emotion.emotionTitle withExt:ext];
        } else {
            [self sendTextMessage:emotion.emotionTitle withExt:@{MESSAGE_ATTR_EXPRESSION_ID:emotion.emotionId,MESSAGE_ATTR_IS_BIG_EXPRESSION:@(YES)}];
        }
        return;
    }
    if (text && text.length > 0) {
        [self sendTextMessage:text withExt:ext];
    }
}

- (void)didStartRecordingVoiceAction:(UIView *)recordView
{
    if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectRecordView:withEvenType:)]) {
        [self.delegate messageViewController:self didSelectRecordView:recordView withEvenType:EaseRecordViewTypeTouchDown];
    } else {
        if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
            [(EaseRecordView *)self.recordView recordButtonTouchDown];
        }
    }
    
    [self _canRecordCompletion:^(EMRecordResponse recordResponse) {
        // 如果是第一次请求权限会有弹窗，这个时候按钮已经释放了
        if (self.chatToolbar.recordButton.state == UIControlStateNormal) {
            [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
            return;
        }
        switch (recordResponse) {
            case EMRequestRecord:
                break;
            case EMCanRecord:
            {
                _isRecording = YES;
                [recordView removeFromSuperview];
                EaseRecordView *tmpView = (EaseRecordView *)recordView;
                tmpView.center = self.view.center;
                [self.view addSubview:tmpView];
                [self.view bringSubviewToFront:recordView];
                int x = arc4random() % 100000;
                NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
                NSString *fileName = [NSString stringWithFormat:@"%d%d",(int)time,x];
                
                [[EMCDDeviceManager sharedInstance] asyncStartRecordingWithFileName:fileName completion:^(NSError *error)
                 {
                     if (error) {
                         NSLog(@"%@",NSEaseLocalizedString(@"message.startRecordFail", @"failure to start recording"));
                         [[NSNotificationCenter defaultCenter]postNotificationName:@"com.ts-plus.notification.name.chat.showNotice" object:@{@"msg":@"录音失败,请稍后重试!"}];
                         _isRecording = NO;
                     }
                 }];
            }
                break;
            case EMCanNotRecord:
            {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"com.ts-plus.notification.name.chat.showNotice" object:@{@"msg":@"没有录音权限,请在设置中开启!"}];
            }
                break;
            default:
                break;
        }
    }];
}

- (void)didCancelRecordingVoiceAction:(UIView *)recordView
{
    if(_isRecording) {
        [[EMCDDeviceManager sharedInstance] cancelCurrentRecording];
        if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectRecordView:withEvenType:)]) {
            [self.delegate messageViewController:self didSelectRecordView:recordView withEvenType:EaseRecordViewTypeTouchUpOutside];
        } else {
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView recordButtonTouchUpOutside];
            }
            [self.recordView removeFromSuperview];
        }
        _isRecording = NO;
    } else {
        [self.recordView removeFromSuperview];
    }
}

- (void)didFinishRecoingVoiceAction:(UIView *)recordView
{
    if (_isRecording) {
        if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectRecordView:withEvenType:)]) {
            [self.delegate messageViewController:self didSelectRecordView:recordView withEvenType:EaseRecordViewTypeTouchUpInside];
        } else {
            if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
                [(EaseRecordView *)self.recordView recordButtonTouchUpInside];
            }
            [self.recordView removeFromSuperview];
        }
        __weak typeof(self) weakSelf = self;
        [[EMCDDeviceManager sharedInstance] asyncStopRecordingWithCompletion:^(NSString *recordPath, NSInteger aDuration, NSError *error) {
            if (!error) {
                [weakSelf sendVoiceMessageWithLocalPath:recordPath duration:aDuration];
            }
            else {
                [weakSelf showHudInView:self.view hint:error.domain];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakSelf hideHud];
                });
            }
        }];
        _isRecording = NO;
    } else {
        [self.recordView removeFromSuperview];
    }
}

- (void)didDragInsideAction:(UIView *)recordView
{
    if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectRecordView:withEvenType:)]) {
        [self.delegate messageViewController:self didSelectRecordView:recordView withEvenType:EaseRecordViewTypeDragInside];
    } else {
        if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
            [(EaseRecordView *)self.recordView recordButtonDragInside];
        }
    }
}

- (void)didDragOutsideAction:(UIView *)recordView
{
    if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectRecordView:withEvenType:)]) {
        [self.delegate messageViewController:self didSelectRecordView:recordView withEvenType:EaseRecordViewTypeDragOutside];
    } else {
        if ([self.recordView isKindOfClass:[EaseRecordView class]]) {
            [(EaseRecordView *)self.recordView recordButtonDragOutside];
        }
    }
}

#pragma mark - EaseChatBarMoreViewDelegate

- (void)moreView:(EaseChatBarMoreView *)moreView didItemInMoreViewAtIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(messageViewController:didSelectMoreView:AtIndex:)]) {
        [self.delegate messageViewController:self didSelectMoreView:moreView AtIndex:index];
        return;
    }
}

- (void)moreViewPhotoAction:(EaseChatBarMoreView *)moreView
{
    // Hide the keyboard
    [self.chatToolbar endEditing:YES];
    // 只能传一张图
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc]initWithMaxImagesCount:1 columnNumber:4 delegate:self];
    imagePickerVc.maxImagesCount = 1;
    imagePickerVc.allowPickingGif = YES;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingOriginalPhoto = YES;
    imagePickerVc.allowPickingMultipleVideo = YES;
    imagePickerVc.isSelectOriginalPhoto = YES;
    imagePickerVc.sortAscendingByModificationDate = NO;
    // 顶部title样式调整
    NSDictionary *styleDic = @{NSForegroundColorAttributeName: [UIColor blackColor]};
    imagePickerVc.navigationBar.titleTextAttributes = styleDic;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        PHAsset* aAsset = assets[0];
        [[PHImageManager defaultManager] requestImageDataForAsset:aAsset options:nil resultHandler:^(NSData *data, NSString *uti, UIImageOrientation orientation, NSDictionary *dic) {
            // 判断是否是GIF
            // 如果是GIF就需要上传原始data
            // 如果不是GIF的图片，就压缩一下,原始的二进制流不能直接上传，非iOS/macOS系统打不开
            // 但是100%的转换图片会很大
            if ([uti isEqualToString:kUTTypeGIF]) {
                [self sendImageMessageWithData:data mimeType:@"image/gif"];
            } else {
                UIImage *originalImage = [UIImage imageWithData:data];
                data = UIImageJPEGRepresentation(originalImage, 0.85);
                [self sendImageMessageWithData:data mimeType:@"image/jpeg"];
            }
        }];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    self.isViewDidAppear = NO;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:YES];
}

- (void)moreViewTakePicAction:(EaseChatBarMoreView *)moreView
{
    // Hide the keyboard
    [self.chatToolbar endEditing:YES];
    
#if TARGET_IPHONE_SIMULATOR
    [self showHint:NSEaseLocalizedString(@"message.simulatorNotSupportCamera", @"simulator does not support taking picture")];
#elif TARGET_OS_IPHONE
    self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
    [self presentViewController:self.imagePicker animated:YES completion:NULL];
    
    self.isViewDidAppear = NO;
    [[EaseSDKHelper shareHelper] setIsShowingimagePicker:YES];
#endif
}

- (void)moreViewLocationAction:(EaseChatBarMoreView *)moreView
{
    // Hide the keyboard
    [self.chatToolbar endEditing:YES];
    TSMessageLocationViewController *locationController = [[TSMessageLocationViewController alloc] init];
    locationController.sendBlock = ^(AMapPOI * _Nullable model, UIImage * _Nullable image) {
        [self sendLocationV2Latitude:model.location.latitude longitude:model.location.longitude address:model.address title:model.name image:image];
    };
   locationController.title = self.roomTitle;
   [self.navigationController pushViewController:locationController animated:YES];
    
    
}

- (void)moreViewAudioCallAction:(EaseChatBarMoreView *)moreView
{
    // Hide the keyboard
    [self.chatToolbar endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":self.conversation.conversationId, @"type":[NSNumber numberWithInt:0]}];
}

- (void)moreViewVideoCallAction:(EaseChatBarMoreView *)moreView
{
    // Hide the keyboard
    [self.chatToolbar endEditing:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_CALL object:@{@"chatter":self.conversation.conversationId, @"type":[NSNumber numberWithInt:1]}];
}

#pragma mark - EMLocationViewDelegate

-(void)sendLocationLatitude:(double)latitude
                  longitude:(double)longitude
                 andAddress:(NSString *)address
{
    [self sendLocationMessageLatitude:latitude longitude:longitude andAddress:address];
}

#pragma mark - Hyphenate

#pragma mark - EMChatManagerDelegate

- (void)didReceiveMessages:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages) {
        NSLog(@"EMMessage --%@\n\n",aMessages);
        if ([self.conversation.conversationId isEqualToString:message.conversationId]) {
            [self addMessageToDataSource:message progress:nil];
            EaseMessageModel *model = [[EaseMessageModel alloc] initWithMessage:message];
            if(model.bodyType == EMMessageBodyTypeText || model.bodyType == EMMessageBodyTypeLocation) {
                // TS+ 当前不需要显示"已读"，所以不发送已读回执
//                //文字内容，直接已读
//                [[EMClient sharedClient].chatManager sendMessageReadAck:message completion:^(EMMessage *message, EMError *error) {
//                    if (!error) {
//                        NSLog(@"发送成功");
//                    }
//                }];
            }
            else {
                [self _sendHasReadResponseForMessages:@[message] isRead:NO];
            }
            if ([self _shouldMarkMessageAsRead])
            {
                [self.conversation markMessageAsReadWithId:message.messageId error:nil];
            }
            // 如果是群管理消息，需要更新一下群信息
            if (model.message.chatType == EMChatTypeGroupChat && [model.message.from isEqualToString:@"admin"]) {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"com.ts-plus.notification.name.chat.uploadGrupInfo" object:nil];
            }
        }
    }
}

- (void)didReceiveCmdMessages:(NSArray *)aCmdMessages
{
    for (EMMessage *message in aCmdMessages) {
        if ([self.conversation.conversationId isEqualToString:message.conversationId]) {
            [self showHint:NSEaseLocalizedString(@"receiveCmd", @"receive cmd message")];
            break;
        }
    }
}

- (void)didReceiveHasDeliveredAcks:(NSArray *)aMessages
{
    for(EMMessage *message in aMessages){
        [self _updateMessageStatus:message];
    }
}

- (void)didReceiveHasReadAcks:(NSArray *)aMessages
{
    for (EMMessage *message in aMessages) {
        if (![self.conversation.conversationId isEqualToString:message.conversationId]){
            continue;
        }
        
        __block id<IMessageModel> model = nil;
        __block BOOL isHave = NO;
        [self.dataArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
         {
             if ([obj conformsToProtocol:@protocol(IMessageModel)])
             {
                 model = (id<IMessageModel>)obj;
                 if ([model.messageId isEqualToString:message.messageId])
                 {
                     model.message.isReadAcked = YES;
                     isHave = YES;
                     *stop = YES;
                 }
             }
         }];
        
        if(!isHave){
            return;
        }
        
        if (_delegate && [_delegate respondsToSelector:@selector(messageViewController:didReceiveHasReadAckForModel:)]) {
            [_delegate messageViewController:self didReceiveHasReadAckForModel:model];
        }
        else{
            [self.tableView reloadData];
        }
    }
}

- (void)didMessageStatusChanged:(EMMessage *)aMessage
                          error:(EMError *)aError;
{
    [self _updateMessageStatus:aMessage];
}

- (void)didMessageAttachmentsStatusChanged:(EMMessage *)message
                                     error:(EMError *)error{
    if (!error) {
        EMFileMessageBody *fileBody = (EMFileMessageBody*)[message body];
        if ([fileBody type] == EMMessageBodyTypeImage) {
            EMImageMessageBody *imageBody = (EMImageMessageBody *)fileBody;
            if ([imageBody thumbnailDownloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody type] == EMMessageBodyTypeVideo){
            EMVideoMessageBody *videoBody = (EMVideoMessageBody *)fileBody;
            if ([videoBody thumbnailDownloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }else if([fileBody type] == EMMessageBodyTypeVoice){
            if ([fileBody downloadStatus] == EMDownloadStatusSuccessed)
            {
                [self _reloadTableViewDataWithMessage:message];
            }
        }
        
    }else{
        
    }
}

#pragma mark - EMCDDeviceManagerProximitySensorDelegate

- (void)proximitySensorChanged:(BOOL)isCloseToUser
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (isCloseToUser)
    {
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    } else {
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        if (self.playingVoiceModel == nil) {
            [[EMCDDeviceManager sharedInstance] disableProximitySensor];
        }
    }
    [audioSession setActive:YES error:nil];
}

#pragma mark - action

- (void)copyMenuAction:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        pasteboard.string = model.text;
    }
    
    self.menuIndexPath = nil;
}

- (void)deleteMenuAction:(id)sender
{
    if (self.menuIndexPath && self.menuIndexPath.row > 0) {
        id<IMessageModel> model = [self.dataArray objectAtIndex:self.menuIndexPath.row];
        NSMutableIndexSet *indexs = [NSMutableIndexSet indexSetWithIndex:self.menuIndexPath.row];
        NSMutableArray *indexPaths = [NSMutableArray arrayWithObjects:self.menuIndexPath, nil];
        
        [self.conversation deleteMessageWithId:model.message.messageId error:nil];
        [self.messsagesSource removeObject:model.message];
        
        if (self.menuIndexPath.row - 1 >= 0) {
            id nextMessage = nil;
            id prevMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row - 1)];
            if (self.menuIndexPath.row + 1 < [self.dataArray count]) {
                nextMessage = [self.dataArray objectAtIndex:(self.menuIndexPath.row + 1)];
            }
            if ((!nextMessage || [nextMessage isKindOfClass:[NSString class]]) && [prevMessage isKindOfClass:[NSString class]]) {
                [indexs addIndex:self.menuIndexPath.row - 1];
                [indexPaths addObject:[NSIndexPath indexPathForRow:(self.menuIndexPath.row - 1) inSection:0]];
            }
        }
        
        [self.dataArray removeObjectsAtIndexes:indexs];
        [self.tableView beginUpdates];
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView endUpdates];
    }
    
    self.menuIndexPath = nil;
}

#pragma mark - public

- (NSArray *)formatMessages:(NSArray *)messages
{
    NSMutableArray *formattedArray = [[NSMutableArray alloc] init];
    if ([messages count] == 0) {
        return formattedArray;
    }
    
    for (EMMessage *message in messages) {
        //Calculate time interval
        CGFloat interval = (self.messageTimeIntervalTag - message.timestamp) / 1000;
        if (self.messageTimeIntervalTag < 0 || interval > 60 * 6 || interval < -60*6) {
            NSDate *messageDate = [NSDate dateWithTimeIntervalInMilliSecondSince1970:(NSTimeInterval)message.timestamp];
            // 使用TS的时间戳
            TSDate *timeDate = [[TSDate alloc]init];
            NSString* timeStr = [timeDate dateString:DateTypeDetail nsDate:messageDate];
            [formattedArray addObject:timeStr];
            self.messageTimeIntervalTag = message.timestamp;
        }
        
        //Construct message model
        id<IMessageModel> model = nil;
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:modelForMessage:)]) {
            model = [_dataSource messageViewController:self modelForMessage:message];
        }
        else{
            model = [[EaseMessageModel alloc] initWithMessage:message];
            model.avatarImage = [UIImage imageNamed:@"IMG_pic_default_secret"];
            model.failImageName = @"imageDownloadFail";
        }
        
        if (model) {
            [formattedArray addObject:model];
        }
    }
    
    return formattedArray;
}

-(void)addMessageToDataSource:(EMMessage *)message
                     progress:(id)progress
{
    [self.messsagesSource addObject:message];
    __weak EaseMessageViewController *weakSelf = self;
    dispatch_async(_messageQueue, ^{
        NSArray *messages = [weakSelf formatMessages:@[message]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.dataArray addObjectsFromArray:messages];
            [weakSelf.tableView reloadData];
            [weakSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[weakSelf.dataArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
    });
}

#pragma mark - public
- (void)tableViewDidTriggerHeaderRefresh
{
    self.messageTimeIntervalTag = -1;
    NSString *messageId = nil;
    if ([self.messsagesSource count] > 0) {
        messageId = [(EMMessage *)self.messsagesSource.firstObject messageId];
    }
    else {
        messageId = nil;
    }
    [self _loadMessagesBefore:messageId count:self.messageCountOfPage append:YES];
    
    [self tableViewDidFinishTriggerHeader:YES reload:YES];
}

#pragma mark - 清空历史消息（TS+）
- (void)cleanAllMassage {
    [self.messsagesSource removeAllObjects];
    [self.dataArray removeAllObjects];
    [self.tableView reloadData];
    [self tableViewDidFinishTriggerHeader:YES reload:YES];
}

#pragma mark - 通话结束后刷新页面数据（TS+）
- (void)callEndReloadData {
    [self.messsagesSource removeAllObjects];
    [self.dataArray removeAllObjects];
    [self _loadMessagesBefore:nil count:self.messageCountOfPage append:YES];
    
    [self tableViewDidFinishTriggerHeader:YES reload:YES];
}

#pragma mark - send message

- (void)refreshAfterSentMessage:(EMMessage*)aMessage
{
    if ([self.messsagesSource count] && [EMClient sharedClient].options.sortMessageByServerTime) {
        NSString *msgId = aMessage.messageId;
        EMMessage *last = self.messsagesSource.lastObject;
        if ([last isKindOfClass:[EMMessage class]]) {
            
            __block NSUInteger index = NSNotFound;
            index = NSNotFound;
            [self.messsagesSource enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(EMMessage *obj, NSUInteger idx, BOOL *stop) {
                if ([obj isKindOfClass:[EMMessage class]] && [obj.messageId isEqualToString:msgId]) {
                    index = idx;
                    *stop = YES;
                }
            }];
            if (index != NSNotFound) {
                [self.messsagesSource removeObjectAtIndex:index];
                [self.messsagesSource addObject:aMessage];
                
                //格式化消息
                self.messageTimeIntervalTag = -1;
                NSArray *formattedMessages = [self formatMessages:self.messsagesSource];
                [self.dataArray removeAllObjects];
                [self.dataArray addObjectsFromArray:formattedMessages];
                [self.tableView reloadData];
                [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.dataArray count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                return;
            }
        }
    }
    [self.tableView reloadData];
}

- (void)_sendMessage:(EMMessage *)message
    isNeedUploadFile:(BOOL)isUploadFile
{
    if (self.conversation.type == EMConversationTypeGroupChat){
        message.chatType = EMChatTypeGroupChat;
    }
    else if (self.conversation.type == EMConversationTypeChatRoom){
        message.chatType = EMChatTypeChatRoom;
    }
    __weak typeof(self) weakself = self;
    if (!([EMClient sharedClient].options.isAutoTransferMessageAttachments) && isUploadFile) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"message.autoTransfer", @"Please customize the transfer attachment method") delegate:nil cancelButtonTitle:NSLocalizedString(@"sure", @"OK") otherButtonTitles:nil, nil];
        [alertView show];
    } else {
        [self addMessageToDataSource:message
                            progress:nil];
        
        [[EMClient sharedClient].chatManager sendMessage:message progress:^(int progress) {
            if (weakself.dataSource && [weakself.dataSource respondsToSelector:@selector(messageViewController:updateProgress:messageModel:messageBody:)]) {
                [weakself.dataSource messageViewController:weakself updateProgress:progress messageModel:nil messageBody:message.body];
            }
        } completion:^(EMMessage *aMessage, EMError *aError) {
            if (!aError) {
                [weakself refreshAfterSentMessage:aMessage];
            }
            else {
                [weakself.tableView reloadData];
            }
        }];
    }
}

- (void)sendTextMessage:(NSString *)text
{
    NSDictionary *ext = nil;
    if (self.conversation.type == EMConversationTypeGroupChat) {
        NSArray *targets = [self _searchAtTargets:text];
        if ([targets count]) {
            __block BOOL atAll = NO;
            [targets enumerateObjectsUsingBlock:^(NSString *target, NSUInteger idx, BOOL *stop) {
                if ([target compare:kGroupMessageAtAll options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                    atAll = YES;
                    *stop = YES;
                }
            }];
            if (atAll) {
                ext = @{kGroupMessageAtList: kGroupMessageAtAll};
            }
            else {
                ext = @{kGroupMessageAtList: targets};
            }
        }
    }
    [self sendTextMessage:text withExt:ext];
}

- (void)sendTextMessage:(NSString *)text withExt:(NSDictionary*)ext
{
   
//    NSString *replace = [text stringByReplacingOccurrencesOfString:@" " withString:@""];
    /// 增加离线推送显示字段
    NSMutableDictionary *sendExt = [[NSMutableDictionary alloc]initWithDictionary:ext];
    NSMutableDictionary *apnsDic = [[NSMutableDictionary alloc]init];
    [apnsDic setValue:@"ThinkSNSPlus" forKey: @"em_push_name"];
    NSString *currentName = [[NSUserDefaults standardUserDefaults] stringForKey: @"TSCurrentUserInfoModel.name"];
    [apnsDic setValue:[NSString stringWithFormat:@"%@:%@", currentName, text] forKey:@"em_push_content"];
    [sendExt setValue:apnsDic forKey: @"em_apns_ext"];

    NSString *replace = [text stringByTrimmingCharactersInSet:
                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (replace.length <= 0 || [replace isEqualToString:@""]) {
        return;
    }
    if (replace.length > singleMsgMaxWordCount) {
        EaseChatToolbar *toolbar = (EaseChatToolbar*)self.chatToolbar;
        toolbar.inputTextView.text = [NSString stringWithFormat:@"%@@", toolbar.inputTextView.text];
        [toolbar.inputTextView resignFirstResponder];
        [self showHint:[NSString stringWithFormat:@"不能超过%ld字",singleMsgMaxWordCount]];
        return;
    }
    EMMessage *message = [EaseSDKHelper getTextMessage:replace to:self.conversation.conversationId messageType:[self _messageTypeFromConversationType] messageExt:sendExt];
    [self _sendMessage:message isNeedUploadFile:NO];
}

- (void)sendLocationMessageLatitude:(double)latitude
                          longitude:(double)longitude
                         andAddress:(NSString *)address
{
    EMMessage *message = [EaseSDKHelper getLocationMessageWithLatitude:latitude longitude:longitude address:address to:self.conversation.conversationId messageType:[self _messageTypeFromConversationType] messageExt:nil];
    [self _sendMessage:message isNeedUploadFile:NO];
}
//MARK: -新版本通过图片方式发送定位
- (void)sendLocationV2Latitude:(double)latitude longitude:(double)longitude address:(NSString *)address title:(NSString *)title image:(UIImage *)image {
    id progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:EMMessageBodyTypeImage];
    }
    else{
        progress = self;
    }
    NSDictionary *locationInfo = @{@"image": @"1", @"address": address, @"title": title, @"latitude": [NSString stringWithFormat:@"%f",latitude], @"longitude": [NSString stringWithFormat:@"%f",longitude]};
    /// 增加离线推送显示字段
    NSMutableDictionary *sendExt = [[NSMutableDictionary alloc]initWithDictionary:locationInfo];
    NSMutableDictionary *apnsDic = [[NSMutableDictionary alloc]init];
    [apnsDic setValue:@"ThinkSNSPlus" forKey: @"em_push_name"];
    NSString *currentName = [[NSUserDefaults standardUserDefaults] stringForKey: @"TSCurrentUserInfoModel.name"];
    [apnsDic setValue:[NSString stringWithFormat:@"%@:%@", currentName, @"发来一条位置消息"] forKey:@"em_push_content"];
    [sendExt setValue:apnsDic forKey: @"em_apns_ext"];

    EMMessage *message = [EaseSDKHelper getImageMessageWithImage:image to:self.conversation.conversationId messageType:[self _messageTypeFromConversationType] messageExt:sendExt];
    [self _sendMessage:message isNeedUploadFile:YES];
}

- (void)sendLocationV2Latitude:(double)latitude longitude:(double)longitude address:(NSString *)address title:(NSString *)title image:(UIImage *)image uid:(NSString *)uid {
    id progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:EMMessageBodyTypeImage];
    }
    else{
        progress = self;
    }
    NSDictionary *locationInfo = @{@"image": @"1", @"address": address, @"title": title, @"latitude": [NSString stringWithFormat:@"%f",latitude], @"longitude": [NSString stringWithFormat:@"%f",longitude]};
    /// 增加离线推送显示字段
    NSMutableDictionary *sendExt = [[NSMutableDictionary alloc]initWithDictionary:locationInfo];
    NSMutableDictionary *apnsDic = [[NSMutableDictionary alloc]init];
    [apnsDic setValue:@"ThinkSNSPlus" forKey: @"em_push_name"];
    NSString *currentName = [[NSUserDefaults standardUserDefaults] stringForKey: @"TSCurrentUserInfoModel.name"];
    [apnsDic setValue:[NSString stringWithFormat:@"%@:%@", currentName, @"发来一条位置消息"] forKey:@"em_push_content"];
    [sendExt setValue:apnsDic forKey: @"em_apns_ext"];
    EMMessage *message = [EaseSDKHelper getImageMessageWithImage:image to:uid messageType:[self _messageTypeFromConversationType] messageExt:sendExt];
    [self _sendMessage:message isNeedUploadFile:YES];
}


- (void)sendImageMessageWithData:(NSData *)imageData
{
    id progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:EMMessageBodyTypeImage];
    }
    else{
        progress = self;
    }
    /// 增加离线推送显示字段
    NSMutableDictionary *sendExt = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *apnsDic = [[NSMutableDictionary alloc]init];
    [apnsDic setValue:@"ThinkSNSPlus" forKey: @"em_push_name"];
    NSString *currentName = [[NSUserDefaults standardUserDefaults] stringForKey: @"TSCurrentUserInfoModel.name"];
    [apnsDic setValue:[NSString stringWithFormat:@"%@:%@", currentName, @"发来一条图片消息"] forKey:@"em_push_content"];
    [sendExt setValue:apnsDic forKey: @"em_apns_ext"];
    
    EMMessage *message = [EaseSDKHelper getImageMessageWithImageData:imageData to:self.conversation.conversationId messageType:[self _messageTypeFromConversationType] messageExt:sendExt];
    [self _sendMessage:message isNeedUploadFile:YES];
}
// MARK: -TS 增加方法
- (void)sendImageMessageWithData:(NSData *)imageData mimeType: (NSString *)mimeType
{
    id progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:EMMessageBodyTypeImage];
    }
    else{
        progress = self;
    }
    NSDictionary *imageDic = @{@"mimeType": @"image/gif"};
    /// 增加离线推送显示字段
    NSMutableDictionary *sendExt = [[NSMutableDictionary alloc]initWithDictionary:imageDic];
    NSMutableDictionary *apnsDic = [[NSMutableDictionary alloc]init];
    [apnsDic setValue:@"ThinkSNSPlus" forKey: @"em_push_name"];
    NSString *currentName = [[NSUserDefaults standardUserDefaults] stringForKey: @"TSCurrentUserInfoModel.name"];
    [apnsDic setValue:[NSString stringWithFormat:@"%@:%@", currentName, @"发来一条图片消息"] forKey:@"em_push_content"];
    [sendExt setValue:apnsDic forKey: @"em_apns_ext"];
    EMMessage *message = [EaseSDKHelper getImageMessageWithImageData:imageData to:self.conversation.conversationId messageType:[self _messageTypeFromConversationType] messageExt:sendExt];
    [self _sendMessage:message isNeedUploadFile:YES];
}



- (void)sendImageMessage:(UIImage *)image
{
    id progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:EMMessageBodyTypeImage];
    }
    else{
        progress = self;
    }
    
    EMMessage *message = [EaseSDKHelper getImageMessageWithImage:image to:self.conversation.conversationId messageType:[self _messageTypeFromConversationType] messageExt:nil];
    [self _sendMessage:message isNeedUploadFile:YES];
}

- (void)sendVoiceMessageWithLocalPath:(NSString *)localPath
                             duration:(NSInteger)duration
{
    id progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:EMMessageBodyTypeVoice];
    }
    else{
        progress = self;
    }
    /// 增加离线推送显示字段
    NSMutableDictionary *sendExt = [[NSMutableDictionary alloc]init];
    NSMutableDictionary *apnsDic = [[NSMutableDictionary alloc]init];
    [apnsDic setValue:@"ThinkSNSPlus" forKey: @"em_push_name"];
    NSString *currentName = [[NSUserDefaults standardUserDefaults] stringForKey: @"TSCurrentUserInfoModel.name"];
    [apnsDic setValue:[NSString stringWithFormat:@"%@:%@", currentName, @"发来一条语音消息"] forKey:@"em_push_content"];
    [sendExt setValue:apnsDic forKey: @"em_apns_ext"];
    EMMessage *message = [EaseSDKHelper getVoiceMessageWithLocalPath:localPath duration:duration to:self.conversation.conversationId messageType:[self _messageTypeFromConversationType] messageExt:sendExt];
    [self _sendMessage:message isNeedUploadFile:YES];
}

- (void)sendVideoMessageWithURL:(NSURL *)url
{
    id progress = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:progressDelegateForMessageBodyType:)]) {
        progress = [_dataSource messageViewController:self progressDelegateForMessageBodyType:EMMessageBodyTypeVideo];
    }
    else{
        progress = self;
    }
    
    EMMessage *message = [EaseSDKHelper getVideoMessageWithURL:url to:self.conversation.conversationId messageType:[self _messageTypeFromConversationType] messageExt:nil];
    [self _sendMessage:message isNeedUploadFile:YES];
}

- (void)sendFileMessageWith:(EMMessage *)message {
    [self _sendMessage:message isNeedUploadFile:YES];
}

#pragma mark - notifycation
- (void)didBecomeActive
{
    self.messageTimeIntervalTag = -1;
    self.dataArray = [[self formatMessages:self.messsagesSource] mutableCopy];
    [self.tableView reloadData];
    
    if (self.isViewDidAppear)
    {
        NSMutableArray *unreadMessages = [NSMutableArray array];
        for (EMMessage *message in self.messsagesSource)
        {
            if ([self shouldSendHasReadAckForMessage:message read:NO])
            {
                [unreadMessages addObject:message];
            }
        }
        if ([unreadMessages count])
        {
            [self _sendHasReadResponseForMessages:unreadMessages isRead:YES];
        }
        
        [_conversation markAllMessagesAsRead:nil];
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(messageViewControllerMarkAllMessagesAsRead:)]) {
            [self.dataSource messageViewControllerMarkAllMessagesAsRead:self];
        }
    }
}

- (void)hideImagePicker
{
    if (_imagePicker && [EaseSDKHelper shareHelper].isShowingimagePicker) {
        [_imagePicker dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark - private
- (void)_reloadTableViewDataWithMessage:(EMMessage *)message
{
    if ([self.conversation.conversationId isEqualToString:message.conversationId])
    {
        for (int i = 0; i < self.dataArray.count; i ++) {
            id object = [self.dataArray objectAtIndex:i];
            if ([object isKindOfClass:[EaseMessageModel class]]) {
                id<IMessageModel> model = object;
                if ([message.messageId isEqualToString:model.messageId]) {
                    id<IMessageModel> model = nil;
                    if (self.dataSource && [self.dataSource respondsToSelector:@selector(messageViewController:modelForMessage:)]) {
                        model = [self.dataSource messageViewController:self modelForMessage:message];
                    }
                    else{
                        model = [[EaseMessageModel alloc] initWithMessage:message];
                        model.avatarImage = [UIImage imageNamed:@"IMG_pic_default_secret"];
                        model.failImageName = @"imageDownloadFail";
                    }
                    
                    [self.tableView beginUpdates];
                    [self.dataArray replaceObjectAtIndex:i withObject:model];
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                    [self.tableView endUpdates];
                    break;
                }
            }
        }
    }
}

- (void)_updateMessageStatus:(EMMessage *)aMessage
{
    BOOL isChatting = [aMessage.conversationId isEqualToString:self.conversation.conversationId];
    if (aMessage && isChatting) {
        id<IMessageModel> model = nil;
        if (_dataSource && [_dataSource respondsToSelector:@selector(messageViewController:modelForMessage:)]) {
            model = [_dataSource messageViewController:self modelForMessage:aMessage];
        }
        else{
            model = [[EaseMessageModel alloc] initWithMessage:aMessage];
            model.avatarImage = [UIImage imageNamed:@"IMG_pic_default_secret"];
            model.failImageName = @"imageDownloadFail";
        }
        if (model) {
            __block NSUInteger index = NSNotFound;
            [self.dataArray enumerateObjectsUsingBlock:^(EaseMessageModel *model, NSUInteger idx, BOOL *stop){
                if ([model conformsToProtocol:@protocol(IMessageModel)]) {
                    if ([aMessage.messageId isEqualToString:model.message.messageId])
                    {
                        index = idx;
                        *stop = YES;
                    }
                }
            }];
            
            if (index != NSNotFound)
            {
                [self.dataArray replaceObjectAtIndex:index withObject:model];
                [self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                [self.tableView endUpdates];
            }
        }
    }
}

- (NSArray*)_searchAtTargets:(NSString*)text
{
    NSMutableArray *targets = nil;
    if (text.length > 1) {
        targets = [NSMutableArray array];
        NSArray *splits = [text componentsSeparatedByString:@"@"];
        if ([splits count]) {
            for (NSString *split in splits) {
                if (split.length) {
                    NSString *atALl = NSEaseLocalizedString(@"group.atAll", @"all");
                    if (split.length >= atALl.length && [split compare:atALl options:NSCaseInsensitiveSearch range:NSMakeRange(0, atALl.length)] == NSOrderedSame) {
                        [targets removeAllObjects];
                        [targets addObject:kGroupMessageAtAll];
                        return targets;
                    }
                    for (EaseAtTarget *target in self.atTargets) {
                        if ([target.userId length]) {
                            if ([split hasPrefix:target.userId] || (target.nickname && [split hasPrefix:target.nickname])) {
                                [targets addObject:target.userId];
                                [self.atTargets removeObject:target];
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    return targets;
}


@end
