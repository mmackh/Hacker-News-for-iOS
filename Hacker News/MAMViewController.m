//
//  MAMViewController.m
//  Hacker News
//
//  Created by mmackh on 6/15/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import "MAMViewController.h"

//Dependancies
#import "MAMHNController.h"
#import "MAMCollectionViewCell.h"
#import "MAMReaderViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface MAMViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,ReaderViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
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
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.collectionView addSubview:refreshControl];
    
    [self refresh:nil];
    [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
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
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
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

    [self.navigationController pushViewController:_readerView animated:YES];
}

- (void)reloadCollectionView
{
    if (!_items.count) return;
    
    [self.collectionView setUserInteractionEnabled:NO];
    
    double delayInSeconds = .2;
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
    [_hnController loadStoriesOfType:_currentSection result:^(NSArray *results, HNControllerStoryType type)
    {
        _items = results;
        [weakSelf reloadCollectionView];
        [weakSelf.collectionView setContentOffset:CGPointZero animated:YES];
        if (sender)
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
    return CGSizeMake(self.collectionView.bounds.size.width, 125 + [[_items[indexPath.row] title] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17] constrainedToSize:CGSizeMake(self.collectionView.bounds.size.width - 20, 90) lineBreakMode:NSLineBreakByTruncatingTail].height);
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
            break;
        case 1:
            title = @"Latest Submissions";
            break;
        case 2:
            title = @"Cream of the Crop";
            break;
    }
    [self.titleLabel setText:title];
    
    __weak MAMViewController *weakSelf = self;
    _items = [_hnController loadStoriesFromCacheOfType:_currentSection];
    [self.collectionView reloadData];
    [_hnController loadStoriesOfType:_currentSection result:^(NSArray *results, HNControllerStoryType type)
     {
         if (type != _currentSection) return;
         _items = results;
         [weakSelf reloadCollectionView];
         [weakSelf.collectionView setContentOffset:CGPointZero animated:NO];
     }];
}
@end
