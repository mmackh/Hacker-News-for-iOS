//
//  MAMReaderViewController.m
//  Hacker News
//
//  Created by mmackh on 6/15/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import "MAMReaderViewController.h"

// Dependancies
#import "MAMCommentsViewController.h"
#import "MAMWebViewController.h"
#import "NSString+Additions.h"

@interface MAMReaderViewController () <UIGestureRecognizerDelegate,UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation MAMReaderViewController
{
    __weak MAMHNStory *_story;
    NSMutableString *_string;
}

#pragma mark -
#pragma mark View Lifecycle

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
    [self.webView.scrollView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 44, 0)];
    
    UITapGestureRecognizer *imageTapDetector = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)];
    [imageTapDetector setNumberOfTapsRequired:1];
    [imageTapDetector setDelegate:self];
    [imageTapDetector setDelaysTouchesBegan:YES];
    [self.webView addGestureRecognizer:imageTapDetector];
}

#pragma mark -
#pragma mark Navigation

- (IBAction)back:(id)sender
{
    [_delegate readerExit];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark -
#pragma mark Story Management

- (void)setStory:(MAMHNStory *)story
{
    _story = story;
    
    NSString *storyLink = story.link.localCachePath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:storyLink])
    {
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:storyLink] cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:20]];
        return;
    }
    
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
    NSMutableString *string = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"view" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil] mutableCopy];
    [string replaceOccurrencesOfString:@"**[title]**" withString:_story.title options:0 range:NSMakeRange(0, string.length)];
    [string replaceOccurrencesOfString:@"**[points]**" withString:_story.score options:0 range:NSMakeRange(0, string.length)];
    [string replaceOccurrencesOfString:@"**[domain]**" withString:_story.domain options:0 range:NSMakeRange(0, string.length)];
    [string replaceOccurrencesOfString:@"**[link]**" withString:_story.link options:0 range:NSMakeRange(0, string.length)];
    _string = string;
    [self.webView loadHTMLString:string baseURL:nil];
    __weak MAMReaderViewController *weakSelf = self;
    [_story loadClearReadLoadBody:^(NSString *resultBody)
     {
         NSString *clearReadDocument = [_string stringByReplacingOccurrencesOfString:@"Loading...  " withString:resultBody options:0 range:NSMakeRange(0, _string.length)];
         [clearReadDocument writeToFile:storyLink atomically:NO encoding:NSUTF8StringEncoding error:nil];
         NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:storyLink]];
         [weakSelf.webView loadRequest:request];
     }];
}

- (MAMHNStory *)story
{
    return _story;
}

#pragma mark -
#pragma mark WebView

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeReload)
    {
        NSLog(@"%@",request.URL);
    }
    if (navigationType == UIWebViewNavigationTypeLinkClicked)
    {
        [self performSegueWithIdentifier:@"toWeb" sender:request];
        return NO;
    }
    return YES;
}

- (void)tapDetected:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateRecognized)
    {
        CGPoint touchPoint = [tap locationInView:self.view];
        NSString *imageURL = [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", touchPoint.x, touchPoint.y]];
        static NSSet *imageFormats;
        if (!imageFormats.count)
        {
            imageFormats = [NSSet setWithObjects:@"jpg",@"jpeg",@"bmp",@"png",nil];
        }
        if ([imageFormats containsObject:imageURL.pathExtension])
        {
            NSCachedURLResponse *response = [[NSURLCache sharedURLCache] cachedResponseForRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:imageURL] cachePolicy:NSURLRequestReturnCacheDataDontLoad timeoutInterval:11]];
            NSLog(@"%@",response);
        }
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toWeb"])
    {
        NSURLRequest *URLRequest = sender;
        MAMWebViewController *webViewController = segue.destinationViewController;
        [webViewController loadURL:URLRequest.URL];
    }
    
    if ([segue.identifier isEqualToString:@"toComments"])
    {
        MAMCommentsViewController *commentsViewController = segue.destinationViewController;
        [commentsViewController setStory:self.story];
    }
}

@end
