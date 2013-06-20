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
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

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
    
    [self.tableView setScrollIndicatorInsets:UIEdgeInsetsMake(0, 0, 44, 0)];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 44, 0)];
    [self.titleLabel setText:@"Loading Comments..."];
    
    __weak MAMCommentsViewController *weakSelf = self;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"toWeb" sender:[NSURL URLWithString:[NSString stringWithFormat:@"https://news.ycombinator.com/%@",[_comments[indexPath.row]replyID]]]];
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
