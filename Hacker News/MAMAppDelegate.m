//
//  MAMAppDelegate.m
//  Hacker News
//
//  Created by mmackh on 6/15/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import "MAMAppDelegate.h"
#import "PocketAPI.h"
#import "Constants.h"

@implementation MAMAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    int cacheSizeMemory = 10*1024*1024;
    int cacheSizeDisk = 100*1024*1024;
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory diskCapacity:cacheSizeDisk diskPath:@"hncache"];
    [NSURLCache setSharedURLCache:sharedCache];
    
    NSString *pocketConsumerKey = @"";
    if ([(NSString*)[UIDevice currentDevice].model isEqualToString:@"iPad"])
    {
        pocketConsumerKey = kPocketConsumerKeyiPad;
    }
    else
    {
        pocketConsumerKey = kPocketConsumerKeyiPhone;
    }
    [[PocketAPI sharedAPI] setConsumerKey:pocketConsumerKey];
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if([[PocketAPI sharedAPI] handleOpenURL:url])
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

@end
