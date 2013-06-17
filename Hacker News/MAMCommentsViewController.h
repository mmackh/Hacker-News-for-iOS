//
//  MAMCommentsViewController.h
//  Hacker News
//
//  Created by mmackh on 6/16/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MAMHNStory;

@interface MAMCommentsViewController : UIViewController

@property (weak,nonatomic) MAMHNStory *story;

@end
