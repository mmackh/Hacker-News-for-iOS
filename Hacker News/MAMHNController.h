//
//  MAMHNController.h
//  Hacker News
//
//  Created by mmackh on 6/15/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import <Foundation/Foundation.h>

//External Dependancies
#import "MAMHNStory.h"
#import "MAMHNComment.h"

typedef NS_ENUM(NSInteger, HNControllerStoryType)
{
    HNControllerStoryTypeTrending,
    HNControllerStoryTypeNew,
    HNControllerStoryTypeBest
};

@interface MAMHNController : NSObject

// Essentials
+ (id)sharedController;

// Methods
- (NSArray *)loadStoriesFromCacheOfType:(HNControllerStoryType)storyType;
- (void)loadStoriesOfType:(HNControllerStoryType)storyType result:(void(^)(NSArray *results))completionBlock;

- (void)loadCommentsOnStoryWithID:(NSString *)storyID result:(void(^)(NSArray *results))completionBlock;

// Helpers
+ (BOOL)isPad;

@end
