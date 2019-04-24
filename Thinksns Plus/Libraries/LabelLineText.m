//
//  LabelLineText.m
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/7/17.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

#import "LabelLineText.h"
#import <CoreText/CoreText.h>

@implementation rangeModel

@end


@implementation LabelLineText

+ (NSArray *)getSeparatedLinesFromLabel:(UILabel *)label
{
    NSString *text = [label text];
    UIFont   *font = [label font];
    CGRect    rect = [label frame];
    CTFontRef myFont = CTFontCreateWithName((__bridge CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithAttributedString:label.attributedText];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)myFont range:NSMakeRange(0, attStr.length)];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,100000));
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    
    for (id line in lines)
    {
        CTLineRef lineRef = (__bridge CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        
        NSString *lineString = [text substringWithRange:range];
        [linesArray addObject:lineString];
    }
    return linesArray;
}

+ (NSArray *)getSeparatedLinesRangeFromLabel:(UILabel *)label
{
    NSString *text = [label text];
    UIFont   *font = [label font];
    CGRect    rect = [label frame];
    CTFontRef myFont = CTFontCreateWithName((__bridge CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithAttributedString:label.attributedText];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)myFont range:NSMakeRange(0, attStr.length)];

    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);

    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,100000));

    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);

    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];

    for (id line in lines)
    {
        CTLineRef lineRef = (__bridge CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        rangeModel *model = [[rangeModel alloc] init];
        model.locations = range.location;
        model.locations = range.length;
        [linesArray addObject:model];
    }
    return linesArray;
}

+ (NSArray *)getSeparatedLinesFromLabel:(NSAttributedString *)labelString frame:(CGRect)Labelframe {
    CGRect    rect = Labelframe;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithAttributedString:labelString];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,100000));
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    
    for (id line in lines)
    {
        CTLineRef lineRef = (__bridge CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        
        NSAttributedString *lineString = [labelString attributedSubstringFromRange:range];
        [linesArray addObject:lineString];
    }
    return linesArray;
}

+ (NSArray *)getSeparatedLinesFromLabelAddAttribute:(NSAttributedString *)labelString frame:(CGRect)Labelframe attribute:(NSDictionary *)attribute {
    CGRect    rect = Labelframe;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithAttributedString:labelString];
    [attStr addAttributes:attribute range:NSMakeRange(0, attStr.length)];
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,100000));
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    
    for (id line in lines)
    {
        CTLineRef lineRef = (__bridge CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        
        NSAttributedString *lineString = [labelString attributedSubstringFromRange:range];
        [linesArray addObject:lineString];
    }
    return linesArray;
}

+ (NSArray *)getSeparatedLinesRangeFromLabel:(NSAttributedString *)labelString frame:(CGRect)Labelframe {
    CGRect    rect = Labelframe;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithAttributedString:labelString];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,100000));
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    
    for (id line in lines)
    {
        CTLineRef lineRef = (__bridge CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        rangeModel *model = [[rangeModel alloc] init];
        model.locations = range.location;
        model.locations = range.length;
        [linesArray addObject:model];
    }
    return linesArray;
}

+ (NSArray *)getSeparatedLinesRangeFromLabelAddAttribute:(NSAttributedString *)labelString frame:(CGRect)Labelframe attribute:(NSDictionary *)attribute {
    CGRect    rect = Labelframe;
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithAttributedString:labelString];
    [attStr addAttributes:attribute range:NSMakeRange(0, attStr.length)];
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,100000));
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    
    for (id line in lines)
    {
        CTLineRef lineRef = (__bridge CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        rangeModel *model = [[rangeModel alloc] init];
        model.locations = range.location;
        model.locations = range.length;
        [linesArray addObject:model];
    }

    return linesArray;
}

+ (NSArray *)rangeOfSubString:(NSString *)subStr inString:(NSString *)string {
    
    NSMutableArray *rangeArray = [NSMutableArray array];
    NSString *temp;
    for (int i = 0; i < string.length;) {
        if (i + subStr.length > string.length) {
            break ;
        }
        temp = [string substringWithRange:NSMakeRange(i, subStr.length)];
        if ([temp isEqualToString:subStr]) {
            NSRange range = {i,subStr.length};
            [rangeArray addObject:NSStringFromRange(range)];
            i = i + (int)subStr.length;
        } else {
            i ++;
        }
    }
    return rangeArray;
}

@end
