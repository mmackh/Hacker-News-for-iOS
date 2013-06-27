#import "MAMSlideNavigationViewController.h"

@interface MAMSlideNavigationViewController ()

@end

@implementation MAMSlideNavigationViewController

- (void)viewWillLayoutSubviews
{
    [self.view.window setBackgroundColor:[UIColor colorWithRed:0.949 green:.949 blue:0.949 alpha:1.0]];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if(animated)
    {
        
        CATransition *transition = [CATransition animation];
        transition.duration = 0.4f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromRight;
        [transition setValue:(id)kCFBooleanFalse forKey:kCATransitionFade];
        [self.view.layer addAnimation:transition forKey:nil];
    }
    [super pushViewController:viewController animated:NO];
}

- (UIViewController*)popViewControllerAnimated:(BOOL)animated
{
    if(animated)
    {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.4f;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionReveal;
        transition.subtype = kCATransitionFromLeft;
        [self.view.layer addAnimation:transition forKey:nil];
        
    }
    return [super popViewControllerAnimated:NO];
}

@end