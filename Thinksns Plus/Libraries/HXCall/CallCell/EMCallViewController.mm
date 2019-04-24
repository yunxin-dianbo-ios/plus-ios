//
//  EMCallViewController.m
//  ChatDemo-UI3.0
//
//  Created by XieYajie on 22/11/2016.
//  Copyright © 2016 XieYajie. All rights reserved.
//

#import "EMCallViewController.h"

//#if DEMO_CALL == 1

//#import "EMVideoRecorderPlugin.h"

#import "DemoCallManager.h"
#import "EMVideoInfoViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface EMCallViewController ()

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *remoteNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *remoteImgView;
@property (weak, nonatomic) IBOutlet UIImageView *headerImage;

@property (weak, nonatomic) IBOutlet UIView *actionView;
@property (weak, nonatomic) IBOutlet UIButton *speakerOutButton;
@property (weak, nonatomic) IBOutlet UIButton *silenceButton;
@property (weak, nonatomic) IBOutlet UIButton *minimizeButton;
@property (weak, nonatomic) IBOutlet UIButton *rejectButton;
@property (weak, nonatomic) IBOutlet UIButton *hangupButton;
@property (weak, nonatomic) IBOutlet UIButton *answerButton;
@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *showVideoInfoButton;

@property (strong, nonatomic) AVAudioPlayer *ringPlayer;
@property (nonatomic) int timeLength;
@property (strong, nonatomic) NSTimer *timeTimer;

@end

//#endif

@implementation EMCallViewController

//#if DEMO_CALL == 1

- (instancetype)initWithCallSession:(EMCallSession *)aCallSession
{
    NSString *xibName = @"EMCallViewController";
    self = [super initWithNibName:xibName bundle:nil];
    if (self) {
        _callSession = aCallSession;
        _isDismissing = NO;
        
        if (aCallSession.type == EMCallTypeVideo) {
            AVAudioSession *audioSession = [AVAudioSession sharedInstance];
            [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
            BOOL ret = [audioSession setActive:NO error:nil];
            if (!ret) {
                NSLog(@"1234567");
            }
        }
    }
    
    return self;
}

//#endif

- (void)viewDidLoad {
    
    
    self.headerImage.layer.cornerRadius = 50;
    self.headerImage.clipsToBounds = YES;
    
    if (self.isDismissing) {
        return;
    }
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//#if DEMO_CALL == 1
    
    [self _layoutSubviews];
    
//#endif
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    if (self.isDismissing) {
        return;
    }
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.isDismissing) {
        return;
    }
    
    [super viewDidAppear:animated];
}

//#if DEMO_CALL == 1

#pragma mark - private

- (void)_layoutSubviews
{
    [self.silenceButton setImage:[UIImage imageNamed:@"btn_chat_mute_on"] forState:UIControlStateSelected];
    self.timeLabel.hidden = YES;
    [self getFaceCover:self.userInfo];
    BOOL isCaller = self.callSession.isCaller;
    switch (self.callSession.type) {
        case EMCallTypeVoice:
        {
            [self.speakerOutButton setImage:[UIImage imageNamed:@"btn_chat_handsfree_on"] forState:UIControlStateSelected];
            if (isCaller) {
                self.rejectButton.hidden = YES;
                self.answerButton.hidden = YES;
            } else {
                self.hangupButton.hidden = YES;
            }
        }
            break;
        case EMCallTypeVideo:
        {
            [self.switchCameraButton setImage:[UIImage imageNamed:@"btn_chat_camera_on"] forState:UIControlStateSelected];
            self.showVideoInfoButton.hidden = NO;
            self.speakerOutButton.hidden = YES;
            self.switchCameraButton.hidden = NO;
            
            if (isCaller) {
                self.rejectButton.hidden = YES;
                self.answerButton.hidden = YES;
            } else {
                self.hangupButton.hidden = YES;
            }
            
            [self _setupLocalVideoView];
//            [self.view bringSubviewToFront:self.topView];
//            [self.view bringSubviewToFront:self.actionView];
        }
            break;
            
        default:
            break;
    }
}

- (void)_setupRemoteVideoView
{
    if (self.callSession.type == EMCallTypeVideo && self.callSession.remoteVideoView == nil) {
        self.callSession.remoteVideoView = [[EMCallRemoteView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.callSession.remoteVideoView.hidden = YES;
        self.callSession.remoteVideoView.backgroundColor = [UIColor clearColor];
        self.callSession.remoteVideoView.scaleMode = EMCallViewScaleModeAspectFill;
        [self.view addSubview:self.callSession.remoteVideoView];
        [self.view sendSubviewToBack:self.callSession.remoteVideoView];
        
        __weak EMCallViewController *weakSelf = self;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            weakSelf.callSession.remoteVideoView.hidden = NO;
        });
    }
}

- (void)_setupLocalVideoView
{
    //2.自己窗口
    CGFloat width = 80;
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGFloat height = size.height / size.width * width;
    self.callSession.localVideoView = [[EMCallLocalView alloc] initWithFrame:CGRectMake(size.width - width - 20, 20, width, height)];
    [self.view addSubview:self.callSession.localVideoView];
    [self.view bringSubviewToFront:self.callSession.localVideoView];
}

#pragma mark - private ring

- (void)_beginRing
{
    [self.ringPlayer stop];
    
    NSString *musicPath = [[NSBundle mainBundle] pathForResource:@"callRing" ofType:@"mp3"];
    NSURL *url = [[NSURL alloc] initFileURLWithPath:musicPath];
    
    self.ringPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [self.ringPlayer setVolume:1];
    self.ringPlayer.numberOfLoops = -1; //设置音乐播放次数  -1为一直循环
    if([self.ringPlayer prepareToPlay])
    {
        [self.ringPlayer play]; //播放
    }
}

- (void)_stopRing
{
    [self.ringPlayer stop];
}

#pragma mark - private timer

- (void)timeTimerAction:(id)sender
{
    self.timeLength += 1;
    int hour = self.timeLength / 3600;
    int m = (self.timeLength - hour * 3600) / 60;
    int s = self.timeLength - hour * 3600 - m * 60;
    
    NSString *sstring = [NSString stringWithFormat:@"%i",s];
    if (s<10) {
        sstring = [NSString stringWithFormat:@"0%i",s];
    }
    
    if (hour > 0) {
        
        self.timeLabel.text = [NSString stringWithFormat:@"%i:%i:%@", hour, m, sstring];
    }
    else if(m > 0){
        self.timeLabel.text = [NSString stringWithFormat:@"%i:%@", m, sstring];
    }
    else{
        self.timeLabel.text = [NSString stringWithFormat:@"00:%@", sstring];
    }
}

- (void)_startTimeTimer
{
    self.timeLength = 0;
    self.timeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeTimerAction:) userInfo:nil repeats:YES];
}

- (void)_stopTimeTimer
{
    if (self.timeTimer) {
        [self.timeTimer invalidate];
        self.timeTimer = nil;
    }
}

/**
 获取通话时长
 */
- (NSString *)getCurrentTime {
    return self.timeLabel.text;
}

#pragma mark - action

//- (IBAction)minimizeAction:(id)sender
//{
//    
//}

- (IBAction)speakerOutAction:(id)sender
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if (self.speakerOutButton.selected) {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    }else {
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }
    [audioSession setActive:YES error:nil];
    self.speakerOutButton.selected = !self.speakerOutButton.selected;
}

- (IBAction)silenceAction:(id)sender
{
    self.silenceButton.selected = !self.silenceButton.selected;
    if (self.silenceButton.selected) {
        [self.callSession pauseVoice];
    } else {
        [self.callSession resumeVoice];
    }
}

- (IBAction)switchCameraAction:(id)sender
{
    [self.callSession switchCameraPosition:self.switchCameraButton.selected];
    self.switchCameraButton.selected = !self.switchCameraButton.selected;
}

- (IBAction)showVideoInfoAction:(id)sender
{
    EMVideoInfoViewController *videoInfoController = [[EMVideoInfoViewController alloc] initWithNibName:@"EMVideoInfoViewController" bundle:nil];
    videoInfoController.callSession = self.callSession;
    videoInfoController.currentTime = self.timeLabel.text;
    [videoInfoController startTimer:self.timeLength];
    [self presentViewController:videoInfoController animated:YES completion:nil];
}

- (IBAction)answerAction:(id)sender
{
    [self _stopRing];
    [[DemoCallManager sharedManager] answerCall:self.callSession.callId];
}

- (IBAction)rejectAction:(id)sender
{
    [self _stopTimeTimer];
    [self _stopRing];
    [DemoCallManager sharedManager].isTouchRejectButton = YES;
    [[DemoCallManager sharedManager] hangupCallWithReason:EMCallEndReasonDecline];
}

- (IBAction)hangupAction:(id)sender
{
    [self _stopTimeTimer];
    [self _stopRing];
    
    [[DemoCallManager sharedManager] hangupCallWithReason:EMCallEndReasonHangup];
}

#pragma mark - public

- (void)stateToConnecting
{
    if (self.callSession.isCaller) {
        self.statusLabel.text = @"正在连接对方......";
    } else {
        self.statusLabel.text = @"建立连接中......";
    }
//    self.statusLabel.text = NSLocalizedString(@"call.connecting", "Incomimg call");
}

- (void)stateToConnected
{
    if (!self.callSession.isCaller) {
        // Gron.Yu  响铃中... fix
        if (self.callSession.type == EMCallTypeVoice) {
            self.statusLabel.text = @"邀请你进入语音聊天";
        } else {
            self.statusLabel.text = @"邀请你进入视频聊天";
        }
    } else {
        self.statusLabel.text = @"已经和对方建立连接";
    }
}

- (void)stateToAnswered
{
    [self _startTimeTimer];
    
    if (self.callSession.type == EMCallTypeVideo) {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:nil];
    }
    
//    NSString *connectStr = @"None";
//    if (_callSession.connectType == EMCallConnectTypeRelay) {
//        connectStr = @"Relay";
//    } else if (_callSession.connectType == EMCallConnectTypeDirect) {
//        connectStr = @"Direct";
//    }
//    
//    self.statusLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"call.speak", @"Can speak..."), connectStr];
    // Gron.Yu  通话中/视频中 fix
    if (self.callSession.type == EMCallTypeVideo) {
        self.statusLabel.text = @"视频中......";
    } else {
        self.statusLabel.text = @"通话中......";
    }
    self.timeLabel.hidden = NO;
    self.hangupButton.hidden = NO;
//    self.statusLabel.hidden = YES;
    self.rejectButton.hidden = YES;
    self.answerButton.hidden = YES;
    
    [self _setupRemoteVideoView];
    
//    NSString *recordPath = NSHomeDirectory();
//    recordPath = [NSString stringWithFormat:@"%@/Library/appdata/chatbuffer",recordPath];
//    NSFileManager *fm = [NSFileManager defaultManager];
//    if(![fm fileExistsAtPath:recordPath]) {
//        [fm createDirectoryAtPath:recordPath
//      withIntermediateDirectories:YES
//                       attributes:nil
//                            error:nil];
//    }
//    [[EMVideoRecorderPlugin sharedInstance] startVideoRecordingToFilePath:recordPath error:nil];
}

- (void)clearData
{
//    [[EMVideoRecorderPlugin sharedInstance] stopVideoRecording:nil];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession overrideOutputAudioPort:AVAudioSessionPortOverrideNone error:nil];
    [audioSession setActive:YES error:nil];
    
    self.callSession.remoteVideoView.hidden = YES;
    self.callSession.remoteVideoView = nil;
    _callSession = nil;
    
    [self _stopTimeTimer];
    [self _stopRing];
}

//#endif

// MARK: - 获取单个用户的头像
- (void)getFaceCover:(NSDictionary *)userInfo  {
    self.remoteNameLabel.text = [userInfo objectForKey:@"callName"];
    if ([[userInfo objectForKey:@"callFace"] isEqualToString:@""]) {
        self.headerImage.image = [UIImage imageNamed:@"IMG_pic_default_secret"];
    } else {
        [self.headerImage sd_setImageWithURL:[NSURL URLWithString:[userInfo objectForKey:@"callFace"]] placeholderImage:[UIImage imageNamed:@"IMG_pic_default_secret"]];
    }
}

- (void)setNetwork:(EMCallNetworkStatus)aStatus
{
    if (aStatus == EMCallNetworkStatusUnstable) {
        self.statusLabel.text = @"网络不稳定";
    } else if (aStatus == EMCallNetworkStatusNoData) {
        self.statusLabel.text = @"无数据";
    } else {
        self.statusLabel.text = @"";
    }
}

- (void)setStreamType:(EMCallStreamingStatus)aType
{
    NSString *str = @"Unkonw";
    switch (aType) {
        case EMCallStreamStatusVoicePause:
            str = @"Audio Mute";
            break;
        case EMCallStreamStatusVoiceResume:
            str = @"Audio Unmute";
            break;
        case EMCallStreamStatusVideoPause:
            str = @"Video Pause";
            break;
        case EMCallStreamStatusVideoResume:
            str = @"Video Resume";
            break;
            
        default:
            break;
    }
    // 参考环信Demo中使用MBProgressHUD进行提示
    //[self showHint:str];
}

@end
