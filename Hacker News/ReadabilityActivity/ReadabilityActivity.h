//
//  ReadabilityActivity.h
//
//  Created by Brendan Lynch on 12-09-20.
//  Copyright (c) 2012 Readability LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const ReadabilityActivityURI;
extern NSString * const ReadabilityActivityAdd;

@interface ReadabilityActivity : UIActivity
{
    @private NSArray *_activityItems;
}

+ (BOOL)canPerformActivity;

@end