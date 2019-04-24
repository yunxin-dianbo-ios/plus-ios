//
//  IMMessageSourceTool.m
//  ThinkSNSPlus
//
//  Created by SmellOfTime on 2018/4/20.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

#import "IMMessageSourceTool.h"

@implementation IMMessageSourceTool
// 发送语音动画
+ (NSArray *)sendMessageVoiceAnimationImages {
    return @[[UIImage imageNamed:@"ico_bofan_blackfull"],[UIImage imageNamed:@"ico_bofan_black003"],[UIImage imageNamed:@"ico_bofan_black001"],[UIImage imageNamed:@"ico_bofan_black002"],[UIImage imageNamed:@"ico_bofan_black003"]];
}
+ (NSArray *)recvMessageVoiceAnimationImages {
    return @[[UIImage imageNamed:@"ico_bofan_greyfull"],[UIImage imageNamed:@"ico_bofan_grey001"],[UIImage imageNamed:@"ico_bofan_grey002"],[UIImage imageNamed:@"ico_bofan_grey003"]];
}
@end
