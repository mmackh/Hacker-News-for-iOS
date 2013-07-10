//
//  MAMCollectionViewCell.h
//  Hacker News
//
//  Created by mmackh on 6/15/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MAMStoryTableViewCell;

@protocol MAMStoryTableViewCellDelegate <NSObject>

@optional
- (void)tableViewDidRecognizeLongPressGestureWithCell:(MAMStoryTableViewCell *)cell;
@end

@interface MAMStoryTableViewCell : UITableViewCell

@property (weak, nonatomic) id<MAMStoryTableViewCellDelegate> delegate;

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *subtitle;
@property (weak, nonatomic) IBOutlet UILabel *description;
@property (weak, nonatomic) IBOutlet UILabel *footer;

@end
