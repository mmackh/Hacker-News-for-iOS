//
//  MAMCommentTableViewCell.m
//  Hacker News
//
//  Created by mmackh on 6/17/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import "MAMCommentTableViewCell.h"
#import "TTTAttributedLabel.h"

@implementation MAMCommentTableViewCell
{
    int _indent;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    for(NSLayoutConstraint *cellConstraint in self.constraints){
        [self removeConstraint:cellConstraint];
        id firstItem = cellConstraint.firstItem == self ? self.contentView : cellConstraint.firstItem;
        id seccondItem = cellConstraint.secondItem == self ? self.contentView : cellConstraint.secondItem;
        NSLayoutConstraint* contentViewConstraint =
        [NSLayoutConstraint constraintWithItem:firstItem
                                     attribute:cellConstraint.firstAttribute
                                     relatedBy:cellConstraint.relation
                                        toItem:seccondItem
                                     attribute:cellConstraint.secondAttribute
                                    multiplier:cellConstraint.multiplier
                                      constant:cellConstraint.constant];
        [self.contentView addConstraint:contentViewConstraint];
    }
    [self.comment setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
    [self.comment setDataDetectorTypes:NSTextCheckingTypeLink];
    [self.comment setLineHeightMultiple:1.07];
    [self.comment setVerticalAlignment:TTTAttributedLabelVerticalAlignmentTop];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    float indentPoints = self.indentationLevel * self.indentationWidth;
    self.contentView.frame =
    CGRectMake(
    indentPoints,
    self.contentView.frame.origin.y,
    self.contentView.frame.size.width - indentPoints,
    self.contentView.frame.size.height
    );
}

@end
