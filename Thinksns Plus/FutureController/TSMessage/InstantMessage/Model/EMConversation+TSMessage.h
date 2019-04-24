//
//  EMConversation+TSMessage.h
//  ThinkSNSPlus
//
//  Created by SmellOfTime on 2018/5/12.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

#import <Hyphenate/Hyphenate.h>
#import <objc/runtime.h>

@interface EMConversation (TSMessage)

@property(nonatomic, strong) NSDictionary * groupInfo;
// 是否屏蔽了会话
@property(nonatomic, assign) BOOL isBlocked;
@end
