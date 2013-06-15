//
//  MAMRefreshControl.m
//  Hacker News
//
//  Created by mmackh on 6/15/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import "MAMRefreshControl.h"

@implementation MAMRefreshControl

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews
{
    UIScrollView* parentScrollView = (UIScrollView*)[self superview];
    
    CGSize viewSize = parentScrollView.frame.size;
    
    if (parentScrollView.contentInset.top + parentScrollView.contentOffset.y == 0 && !self.refreshing) {
        self.hidden = YES;
    } else {
        self.hidden = NO;
    }
    
    CGFloat y = parentScrollView.contentOffset.y + parentScrollView.scrollIndicatorInsets.top;
    
    self.frame = CGRectMake(0, y, viewSize.width, viewSize.height);
    self.backgroundColor = [parentScrollView backgroundColor];
    [super layoutSubviews];
}

@end
