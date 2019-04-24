//
//  EaseMessageActionStringCell.h
//  ThinkSNSPlus
//
//  Created by SmellOfTime on 2018/4/24.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EaseMessageActionStringCell : UITableViewCell
@property (strong, nonatomic) UILabel *noticeLabel;
@property (strong, nonatomic) UIButton *actionBtn;

+ (NSString *)cellIdentifier;

@end
