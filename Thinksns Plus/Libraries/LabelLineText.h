//
//  LabelLineText.h
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/7/17.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

#import <Foundation/Foundation.h>

@class rangeModel;

@interface rangeModel : NSObject

@property (assign, nonatomic) NSInteger locations;
@property (assign, nonatomic) NSInteger lengths;

@end

@interface LabelLineText : NSObject

@property (strong, nonatomic) rangeModel *model;
+ (NSArray *)getSeparatedLinesFromLabel:(UILabel *)label;
+ (NSArray *)getSeparatedLinesRangeFromLabel:(UILabel *)label;

+ (NSArray *)getSeparatedLinesFromLabel:(NSAttributedString *)labelString frame:(CGRect)Labelframe;
+ (NSArray *)getSeparatedLinesFromLabelAddAttribute:(NSAttributedString *)labelString frame:(CGRect)Labelframe attribute:(NSDictionary *)attribute;
+ (NSArray *)getSeparatedLinesRangeFromLabel:(NSAttributedString *)labelString frame:(CGRect)Labelframe;
+ (NSArray *)getSeparatedLinesRangeFromLabelAddAttribute:(NSAttributedString *)labelString frame:(CGRect)Labelframe attribute:(NSDictionary *)attribute;

/// 获取一个字符串里面包含某串字符的所有range数组
+ (NSArray *)rangeOfSubString:(NSString *)subStr inString:(NSString *)string;

@end
