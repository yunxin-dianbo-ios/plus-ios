//
//  TSMessageShareInfoCell.h
//  ThinkSNSPlus
//
//  Created by IMAC on 2018/8/16.
//  Copyright © 2018年 ZhiYiCX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TYAttributedLabel/TYAttributedLabel.h>
#import "IMessageModel.h"
#import "EaseUI.h"
#import "EaseMessageCell.h"

@protocol TSMessageShareInfoCellDelegate;
@interface TSMessageShareInfoCell : UITableViewCell
// base
@property (strong, nonatomic) UIImageView *backgroundImageView;
@property (strong, nonatomic) UIImageView *avatarView;
@property (strong, nonatomic) UILabel *nameLabel;
/**认证图标 */
@property (strong, nonatomic) UIImageView *userIconView;

//text views
@property (strong, nonatomic) TYAttributedLabel *textContentLabel;
// 标题
@property (strong, nonatomic) UILabel *shareTitleLabel;
// 封面图标
@property (strong, nonatomic) UIImageView *coverImageView;
// 小图标
@property (strong, nonatomic) UIImageView *iconImageView;
// model
@property (strong, nonatomic) id<IMessageModel> model;

@property (weak, nonatomic) id<TSMessageShareInfoCellDelegate> delegate;
- (void)creatUI;
- (void)updataInfoModel:(id<IMessageModel>)model;

@end

@protocol TSMessageShareInfoCellDelegate <NSObject>
@optional

- (void)didTapTSMessageShareInfoCell:(TSMessageShareInfoCell*)cell model:(id<IMessageModel>)model;

@end
