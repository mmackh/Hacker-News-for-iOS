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
    UIActivityViewController *activityViewController = [[super alloc] initWithActivityItems:@[URL] applicationActivities:activities];
    [activityViewController setExcludedActivityTypes:@[UIActivityTypePostToWeibo]];
    return activityViewController;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) return;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) return;
    NSString *cls = [@"VUlBY3Rpdml0eUNhbmNlbEJ1dHRvbg==" base64Decode];
    for (id view in [[self.view.subviews objectAtIndex:0] subviews]) {
        if ([view isKindOfClass:[UIImageView class]])
        {
            UIImageView *background = view;
            [background setImage:[[UIImage alloc] init]];
            [background setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.9]];
        }
        if ([view isKindOfClass:NSClassFromString(cls)])
        {
            for (id subview in [view subviews])
            {
                if ([subview isKindOfClass:[UIImageView class]])
                {
                    [subview removeFromSuperview];
                }
            }
        }
    }
}

@end
