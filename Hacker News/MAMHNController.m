//
//  MAMHNController.m
//  Hacker News
//
//  Created by mmackh on 6/15/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import "MAMHNController.h"

// Dependancies
#import "AFNetworking/AFNetworking.h"
#import "RaptureXML/RXMLElement.h"

@implementation MAMHNController

+ (BOOL)isPad
{
    static BOOL isPad;
    static int isSet = 0;
    if (isSet == 0)
    {
        isPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
        isSet = 1;
    }
    return isPad;
}

+ (id)sharedController
{
    static dispatch_once_t onceToken;
    static MAMHNController *hnController;
    dispatch_once(&onceToken, ^{
        hnController = [[self alloc] init];
    });
    return hnController;
}

- (id)init
{
    self = [super init];
    if(!self) return nil;
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    [AFHTTPRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"application/rss+xml"]];
    return self;
}

- (void)loadStoriesOfType:(HNControllerStoryType)storyType result:(void(^)(NSArray *results))completionBlock
{
    static const NSString *host = @"http://api.thequeue.org/hn/";
    NSString *targetURLString;
   
    switch (storyType)
    {
        case HNControllerStoryTypeTrending:
            targetURLString = [host stringByAppendingString:@"frontpage.xml"];
            break;
        case HNControllerStoryTypeNew:
            targetURLString = [host stringByAppendingString:@"new.xml"];
            break;
        case HNControllerStoryTypeBest:
            targetURLString = [host stringByAppendingString:@"best.xml"];
            break;
    }
    
    __weak id weakSelf = self;
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:targetURLString] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:10];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCacheResponseBlock:^NSCachedURLResponse *(NSURLConnection *connection, NSCachedURLResponse *cachedResponse) { return nil; }];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSMutableArray *results = [[NSMutableArray alloc] init];
        
        RXMLElement *rootXML = [RXMLElement elementFromXMLString:responseString encoding:NSUTF8StringEncoding];
        [rootXML iterate:@"channel.item" usingBlock: ^(RXMLElement *e)
        {
            MAMHNStory *story = [weakSelf storyFactory];
            [story setTitle:[e child:@"title"].text];
            
            [results addObject:story];
        }];
        completionBlock(results);
        [NSKeyedArchiver archiveRootObject:results toFile:[weakSelf pathForPersistedStoriesOfType:storyType]];
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"%@",error.description);
    }];
    [operation start];
}

- (MAMHNStory *)storyFactory
{
    return [[MAMHNStory alloc] init];
}

- (NSArray *)loadStoriesFromCacheOfType:(HNControllerStoryType)storyType
{
    NSString *path = [self pathForPersistedStoriesOfType:storyType];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return nil;
    NSArray *results = [NSKeyedUnarchiver unarchiveObjectWithFile:[self pathForPersistedStoriesOfType:storyType]];
    return results;
}

- (NSString *)pathForPersistedStoriesOfType:(HNControllerStoryType)storyType
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [NSString stringWithFormat:@"%@/x%ihn",[paths objectAtIndex:0],storyType];
}

@end
