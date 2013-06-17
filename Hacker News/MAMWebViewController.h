//
//  MAMWebViewController.h
//  Hacker News
//
//  Created by mmackh on 6/16/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAMWebViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (void)loadURL:(NSURL *)URL;

@end
