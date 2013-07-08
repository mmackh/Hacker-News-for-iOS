//
//  MAMInstapaperActivity.h
//  Hacker News
//
//  Created by mmackh on 7/8/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAMInstapaperActivity : UIActivity
{
    @private NSArray *_activityItems;
}

+ (BOOL)canPerformActivity;

@end
