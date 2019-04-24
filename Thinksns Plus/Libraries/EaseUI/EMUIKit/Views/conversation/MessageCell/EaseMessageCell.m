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

#import "EaseMessageCell.h"

#import "EaseBubbleView+Text.h"
#import "EaseBubbleView+Image.h"
#import "EaseBubbleView+Location.h"
#import "EaseBubbleView+Voice.h"
#import "EaseBubbleView+Video.h"
#import "EaseBubbleView+File.h"
#import "UIImageView+EMWebCache.h"
#import "EaseEmotionEscape.h"
#import "EaseLocalDefine.h"
#import "IMMessageSourceTool.h"
#import "EaseSDKHelper.h"

CGFloat const EaseMessageCellPadding = 10;

NSString *const EaseMessageCellIdentifierRecvText = @"EaseMessageCellRecvText";
NSString *const EaseMessageCellIdentifierRecvLocation = @"EaseMessageCellRecvLocation";
NSString *const EaseMessageCellIdentifierRecvVoice = @"EaseMessageCellRecvVoice";
NSString *const EaseMessageCellIdentifierRecvVideo = @"EaseMessageCellRecvVideo";
NSString *const EaseMessageCellIdentifierRecvImage = @"EaseMessageCellRecvImage";
NSString *const EaseMessageCellIdentifierRecvFile = @"EaseMessageCellRecvFile";

NSString *const EaseMessageCellIdentifierSendText = @"EaseMessageCellSendText";
NSString *const EaseMessageCellIdentifierSendLocation = @"EaseMessageCellSendLocation";
NSString *const EaseMessageCellIdentifierSendVoice = @"EaseMessageCellSendVoice";
NSString *const EaseMessageCellIdentifierSendVideo = @"EaseMessageCellSendVideo";
NSString *const EaseMessageCellIdentifierSendImage = @"EaseMessageCellSendImage";
NSString *const EaseMessageCellIdentifierSendFile = @"EaseMessageCellSendFile";

#define ReplaceH5String @"≤¬πø∆œ≈"//用来替换前面的h5代码，做富文本
// 可以匹配 http www
#define urlRegixted2 @"((http|https|Http|Https)://|www.|Www.|WWW.)*(([a-zA-Z0-9\\._-]+\\.[a-zA-Z]{2,6})|([0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}))(:[0-9]{1,4})*(/[a-zA-Z0-9\\&%_\\./-~-]*)?"
#define NOTNULL(x) ((![x isKindOfClass:[NSNull class]])&&x)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)

@interface EaseMessageCell()
{
    EMMessageBodyType _messageType;
}

@property (nonatomic) NSLayoutConstraint *statusWidthConstraint;
@property (nonatomic) NSLayoutConstraint *activtiyWidthConstraint;
@property (nonatomic) NSLayoutConstraint *hasReadWidthConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleMaxWidthConstraint;

@end

@implementation EaseMessageCell

@synthesize statusButton = _statusButton;
@synthesize bubbleView = _bubbleView;
@synthesize hasRead = _hasRead;
@synthesize activity = _activity;

+ (void)initialize
{
    // UIAppearance Proxy Defaults
    EaseMessageCell *cell = [self appearance];
    cell.statusSize = 14;
    cell.activitySize = 14;
    cell.bubbleMaxWidth = 200;
    cell.leftBubbleMargin = UIEdgeInsetsMake(8, 10, 8, 3);
    cell.rightBubbleMargin = UIEdgeInsetsMake(8, 10, 8, 3);
    cell.bubbleMargin = UIEdgeInsetsMake(8, 0, 8, 0);
    
    cell.messageTextFont = [UIFont systemFontOfSize:15];
    cell.messageTextColor = [UIColor blackColor];
    
    cell.messageLocationFont = [UIFont systemFontOfSize:12];
    cell.messageLocationColor = [UIColor blackColor];
    
    cell.messageVoiceDurationColor = [UIColor grayColor];
    cell.messageVoiceDurationFont = [UIFont systemFontOfSize:12];
    cell.voiceCellWidth = 75.f;
    
    cell.messageFileNameColor = [UIColor blackColor];
    cell.messageFileNameFont = [UIFont systemFontOfSize:13];
    cell.messageFileSizeColor = [UIColor grayColor];
    cell.messageFileSizeFont = [UIFont systemFontOfSize:11];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                        model:(id<IMessageModel>)model
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessibilityIdentifier = @"table_cell";

        _messageType = model.bodyType;
        [self _setupSubviewsWithType:_messageType
                            isSender:model.isSender
                               model:model];
    }
    
    return self;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - setup subviews

/*!
 @method
 @brief 加载子视图
 @discussion  
 @param messageType  消息体类型
 @param isSender     登录用户是否为发送方
 @param model        消息对象model
 @result
 */
- (void)_setupSubviewsWithType:(EMMessageBodyType)messageType
                      isSender:(BOOL)isSender
                         model:(id<IMessageModel>)model
{
    _statusButton = [[UIButton alloc] init];
    _statusButton.accessibilityIdentifier = @"status";
    _statusButton.translatesAutoresizingMaskIntoConstraints = NO;
    _statusButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [_statusButton setImage:[UIImage imageNamed:@"msg_box_remind"] forState:UIControlStateNormal];//EaseUIResource.bundle/messageSendFail
    [_statusButton addTarget:self action:@selector(statusAction) forControlEvents:UIControlEventTouchUpInside];
    _statusButton.hidden = YES;
    [self.contentView addSubview:_statusButton];
    
    _bubbleView = [[EaseBubbleView alloc] initWithMargin:isSender?_rightBubbleMargin:_leftBubbleMargin isSender:isSender];
    _bubbleView.translatesAutoresizingMaskIntoConstraints = NO;
    _bubbleView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_bubbleView];
    
    _avatarView = [[UIImageView alloc] init];
    _avatarView.translatesAutoresizingMaskIntoConstraints = NO;
    _avatarView.backgroundColor = [UIColor clearColor];
    _avatarView.clipsToBounds = YES;
    _avatarView.userInteractionEnabled = YES;
    [self.contentView addSubview:_avatarView];
    
    _hasRead = [[UILabel alloc] init];
    _hasRead.accessibilityIdentifier = @"has_read";
    _hasRead.translatesAutoresizingMaskIntoConstraints = NO;
    _hasRead.text = NSEaseLocalizedString(@"hasRead", @"Read");
    _hasRead.textAlignment = NSTextAlignmentCenter;
    _hasRead.font = [UIFont systemFontOfSize:10];
    _hasRead.textColor = [UIColor grayColor];
    _hasRead.hidden = YES;
    [_hasRead sizeToFit];
    [self.contentView addSubview:_hasRead];
    
    _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activity.accessibilityIdentifier = @"sending";
    _activity.translatesAutoresizingMaskIntoConstraints = NO;
    _activity.backgroundColor = [UIColor clearColor];
    _activity.transform = CGAffineTransformMakeScale(0.7, 0.7);
    _activity.hidden = YES;
    [self.contentView addSubview:_activity];
    
    if ([self respondsToSelector:@selector(isCustomBubbleView:)] && [self isCustomBubbleView:model]) {
        [self setCustomBubbleView:model];
    } else {
        switch (messageType) {
            case EMMessageBodyTypeText:
            {
                [_bubbleView setupTextBubbleView];
                _bubbleView.textContentLabel.font = [UIFont systemFontOfSize:15];
                _bubbleView.textContentLabel.textColor = _messageTextColor;
            }
                break;
            case EMMessageBodyTypeImage:
            {
                [_bubbleView setupImageBubbleView];
                _bubbleView.imageView.image = [UIImage imageNamed:@"EaseUIResource.bundle/imageDownloadFail"];
            }
                break;
            case EMMessageBodyTypeLocation:
            {
                [_bubbleView setupLocationBubbleView];
                
                _bubbleView.locationImageView.image = [[UIImage imageNamed:@"pic_chat_map_me"] stretchableImageWithLeftCapWidth:0.1 topCapHeight:0.1];
                _bubbleView.locationLabel.font = _messageLocationFont;
                _bubbleView.locationLabel.textColor = _messageLocationColor;
            }
                break;
            case EMMessageBodyTypeVoice:
            {
                [_bubbleView setupVoiceBubbleView];
                
                _bubbleView.voiceDurationLabel.textColor = _messageVoiceDurationColor;
                _bubbleView.voiceDurationLabel.font = _messageVoiceDurationFont;
            }
                break;
            case EMMessageBodyTypeVideo:
            {
                [_bubbleView setupVideoBubbleView];
                _bubbleView.backgroundImageView.image = nil;
                _bubbleView.backgroundImageView.backgroundColor = [UIColor clearColor];
                _bubbleView.videoTagView.image = [UIImage imageNamed:@"ico_chat_play"];//EaseUIResource.bundle/messageVideo
            }
                break;
            case EMMessageBodyTypeFile:
            {
                [_bubbleView setupFileBubbleView];
                
                _bubbleView.fileNameLabel.font = _messageFileNameFont;
                _bubbleView.fileNameLabel.textColor = _messageFileNameColor;
                _bubbleView.fileSizeLabel.font = _messageFileSizeFont;
            }
                break;
            default:
                break;
        }
    }
    
    if (messageType != EMMessageBodyTypeText) {
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewTapAction:)];
        [_bubbleView addGestureRecognizer:tapRecognizer];
    } else {
        _bubbleView.textContentLabel.delegate = self;
        _bubbleView.backgroundImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bubbleViewTapAction:)];
        [_bubbleView addGestureRecognizer:tapRecognizer];
    }
    
    [self _setupConstraints];
    
    UITapGestureRecognizer *tapRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(avatarViewTapAction:)];
    [_avatarView addGestureRecognizer:tapRecognizer2];
}

#pragma mark - Setup Constraints

/*!
 @method
 @brief 设置控件约束
 @discussion  设置气泡宽度、发送状态、已读提示的约束
 @result
 */
- (void)_setupConstraints
{
    //bubble view
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-EaseMessageCellPadding]];
    
    self.bubbleMaxWidthConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.bubbleMaxWidth];
    [self addConstraint:self.bubbleMaxWidthConstraint];
//    self.bubbleMaxWidthConstraint.active = YES;
    
    //status button
    self.statusWidthConstraint = [NSLayoutConstraint constraintWithItem:self.statusButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.statusSize];
    [self addConstraint:self.statusWidthConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.statusButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute:NSLayoutAttributeLeft multiplier:1.0 constant: -10]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.statusButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.statusButton attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.statusButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    
    //activtiy
    self.activtiyWidthConstraint = [NSLayoutConstraint constraintWithItem:self.activity attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.activitySize];
    [self addConstraint:self.activtiyWidthConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activity attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-10]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activity attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.activity attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activity attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];

    [self _updateHasReadWidthConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.hasRead attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.hasRead attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:12]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.hasRead attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:22]];
}

#pragma mark - Update Constraint

/*!
 @method
 @brief 修改已读Label的宽度约束
 @discussion
 @result
 */
- (void)_updateHasReadWidthConstraint
{
    if (_hasRead) {
        [self removeConstraint:self.hasReadWidthConstraint];
        
        self.hasReadWidthConstraint = [NSLayoutConstraint constraintWithItem:_hasRead attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:40];
        [self addConstraint:self.hasReadWidthConstraint];
    }
}

/*!
 @method
 @brief 修改发送状态按钮的宽度约束，主要是发送失败的状态
 @discussion
 @result
 */
- (void)_updateStatusButtonWidthConstraint
{
    if (_statusButton) {
        [self removeConstraint:self.statusWidthConstraint];
        
        self.statusWidthConstraint = [NSLayoutConstraint constraintWithItem:self.statusButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:self.statusSize];
        [self addConstraint:self.statusWidthConstraint];
    }
}

/*!
 @method
 @brief 修改发送进度的宽度约束
 @discussion
 @result
 */
- (void)_updateActivityWidthConstraint
{
    if (_activity) {
        [self removeConstraint:self.activtiyWidthConstraint];
        
        self.statusWidthConstraint = [NSLayoutConstraint constraintWithItem:self.activity attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:self.activitySize];
        [self addConstraint:self.activtiyWidthConstraint];
    }
}

/*!
 @method
 @brief 修改气泡的宽度约束
 @discussion
 @result
 */
- (void)_updateBubbleMaxWidthConstraint
{
    [self removeConstraint:self.bubbleMaxWidthConstraint];
//    self.bubbleMaxWidthConstraint.active = NO;
    
    //气泡宽度小于等于bubbleMaxWidth
    self.bubbleMaxWidthConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.bubbleMaxWidth];
    [self addConstraint:self.bubbleMaxWidthConstraint];
//    self.bubbleMaxWidthConstraint.active = YES;
}

#pragma mark - setter

- (void)setModel:(id<IMessageModel>)model
{
    _model = model;
    if ([self respondsToSelector:@selector(isCustomBubbleView:)] && [self isCustomBubbleView:model]) {
        [self setCustomModel:model];
    } else {
        _bubbleView.callTagImage.hidden = YES;
        switch (model.bodyType) {
            case EMMessageBodyTypeText:
            {
                if (model.message.ext.count && [model.message.ext objectForKey:@"callRecord"] && [[model.message.ext objectForKey:@"callRecord"] isEqualToString:@"YES"]) {
                    _bubbleView.callTagImage.hidden = NO;
                    NSString *callType = [model.message.ext objectForKey:@"callType"];
                    BOOL isVoiceType = [callType isEqualToString:@"voice"];
                    
                    if (model.message.direction == EMMessageDirectionSend) {
                        _bubbleView.callTagImage.image = [UIImage imageNamed: isVoiceType ? @"btn_chat_bluephone" : @"btn_chat_bluevideo"];
                    }else if (model.message.direction == EMMessageDirectionReceive) {
                        _bubbleView.callTagImage.image = [UIImage imageNamed: isVoiceType ? @"btn_chat_greyphone" : @"btn_chat_greyvideo"];
                    }
                }
                _bubbleView.textContentLabel = [EaseMessageCell getAllTextAttributeLabel:model.text attlabel:_bubbleView.textContentLabel font:15 color:[UIColor darkTextColor]];
            }
                break;
            case EMMessageBodyTypeImage:
            {
                // 使用缩略图不清晰，根据需要直接使用了原图
                //  model.thumbnailImage
                UIImage *image = _model.image;
                if (!image) {
                    image = _model.image;
                    if (!image) {
                        [_bubbleView.imageView sd_setImageWithURL:[NSURL URLWithString:_model.thumbnailFileURLPath] placeholderImage:[UIImage imageNamed:_model.failImageName]];
                    } else {
                        _bubbleView.imageView.image = image;
                    }
                } else {
                    _bubbleView.imageView.image = image;
                }
                if (self.model.isSender) {
                    self.sendBubbleBackgroundImage = nil;
                } else {
                    self.recvBubbleBackgroundImage = nil;
                }
                _bubbleView.backgroundImageView.backgroundColor = [UIColor clearColor];
                if (_model.message.ext != nil) {
                    // 给title赋值
                    NSString *address = _model.message.ext[@"title"];
                    _bubbleView.bottomTitleLabel.text = address;
                    _bubbleView.bottomSubTitleLabel.text = _model.message.ext[@"address"];
                }
            }
                break;
            case EMMessageBodyTypeLocation:
            {
                _bubbleView.locationImageView.frame = self.bubbleView.backgroundImageView.bounds;
                if (self.model.isSender == YES) {
                    _bubbleView.locationImageView.image = [UIImage imageNamed:@"pic_chat_map_me"];
                } else {
                    _bubbleView.locationImageView.image = [UIImage imageNamed:@"pic_chat_map"];
                }
                _bubbleView.locationLabel.text = _model.address;
            }
                break;
            case EMMessageBodyTypeVoice:
            {
                if (_bubbleView.voiceImageView) {
                    if ([self.sendMessageVoiceAnimationImages count] > 0 && [self.recvMessageVoiceAnimationImages count] > 0) {
                        self.bubbleView.voiceImageView.image = self.model.isSender ?[self.sendMessageVoiceAnimationImages objectAtIndex:0] : [self.recvMessageVoiceAnimationImages objectAtIndex:0];
                        _bubbleView.voiceImageView.animationImages = self.model.isSender ? self.sendMessageVoiceAnimationImages:self.recvMessageVoiceAnimationImages;
                    } else {
                        self.bubbleView.voiceImageView.image = self.model.isSender ?[UIImage imageNamed:@"ico_bofan_blackfull"]: [UIImage imageNamed:@"ico_bofan_greyfull"];
                    }
                } else {
                    NSLog(@"voiceImageView -- nil");
                }
                
                if (!self.model.isSender) {
                    if (self.model.isMediaPlayed){
                        _bubbleView.isReadView.hidden = YES;
                    } else {
                        _bubbleView.isReadView.hidden = NO;
                    }
                }
                if (_model.isMediaPlaying) {
                    if (_bubbleView.voiceImageView.animationImages.count == 0) {
                        // 不清楚什么情况下图片资源会丢失
                        self.sendMessageVoiceAnimationImages = [IMMessageSourceTool sendMessageVoiceAnimationImages];
                        self.recvMessageVoiceAnimationImages = [IMMessageSourceTool recvMessageVoiceAnimationImages];
                        self.bubbleView.voiceImageView.image = self.model.isSender ?[self.sendMessageVoiceAnimationImages objectAtIndex:0] : [self.recvMessageVoiceAnimationImages objectAtIndex:0];
                        _bubbleView.voiceImageView.animationImages = self.model.isSender ? self.sendMessageVoiceAnimationImages:self.recvMessageVoiceAnimationImages;
                    }
                    [_bubbleView.voiceImageView startAnimating];
                }
                else{
                    [_bubbleView.voiceImageView stopAnimating];
                }
                
                _bubbleView.voiceDurationLabel.text = [NSString stringWithFormat:@"%d''",(int)_model.mediaDuration];
            }
                break;
            case EMMessageBodyTypeVideo:
            {
                UIImage *image = _model.isSender ? _model.image : _model.thumbnailImage;
                if (!image) {
                    image = _model.image;
                    if (!image) {
                        [_bubbleView.videoImageView sd_setImageWithURL:[NSURL URLWithString:_model.fileURLPath] placeholderImage:[UIImage imageNamed:_model.failImageName]];
                    } else {
                        _bubbleView.videoImageView.image = image;
                    }
                } else {
                    _bubbleView.videoImageView.image = image;
                }
            }
                break;
            case EMMessageBodyTypeFile:
            {
                _bubbleView.fileIconView.image = [UIImage imageNamed:_model.fileIconName];
                _bubbleView.fileNameLabel.text = _model.fileName;
                _bubbleView.fileSizeLabel.text = _model.fileSizeDes;
            }
                break;
            default:
                break;
        }
    }
}

- (void)setStatusSize:(CGFloat)statusSize
{
    _statusSize = statusSize;
    [self _updateStatusButtonWidthConstraint];
}

- (void)setActivitySize:(CGFloat)activitySize
{
    _activitySize = activitySize;
    [self _updateActivityWidthConstraint];
}

- (void)setSendBubbleBackgroundImage:(UIImage *)sendBubbleBackgroundImage
{
    _sendBubbleBackgroundImage = sendBubbleBackgroundImage;
}

- (void)setRecvBubbleBackgroundImage:(UIImage *)recvBubbleBackgroundImage
{
    _recvBubbleBackgroundImage = recvBubbleBackgroundImage;
}

- (void)setBubbleMaxWidth:(CGFloat)bubbleMaxWidth
{
    _bubbleMaxWidth = bubbleMaxWidth;
    [self _updateBubbleMaxWidthConstraint];
}

- (void)setRightBubbleMargin:(UIEdgeInsets)rightBubbleMargin
{
    _rightBubbleMargin = rightBubbleMargin;
}

- (void)setLeftBubbleMargin:(UIEdgeInsets)leftBubbleMargin
{
    _leftBubbleMargin = leftBubbleMargin;
}

- (void)setBubbleMargin:(UIEdgeInsets)bubbleMargin
{
    _bubbleMargin = bubbleMargin;
    _bubbleMargin = self.model.isSender ? _rightBubbleMargin:_leftBubbleMargin;
    if ([self respondsToSelector:@selector(isCustomBubbleView:)] && [self isCustomBubbleView:_model]) {
        [self updateCustomBubbleViewMargin:_bubbleMargin model:_model];
    } else {
        if (_bubbleView) {
            switch (_messageType) {
                case EMMessageBodyTypeText:
                {
                    [_bubbleView updateTextMargin:_bubbleMargin];
                }
                    break;
                case EMMessageBodyTypeImage:
                {
                    [_bubbleView updateImageMargin:_bubbleMargin];
                }
                    break;
                case EMMessageBodyTypeLocation:
                {
                    [_bubbleView updateLocationMargin:_bubbleMargin];
                }
                    break;
                case EMMessageBodyTypeVoice:
                {
                    [_bubbleView updateVoiceMargin:_bubbleMargin];
                }
                    break;
                case EMMessageBodyTypeVideo:
                {
                    [_bubbleView updateVideoMargin:_bubbleMargin];
                }
                    break;
                case EMMessageBodyTypeFile:
                {
                    [_bubbleView updateFileMargin:_bubbleMargin];
                }
                    break;
                default:
                    break;
            }
            
        }
    }
}

- (void)setMessageTextFont:(UIFont *)messageTextFont
{
    _messageTextFont = messageTextFont;
//    if (_bubbleView.textContentLabel) {
//        _bubbleView.textContentLabel.font = messageTextFont;
//    }
}

- (void)setMessageTextColor:(UIColor *)messageTextColor
{
    _messageTextColor = messageTextColor;
//    if (_bubbleView.textContentLabel) {
//        _bubbleView.textContentLabel.textColor = _messageTextColor;
//    }
}

- (void)setMessageLocationColor:(UIColor *)messageLocationColor
{
    _messageLocationColor = messageLocationColor;
    if (_bubbleView.locationLabel) {
        _bubbleView.locationLabel.textColor = _messageLocationColor;
    }
}

- (void)setMessageLocationFont:(UIFont *)messageLocationFont
{
    _messageLocationFont = messageLocationFont;
    if (_bubbleView.locationLabel) {
        _bubbleView.locationLabel.font = _messageLocationFont;
    }
}

- (void)setSendMessageVoiceAnimationImages:(NSArray *)sendMessageVoiceAnimationImages
{
    _sendMessageVoiceAnimationImages = sendMessageVoiceAnimationImages;
}

- (void)setRecvMessageVoiceAnimationImages:(NSArray *)recvMessageVoiceAnimationImages
{
    _recvMessageVoiceAnimationImages = recvMessageVoiceAnimationImages;
}

- (void)setMessageVoiceDurationColor:(UIColor *)messageVoiceDurationColor
{
    _messageVoiceDurationColor = messageVoiceDurationColor;
    if (_bubbleView.voiceDurationLabel) {
        _bubbleView.voiceDurationLabel.textColor = _messageVoiceDurationColor;
    }
}

- (void)setMessageVoiceDurationFont:(UIFont *)messageVoiceDurationFont
{
    _messageVoiceDurationFont = messageVoiceDurationFont;
    if (_bubbleView.voiceDurationLabel) {
        _bubbleView.voiceDurationLabel.font = _messageVoiceDurationFont;
    }
}

- (void)setMessageFileNameFont:(UIFont *)messageFileNameFont
{
    _messageFileNameFont = messageFileNameFont;
    if (_bubbleView.fileNameLabel) {
        _bubbleView.fileNameLabel.font = _messageFileNameFont;
    }
}

- (void)setMessageFileNameColor:(UIColor *)messageFileNameColor
{
    _messageFileNameColor = messageFileNameColor;
    if (_bubbleView.fileNameLabel) {
        _bubbleView.fileNameLabel.textColor = _messageFileNameColor;
    }
}

- (void)setMessageFileSizeFont:(UIFont *)messageFileSizeFont
{
    _messageFileSizeFont = messageFileSizeFont;
    if (_bubbleView.fileSizeLabel) {
        _bubbleView.fileSizeLabel.font = _messageFileSizeFont;
    }
}

- (void)setMessageFileSizeColor:(UIColor *)messageFileSizeColor
{
    _messageFileSizeColor = messageFileSizeColor;
    if (_bubbleView.fileSizeLabel) {
        _bubbleView.fileSizeLabel.textColor = _messageFileSizeColor;
    }
}

#pragma mark - action

/*!
 @method
 @brief 气泡的点击手势事件
 @discussion
 @result
 */
- (void)bubbleViewTapAction:(UITapGestureRecognizer *)tapRecognizer
{
    if (tapRecognizer.state == UIGestureRecognizerStateEnded) {
        if (!_delegate) {
            return;
        }
        
        if ([self respondsToSelector:@selector(isCustomBubbleView:)] && [self isCustomBubbleView:_model]) {
            if ([_delegate respondsToSelector:@selector(messageCellSelected:)]) {
                [_delegate messageCellSelected:_model];
                return;
            }
        }
        switch (_model.bodyType) {
            // 分享的卡片才触发点击
            case EMMessageBodyTypeText: {
            }
                break;
            case EMMessageBodyTypeImage:
            {
//                if ([_delegate respondsToSelector:@selector(messageCellSelected:)]) {
//                    [_delegate messageCellSelected:_model];
//                }
                if ([_delegate respondsToSelector:@selector(imageMessageCellSelected:data:)]) {
                    [_delegate imageMessageCellSelected:self data:_model];
                }
            }
                break;
            case EMMessageBodyTypeLocation:
            {
                if ([_delegate respondsToSelector:@selector(messageCellSelected:)]) {
                    [_delegate messageCellSelected:_model];
                }
            }
                break;
            case EMMessageBodyTypeVoice:
            {
//                _model.isMediaPlaying = !_model.isMediaPlaying;
//                if (_model.isMediaPlaying) {
//                    [_bubbleView.voiceImageView startAnimating];
//                }
//                else{
//                    [_bubbleView.voiceImageView stopAnimating];
//                }
                if ([_delegate respondsToSelector:@selector(messageCellSelected:)]) {
                    [_delegate messageCellSelected:_model];
                }
            }
                break;
            case EMMessageBodyTypeVideo:
            {
                if ([_delegate respondsToSelector:@selector(messageCellSelected:)]) {
                    [_delegate messageCellSelected:_model];
                }
            }
                break;
            case EMMessageBodyTypeFile:
            {
                if ([_delegate respondsToSelector:@selector(messageCellSelected:)]) {
                    [_delegate messageCellSelected:_model];
                }
            }
                break;
            default:
                break;
        }
    }
}

/*!
 @method
 @brief 头像的点击事件
 @discussion
 @result
 */
- (void)avatarViewTapAction:(UITapGestureRecognizer *)tapRecognizer
{
    if ([_delegate respondsToSelector:@selector(avatarViewSelcted:)]) {
        [_delegate avatarViewSelcted:_model];
    }
}

/*!
 @method
 @brief 发送失败按钮的点击事件，进行消息重发
 @discussion
 @result
 */
- (void)statusAction
{
    if ([_delegate respondsToSelector:@selector(statusButtonSelcted:withMessageCell:)]) {
        [_delegate statusButtonSelcted:_model withMessageCell:self];
    }
}

#pragma mark - IModelCell
/*
- (BOOL)isCustomBubbleView:(id<IMessageModel>)model
{
    return NO;
}

- (void)setCustomModel:(id<IMessageModel>)model
{

}

- (void)setCustomBubbleView:(id<IMessageModel>)model
{

}

- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{

}*/

#pragma mark - public

/*!
 @method
 @brief 获取cell的重用标识
 @discussion
 @param model        消息对象model
 @result 返回cell的重用标识
 */
+ (NSString *)cellIdentifierWithModel:(id<IMessageModel>)model
{
    NSString *cellIdentifier = nil;
    if (model.isSender) {
        switch (model.bodyType) {
            case EMMessageBodyTypeText:
                cellIdentifier = EaseMessageCellIdentifierSendText;
                break;
            case EMMessageBodyTypeImage:
                cellIdentifier = EaseMessageCellIdentifierSendImage;
                break;
            case EMMessageBodyTypeVideo:
                cellIdentifier = EaseMessageCellIdentifierSendVideo;
                break;
            case EMMessageBodyTypeLocation:
                cellIdentifier = EaseMessageCellIdentifierSendLocation;
                break;
            case EMMessageBodyTypeVoice:
                cellIdentifier = EaseMessageCellIdentifierSendVoice;
                break;
            case EMMessageBodyTypeFile:
                cellIdentifier = EaseMessageCellIdentifierSendFile;
                break;
            default:
                break;
        }
    }
    else{
        switch (model.bodyType) {
            case EMMessageBodyTypeText:
                cellIdentifier = EaseMessageCellIdentifierRecvText;
                break;
            case EMMessageBodyTypeImage:
                cellIdentifier = EaseMessageCellIdentifierRecvImage;
                break;
            case EMMessageBodyTypeVideo:
                cellIdentifier = EaseMessageCellIdentifierRecvVideo;
                break;
            case EMMessageBodyTypeLocation:
                cellIdentifier = EaseMessageCellIdentifierRecvLocation;
                break;
            case EMMessageBodyTypeVoice:
                cellIdentifier = EaseMessageCellIdentifierRecvVoice;
                break;
            case EMMessageBodyTypeFile:
                cellIdentifier = EaseMessageCellIdentifierRecvFile;
                break;
            default:
                break;
        }
    }
    
    return cellIdentifier;
}

/*!
 @method
 @brief 根据消息的内容，获取当前cell的高度
 @discussion
 @param model        消息对象model
 @result 返回cell高度
 */
+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
    if (model.cellHeight > 0) {
        return model.cellHeight;
    }
    
    EaseMessageCell *cell = [self appearance];
    CGFloat bubbleMaxWidth = cell.bubbleMaxWidth;
    if ([UIDevice currentDevice].systemVersion.floatValue == 7.0) {
        bubbleMaxWidth = 200;
    }
    bubbleMaxWidth -= (cell.leftBubbleMargin.left + cell.leftBubbleMargin.right + cell.rightBubbleMargin.left + cell.rightBubbleMargin.right)/2;
    // 增加了name和气泡直接增加了5pt
    CGFloat height = EaseMessageCellPadding + 5 + EaseMessageCellPadding + cell.bubbleMargin.top + cell.bubbleMargin.bottom;
    
    switch (model.bodyType) {
        case EMMessageBodyTypeText:
        {
//            NSAttributedString *text = [[EaseEmotionEscape sharedInstance] attStringFromTextForChatting:model.text textFont:cell.messageTextFont];
//            CGRect rect = [text boundingRectWithSize:CGSizeMake(bubbleMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil];
//            height += (rect.size.height > 20 ? rect.size.height : 20) + 10;
//            NSString *allstr = [self replaceAllStr:model.text];
            if (model.message.ext[@"letter"]) {
                NSString *msgType = model.message.ext[@"dynamic_type"];
                // 视频动态和图片动态的高度不一样，其他都是一样的高度
                if ([msgType isEqualToString:@"dynamic_image"] || [msgType isEqualToString:@"dynamic_video"]) {
                    height += 40;
                } else if ([msgType isEqualToString:@"dynamic_word"]) {
                    /// 修改聊天内容富文本 TYAttributedLabel 宽度高度等等
                    CGSize commSize = [model.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize: 15]}];
                    CGFloat width = commSize.width;
                    if (width > SCREEN_WIDTH - 40 * 3.5) {
                        width = SCREEN_WIDTH - 40 * 3.5;
                    } else {
                        width = SCREEN_WIDTH - 40 * 3.5;
                    }
                    CGFloat textHeight = [self getLabelHight:width content:model.text uifont:15];
                    CGFloat heights = textHeight + 14 + 5;
                    heights = heights < 60 ? heights : 60;
                    height += heights;
                } else if ([msgType isEqualToString:@"dynamic_word"]) {
                    /// 修改聊天内容富文本 TYAttributedLabel 宽度高度等等
                    CGSize commSize = [model.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize: 15]}];
                    CGFloat width = commSize.width;
                    if (width > SCREEN_WIDTH - 40 * 3.5) {
                        width = SCREEN_WIDTH - 40 * 3.5;
                    } else {
                        width = SCREEN_WIDTH - 40 * 3.5;
                    }
                    CGFloat textHeight = [self getLabelHight:width content:model.text uifont:15];
                    CGFloat heights = textHeight + 14 + 5;
                    heights = heights < 60 ? heights : 60;
                    height += heights;
                } else {
                    height += 60;
                }
            } else {
                /// 修改聊天内容富文本 TYAttributedLabel 宽度高度等等
                CGSize commSize = [model.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize: 15]}];
                CGFloat width = commSize.width;
                if (width > SCREEN_WIDTH - 40 * 3.5) {
                    width = SCREEN_WIDTH - 40 * 3.5;
                } else {
                    width = SCREEN_WIDTH - 40 * 3.5;
                }
                
                CGFloat heights = [self getLabelHight:width content:model.text uifont:15];
                height += heights;
            }
        }
            break;
        case EMMessageBodyTypeImage:{
            if (model.message.ext.count > 0 && [model.message.ext[@"image"] boolValue] == YES) {
                /// 自定义的地图信息
                height += kEMMessageLocationHeight;
            } else {
                CGSize reguSize;
                if (model.imageSize.height == 0 || model.imageSize.width == 0) {
                    reguSize = [EaseSDKHelper getChatImageRegularSize:model.thumbnailImageSize];
                } else {
                    reguSize = [EaseSDKHelper getChatImageRegularSize:model.imageSize];
                }
                height += reguSize.height;
            }
        }
            break;
        case EMMessageBodyTypeVideo:
        {
            CGSize reguSize;
            if (model.imageSize.height == 0 || model.imageSize.width == 0) {
                reguSize = [EaseSDKHelper getChatImageRegularSize:model.thumbnailImageSize];
            } else {
                reguSize = [EaseSDKHelper getChatImageRegularSize:model.imageSize];
            }
            height += reguSize.height;
        }
            break;
        case EMMessageBodyTypeLocation:
        {
            height += kEMMessageLocationHeight;
        }
            break;
        case EMMessageBodyTypeVoice:
        {
            height += kEMMessageVoiceHeight;
        }
            break;
        case EMMessageBodyTypeFile:
        {
            NSString *text = model.fileName;
            UIFont *font = cell.messageFileNameFont;
            CGRect nameRect;
            if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
                nameRect = [text boundingRectWithSize:CGSizeMake(bubbleMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
            } else {
                nameRect.size = [text sizeWithFont:font constrainedToSize:CGSizeMake(bubbleMaxWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
            }
            height += (nameRect.size.height > 20 ? nameRect.size.height : 20);
            
            text = model.fileSizeDes;
            font = cell.messageFileSizeFont;
            CGRect sizeRect;
            if ([NSString instancesRespondToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
                sizeRect = [text boundingRectWithSize:CGSizeMake(bubbleMaxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
            } else {
                sizeRect.size = [text sizeWithFont:font constrainedToSize:CGSizeMake(bubbleMaxWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByCharWrapping];
            }
            height += (sizeRect.size.height > 15 ? sizeRect.size.height : 15);
        }
            break;
        default:
            break;
    }

    height += EaseMessageCellPadding;
    model.cellHeight = height;
    
    return height;
}

+ (TYAttributedLabel *)getAllTextAttributeLabel:(NSString *)allStr attlabel:(TYAttributedLabel *)attLabel font:(NSInteger)font color:(UIColor *)color {
    UIColor *defualtC = attLabel.textColor;
    attLabel.text = [self replaceHtmlLanguageWithSpace:allStr];
    attLabel.text = allStr;
    attLabel.backgroundColor = [UIColor clearColor];
    // 属性文本生成器
    TYTextContainer *attStringCreater = [[TYTextContainer alloc]init];
    attStringCreater.text = attLabel.text;
    NSMutableArray *tmpArray = [NSMutableArray arrayWithArray:[self getTyStoreArrs:allStr font:font chatlistnameColor:color]];
    // 添加图片信息数组到label
    [attStringCreater addTextStorageArray:tmpArray];
    [attLabel setTextContainer:attStringCreater];
    //TYLabel的属性不能在设置frame之前设置，不然会失效，
    attLabel.linesSpacing = 0;
    attLabel.characterSpacing = 0.5;
    attLabel.font = [UIFont systemFontOfSize:font];
    attLabel.lineBreakMode = kCTLineBreakByTruncatingTail;
    attLabel.numberOfLines = 0;
    attLabel.textColor = defualtC;
    return attLabel;
}

/**
 *  @author heiheihei
 *
 *  @brief  获取富文本替换的部分
 *
 *  @param str 文本.参数一定要是完整的，url没被替换的
 *
 *  @return 富文本数组
 */
+ (NSMutableArray *)getTyStoreArrs:(NSString *)allCommStr font:(NSInteger)font chatlistnameColor:(UIColor *)nameColor
{
    if (!nameColor) {
        nameColor = [UIColor colorWithRed:89.0f/255.0f green:182.0f/255.0f blue:215.0f/255.0f alpha:1.0f];
    }
    
    NSMutableArray *tmpArray = [NSMutableArray new];
    //正则匹配和替换H5
    NSString *orangStr = allCommStr;
    allCommStr = [self replaceH5:allCommStr];
    NSMutableArray *urlArr = [NSMutableArray new];
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegixted2 options:NSRegularExpressionCaseInsensitive error:&error];
    NSArray *arrayUrlMatch = [regex matchesInString:allCommStr options:0 range:NSMakeRange(0, allCommStr.length)];
    for (NSTextCheckingResult *match in arrayUrlMatch){
        
        NSString* substringForMatch = [allCommStr substringWithRange:match.range];
        
        [urlArr addObject:substringForMatch];
    }
    
    //如果有网址
    if (urlArr.count>0) {
        int i = 0;
        for (NSString *str in urlArr) {
            TYLinkTextStorage *textStorage = [[TYLinkTextStorage alloc]init];
            textStorage.textColor = [UIColor colorWithRed:89.0f/255.0f green:182.0f/255.0f blue:215.0f/255.0f alpha:1.0f];
            textStorage.font = [UIFont systemFontOfSize:font];
            textStorage.linkData = str;
            textStorage.underLineStyle = kCTUnderlineStyleNone;
            NSRange compUrlStrRange = [allCommStr rangeOfString:str];
            
            NSString * replaceStr = [[NSString alloc]init];
            
            for (int i = 0; i < compUrlStrRange.length; i ++) {
                replaceStr = [replaceStr stringByAppendingString:@"ß"];
            }
            textStorage.range = compUrlStrRange;
            allCommStr = [allCommStr stringByReplacingCharactersInRange:compUrlStrRange withString:replaceStr];
            textStorage.text = str;
            [tmpArray addObject:textStorage];
            i++;
        }
    }
    return tmpArray;
}

+ (NSArray *) emojiStringArray
{
    
    return [NSArray arrayWithObjects:@"[aini]",@"[aoman]",@"[baiyan]",@"[baobao]",@"[bishi]",@"[bizui]",@"[cahan]",@"[chajing]",@"[ciya]",@"[dabian]",@"[dabing]",@"[daku]",@"[deyi]",@"[fadai]",@"[fanu]",@"[fendou]",@"[ganga]",@"[gouyin]",@"[guzhang]",@"[haixiu]",@"[haha]",@"[haochi]",@"[haqian]",@"[huaixiao]",@"[jingkong]",@"[jingya]",@"[kafei]",@"[keai]",@"[kelian]",@"[ku]",@"[kuaikule]",@"[kulou]",@"[kun]",@"[lanqiu]",@"[lenghan]",@"[liuhan]",@"[liulei]",@"[ma]",@"[nanguo]",@"[no]",@"[ok]",@"[peifu]",@"[pizui]",@"[pingpang]",@"[qiang]",@"[qiaoda]",@"[qinqin]",@"[qioudale]",@"[ruo]",@"[se]",@"[shuai]",@"[shuijiao]",@"[tiaopi]",@"[touxiao]",@"[tu]",@"[wabi]",@"[weiqu]",@"[weixiao]",@"[woquan]",@"[woshou]",@"[xia]",@"[xu]",@"[yeah]",@"[yinxian]",@"[yiwen]",@"[youhengheng]",@"[yueliang]",@"[yun]",@"[zaijian]",@"[zhemo]",@"[zhu]",@"[zhuakuang]",@"[zuohengheng]",nil];
}

+ (CGFloat)getLabelHight:(CGFloat)labelWidth content:(NSString *)containStr uifont:(NSInteger)font
{
    if (!NOTNULL(containStr)||!containStr||[containStr isEqualToString:@""]) {
        return 0;
    }
    containStr = [containStr stringByReplacingOccurrencesOfString:@" " withString:@"E"];
    TYAttributedLabel *tyLabel = [TYAttributedLabel new];
    tyLabel = [self getAllTextAttributeLabel:containStr attlabel:tyLabel font:font color:[UIColor redColor]];
    tyLabel.linesSpacing = 0;
    tyLabel.characterSpacing = 0.5;
    [tyLabel setFrameWithOrign:CGPointMake(0,0) Width:labelWidth];
    [tyLabel sizeToFit];
    CGFloat height= tyLabel.frame.size.height;
    tyLabel = nil;
    return height;
}

- (void)attributedLabel:(TYAttributedLabel *)attributedLabel textStorageClicked:(id<TYTextStorageProtocol>)textStorage atPoint:(CGPoint)point {
    //非文本/比如表情什么的
    if (![textStorage isKindOfClass:[TYLinkTextStorage class]]) {
        return;
    }
    id linkContain = ((TYLinkTextStorage *)textStorage).linkData;
    if (_delegate && [_delegate respondsToSelector:@selector(urlTouch:)]) {
        [_delegate urlTouch:[NSString stringWithFormat:@"%@",linkContain]];
    }
}

+(NSString *)replaceH5:(NSString *)contentStr
{
    //h5代码替换
    NSString *getStr = contentStr;
    contentStr = [[contentStr stringByReplacingOccurrencesOfString:@"<([^>]*)>" withString:@""] stringByReplacingOccurrencesOfString:@"\\*|\t|\r" withString:@""];
//    contentStr = [[contentStr
//                   stringByReplacingOccurrencesOfRegex:@"<([^>]*)>" withString:@""] stringByReplacingOccurrencesOfRegex:@"\\*|\t|\r" withString:@""];
    if (![contentStr isEqualToString:getStr]) {
        if ([getStr rangeOfString:@"myRegularId="].length>0) {
            contentStr = [contentStr stringByReplacingOccurrencesOfString:ReplaceH5String withString:@""];
        }
    }
    return contentStr;
}

+(NSString *)replaceHtmlLanguageWithSpace:(NSString *)contentStr
{
    if (!contentStr||!NOTNULL(contentStr)) {
        return @"";
    }
    contentStr = [self replaceH5:contentStr];
    //    contentStr = [self replaceUrl:contentStr];
    return contentStr;
}

@end
