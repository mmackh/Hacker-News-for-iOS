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

@interface MAMViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

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

#pragma mark -
#pragma mark CollectionView Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.collectionView.bounds.size.width, 125 + [[_items[indexPath.row] title] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Medium" size:17] constrainedToSize:CGSizeMake(self.collectionView.bounds.size.width - 10, 70) lineBreakMode:NSLineBreakByTruncatingTail].height);
}
@end
