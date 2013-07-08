//
//  MAMInstapaperActivity.m
//  Hacker News
//
//  Created by mmackh on 7/8/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import "MAMInstapaperActivity.h"

static NSString * const InstapaperActivityURI = @"ihttp://";

@implementation MAMInstapaperActivity

- (NSString *)activityType
{
    return @"UIActivityInstapaper";
}

- (NSString *)activityTitle
{
    return @"Instapaper";
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)?@"instapaper-ipad":@"instapaper"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    if (![MAMInstapaperActivity canPerformActivity]) {
        return NO;
    }
    for (NSObject *item in activityItems) {
        if (![item isKindOfClass:[NSURL class]] && ![item isKindOfClass:[NSString class]]) {
            return NO;
        }
    }
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    _activityItems = activityItems;
}

- (void)performActivity {
    if ([MAMInstapaperActivity canPerformActivity]){
        NSString *activityURL = nil;
        
        if([_activityItems[0] isKindOfClass:[NSURL class]]) {
            activityURL = [_activityItems[0] absoluteString];
            
        } else {
            activityURL = _activityItems[0];
        }
        NSString *instapaperURLString = [NSString stringWithFormat:@"i%@",activityURL];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:instapaperURLString]];
        [self activityDidFinish:YES];
    } else{
        [self activityDidFinish:NO];
    }
}

+ (BOOL)canPerformActivity {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:InstapaperActivityURI]])
    {
        return YES;
    }
    
    return NO;
}

@end
