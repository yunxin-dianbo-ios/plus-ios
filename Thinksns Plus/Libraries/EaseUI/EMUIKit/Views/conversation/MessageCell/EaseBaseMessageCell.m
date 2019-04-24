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

#import "EaseBaseMessageCell.h"

#import "UIImageView+EMWebCache.h"
#import "EaseSDKHelper.h"

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
@interface EaseBaseMessageCell()

@property (strong, nonatomic) UILabel *nameLabel;

@property (nonatomic) NSLayoutConstraint *avatarWidthConstraint;
@property (nonatomic) NSLayoutConstraint *nameHeightConstraint;
//@property (nonatomic) NSLayoutConstraint *iconHeightConstraint;

@property (nonatomic) NSLayoutConstraint *bubbleWithAvatarRightConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleWithoutAvatarRightConstraint;

@property (nonatomic) NSLayoutConstraint *bubbleWithNameTopConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleWithoutNameTopConstraint;
@property (nonatomic) NSLayoutConstraint *bubbleWithImageConstraint;

@end

@implementation EaseBaseMessageCell

@synthesize nameLabel = _nameLabel;

+ (void)initialize
{
    // UIAppearance Proxy Defaults
    EaseBaseMessageCell *cell = [self appearance];
    cell.avatarSize = 30;
    cell.avatarCornerRadius = 0;
    
    cell.messageNameColor = [UIColor grayColor];
    cell.messageNameFont = [UIFont systemFontOfSize:13];
    cell.messageNameHeight = 15;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        cell.messageNameIsHidden = NO;
    }
    
//    cell.bubbleMargin = UIEdgeInsetsMake(8, 15, 8, 10);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                        model:(id<IMessageModel>)model
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier model:model];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = _messageNameFont;
        _nameLabel.textColor = _messageNameColor;
        [self.contentView addSubview:_nameLabel];
        
        self.iconView = [[UIImageView alloc] init];
        self.iconView.backgroundColor = [UIColor clearColor];
        self.iconView.clipsToBounds = YES;
        self.iconView.layer.cornerRadius = 40 * 0.35 / 2.0;
        self.iconView.userInteractionEnabled = YES;
        [self addSubview:self.iconView];
        
        [self configureLayoutConstraintsWithModel:model];
        
        if ([UIDevice currentDevice].systemVersion.floatValue == 7.0) {
            self.messageNameHeight = 15;
        }
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _bubbleView.backgroundImageView.image = self.model.isSender ? self.sendBubbleBackgroundImage : self.recvBubbleBackgroundImage;
    CGFloat margin = [EaseMessageCell appearance].leftBubbleMargin.left + [EaseMessageCell appearance].leftBubbleMargin.right;
    switch (self.model.bodyType) {
        case EMMessageBodyTypeText:
        {
            // 普通文本消息
            CGSize commSize = [self.model.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize: 15]}];
            CGFloat width = commSize.width;
            if (width > SCREEN_WIDTH - self.avatarSize * 3.5) {
                width = SCREEN_WIDTH - self.avatarSize * 3.5;
            }
            
            [self removeConstraint:self.bubbleWithImageConstraint];
            CGFloat margin = [EaseMessageCell appearance].leftBubbleMargin.left + [EaseMessageCell appearance].leftBubbleMargin.right;
            self.bubbleWithImageConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width + margin + 9];
            [self addConstraint:self.bubbleWithImageConstraint];
            self.bubbleView.callTagImage.frame = CGRectMake(8, (self.bubbleView.frame.size.height - 20)/2.0, 20, 20);
        }
            break;
        case EMMessageBodyTypeImage:
        {
            if (self.model.message.ext.count > 0 && [self.model.message.ext[@"image"] boolValue] == YES) {
                /// 说明是定位的卡片
                /// 默认宽高比3:2
                CGSize retSize = CGSizeMake(kEMMessageLocationHeight / 2.0 * 3, kEMMessageLocationHeight);
                [self removeConstraint:self.bubbleWithImageConstraint];
                
                self.bubbleView.imageView.frame = CGRectMake(self.bubbleView.backgroundImageView.bounds.origin.x, self.bubbleView.backgroundImageView.bounds.origin.y, retSize.width + margin, retSize.height + 16);
                self.bubbleView.bottomBgView.frame = CGRectMake(0, self.bubbleView.imageView.frame.size.height - 45, self.bubbleView.imageView.frame.size.width, 45);
                self.bubbleView.bottomBgView.hidden = NO;
                self.bubbleView.bottomTitleLabel.frame = CGRectMake(7, 8, self.bubbleView.bottomBgView.frame.size.width - 7* 2, 14);
                self.bubbleView.bottomSubTitleLabel.frame = CGRectMake(7, CGRectGetMaxY(self.bubbleView.bottomTitleLabel.frame) + 4, self.bubbleView.frame.size.width, 10);

                UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bubbleView.imageView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(12, 12)];
                if (self.model.isSender) {
                    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bubbleView.imageView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(12, 12)];
                }
                CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
                self.bubbleView.imageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
                maskLayer.frame = self.bubbleView.imageView.bounds;
                maskLayer.path = maskPath.CGPath;
                self.bubbleView.imageView.layer.mask = maskLayer;
                /// 底部的mask
                UIBezierPath *bottomMaskPath = [UIBezierPath bezierPathWithRoundedRect:self.bubbleView.bottomBgView.bounds byRoundingCorners: UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(12, 12)];
                if (self.model.isSender) {
                    bottomMaskPath = [UIBezierPath bezierPathWithRoundedRect:self.bubbleView.imageView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(12, 12)];
                }
                CAShapeLayer *bottomMaskLayer = [[CAShapeLayer alloc] init];
                bottomMaskLayer.frame = self.bubbleView.bottomBgView.bounds;
                bottomMaskLayer.path = bottomMaskPath.CGPath;
                self.bubbleView.bottomBgView.layer.mask = bottomMaskLayer;

                self.bubbleWithImageConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:retSize.width + margin];
                [self addConstraint:self.bubbleWithImageConstraint];

                } else {

                CGSize retSize;
                if (self.model.imageSize.height == 0 || self.model.imageSize.width == 0) {
                    retSize = [EaseSDKHelper getChatImageRegularSize:self.model.thumbnailImageSize];
                } else {
                    retSize = [EaseSDKHelper getChatImageRegularSize:self.model.imageSize];
                }
                [self removeConstraint:self.bubbleWithImageConstraint];
                
                self.bubbleView.imageView.frame = CGRectMake(self.bubbleView.backgroundImageView.bounds.origin.x, self.bubbleView.backgroundImageView.bounds.origin.y, retSize.width + margin, retSize.height + 16);
                UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bubbleView.imageView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(12, 12)];
                if (self.model.isSender) {
                    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bubbleView.imageView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(12, 12)];
                }
                CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
                self.bubbleView.imageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
                maskLayer.frame = self.bubbleView.imageView.bounds;
                maskLayer.path = maskPath.CGPath;
                self.bubbleView.imageView.layer.mask = maskLayer;
                self.bubbleWithImageConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:retSize.width + margin];
                [self addConstraint:self.bubbleWithImageConstraint];
                }
        }
            break;
        case EMMessageBodyTypeLocation:
        {
            // 去除掉图片
            _bubbleView.backgroundImageView.image = nil;
            // 处理不同情况的圆角
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bubbleView.locationImageView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(12, 12)];
            if (self.model.isSender) {
                maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bubbleView.locationImageView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(12, 12)];
            }
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = self.bubbleView.locationImageView.bounds;
            maskLayer.path = maskPath.CGPath;
            self.bubbleView.locationImageView.layer.mask = maskLayer;
        }
            break;
        case EMMessageBodyTypeVoice:
        {
            [self removeConstraint:self.bubbleWithImageConstraint];
            self.bubbleWithImageConstraint = [NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[EaseMessageCell appearance].voiceCellWidth];
            [self addConstraint:self.bubbleWithImageConstraint];
        }
            break;
        case EMMessageBodyTypeVideo:
        {
            // 去除掉图片
            _bubbleView.backgroundImageView.image = nil;
            // 处理不同情况的圆角
            _bubbleView.videoImageView.clipsToBounds = YES;
            _bubbleView.videoImageView.contentMode = UIViewContentModeScaleAspectFill;
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bubbleView.videoImageView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(12, 12)];
            if (self.model.isSender) {
                maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bubbleView.videoImageView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(12, 12)];
            }
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = self.bubbleView.videoImageView.bounds;
            maskLayer.path = maskPath.CGPath;
            self.bubbleView.videoImageView.layer.mask = maskLayer;
        }
            break;
        case EMMessageBodyTypeFile:
        {
        }
            break;
        default:
            break;
    }
}
/*!
 @method
 @brief 根据传入的消息对象，设置头像、昵称、气泡的约束
 @discussion
 @param model   消息对象
 @result
 */
- (void)configureLayoutConstraintsWithModel:(id<IMessageModel>)model
{
    if (model.isSender) {
        [self configureSendLayoutConstraints];
    } else {
        [self configureRecvLayoutConstraints];
    }
}

/*!
 @method
 @brief 发送方控件约束
 @discussion  当前登录用户为消息发送方时，设置控件约束，在cell的右侧排列显示
 @result
 */
- (void)configureSendLayoutConstraints
{
    //avatar view
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:EaseMessageCellPadding]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-EaseMessageCellPadding]];
    
    self.avatarWidthConstraint = [NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.avatarSize];
    [self addConstraint:self.avatarWidthConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    
    //name label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:EaseMessageCellPadding]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-EaseMessageCellPadding]];
    
    self.nameHeightConstraint = [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.messageNameHeight];
    [self addConstraint:self.nameHeightConstraint];
    
    //bubble view
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-EaseMessageCellPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.nameLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5]];
    
    //status button
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.statusButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-EaseMessageCellPadding]];
    
    //activity
//    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.activity attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-EaseMessageCellPadding]];
    
    //hasRead
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.hasRead attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.bubbleView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:-EaseMessageCellPadding]];
}

/*!
 @method
 @brief 接收方控件约束
 @discussion  当前登录用户为消息接收方时，设置控件约束，在cell的左侧排列显示
 @result
 */
- (void)configureRecvLayoutConstraints
{
    //avatar view
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:EaseMessageCellPadding]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:EaseMessageCellPadding]];
    
    self.avatarWidthConstraint = [NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.avatarSize];
    [self addConstraint:self.avatarWidthConstraint];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0]];
    
    //name label
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTop multiplier:1.0 constant:EaseMessageCellPadding]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeRight multiplier:1.0 constant:EaseMessageCellPadding]];
    
    self.nameHeightConstraint = [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.messageNameHeight];
    [self addConstraint:self.nameHeightConstraint];
    
    //bubble view
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.avatarView attribute:NSLayoutAttributeRight multiplier:1.0 constant:EaseMessageCellPadding]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.bubbleView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.nameLabel attribute:NSLayoutAttributeBottom multiplier:1.0 constant:5]];
}

#pragma mark - Update Constraint

/*!
 @method
 @brief 更新头像宽度的约束
 @discussion
 @result
 */
- (void)_updateAvatarViewWidthConstraint
{
    if (self.avatarView) {
        [self removeConstraint:self.avatarWidthConstraint];
        
        self.avatarWidthConstraint = [NSLayoutConstraint constraintWithItem:self.avatarView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:self.avatarSize];
        [self addConstraint:self.avatarWidthConstraint];
    }
}

/*!
 @method
 @brief 更新昵称高度的约束
 @discussion
 @result
 */
- (void)_updateNameHeightConstraint
{
    if (_nameLabel) {
        [self removeConstraint:self.nameHeightConstraint];
        
        self.nameHeightConstraint = [NSLayoutConstraint constraintWithItem:self.nameLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:self.messageNameHeight];
        [self addConstraint:self.nameHeightConstraint];
    }
}

#pragma mark - setter

- (void)setModel:(id<IMessageModel>)model
{
    [super setModel:model];
    
    if (model.avatarURLPath) {
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:model.avatarURLPath] placeholderImage:model.avatarImage];
    } else {
        self.avatarView.image = model.avatarImage;
    }
    _nameLabel.text = model.nickname;
    
    if (self.model.isSender) {
        _hasRead.hidden = YES;
        switch (self.model.messageStatus) {
            case EMMessageStatusDelivering:
            {
                _statusButton.hidden = YES;
                [_activity setHidden:NO];
                [_activity startAnimating];
            }
                break;
            case EMMessageStatusSucceed:
            {
                _statusButton.hidden = YES;
                [_activity stopAnimating];
                // TS+
                // 不显示已读
//                if (self.model.isMessageRead) {
//                    _hasRead.hidden = NO;
//                }
                _hasRead.hidden = YES;
            }
                break;
            case EMMessageStatusPending:
            case EMMessageStatusFailed:
            {
                [_activity stopAnimating];
                [_activity setHidden:YES];
                _statusButton.hidden = NO;
            }
                break;
            default:
                break;
        }
    }
}

- (void)setMessageNameFont:(UIFont *)messageNameFont
{
    _messageNameFont = messageNameFont;
    if (_nameLabel) {
        _nameLabel.font = _messageNameFont;
    }
}

- (void)setMessageNameColor:(UIColor *)messageNameColor
{
    _messageNameColor = messageNameColor;
    if (_nameLabel) {
        _nameLabel.textColor = _messageNameColor;
    }
}

- (void)setMessageNameHeight:(CGFloat)messageNameHeight
{
    _messageNameHeight = messageNameHeight;
    if (_nameLabel) {
        [self _updateNameHeightConstraint];
    }
}

- (void)setAvatarSize:(CGFloat)avatarSize
{
    _avatarSize = avatarSize;
    if (self.avatarView) {
        [self _updateAvatarViewWidthConstraint];
    }
}

- (void)setAvatarCornerRadius:(CGFloat)avatarCornerRadius
{
    _avatarCornerRadius = avatarCornerRadius;
    if (self.avatarView){
        self.avatarView.layer.cornerRadius = avatarCornerRadius;
    }
}

- (void)setMessageNameIsHidden:(BOOL)messageNameIsHidden
{
    _messageNameIsHidden = messageNameIsHidden;
    if (_nameLabel) {
        _nameLabel.hidden = messageNameIsHidden;
    }
}

#pragma mark - public

/*!
 @method
 @brief 获取当前cell的高度
 @discussion  
 @result
 */
+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
    EaseBaseMessageCell *cell = [self appearance];
    
    CGFloat minHeight = cell.avatarSize + EaseMessageCellPadding * 2;
    CGFloat height = cell.messageNameHeight;
    if ([UIDevice currentDevice].systemVersion.floatValue == 7.0) {
        height = 15;
    }
    height += - EaseMessageCellPadding + [EaseMessageCell cellHeightWithModel:model];
    height = height > minHeight ? height : minHeight;
    
    return height;
}

@end
