//
//  MAMHNController.m
//  Hacker News
//
//  Created by mmackh on 6/15/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import "MAMHNController.h"

@implementation MAMHNController

+ (BOOL)isPad
{
    static BOOL isPad;
    static int isSet = 0;
    if (isSet == 0)
    {
        isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
        isSet = 1;
    }
    return isPad;
}

+ (id)sharedController
{
    static dispatch_once_t onceToken;
    static MAMHNController *hnController;
    dispatch_once(&onceToken, ^{
        hnController = [[self alloc] init];
    });
    return hnController;
}

- (id)init
{
    if((self = [super init]) == nil) return nil;
    
    return self;
}

- (NSArray *)loadStoriesFromCacheOfType:(HNControllerStoryType)storyType
{
    
}

- (void)loadStoriesOfType:(HNControllerStoryType)storyType result:(void(^)(NSArray *results))completionBlock
{
    
}

@end
