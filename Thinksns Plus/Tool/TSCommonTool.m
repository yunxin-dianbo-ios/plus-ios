//
//  TSCommonTool.m
//  ThinkSNSPlus
//
//  Created by SmellOfTime on 2018/6/6.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

#import "TSCommonTool.h"

@implementation TSCommonTool

+ (BOOL)stringContainsEmoji:(NSString *)string {
    __block BOOL returnValue = NO;
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         const unichar hs = [substring characterAtIndex:0];
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f9de) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3 || ls == 0xfe0f || ls == 0xd83c) {
                 returnValue = YES;
             }
         } else {
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    return returnValue;
}
// 字符串截取
+ (NSString *)getStriingFromString:(NSString *) originalString rang:(NSRange)rang {
    NSString *resultString = [originalString substringWithRange:rang];
    return resultString;
}
// 删除某一个rang的字符串
+ (NSString *)deleteStringFromString:(NSString *) originalString rang:(NSRange)rang {
    NSString *resultString;
    NSString *subStr = [originalString substringToIndex:rang.location];
    NSString *endStr = [originalString substringFromIndex:rang.location + rang.length];
    resultString = [NSString stringWithFormat:@"%@%@", subStr, endStr];
    return resultString;
}
+ (UITextView *)atMeTextViewEdit:(UITextView*) textView {
    NSRange selectedRange = textView.selectedRange;
    if (selectedRange.location > 0) {
        NSString *editLeftChar = [textView.text substringWithRange:NSMakeRange(selectedRange.location - 1, 1)];
        if ([editLeftChar isEqualToString:@"@"]) {
            textView.text = [TSCommonTool deleteStringFromString:textView.text rang:NSMakeRange(selectedRange.location - 1, 1)];
            textView.selectedRange = NSMakeRange(selectedRange.location - 1, 0);
        }
    }
    return textView;
}

@end
