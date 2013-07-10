//
//  MAMSingleton.h
//  Hacker News
//
//  Created by Zach Orr on 7/9/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAMSingleton : NSObject

+ (MAMSingleton*)sharedSingleton;
- (UIActivityViewController*)activityViewControllerForURL:(NSURL*)URL;

@end
