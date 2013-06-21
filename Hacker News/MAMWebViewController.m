//
//  MAMWebViewController.m
//  Hacker News
//
//  Created by mmackh on 6/16/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import "MAMWebViewController.h"
#import "TUSafariActivity.h"

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
    
    BOOL isPad = [MAMHNController isPad];
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake((isPad)?44:0, 0, (isPad)?0:44, 0);
    [self.webView.scrollView setScrollIndicatorInsets:edgeInsets];
    [self.webView.scrollView setContentInset:edgeInsets];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:_URLToLoad]];
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
    NSURL *URL = self.webView.request.URL;
    TUSafariActivity *activity = [[TUSafariActivity alloc] init];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[URL] applicationActivities:@[activity]];
    [activityViewController setExcludedActivityTypes:@[UIActivityTypePostToWeibo]];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)loadURL:(NSURL *)URL
{
    _URLToLoad = URL;
}

@end
