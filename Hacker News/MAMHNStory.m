//
//  MAMHNStory.m
//  Hacker News
//
//  Created by mmackh on 6/15/13.
//  Copyright (c) 2013 Maximilian Mackh. All rights reserved.
//

#import "MAMHNStory.h"

// Dependancies
#import "AFNetworking/AFNetworking.h"
#import "RXMLElement.h"

@implementation MAMHNStory
{
    NSString *_subtitle;
    NSString *_footer;
}

- (NSString *)subtitle
{
    if (!_subtitle)
    {
        _subtitle = [NSString stringWithFormat:@"Submitted %@ by %@",self.pubDate,self.user];
    }
    return _subtitle;
}

- (NSString *)footer
{
    if (!_footer)
    {
        _footer = [NSString stringWithFormat:@"%@ | %@",self.score,self.commentsValue];
    }
    return _footer;
}

- (NSString *)domain
{
    return [[NSURL URLWithString:self.link] host];
}

- (void)loadClearReadLoadBody:(void(^)(NSString *resultBody, MAMHNStory *story))completionBlock
{
    NSString *urlString = [NSString stringWithFormat:@"http://api.thequeue.org/v1/clear?url=%@",self.link];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLCacheStorageAllowed timeoutInterval:60];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        RXMLElement *rootXML = [RXMLElement elementFromXMLString:responseString encoding:NSUTF8StringEncoding];
        [rootXML iterate:@"channel.item.description" usingBlock: ^(RXMLElement *e)
        {
            completionBlock(e.text,self);
        }];
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {
        NSLog(@"Failed to load %@",error);
    }];
    [operation start];
};

#pragma mark -
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    self.title = [decoder decodeObjectForKey:@"1"];
    self.description = [decoder decodeObjectForKey:@"2"];
    self.pubDate = [decoder decodeObjectForKey:@"3"];
    self.score = [decoder decodeObjectForKey:@"4"];
    self.user = [decoder decodeObjectForKey:@"5"];
    self.link = [decoder decodeObjectForKey:@"6"];
    self.discussionLink = [decoder decodeObjectForKey:@"7"];
    self.commentsValue = [decoder decodeObjectForKey:@"8"];
    self.hostValue = [decoder decodeObjectForKey:@"9"];
    self.hnID = [decoder decodeObjectForKey:@"10"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.title forKey:@"1"];
    [encoder encodeObject:self.description forKey:@"2"];
    [encoder encodeObject:self.pubDate forKey:@"3"];
    [encoder encodeObject:self.score forKey:@"4"];
    [encoder encodeObject:self.user forKey:@"5"];
    [encoder encodeObject:self.link forKey:@"6"];
    [encoder encodeObject:self.discussionLink forKey:@"7"];
    [encoder encodeObject:self.commentsValue forKey:@"8"];
    [encoder encodeObject:self.hostValue forKey:@"9"];
    [encoder encodeObject:self.hnID forKey:@"10"];
}

@end
