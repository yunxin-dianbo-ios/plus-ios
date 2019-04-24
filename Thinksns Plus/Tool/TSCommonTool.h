//
//  TSCommonTool.h
//  ThinkSNSPlus
//
//  Created by SmellOfTime on 2018/6/6.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSCommonTool : NSObject
// 字符串是否包含emoji
+ (BOOL)stringContainsEmoji:(NSString *)string;

// 字符串截取
+ (NSString *)getStriingFromString:(NSString *) originalString rang:(NSRange)rang;
// 删除某一个rang的字符串
+ (NSString *)deleteStringFromString:(NSString *) originalString rang:(NSRange)rang;
// 处理@我的的输入框
+ (UITextView *)atMeTextViewEdit:(UITextView*) textView;

@end
