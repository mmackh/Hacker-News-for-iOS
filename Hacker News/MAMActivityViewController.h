//
//  MAMActivityViewController.h
//  Hacker News
//
//  Created by Zach Orr on 7/9/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MAMActivityViewController : NSObject

+ (UIActivityViewController*)controllerForURL:(NSURL*)URL;

@end
