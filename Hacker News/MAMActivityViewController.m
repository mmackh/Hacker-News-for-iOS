//
//  MAMActivityViewController.m
//  Hacker News
//
//  Created by Zach Orr on 7/9/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import "MAMActivityViewController.h"
#import "NSString+Additions.h"

// UIActivities
#import "PocketAPIActivity.h"
#import "ReadabilityActivity.h"
#import "MAMInstapaperActivity.h"
#import "TUSafariActivity.h"

@implementation MAMActivityViewController

+ (UIActivityViewController*)controllerForURL:(NSURL*)URL
{
    static NSArray *activities = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,
    ^{
        NSMutableArray *mutableActivities = [NSMutableArray new];
        TUSafariActivity *safariActivity = [[TUSafariActivity alloc] init];
        [mutableActivities addObject:safariActivity];
        PocketAPIActivity *pocketActivity = [[PocketAPIActivity alloc] init];
        [mutableActivities addObject:pocketActivity];
        if ([ReadabilityActivity canPerformActivity])
        {
            ReadabilityActivity *readabilityActivity = [[ReadabilityActivity alloc] init];
            [mutableActivities addObject:readabilityActivity];
        }
        if ([MAMInstapaperActivity canPerformActivity])
        {
            MAMInstapaperActivity *instapaperActivity = [[MAMInstapaperActivity alloc] init];
            [mutableActivities addObject:instapaperActivity];
        }
        activities = mutableActivities.copy;
    });
    UIActivityViewController *activityViewController = [[super alloc] initWithActivityItems:@[URL] applicationActivities:activities];
    [activityViewController setExcludedActivityTypes:@[UIActivityTypePostToWeibo]];
    return activityViewController;
}

@end
