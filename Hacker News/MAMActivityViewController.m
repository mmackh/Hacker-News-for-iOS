//
//  MAMActivityViewController.m
//  Hacker News
//
//  Created by Zach Orr on 7/9/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import "MAMActivityViewController.h"

// UIActivities
#import "PocketAPIActivity.h"
#import "ReadabilityActivity.h"
#import "MAMInstapaperActivity.h"
#import "TUSafariActivity.h"

@implementation MAMActivityViewController

+ (UIActivityViewController*)controllerForURL:(NSURL*)URL
{
    NSMutableArray *activities = [NSMutableArray new];
    TUSafariActivity *safariActivity = [[TUSafariActivity alloc] init];
    [activities addObject:safariActivity];
    PocketAPIActivity *pocketActivity = [[PocketAPIActivity alloc] init];
    [activities addObject:pocketActivity];
    if ([ReadabilityActivity canPerformActivity])
    {
        ReadabilityActivity *readabilityActivity = [[ReadabilityActivity alloc] init];
        [activities addObject:readabilityActivity];
    }
    if ([MAMInstapaperActivity canPerformActivity])
    {
        MAMInstapaperActivity *instapaperActivity = [[MAMInstapaperActivity alloc] init];
        [activities addObject:instapaperActivity];
    }
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[URL] applicationActivities:activities];
    [activityViewController setExcludedActivityTypes:@[UIActivityTypePostToWeibo]];
    return activityViewController;
}

@end
