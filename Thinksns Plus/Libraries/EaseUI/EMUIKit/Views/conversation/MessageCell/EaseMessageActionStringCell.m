//
//  EaseMessageActionStringCell.m
//  ThinkSNSPlus
//
//  Created by SmellOfTime on 2018/4/24.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

#import "EaseMessageActionStringCell.h"

@interface EaseMessageActionStringCell()

@end

@implementation EaseMessageActionStringCell
+ (void)initialize
{

}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self _setupSubview];
    }
    
    return self;
}

#pragma mark - setup subviews

- (void)_setupSubview
{
    self.noticeLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 140, 18)];
    self.noticeLabel.backgroundColor = [UIColor grayColor];
    self.noticeLabel.text = @"快速                  ,开启群聊";
    self.noticeLabel.textColor = [UIColor whiteColor];
    self.noticeLabel.textAlignment = NSTextAlignmentCenter;
    self.noticeLabel.font = [UIFont systemFontOfSize:10];
    self.noticeLabel.layer.cornerRadius = 18 / 2.0;;
    self.noticeLabel.clipsToBounds = YES;
    [self.contentView addSubview:self.noticeLabel];
    self.noticeLabel.center = CGPointMake(([UIScreen mainScreen].bounds.size.width - 140) / 2.0, 34.5 / 2.0);
    
    UIButton *touchBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.noticeLabel.center.x - 30, 0, 80, self.noticeLabel.frame.size.height)];
    [touchBtn addTarget:self action:@selector(actionBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    touchBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    touchBtn.center = CGPointMake(touchBtn.center.x, self.noticeLabel.center.y);
    [touchBtn setTitle:@"编辑群名称" forState:UIControlStateNormal];
    [touchBtn setTitleColor:[UIColor colorWithRed:89 / 255.0 green:182 / 255.0 blue:215 / 255.0 alpha:1] forState:UIControlStateNormal];
    [self.contentView addSubview:touchBtn];
    self.actionBtn = touchBtn;
}

- (void)actionBtnClick:(UIButton*)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.ts-plus.notification.name.chat.clickEditGroupBtn" object:nil];
}

#pragma mark - public

+ (NSString *)cellIdentifier
{
    return @"EaseMessageActionStringCell";
}

@end
