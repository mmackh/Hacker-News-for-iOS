//
//  MAMCommentsViewController.m
//  Hacker News
//
//  Created by mmackh on 6/16/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import "MAMCommentsViewController.h"

// Dependancies
#import "MAMHNController.h"
#import "MAMCommentTableViewCell.h"
#import "TTTAttributedLabel.h"
#import "MAMWebViewController.h"

@interface MAMCommentsViewController () <UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate,TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MAMCommentsViewController
{
    MAMHNController *_hnController;
    NSArray *_comments;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak MAMCommentsViewController *weakSelf = self;
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 43, 0)];
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(40, 0, 0, 0)];
    [[MAMHNController sharedController] loadCommentsOnStoryWithID:_story.hnID result:^(NSArray *results)
    {
        _comments = results;
        [weakSelf.tableView reloadData];
    }];
    [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)dealloc
{
    [self.view removeObserver:self forKeyPath:@"frame"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.tableView reloadData];
}

- (IBAction)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark -
#pragma mark TableView

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 40)];
    [headerView setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
    
    UILabel*headerLabel = [[UILabel alloc] initWithFrame:CGRectInset(headerView.bounds, 10, 0)];
    [headerLabel setText:self.story.title];
    [headerLabel setMinimumScaleFactor:0.8];
    [headerLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
    [headerLabel setTextColor:[UIColor whiteColor]];
    [headerLabel setBackgroundColor:[UIColor clearColor]];
    [headerLabel setAdjustsFontSizeToFitWidth:YES];
    [headerLabel setAdjustsLetterSpacingToFitWidth:YES];
    [headerLabel setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [headerView addSubview:headerLabel];
    
    UITapGestureRecognizer *headerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headerTapped:)];
    [headerTap setNumberOfTapsRequired:1];
    [headerTap setNumberOfTouchesRequired:1];
    [headerView addGestureRecognizer:headerTap];

    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"toWeb" sender:[NSURL URLWithString:[NSString stringWithFormat:@"https://news.ycombinator.com/%@",[_comments[indexPath.row]replyID]]]];
}

- (void)headerTapped:(UITapGestureRecognizer *)tap
{
    if (tap.state == UIGestureRecognizerStateRecognized)
    {
        [self performSegueWithIdentifier:@"toWeb" sender:[NSURL URLWithString:[NSString stringWithFormat:@"https://news.ycombinator.com/item?id=%@",_story.hnID]]];
    }
}

- (float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MAMCommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    MAMHNComment *comment = _comments[indexPath.row];
    [cell.comment setTextColor:comment.color];
    [cell.comment setDelegate:self];
    [cell.comment setText:comment.comment];
    
    
    [cell.user setText:comment.username];
    [cell.time setText:comment.time];
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MAMHNComment *hnComment = _comments[indexPath.row];
    float width = (self.tableView.bounds.size.width - ([hnComment indentationLevel] * 10)  - 20);
    return [MAMCommentTableViewCell heightForCellWithText:hnComment.comment constrainedToWidth:width];
}

- (int)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [_comments[indexPath.row] indentationLevel];
}

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    [self performSegueWithIdentifier:@"toWeb" sender:url];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"toWeb"])
    {
        MAMWebViewController *webViewController = segue.destinationViewController;
        [webViewController loadURL:sender];
    }
}


@end
