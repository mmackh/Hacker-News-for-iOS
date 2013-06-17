//
//  MAMWebViewController.m
//  Hacker News
//
//  Created by mmackh on 6/16/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import "MAMWebViewController.h"

@interface MAMWebViewController ()

@end

@implementation MAMWebViewController
{
    NSURL *_URLToLoad;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.webView loadRequest:[NSURLRequest requestWithURL:_URLToLoad]];
    [self.webView.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 44, 0)];
    [self.webView.scrollView setContentInset:UIEdgeInsetsMake(0, 0, 44, 0)];
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)back:(id)sender
{
    if ([self.webView canGoBack])
    {
        [self.webView goBack];
    }
}
- (IBAction)forward:(id)sender
{
    if ([self.webView canGoForward])
    {
        [self.webView goForward];
    }
}
- (IBAction)safari:(id)sender
{
    [[UIApplication sharedApplication] openURL:self.webView.request.URL];
}

- (void)loadURL:(NSURL *)URL
{
    _URLToLoad = URL;
}

@end
