//
//  MAMViewController.m
//  Hacker News
//
//  Created by mmackh on 6/15/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import "MAMViewController.h"

//Dependancies
#import "MAMStoryTableViewCell.h"
#import "MAMReaderViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MAMButton.h"

//Categories
#import "UIView+AnchorPoint.h"

@interface MAMViewController () <UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate,ReaderViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet MAMButton *trendingButton;
@property (weak, nonatomic) IBOutlet MAMButton *latestButton;
@property (weak, nonatomic) IBOutlet MAMButton *bestButton;

- (IBAction)changeSection:(id)sender;
- (IBAction)swipe:(id)sender;

@end

@implementation MAMViewController
{
    MAMHNController *_hnController;
    MAMReaderViewController *_readerView;
    NSArray *_items;
    int _selectedRow;
    int _currentSection;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _hnController = [MAMHNController sharedController];
    _items = [_hnController loadStoriesFromCacheOfType:HNControllerStoryTypeTrending];
    _currentSection = 0;
    [_trendingButton setSelected:YES];
    
    UIEdgeInsets tableViewEdgeInsets = UIEdgeInsetsMake(0, 0, [MAMHNController isPad]?0:44, 0);
    [self.tableView setContentInset:tableViewEdgeInsets];
    [self.tableView setScrollIndicatorInsets:tableViewEdgeInsets];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl setTintColor:[UIColor colorWithWhite:.75f alpha:1.0]];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc
{
    [self.view removeObserver:self forKeyPath:@"frame"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.tableView flashScrollIndicators];
    
}

#pragma mark -
#pragma mark TableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MAMStoryTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    __weak MAMHNStory *story = _items[indexPath.row];
    [cell.title setText:story.title];
    [cell.subtitle setText:story.subtitle];
    [cell.description setText:story.description];
    [cell.footer setText:story.footer];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedRow = indexPath.row;
    if(_readerView == nil)
    {
        _readerView = [self.storyboard instantiateViewControllerWithIdentifier:@"readerView"];
        [_readerView setDelegate:self];
        [_readerView view];
    }
    if (![[_items[_selectedRow] title] isEqualToString:_readerView.story.title])
    {
        [_readerView setStory:_items[_selectedRow]];
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self.navigationController pushViewController:_readerView animated:YES];
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static int fontSize = 0;
    if (fontSize == 0)
    {
        fontSize = ([MAMHNController isPad])?20:17;
    }
    return 125 + [[_items[indexPath.row] title] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:fontSize] constrainedToSize:CGSizeMake(self.tableView.bounds.size.width - 20, 90) lineBreakMode:NSLineBreakByTruncatingTail].height;
}

- (IBAction)refresh:(id)sender
{
    __weak MAMViewController *weakSelf = self;
    [_hnController loadStoriesOfType:_currentSection result:^(NSArray *results, HNControllerStoryType type, BOOL success)
    {
        if (!success)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Connection to server failed. Please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        _items = results;
        [weakSelf.tableView reloadData];
        [weakSelf.tableView setContentOffset:CGPointZero animated:YES];
        if ([sender isKindOfClass:[UIRefreshControl class]])
        {
            UIRefreshControl *refreshControl = sender;
            [refreshControl endRefreshing];
        }
     }];
}

- (void)readerExit
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark Change Sections

- (IBAction)changeSection:(id)sender
{
    CABasicAnimation *stretchAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale.x"];
    [stretchAnimation setToValue:[NSNumber numberWithDouble:1.02]];
    [stretchAnimation setRemovedOnCompletion:YES];
    [stretchAnimation setFillMode:kCAFillModeRemoved];
    [stretchAnimation setAutoreverses:YES];
    [stretchAnimation setDuration:0.15];
    
    if (_currentSection != [sender tag])
    {
        [stretchAnimation setBeginTime:CACurrentMediaTime() + 0.30];
    }
    [stretchAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    int anchorPointX = (_currentSection > [sender tag])?0:1;
    if (_currentSection == 0 && [sender tag] == 0) {
        anchorPointX  = 0;
    }
    [self.view setAnchorPoint:CGPointMake(anchorPointX,0.5) forView:self.view];
    [self.view.layer addAnimation:stretchAnimation forKey:@"animations"];
    
    if (_currentSection != [sender tag])
    {
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionPush];
        [animation setSubtype:(_currentSection > [sender tag] ? kCATransitionFromLeft : kCATransitionFromRight)];
        [animation setDuration:0.3f];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [[self.tableView layer] addAnimation:animation forKey:nil];
    }
    
    _currentSection = [sender tag];
    NSString *title;
    switch (_currentSection)
    {
        case 0:
            title = @"Currently Trending";
            [_trendingButton setSelected:YES];
            [_latestButton setSelected:NO];
            [_bestButton setSelected:NO];
            break;
        case 1:
            title = @"Latest Submissions";
            [_trendingButton setSelected:NO];
            [_latestButton setSelected:YES];
            [_bestButton setSelected:NO];
            break;
        case 2:
            title = @"Cream of the Crop";
            [_trendingButton setSelected:NO];
            [_latestButton setSelected:NO];
            [_bestButton setSelected:YES];
            break;
    }
    [self.titleLabel setText:title];
    
    _items = [_hnController loadStoriesFromCacheOfType:_currentSection];
    [self.tableView reloadData];
    [self.tableView setContentOffset:CGPointZero animated:NO];
    
    __weak MAMViewController *weakSelf = self;
    [_hnController loadStoriesOfType:_currentSection result:^(NSArray *results, HNControllerStoryType type, BOOL success)
     {
         if (!success)
         {
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Connection to server failed. Please try again later" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [alert show];
             return;
         }
         if (type != _currentSection) return;
         _items = results;
         [weakSelf.tableView reloadData];
     }];
}

- (IBAction)swipe:(id)sender
{
    UISwipeGestureRecognizer *swipe = sender;
    if (swipe.state == UIGestureRecognizerStateRecognized)
    {
        if (swipe.direction == UISwipeGestureRecognizerDirectionLeft)
        {
            if (_currentSection == 1)
            {
                [_bestButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            if (_currentSection == 0)
            {
                [_latestButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
        if (swipe.direction == UISwipeGestureRecognizerDirectionRight)
        {
            if (_currentSection == 1)
            {
                [_trendingButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            if (_currentSection == 2)
            {
                [_latestButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

@end
