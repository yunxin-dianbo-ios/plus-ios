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


#import "EaseBubbleView+Location.h"

@implementation EaseBubbleView (Location)

- (void)layoutSubviews {
    [super layoutSubviews];
//    
//    CGFloat availableLabelWidth = self.frame.size.width;
//    self.locationLabel.preferredMaxLayoutWidth = availableLabelWidth - 30;
//    
//    [super layoutSubviews];
}

#pragma mark - private

- (void)_setupLocationBubbleMarginConstraints
{
    NSLayoutConstraint *marginTopConstraint = [NSLayoutConstraint constraintWithItem:self.locationImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *marginBottomConstraint = [NSLayoutConstraint constraintWithItem:self.locationImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
    NSLayoutConstraint *marginLeftConstraint = [NSLayoutConstraint constraintWithItem:self.locationImageView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    NSLayoutConstraint *marginRightConstraint = [NSLayoutConstraint constraintWithItem:self.locationImageView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.backgroundImageView attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    
    [self.marginConstraints removeAllObjects];
    [self.marginConstraints addObject:marginTopConstraint];
    [self.marginConstraints addObject:marginBottomConstraint];
    [self.marginConstraints addObject:marginLeftConstraint];
    [self.marginConstraints addObject:marginRightConstraint];
    
    [self addConstraints:self.marginConstraints];
}

- (void)_setupLocationBubbleConstraints
{
    [self _setupLocationBubbleMarginConstraints];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.locationLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.locationImageView attribute:NSLayoutAttributeBottom multiplier: 1.0 constant: -7]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.locationLabel attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.locationImageView attribute:NSLayoutAttributeRight multiplier: 1.0 constant: -9]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.locationLabel attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.locationImageView attribute:NSLayoutAttributeLeft multiplier: 1.0 constant: 9]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.locationLabel attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeHeight multiplier:1 constant: 35]];
}

#pragma mark - public

- (void)setupLocationBubbleView
{
    self.locationImageView = [[UIImageView alloc] init];
    self.locationImageView.translatesAutoresizingMaskIntoConstraints = NO;
    self.locationImageView.backgroundColor = [UIColor clearColor];
    self.locationImageView.clipsToBounds = YES;
    [self addSubview:self.locationImageView];
    self.locationLabel = [[UILabel alloc] init];
    self.locationLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.locationLabel.numberOfLines = 1;
    self.locationLabel.textAlignment = NSTextAlignmentCenter;
    self.locationLabel.backgroundColor = [UIColor clearColor];
    [self.locationImageView addSubview:self.locationLabel];
    
    [self _setupLocationBubbleConstraints];
}

- (void)updateLocationMargin:(UIEdgeInsets)margin
{
    if (_margin.top == margin.top && _margin.bottom == margin.bottom && _margin.left == margin.left && _margin.right == margin.right) {
        return;
    }
    _margin = margin;
    
    [self removeConstraints:self.marginConstraints];
    [self _setupLocationBubbleMarginConstraints];
}

@end
