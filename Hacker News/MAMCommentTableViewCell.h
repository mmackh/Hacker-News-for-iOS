//
//  MAMCommentTableViewCell.h
//  Hacker News
//
//  Created by mmackh on 6/17/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TTTAttributedLabel;

@interface MAMCommentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *user;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *comment;

@end
