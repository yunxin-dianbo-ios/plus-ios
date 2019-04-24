//
//  EaseCallRecordMessageCell.m
//  ThinkSNS（探索版）
//
//  Created by LiuYu on 2017/5/5.
//  Copyright © 2017年 zhiyicx. All rights reserved.
//

#import "EaseCallRecordMessageCell.h"
#import <Masonry/Masonry.h>

@interface EaseCallRecordMessageCell ()



@end

const static CGFloat sizeWidth = 20;
const static CGFloat sizeHeight = sizeWidth;
const static CGFloat topSpace = 5;
const static CGFloat letfSenderType = 8;
const static CGFloat letfnotSenderType = 15;

@implementation EaseCallRecordMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier model:(id<IMessageModel>)model {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier model:model];
    if (self) {
        self.avatarSize = 40;
        self.avatarCornerRadius = 20;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setModel:(id<IMessageModel>)model {

    if (![model.text hasPrefix:@"     "]) {
        model.text = [NSString stringWithFormat:@"     %@",model.text];
    }

    [super setModel:model];
    
//    CGFloat tagImageLeftSpace = letfSenderType;//model.message.direction == EMMessageDirectionSend ? letfSenderType : letfnotSenderType;
//
//    __weak typeof(self) weakSelf = self;
//    if (!self.callTagImage) {
//        self.callTagImage = [[UIImageView alloc] init];
//        [self.bubbleView addSubview:self.callTagImage];
//        [self.callTagImage mas_makeConstraints:^(MASConstraintMaker *make) {
////            make.top.equalTo(weakSelf.bubbleView.mas_top).offset(topSpace);
//            make.left.equalTo(weakSelf.bubbleView.mas_left).offset(tagImageLeftSpace);
//            make.size.mas_equalTo(CGSizeMake(sizeWidth, sizeHeight));
//            make.centerY.equalTo(weakSelf.bubbleView.textLabel.mas_centerY);
//        }];
//    } else {
//        [self.callTagImage mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(weakSelf.bubbleView.mas_left).offset(tagImageLeftSpace);
//        }];
//    }
//
//    NSString *callType = [model.message.ext objectForKey:@"callType"];
//    BOOL isVoiceType = [callType isEqualToString:@"voice"];
//
//    if (model.message.direction == EMMessageDirectionSend) {
//        self.callTagImage.image = [UIImage imageNamed: isVoiceType ? @"btn_chat_bluephone" : @"btn_chat_bluevideo"];
//    }else if (model.message.direction == EMMessageDirectionReceive) {
//        self.callTagImage.image = [UIImage imageNamed: isVoiceType ? @"btn_chat_greyphone" : @"btn_chat_greyvideo"];
//    }
}


@end
