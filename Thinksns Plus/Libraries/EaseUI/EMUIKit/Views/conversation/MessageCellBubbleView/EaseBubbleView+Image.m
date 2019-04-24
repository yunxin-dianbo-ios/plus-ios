/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */


#import "EaseBubbleView+Image.h"

@implementation EaseBubbleView (Image)

#pragma mark - private

- (void)_setupImageBubbleMarginConstraints
{
//    NSLayoutConstraint *marginTopConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:self.margin.top];
//    NSLayoutConstraint *marginBottomConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:-self.margin.bottom];
//    NSLayoutConstraint *marginLeftConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.margin.right];
//    NSLayoutConstraint *marginRightConstraint = [NSLayoutConstraint constraintWithItem:self.imageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:self.margin.left];
//
//    [self.marginConstraints removeAllObjects];
//    [self.marginConstraints addObject:marginTopConstraint];
//    [self.marginConstraints addObject:marginBottomConstraint];
//    [self.marginConstraints addObject:marginLeftConstraint];
//    [self.marginConstraints addObject:marginRightConstraint];
//
//    [self addConstraints:self.marginConstraints];
//    self.imageView.bounds = self.backgroundImageView.bounds;
}

- (void)_setupImageBubbleConstraints
{
    [self _setupImageBubbleMarginConstraints];
}

#pragma mark - public

- (void)setupImageBubbleView
{
    self.imageView = [[UIImageView alloc] init];
//    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.imageView.backgroundColor = [UIColor clearColor];
    self.bottomBgView = [[UIView alloc] init];
    self.bottomBgView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.9];
    self.bottomBgView.clipsToBounds = YES;
    [self.imageView addSubview:self.bottomBgView];
    
    self.bottomTitleLabel = [[UILabel alloc] init];
    self.bottomTitleLabel.numberOfLines = 1;
    self.bottomTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:12];
    self.bottomTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.bottomTitleLabel.backgroundColor = [UIColor clearColor];
    self.bottomTitleLabel.textColor = [UIColor colorWithRed:51.0 / 255 green:51.0 / 255 blue:51.0 / 255 alpha:1];

    [self.bottomBgView addSubview:self.bottomTitleLabel];

    self.bottomSubTitleLabel = [[UILabel alloc] init];
    self.bottomSubTitleLabel.numberOfLines = 1;
    self.bottomSubTitleLabel.font = [UIFont systemFontOfSize:10];
    self.bottomSubTitleLabel.textAlignment = NSTextAlignmentLeft;
    self.bottomSubTitleLabel.backgroundColor = [UIColor clearColor];
    self.bottomSubTitleLabel.textColor = [UIColor colorWithRed:153.0 / 255 green:153.0 / 255 blue:153.0 / 255 alpha:1];
    [self.bottomBgView addSubview:self.bottomSubTitleLabel];
    [self addSubview:self.imageView];
    
    [self _setupImageBubbleConstraints];
}

- (void)updateImageMargin:(UIEdgeInsets)margin
{
    if (_margin.top == margin.top && _margin.bottom == margin.bottom && _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;
    
    [self removeConstraints:self.marginConstraints];
    [self _setupImageBubbleMarginConstraints];
}

@end
