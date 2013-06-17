//
//  MAMReaderViewController.h
//  Hacker News
//
//  Created by mmackh on 6/15/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAMHNController.h"

@protocol ReaderViewDelegate <NSObject>

- (void)readerExit;

@end

@interface MAMReaderViewController : UIViewController

@property (weak, nonatomic) id<ReaderViewDelegate> delegate;

- (void)setStory:(MAMHNStory *)story;
- (MAMHNStory *)story;

@end