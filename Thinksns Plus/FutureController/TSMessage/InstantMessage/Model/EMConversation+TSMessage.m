//
//  EMConversation+TSMessage.m
//  ThinkSNSPlus
//
//  Created by SmellOfTime on 2018/5/12.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

#import "EMConversation+TSMessage.h"

static const void *kGroupInfo = "KeyEMConversationTSMessageGroupInfo";
static const void *kEMConversationIsBlocked = "kEMConversationIsBlocked";

@implementation EMConversation (TSMessage)

// 给群聊添加群信息
- (NSDictionary *)groupInfo {
    return objc_getAssociatedObject(self, kGroupInfo);
}

- (void)setGroupInfo:(NSDictionary *)groupInfo {
    objc_setAssociatedObject(self, kGroupInfo, groupInfo, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
// 是否屏蔽了会话
- (BOOL)isBlocked {
    return [objc_getAssociatedObject(self, kEMConversationIsBlocked) boolValue];
}
- (void)setIsBlocked:(BOOL)isBlocked {
    objc_setAssociatedObject(self, kEMConversationIsBlocked, @(isBlocked), OBJC_ASSOCIATION_COPY_NONATOMIC);
}
@end
