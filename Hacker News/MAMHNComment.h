//
//  MAMHNComment.h
//  Hacker News
//
//  Created by mmackh on 6/16/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAMHNComment : NSObject

@property (copy,nonatomic) NSString *comment;
@property (copy,nonatomic) NSString *commentID;
@property (copy,nonatomic) NSString *time;
@property (copy,nonatomic) NSString *username;
@property (copy,nonatomic) NSString *replyID;

@property (readwrite) int indentationLevel;

- (UIColor *)color;

@end
