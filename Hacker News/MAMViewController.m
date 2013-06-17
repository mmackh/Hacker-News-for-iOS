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

@end

@implementation MAMViewController
{
    MAMHNController *_hnController;
    MAMReaderViewController *_readerView;
    NSArray *_items;
    int _selectedRow;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.collectionView setScrollIndicatorInsets:UIEdgeInsetsMake(44, 0, 44, 0)];
    
    _hnController = [MAMHNController sharedController];
    _items = [_hnController loadStoriesFromCacheOfType:HNControllerStoryTypeTrending];
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
    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
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
    
    __weak UINavigationController *weakNavController = self.navigationController;
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
    {
        [weakNavController pushViewController:_readerView animated:YES];
    });
}

- (IBAction)refresh:(id)sender
{
    __weak MAMViewController *weakSelf = self;
    [_hnController loadStoriesOfType:HNControllerStoryTypeTrending result:^(NSArray *results)
    {
        _items = results;
        [weakSelf.collectionView reloadData];
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

@end
