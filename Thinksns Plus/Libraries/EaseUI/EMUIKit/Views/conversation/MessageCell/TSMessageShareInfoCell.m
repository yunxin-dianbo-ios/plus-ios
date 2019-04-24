//
//  TSMessageShareInfoCell.m
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/16.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

#import "TSMessageShareInfoCell.h"
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)

@interface TSMessageShareInfoCell()

@property (nonatomic, assign) CGFloat avatarSize;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGFloat bubbleViewHeight;
@property (nonatomic, assign) CGFloat bubbleViewWidth;

@end

@implementation TSMessageShareInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    [self creatUI];
    return self;
}
- (void)creatUI {
    UITapGestureRecognizer *bgTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bgViewDidTapCell)];
    [self.contentView addGestureRecognizer:bgTap];

    self.avatarSize = 40.0;
    self.avatarView = [[UIImageView alloc] init];
    self.avatarView.backgroundColor = [UIColor clearColor];
    self.avatarView.clipsToBounds = YES;
    self.avatarView.layer.cornerRadius = self.avatarSize / 2.0;
    self.avatarView.userInteractionEnabled = YES;
    self.avatarView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    [self.contentView addSubview:self.avatarView];
    
    self.nameLabel = [[UILabel alloc]init];
    self.nameLabel.textColor = [UIColor grayColor];
    self.nameLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:self.nameLabel];
    
    self.userIconView = [[UIImageView alloc] init];
    self.userIconView.backgroundColor = [UIColor lightGrayColor];
    self.userIconView.clipsToBounds = YES;
    self.userIconView.layer.cornerRadius = 40 * 0.35 / 2.0;
    self.userIconView.userInteractionEnabled = YES;
    [self.contentView addSubview:self.userIconView];
    
    // 不使用约束，用代码设置frame
    self.backgroundImageView = [[UIImageView alloc] init];
    self.backgroundImageView.userInteractionEnabled = YES;
    self.backgroundImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.backgroundImageView];
    UITapGestureRecognizer *bubullViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(bubbleViewDidTap)];
    [self.backgroundImageView addGestureRecognizer:bubullViewTap];
    
    self.textContentLabel = [[TYAttributedLabel alloc] init];
    self.textContentLabel.accessibilityIdentifier = @"text_label";
    self.textContentLabel.numberOfLines = 0;
    self.textContentLabel.clipsToBounds = YES;
    self.textContentLabel.backgroundColor = [UIColor orangeColor];
    [self.backgroundImageView addSubview:self.textContentLabel];
    
    // title
    self.shareTitleLabel = [[UILabel alloc]init];
    self.shareTitleLabel.numberOfLines = 2;
    self.shareTitleLabel.textColor = [UIColor blueColor];
    self.shareTitleLabel.font = [UIFont systemFontOfSize:13];
    self.shareTitleLabel.clipsToBounds = YES;
    [self.backgroundImageView addSubview:self.shareTitleLabel];
    
    // cover
    self.coverImageView = [[UIImageView alloc]init];
    self.coverImageView.clipsToBounds = YES;
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.coverImageView.clipsToBounds = YES;
    self.coverImageView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
    [self.backgroundImageView addSubview:self.coverImageView];
    
    // icon
    self.iconImageView = [[UIImageView alloc]init];
    [self.backgroundImageView addSubview:self.iconImageView];
}
- (void)updataInfoModel:(id<IMessageModel>)model {
    self.model = model;
    self.cellHeight = [EaseBaseMessageCell cellHeightWithModel:model];
    self.bubbleViewHeight = self.cellHeight - (10 + 15 + 10);
    // 赋值，同时设置控件的frame
    [self.avatarView sd_setImageWithURL:[NSURL URLWithString:model.avatarURLPath] placeholderImage: model.avatarImage];
    self.nameLabel.text = model.nickname;
    // 发送方 Left
    if (model.isSender) {
        self.avatarView.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 10 - 40, 10, 40, 40);
        self.nameLabel.frame = CGRectMake(CGRectGetMinX(self.avatarView.frame) - 10 - 120, 10, 120, 15);
        self.nameLabel.textAlignment = NSTextAlignmentRight;
        self.backgroundImageView.image = [[UIImage imageNamed:@"IMG_bg_chat_blue"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12) resizingMode:UIImageResizingModeStretch];
    } else {
        // 接收方 Right
        self.avatarView.frame = CGRectMake(10, 10, 40, 40);
        self.nameLabel.frame = CGRectMake(CGRectGetMaxX(self.avatarView.frame) + 10, 10, 120, 15);
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.backgroundImageView.image = [[UIImage imageNamed:@"IMG_bg_chat_grey"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12) resizingMode:UIImageResizingModeStretch];
    }
    self.userIconView.frame = CGRectMake(CGRectGetMaxX(self.avatarView.frame) - (self.avatarSize * 0.35), CGRectGetMaxY(self.avatarView.frame) - (self.avatarSize * 0.35), (self.avatarSize * 0.35), (self.avatarSize * 0.35));

    NSDictionary *msgInfo = self.model.message.ext;
    NSString *msgType = msgInfo[@"letter"];
    if (msgType.length) {
        // 分享的卡片
        // dynamic: 动态 info: 资讯 circle：圈子 post：帖子
        if ([msgType isEqualToString:@"dynamic"]) {
            self.shareTitleLabel.text = msgInfo[@"letter_name"];
            if ([model.message.ext[@"dynamic_type"] isEqualToString:@"dynamic_word"]) {
                self.textContentLabel = [EaseMessageCell getAllTextAttributeLabel:model.text attlabel:self.textContentLabel font:15 color:[UIColor darkTextColor]];
            } else if ([model.message.ext[@"dynamic_type"] isEqualToString:@"dynamic_image"]) {
                self.textContentLabel = [EaseMessageCell getAllTextAttributeLabel:@"查看图片" attlabel:self.textContentLabel font:15 color:[UIColor darkTextColor]];
            } else if ([model.message.ext[@"dynamic_type"] isEqualToString:@"dynamic_video"]) {
                self.textContentLabel = [EaseMessageCell getAllTextAttributeLabel:@"查看视频" attlabel:self.textContentLabel font:15 color:[UIColor darkTextColor]];
            }
        } else if ([msgType isEqualToString:@"info"]) {
            self.textContentLabel = [EaseMessageCell getAllTextAttributeLabel:model.text attlabel:self.textContentLabel font:15 color:[UIColor darkTextColor]];
            self.shareTitleLabel.text = msgInfo[@"letter_name"];
            [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:msgInfo[@"letter_image"]]];
        } else if ([msgType isEqualToString:@"circle"] || [msgType isEqualToString:@"post"]) {
            self.textContentLabel = [EaseMessageCell getAllTextAttributeLabel:model.text attlabel:self.textContentLabel font:15 color:[UIColor darkTextColor]];
            self.shareTitleLabel.text = msgInfo[@"letter_name"];
            [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:msgInfo[@"letter_image"]]];
        } else if ([msgType isEqualToString:@"questions"] || [msgType isEqualToString:@"question-answers"]) {
            self.shareTitleLabel.text = msgInfo[@"letter_name"];
            self.textContentLabel = [EaseMessageCell getAllTextAttributeLabel:model.text attlabel:self.textContentLabel font:15 color:[UIColor darkTextColor]];
        }
        // dynamic: 动态 info: 资讯 circle：圈子 post：帖子
        if ([msgType isEqualToString:@"dynamic"]) {
            [self configSharedDynamicMsgUI];
        } else if ([msgType isEqualToString:@"info"]) {
            [self configShareInfoMsgUI];
        } else if ([msgType isEqualToString:@"circle"]) {
            [self configShareCirclMsgUI];
        } else if ([msgType isEqualToString:@"post"]) {
            [self configShareCirclMsgUI];
        } else if ([msgType isEqualToString:@"questions"]) {
            [self configSharedQuestionUI];
        } else if ([msgType isEqualToString:@"question-answers"]) {
            [self configSharedQuestionAnswerUI];
        }
    }
}

// MARK: - 圈子转发以及帖子转发
- (void)configShareCirclMsgUI {
    CGSize bubbleSize = CGSizeMake(SCREEN_WIDTH - (self.avatarSize + 20) * 2, 75);
    CGFloat coverImageWidth = 75;
    CGFloat coverImageHeight = 76;
    self.bubbleViewWidth = bubbleSize.width;
    self.bubbleViewHeight = coverImageHeight;
    self.shareTitleLabel.numberOfLines = 1;
    self.textContentLabel.numberOfLines = 2;
    self.textContentLabel.font = [UIFont systemFontOfSize:12];
    self.iconImageView.hidden = YES;
    self.coverImageView.hidden = NO;
    self.shareTitleLabel.textColor = [UIColor colorWithRed:93 / 255.0 green:184 / 255.0 blue:216 / 215     alpha:1];
    self.textContentLabel.textColor = [UIColor colorWithRed:102 / 255.0 green:102 / 255.0 blue:102 / 255.0 alpha:1];
    if (self.model.isSender) {
        // 发送方
        NSString *letterImage = self.model.message.ext[@"letter_image"];
        if (letterImage.length == 0) {
            coverImageHeight = coverImageWidth = 0;
        }
        // 有图
        self.shareTitleLabel.frame = CGRectMake(15, 12, self.bubbleViewWidth  - coverImageWidth - ((coverImageWidth ? 8 : 0 + 15) + 15), 15);
        self.textContentLabel.frame = CGRectMake(self.shareTitleLabel.frame.origin.x, CGRectGetMaxY(self.shareTitleLabel.frame) + 8, self.shareTitleLabel.frame.size.width, 38);
        
        self.coverImageView.frame = CGRectMake(CGRectGetMaxX(self.shareTitleLabel.frame) + 8, 0, coverImageWidth, coverImageHeight);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.coverImageView.bounds byRoundingCorners:UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.coverImageView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.coverImageView.layer.mask = maskLayer;
        
        self.backgroundImageView.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame) - self.bubbleViewWidth,
                                                    CGRectGetMaxY(self.nameLabel.frame) + 5, self.bubbleViewWidth, self.bubbleViewHeight);
        UIBezierPath *backgroundImageViewMaskPath = [UIBezierPath bezierPathWithRoundedRect:self.backgroundImageView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(12, 12)];
        CAShapeLayer *backgroundImageViewMaskLayer = [[CAShapeLayer alloc] init];
        backgroundImageViewMaskLayer.frame = self.backgroundImageView.bounds;
        backgroundImageViewMaskLayer.path = backgroundImageViewMaskPath.CGPath;
        self.backgroundImageView.layer.mask = backgroundImageViewMaskLayer;
    } else {
        // 接收方
        NSString *letterImage = self.model.message.ext[@"letter_image"];
        if (letterImage.length == 0) {
            coverImageHeight = coverImageWidth = 0;
        }
        self.coverImageView.frame = CGRectMake(0, 0, coverImageWidth, coverImageHeight);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.coverImageView.bounds byRoundingCorners:UIRectCornerBottomLeft cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        self.coverImageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        maskLayer.frame = self.coverImageView.bounds;
        
        maskLayer.path = maskPath.CGPath;
        self.coverImageView.layer.mask = maskLayer;
        self.shareTitleLabel.frame = CGRectMake(CGRectGetMaxX(self.coverImageView.frame) + (coverImageWidth ? 8 : 15), 12, self.bubbleViewWidth  - coverImageWidth - (8 + (coverImageWidth ? 8 : 15)), 15);
        self.textContentLabel.frame = CGRectMake(self.shareTitleLabel.frame.origin.x, CGRectGetMaxY(self.shareTitleLabel.frame) + 8, self.shareTitleLabel.frame.size.width, 38);
        
        self.backgroundImageView.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetMaxY(self.nameLabel.frame) + 5, self.bubbleViewWidth, self.bubbleViewHeight);
        UIBezierPath *backgroundImageViewMaskPath = [UIBezierPath bezierPathWithRoundedRect:self.backgroundImageView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(12, 12)];
        CAShapeLayer *backgroundImageViewMaskLayer = [[CAShapeLayer alloc] init];
        backgroundImageViewMaskLayer.frame = self.backgroundImageView.bounds;
        backgroundImageViewMaskLayer.path = backgroundImageViewMaskPath.CGPath;
        self.backgroundImageView.layer.mask = backgroundImageViewMaskLayer;
    }
}
// MARK: - 资讯转发
- (void)configShareInfoMsgUI {
    CGSize bubbleSize = CGSizeMake(SCREEN_WIDTH - (self.avatarSize + 20) * 2, 75);
    self.bubbleViewWidth = bubbleSize.width;

    self.shareTitleLabel.numberOfLines = 2;
    self.textContentLabel.numberOfLines = 1;
    self.textContentLabel.font = [UIFont systemFontOfSize:12];
    self.textContentLabel.textColor = [UIColor colorWithRed:51 / 255.0 green:51 / 255.0 blue:51 / 255.0 alpha:1];
    self.shareTitleLabel.textColor = [UIColor colorWithRed:51 / 255.0 green:51 / 255.0 blue:51 / 255.0 alpha:1];
    self.iconImageView.hidden = YES;
    self.coverImageView.hidden = NO;
    if (self.model.isSender) {
        // 发送方
        CGFloat coverImageWidth = 75;
        CGFloat coverImageHeight = 51;
        // 都有图
        self.coverImageView.frame = CGRectMake(12, 12, coverImageWidth, coverImageHeight);
        self.shareTitleLabel.frame = CGRectMake(CGRectGetMaxX(self.coverImageView.frame) + 14, 10, self.bubbleViewWidth  - coverImageWidth - (12 + 15 + 12), 34);
        self.textContentLabel.frame = CGRectMake(self.shareTitleLabel.frame.origin.x, CGRectGetMaxY(self.shareTitleLabel.frame) + 4, self.shareTitleLabel.frame.size.width, 16);
        self.backgroundImageView.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame) - self.bubbleViewWidth, CGRectGetMaxY(self.nameLabel.frame) + 5, self.bubbleViewWidth, self.bubbleViewHeight);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.backgroundImageView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(12, 12)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.backgroundImageView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.backgroundImageView.layer.mask = maskLayer;
    } else {
        // 接收方
        CGFloat coverImageWidth = 75;
        CGFloat coverImageHeight = 51;
        self.shareTitleLabel.frame = CGRectMake(12, 12, self.bubbleViewWidth  - coverImageWidth - (12 + 15 + 12), 34);
        self.textContentLabel.frame = CGRectMake(self.shareTitleLabel.frame.origin.x, CGRectGetMaxY(self.shareTitleLabel.frame) + 4, self.shareTitleLabel.frame.size.width, 16);
        self.coverImageView.frame = CGRectMake(CGRectGetMaxX(self.shareTitleLabel.frame) + 14, 12, coverImageWidth, coverImageHeight);
        self.backgroundImageView.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetMaxY(self.nameLabel.frame) + 5, self.bubbleViewWidth, self.bubbleViewHeight);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.backgroundImageView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(12, 12)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.backgroundImageView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.backgroundImageView.layer.mask = maskLayer;
    }
}
// MARK: - 文字动态
- (void)configSharedDynamicMsgUI {
    // 纯文本
    if ([self.model.message.ext[@"dynamic_type"] isEqualToString:@"dynamic_word"]) {
        [self configSharedTextDynamicMsgUI];
    } else {
        // 图片/视频
        [self configSharedMediaDynamicMsgUI];
    }
}
// 纯文本
- (void)configSharedTextDynamicMsgUI {
    CGSize maxBubbleSize = CGSizeMake(SCREEN_WIDTH - (self.avatarSize + 20) * 2, 53);
    CGSize minBubbleSize = CGSizeMake(112, 53);
    CGSize titleSize = [self.model.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize: 15]}];
    CGFloat titleHeight = 0;
    CGFloat titleWidth = 0;
    if (titleSize.width < minBubbleSize.width) {
        titleWidth = minBubbleSize.width;
    } else if(titleSize.width > maxBubbleSize.width) {
        titleWidth = maxBubbleSize.width;
    } else {
        titleWidth = titleSize.width;
    }
    CGFloat contentHeight = [EaseMessageCell getLabelHight:titleWidth content:self.model.text uifont: 15];
    titleHeight = contentHeight < 12 * 2 + 5 ? contentHeight : 12 * 2 + 5;
    titleSize = CGSizeMake(titleWidth, titleHeight);

    self.bubbleViewWidth = titleSize.width;

    self.shareTitleLabel.numberOfLines = 1;
    self.textContentLabel.numberOfLines = 2;
    self.textContentLabel.font = [UIFont systemFontOfSize:12];
    self.iconImageView.hidden = YES;
    self.coverImageView.hidden = YES;
    self.shareTitleLabel.textColor = [UIColor colorWithRed:93 / 255.0 green:184 / 255.0 blue:216 / 255.0 alpha:1];
    self.textContentLabel.textColor = [UIColor colorWithRed:102 / 255.0 green:102 / 255.0 blue:102 / 255.0 alpha:1];
    
    if (self.model.isSender) {
        // 发送方
        self.shareTitleLabel.frame = CGRectMake(12, 12, self.bubbleViewWidth  - (13 + 13), 14);
        self.textContentLabel.frame = CGRectMake(self.shareTitleLabel.frame.origin.x, CGRectGetMaxY(self.shareTitleLabel.frame) + 5, self.shareTitleLabel.frame.size.width, titleHeight + 6);
        self.backgroundImageView.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame) - self.bubbleViewWidth, CGRectGetMaxY(self.nameLabel.frame) + 5, self.bubbleViewWidth, self.bubbleViewHeight);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.backgroundImageView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(12, 12)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.backgroundImageView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.backgroundImageView.layer.mask = maskLayer;
    } else {
        // 接收方
        self.shareTitleLabel.frame = CGRectMake(12, 12, self.bubbleViewWidth  - (13 + 13), 14);
        self.textContentLabel.frame = CGRectMake(self.shareTitleLabel.frame.origin.x, CGRectGetMaxY(self.shareTitleLabel.frame) + 5, self.shareTitleLabel.frame.size.width, titleHeight + 6);
        
        self.backgroundImageView.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetMaxY(self.nameLabel.frame) + 5, self.bubbleViewWidth, self.bubbleViewHeight);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.backgroundImageView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(12, 12)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.backgroundImageView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.backgroundImageView.layer.mask = maskLayer;
    }
}

// 图片/视频
- (void)configSharedMediaDynamicMsgUI {
    CGSize maxBubbleSize = CGSizeMake(SCREEN_WIDTH - (self.avatarSize + 20) * 2, 53);
    CGSize minBubbleSize = CGSizeMake(112, 53);
    CGSize titleSize = [self.model.message.ext[@"letter_name"] sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize: 15]}];
    if (titleSize.width < minBubbleSize.width) {
        titleSize = minBubbleSize;
    } else if(titleSize.width > maxBubbleSize.width) {
        titleSize = maxBubbleSize;
    }
    self.bubbleViewWidth = titleSize.width;
    self.shareTitleLabel.numberOfLines = 1;
    self.textContentLabel.numberOfLines = 1;
    self.textContentLabel.font = [UIFont systemFontOfSize:12];
    self.iconImageView.hidden = NO;
    self.coverImageView.hidden = YES;
    self.shareTitleLabel.textColor = [UIColor colorWithRed:89 / 255.0 green:182 / 255.0 blue:215 / 255.0  alpha:1];
    self.textContentLabel.textColor = [UIColor colorWithRed:153 / 255.0 green:153 / 255.0 blue:153 / 255.0 alpha:1];

    NSString *iconImageName;
    if (self.model.isSender) {
        // 发送方
        self.shareTitleLabel.frame = CGRectMake(12, 12, self.bubbleViewWidth - (12 + 12), 14);
        self.iconImageView.frame = CGRectMake(12, CGRectGetMaxY(self.shareTitleLabel.frame) + (5 + 15 - 11), 13, 11);
        self.textContentLabel.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame) + 6, CGRectGetMaxY(self.shareTitleLabel.frame) + 5, 52, 15);
        self.backgroundImageView.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame) - self.bubbleViewWidth, CGRectGetMaxY(self.nameLabel.frame) + 5, self.bubbleViewWidth,  self.bubbleViewHeight);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.backgroundImageView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(12, 12)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.backgroundImageView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.backgroundImageView.layer.mask = maskLayer;
        if ([self.model.message.ext[@"dynamic_type"] isEqualToString:@"dynamic_video"]) {
            iconImageName = @"ico_chat_video_disabled";
        } else if ([self.model.message.ext[@"dynamic_type"] isEqualToString:@"dynamic_image"]) {
            iconImageName = @"ico_chat_pic_disabled";
        }
    } else {
        // 接收方
        self.shareTitleLabel.frame = CGRectMake(12, 12, self.bubbleViewWidth - (12 + 12), 14);
        self.iconImageView.frame = CGRectMake(12, CGRectGetMaxY(self.shareTitleLabel.frame) + (5 + 15 - 11), 13, 11);
        self.textContentLabel.frame = CGRectMake(CGRectGetMaxX(self.iconImageView.frame) + 6, CGRectGetMaxY(self.shareTitleLabel.frame) + 5, 52, 15);
        self.backgroundImageView.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetMaxY(self.nameLabel.frame) + 5, self.bubbleViewWidth, self.bubbleViewHeight);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.backgroundImageView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(12, 12)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.backgroundImageView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.backgroundImageView.layer.mask = maskLayer;
        if ([self.model.message.ext[@"dynamic_type"] isEqualToString:@"dynamic_video"]) {
            iconImageName = @"ico_video_highlight";
        } else if ([self.model.message.ext[@"dynamic_type"] isEqualToString:@"dynamic_image"]) {
            iconImageName = @"ico_pic_highlight";
        }
    }
    self.iconImageView.image = [UIImage imageNamed:iconImageName];
}
// MARK: - 问题
- (void)configSharedQuestionUI {
    CGSize bubbleSize = CGSizeMake(SCREEN_WIDTH - (self.avatarSize + 20) * 2, 75);
    self.bubbleViewWidth = bubbleSize.width;
    
    self.shareTitleLabel.numberOfLines = 1;
    self.textContentLabel.numberOfLines = 2;
    self.textContentLabel.font = [UIFont systemFontOfSize:12];
    self.iconImageView.hidden = YES;
    self.coverImageView.hidden = YES;
    self.shareTitleLabel.textColor = [UIColor colorWithRed:93 / 255.0 green:184 / 255.0 blue:216 / 255.0 alpha:1];
    self.textContentLabel.textColor = [UIColor colorWithRed:102 / 255.0 green:102 / 255.0 blue:102 / 255.0 alpha:1];
    
    if (self.model.isSender) {
        // 发送方
        self.shareTitleLabel.frame = CGRectMake(12, 12, self.bubbleViewWidth  - (13 + 13), 14);
        self.textContentLabel.frame = CGRectMake(self.shareTitleLabel.frame.origin.x, CGRectGetMaxY(self.shareTitleLabel.frame) + 5, self.shareTitleLabel.frame.size.width, 35);
        self.backgroundImageView.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame) - self.bubbleViewWidth, CGRectGetMaxY(self.nameLabel.frame) + 5, self.bubbleViewWidth, self.bubbleViewHeight);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.backgroundImageView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(12, 12)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.backgroundImageView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.backgroundImageView.layer.mask = maskLayer;
    } else {
        // 接收方
        self.shareTitleLabel.frame = CGRectMake(12, 12, self.bubbleViewWidth  - (13 + 13), 14);
        self.textContentLabel.frame = CGRectMake(self.shareTitleLabel.frame.origin.x, CGRectGetMaxY(self.shareTitleLabel.frame) + 5, self.shareTitleLabel.frame.size.width, 35);
        
        self.backgroundImageView.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetMaxY(self.nameLabel.frame) + 5, self.bubbleViewWidth, self.bubbleViewHeight);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.backgroundImageView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(12, 12)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.backgroundImageView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.backgroundImageView.layer.mask = maskLayer;
    }
}
// MARK: - 回答
- (void)configSharedQuestionAnswerUI {
    CGSize bubbleSize = CGSizeMake(SCREEN_WIDTH - (self.avatarSize + 20) * 2, 75);
    self.bubbleViewWidth = bubbleSize.width;
    
    self.shareTitleLabel.numberOfLines = 1;
    self.textContentLabel.numberOfLines = 2;
    self.textContentLabel.font = [UIFont systemFontOfSize:12];
    self.iconImageView.hidden = YES;
    self.coverImageView.hidden = YES;
    self.shareTitleLabel.textColor = [UIColor colorWithRed:93 / 255.0 green:184 / 255.0 blue:216 / 255.0 alpha:1];
    self.textContentLabel.textColor = [UIColor colorWithRed:102 / 255.0 green:102 / 255.0 blue:102 / 255.0 alpha:1];
    
    if (self.model.isSender) {
        // 发送方
        self.shareTitleLabel.frame = CGRectMake(12, 12, self.bubbleViewWidth  - (13 + 13), 14);
        self.textContentLabel.frame = CGRectMake(self.shareTitleLabel.frame.origin.x, CGRectGetMaxY(self.shareTitleLabel.frame) + 5, self.shareTitleLabel.frame.size.width, 35);
        self.backgroundImageView.frame = CGRectMake(CGRectGetMaxX(self.nameLabel.frame) - self.bubbleViewWidth, CGRectGetMaxY(self.nameLabel.frame) + 5, self.bubbleViewWidth, self.bubbleViewHeight);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.backgroundImageView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopLeft cornerRadii:CGSizeMake(12, 12)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.backgroundImageView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.backgroundImageView.layer.mask = maskLayer;
    } else {
        // 接收方
        self.shareTitleLabel.frame = CGRectMake(12, 12, self.bubbleViewWidth  - (13 + 13), 14);
        self.textContentLabel.frame = CGRectMake(self.shareTitleLabel.frame.origin.x, CGRectGetMaxY(self.shareTitleLabel.frame) + 5, self.shareTitleLabel.frame.size.width, 35);
        
        self.backgroundImageView.frame = CGRectMake(CGRectGetMinX(self.nameLabel.frame), CGRectGetMaxY(self.nameLabel.frame) + 5, self.bubbleViewWidth, self.bubbleViewHeight);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.backgroundImageView.bounds byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight cornerRadii:CGSizeMake(12, 12)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.backgroundImageView.bounds;
        maskLayer.path = maskPath.CGPath;
        self.backgroundImageView.layer.mask = maskLayer;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (void)bubbleViewDidTap {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapTSMessageShareInfoCell:model:)]) {
        [self.delegate didTapTSMessageShareInfoCell:self model:self.model];
    }
}
- (void)bgViewDidTapCell {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapTSMessageShareInfoCell:model:)]) {
        [self.delegate didTapTSMessageShareInfoCell:self model:self.model];
    }
}
@end
