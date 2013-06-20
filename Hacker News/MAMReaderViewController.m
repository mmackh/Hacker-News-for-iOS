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
#import <QuartzCore/QuartzCore.h>
#import "TUSafariActivity.h"

typedef NS_ENUM(NSInteger, StoryTransitionType)
{
    StoryTransitionTypeNext,
    StoryTransitionTypePrevious
};

typedef NS_ENUM(NSInteger, FontSizeChangeType)
{
    FontSizeChangeTypeIncrease,
    FontSizeChangeTypeDecrease,
    FontSizeChangeTypeNone
};

@interface MAMReaderViewController () <UIGestureRecognizerDelegate,UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)tabButtonTapped:(id)sender;

@end

@implementation MAMReaderViewController
{
    MAMHNStory *_story;
    NSMutableString *_string;
    int _currentFontSize;
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
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"ftsz"] == nil)
    {
        _currentFontSize = 100;
    }
    else
    {
        _currentFontSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"ftsz"];
    }
    
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
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.innerHTML = \"\";"];
    
    NSString *storyLink = story.link.localCachePath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:storyLink])
    {
        NSString *htmlString = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:storyLink] encoding:NSUTF8StringEncoding error:nil];
        [self.webView loadHTMLString:htmlString baseURL:nil];
        return;
    }
    
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
#pragma mark Fontsize Change

- (IBAction)fontSizePinch:(id)sender
{
    UIPinchGestureRecognizer *pinch = sender;
    if (pinch.state == UIGestureRecognizerStateRecognized)
    {
        [self changeFontSize:(pinch.scale > 1)?FontSizeChangeTypeIncrease:FontSizeChangeTypeDecrease];
    }
}

- (void)changeFontSize:(FontSizeChangeType)changeType
{
    if (changeType == FontSizeChangeTypeIncrease && _currentFontSize == 160) return;
    if (changeType == FontSizeChangeTypeDecrease && _currentFontSize == 50) return;
    if (changeType != FontSizeChangeTypeNone)
    {
        _currentFontSize = (changeType == FontSizeChangeTypeIncrease) ? _currentFontSize + 5 : _currentFontSize - 5;
        [[NSUserDefaults standardUserDefaults] setInteger:_currentFontSize forKey:@"ftsz"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    NSString *jsString = [[NSString alloc] initWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%d%%'",
                          _currentFontSize];
    [self.webView stringByEvaluatingJavaScriptFromString:jsString];
}


#pragma mark -
#pragma mark WebView

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self changeFontSize:FontSizeChangeTypeNone];
}

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

- (IBAction)tabButtonTapped:(id)sender
{
    int numberOfButtonTapped = [sender tag];
    switch (numberOfButtonTapped)
    {
        case 0:
            [self back:nil];
            break;
        case 1:
            [self transitionToStory:StoryTransitionTypePrevious];
            break;
        case 2:
            [self transitionToStory:StoryTransitionTypeNext];
            break;
        case 3:
            [self performSegueWithIdentifier:@"toComments" sender:nil];
            break;
        case 4:
        {
            NSURL *URL = [NSURL URLWithString:self.story.link];
            TUSafariActivity *activity = [[TUSafariActivity alloc] init];
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[URL] applicationActivities:@[activity]];
            [activityViewController setExcludedActivityTypes:@[UIActivityTypePostToWeibo]];
            [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
        }
            break;
    }
}

- (void)transitionToStory:(StoryTransitionType)transitionType
{
    MAMHNController *hnController = [MAMHNController sharedController];
    MAMHNStory *story = (transitionType == StoryTransitionTypeNext) ? [hnController nextStory:_story] : [hnController previousStory:_story];
    if (story == nil) return;
    
    CATransition *animation = [CATransition animation];
    [animation setType:kCATransitionPush];
    [animation setSubtype:(transitionType == StoryTransitionTypeNext ? kCATransitionFromTop : kCATransitionFromBottom)];
    [animation setDuration:0.5f];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[self.webView layer] addAnimation:animation forKey:nil];

    [self setStory:story];
}

@end
