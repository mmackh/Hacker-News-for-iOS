//
//  MAMHNStory.h
//  Hacker News
//
//  Created by mmackh on 6/15/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAMHNStory : NSObject <NSCoding>

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *description;
@property (nonatomic,copy) NSString *pubDate;
@property (nonatomic,copy) NSString *score;
@property (nonatomic,copy) NSString *user;
@property (nonatomic,copy) NSString *link;
@property (nonatomic,copy) NSString *discussionLink;
@property (nonatomic,copy) NSString *commentsValue;
@property (nonatomic,copy) NSString *hostValue;
@property (nonatomic,copy) NSString *hnID;
@property (nonatomic,copy) NSString *clearBody;
@property (nonatomic,assign) BOOL alreadyRead;

- (NSString *)subtitle;
- (NSString *)footer;

- (NSString *)domain;
- (void)loadClearReadLoadBody:(void(^)(NSString *resultBody, MAMHNStory *story, BOOL success))completionBlock;

@end
