//
//  MAMReaderViewController.m
//  Hacker News
//
//  Created by mmackh on 6/15/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import "MAMReaderViewController.h"

@interface MAMReaderViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation MAMReaderViewController

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
    for(UIView *view in [[[self.webView subviews] objectAtIndex:0] subviews]) {
        if([view isKindOfClass:[UIImageView class]]) { view.hidden = YES; }
    }
    [self.webView loadHTMLString:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"view" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil] baseURL:nil];
}

- (IBAction)back:(id)sender
{
    [_delegate readerExit];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

@end
