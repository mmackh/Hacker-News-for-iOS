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
    [super layoutSubviews];
    self.frame = CGRectOffset(self.frame, 0, 44);
    self.backgroundColor = self.superview.backgroundColor;
}

@end
