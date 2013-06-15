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
    NSArray *_items;
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
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
}

- (IBAction)refresh:(id)sender
{
    __weak MAMViewController *weakSelf = self;
    [_hnController loadStoriesOfType:HNControllerStoryTypeTrending result:^(NSArray *results)
    {
        _items = results;
        dispatch_async(dispatch_get_main_queue(),
        ^{
            [weakSelf.collectionView reloadData];
            if (sender)
            {
                UIRefreshControl *refreshControl = sender;
                [refreshControl endRefreshing];
            }
        });
     }];
}

- (void)readerExit
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.2f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
	[self.view.layer addAnimation:transition forKey:nil];
	[self.navigationController popViewControllerAnimated:NO];
}

#pragma mark -
#pragma mark CollectionView Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.collectionView.bounds.size.width, 125 + [[_items[indexPath.row] title] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17] constrainedToSize:CGSizeMake(self.collectionView.bounds.size.width - 20, 90) lineBreakMode:NSLineBreakByTruncatingTail].height);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toReader"])
    {
        MAMReaderViewController *readerVC = [segue destinationViewController];
        [readerVC setDelegate:self];
    }
}

@end
