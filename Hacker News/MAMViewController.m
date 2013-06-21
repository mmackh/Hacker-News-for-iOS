//
//  MAMViewController.m
//  Hacker News
//
//  Created by mmackh on 6/15/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import "MAMViewController.h"

//Dependancies
#import "MAMCollectionViewCell.h"
#import "MAMReaderViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "MAMButton.h"

@interface MAMViewController () <UIGestureRecognizerDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,ReaderViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet MAMButton *trendingButton;
@property (weak, nonatomic) IBOutlet MAMButton *latestButton;
@property (weak, nonatomic) IBOutlet MAMButton *bestButton;

- (IBAction)changeSection:(id)sender;

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
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    
    [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc
{
    [self.view removeObserver:self forKeyPath:@"frame"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.collectionView flashScrollIndicators];
    
}

#pragma mark -
#pragma mark CollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MAMCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    MAMHNStory *story = _items[indexPath.row];
    [cell.title setText:story.title];
    [cell.subtitle setText:[NSString stringWithFormat:@"Submitted %@ by %@",story.pubDate,story.user]];
    [cell.description setText:story.description];
    [cell.footer setText:[NSString stringWithFormat:@"%@ | %@",story.score,story.commentsValue]];
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
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
    
    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
    [self.navigationController pushViewController:_readerView animated:YES];
}

- (void)reloadCollectionView
{
    if (!_items.count) return;
    
    [self.collectionView setUserInteractionEnabled:NO];
    
    double delayInSeconds = .3;
    __weak MAMViewController *weakSelf = self;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [weakSelf.collectionView reloadData];
        [weakSelf.collectionView setUserInteractionEnabled:YES];
    });
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
        [weakSelf reloadCollectionView];
        [weakSelf.collectionView setContentOffset:CGPointZero animated:YES];
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
#pragma mark CollectionView Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static int fontSize = 0;
    if (fontSize == 0)
    {
        fontSize = ([MAMHNController isPad])?20:17;
    }
    return CGSizeMake(self.collectionView.bounds.size.width, 125 + [[_items[indexPath.row] title] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:fontSize] constrainedToSize:CGSizeMake(self.collectionView.bounds.size.width - 20, 90) lineBreakMode:NSLineBreakByTruncatingTail].height);
}

#pragma mark -
#pragma mark Change Sections

- (IBAction)changeSection:(id)sender
{
    if (_currentSection != [sender tag])
    {
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionPush];
        [animation setSubtype:(_currentSection > [sender tag] ? kCATransitionFromLeft : kCATransitionFromRight)];
        [animation setDuration:0.3f];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [[self.collectionView layer] addAnimation:animation forKey:@"swap"];
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
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointZero animated:NO];
    
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
         [weakSelf reloadCollectionView];
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
