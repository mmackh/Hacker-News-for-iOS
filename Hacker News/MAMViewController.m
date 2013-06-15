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

@interface MAMViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation MAMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.collectionView flashScrollIndicators];
    
    [MAMHNController isPad];
    [MAMHNController isPad];
    [MAMHNController isPad];
}

#pragma mark -
#pragma mark CollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (UICollectionViewFlowLayout *)collectionViewFlowLayout
{
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    return flowLayout;
}
@end
