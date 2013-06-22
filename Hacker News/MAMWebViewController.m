//
//  MAMWebViewController.m
//  Hacker News
//
//  Created by mmackh on 6/16/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import "MAMWebViewController.h"
#import "TUSafariActivity.h"

@interface MAMWebViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@end

@implementation MAMWebViewController
{
    NSURL *_URLToLoad;
    
    // iPad Specifics
    UIPopoverController *_popoverController;
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
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake((isPad)?0:0, 0, (isPad)?0:44, 0);
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
    
    if ([MAMHNController isPad])
    {
        _popoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        [_popoverController presentPopoverFromRect:self.shareButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else
    {
        [self presentViewController:activityViewController animated:YES completion:nil];
    }
}

- (void)loadURL:(NSURL *)URL
{
    _URLToLoad = URL;
}

#pragma mark -
#pragma mark Gesture Recognizer

- (IBAction)twoSwipeDetected:(id)sender
{
    UIGestureRecognizer *swipe = sender;
    if (swipe.state == UIGestureRecognizerStateRecognized)
    {
        [self dismiss:nil];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
