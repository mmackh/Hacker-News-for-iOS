//
//  MAMCommentsViewController.m
//  Hacker News
//
//  Created by mmackh on 6/16/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import "MAMCommentsViewController.h"

// Dependancies
#import "MAMCommentTableViewCell.h"
#import "TTTAttributedLabel.h"
#import "MAMWebViewController.h"

@interface MAMCommentsViewController () <UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate,TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation MAMCommentsViewController
{
    MAMHNController *_hnController;
    NSArray *_comments;
}

- (BOOL)prefersStatusBarHidden
{
    if ([MAMHNController isPad]) return YES;
    return NO;
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
    
    BOOL isPad = [MAMHNController isPad];
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake((isPad)?44:0, 0, (isPad)?0:44, 0);
    [self.tableView setScrollIndicatorInsets:edgeInsets];
    [self.tableView setContentInset:edgeInsets];
    
    UITableViewController *tableViewController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    [tableViewController setTableView:self.tableView];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl setTintColor:[UIColor colorWithWhite:.75f alpha:1.0]];
    [refreshControl addTarget:self action:@selector(loadComments:) forControlEvents:UIControlEventValueChanged];
    [tableViewController setRefreshControl:refreshControl];
    
    [self.titleLabel setText:@"Loading Comments..."];
    [self loadComments:nil];
    [self.view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)loadComments:(id)sender
{
    __weak typeof(self) weakSelf = self;
    [[MAMHNController sharedController] loadCommentsOnStoryWithID:_story.hnID result:^(NSArray *results)
     {
         if (!results.count)
         {
             [weakSelf.titleLabel setText:@"No Comments"];
             return;
         }
         _comments = results;
         [weakSelf.tableView reloadData];
         [weakSelf.tableView flashScrollIndicators];
         [weakSelf.titleLabel setText:self.story.title];
         if (sender)
         {
             [sender endRefreshing];
         }
     }];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"toWeb" sender:[NSURL URLWithString:[NSString stringWithFormat:@"https://news.ycombinator.com/%@",[_comments[indexPath.row]replyID]]]];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:cell.contentView.backgroundColor];
}

- (IBAction)headerTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateRecognized)
    {
        [self performSegueWithIdentifier:@"toWeb" sender:[NSURL URLWithString:[NSString stringWithFormat:@"https://news.ycombinator.com/item?id=%@",_story.hnID]]];
    }
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
    static float screenWidth;
    if (screenWidth == 0)
    {
        screenWidth = [[UIScreen mainScreen] bounds].size.width;
    }
    MAMHNComment *hnComment = _comments[indexPath.row];
    float width = (screenWidth - ([hnComment indentationLevel] * 10)  - 20);
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
