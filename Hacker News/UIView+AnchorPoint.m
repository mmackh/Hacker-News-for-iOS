//
//  UIView.m
//  Hacker News
//
//  Created by Maximilian Mackh on 02/07/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import "UIView+AnchorPoint.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (AnchorPoint)

//Thanks http://stackoverflow.com/a/5666430/1091044

-(void)setAnchorPoint:(CGPoint)anchorPoint forView:(UIView *)view
{
    CGPoint newPoint = CGPointMake(view.bounds.size.width * anchorPoint.x, view.bounds.size.height * anchorPoint.y);
    CGPoint oldPoint = CGPointMake(view.bounds.size.width * view.layer.anchorPoint.x, view.bounds.size.height * view.layer.anchorPoint.y);
    
    newPoint = CGPointApplyAffineTransform(newPoint, view.transform);
    oldPoint = CGPointApplyAffineTransform(oldPoint, view.transform);
    
    CGPoint position = view.layer.position;
    
    position.x -= oldPoint.x;
    position.x += newPoint.x;
    
    position.y -= oldPoint.y;
    position.y += newPoint.y;
    
    view.layer.position = position;
    view.layer.anchorPoint = anchorPoint;
}

@end
