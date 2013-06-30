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
#import "PocketAPIActivity.h"

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

// iPad Only
@property (weak, nonatomic) IBOutlet UIButton *shareButton;

@end

@implementation MAMReaderViewController
{
    MAMHNStory *_story;
    NSMutableString *_string;
    int _currentFontSize;
    
    //iPad Specifics
    UIPopoverController *_popoverController;
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
    
    BOOL isPad = [MAMHNController isPad];
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake((isPad)?44:0, 0, (isPad)?0:44, 0);
    [self.webView.scrollView setScrollIndicatorInsets:edgeInsets];
    [self.webView.scrollView setContentInset:edgeInsets];
    
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
    [self.webView stringByEvaluatingJavaScriptFromString:@"document.open();document.close();"];
    
    NSString *storyLink = story.link.localCachePath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:storyLink])
    {
        NSString *htmlString = [NSString stringWithContentsOfURL:[NSURL fileURLWithPath:storyLink] encoding:NSUTF8StringEncoding error:nil];
        htmlString = [htmlString stringByReplacingOccurrencesOfString:@"**[txtadjust]**" withString:[NSString stringWithFormat:@"%i",_currentFontSize]];
        [self.webView loadHTMLString:htmlString baseURL:nil];
        return;
    }
    
    NSMutableString *string = [[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:([MAMHNController isPad])?@"view_Pad":@"view" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil] mutableCopy];
    [string replaceOccurrencesOfString:@"**[title]**" withString:_story.title options:0 range:NSMakeRange(0, string.length)];
    [string replaceOccurrencesOfString:@"**[points]**" withString:_story.score options:0 range:NSMakeRange(0, string.length)];
    [string replaceOccurrencesOfString:@"**[domain]**" withString:_story.domain options:0 range:NSMakeRange(0, string.length)];
    [string replaceOccurrencesOfString:@"**[link]**" withString:_story.link options:0 range:NSMakeRange(0, string.length)];
    
    _string = string;
    [self.webView loadHTMLString:string baseURL:nil];
    __weak MAMReaderViewController *weakSelf = self;
    [_story loadClearReadLoadBody:^(NSString *resultBody)
     {
         NSString *clearReadDocument = [string stringByReplacingOccurrencesOfString:@"Loading...  " withString:resultBody options:0 range:NSMakeRange(0, _string.length)];
         [clearReadDocument writeToFile:storyLink atomically:NO encoding:NSUTF8StringEncoding error:nil];
         [weakSelf.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:storyLink] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:20]];
         double delayInSeconds = .2;
         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
         dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
         {
             [weakSelf changeFontSize:FontSizeChangeTypeNone];
         });
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
            // I'd like to expand to a fullscreen image here - suggestions are welcome
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
            TUSafariActivity *safariActivity = [[TUSafariActivity alloc] init];
            PocketAPIActivity *pocketActivity = [[PocketAPIActivity alloc] init];
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[URL] applicationActivities:@[safariActivity, pocketActivity]];
            [activityViewController setExcludedActivityTypes:@[UIActivityTypePostToWeibo]];
            
            if ([MAMHNController isPad])
            {
                _popoverController = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
                [_popoverController presentPopoverFromRect:self.shareButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            }
            else
            {
                [self.navigationController presentViewController:activityViewController animated:YES completion:nil];
            }
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
