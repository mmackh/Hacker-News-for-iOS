//
//  NSObject+Notifications.m
//  InstaPDF
//
//  Created by Maximilian Mackh on 18/09/13.
//  Copyright (c) 2013 mackh ag. All rights reserved.
//

#import "NSObject+Notifications.h"

#pragma clang diagnostic ignored "-Wincomplete-implementation"
@implementation NSObject (Notifications)

- (void)subscribeToNotifications:(NSArray *)notifications
{
    for (id notification in notifications)
    {
        if ([notification isKindOfClass:[NSString class]])
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_notf_received_ipdf:) name:notification object:nil];
        }
    }
}

- (void)unsubscribeFromNotifications:(NSArray *)notifications
{
    for (id notification in notifications)
    {
        if ([notification isKindOfClass:[NSString class]])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:notification object:nil];
        }
    }
}

- (void)subscribeToNotification:(NSString *)notificationName
{
    [self subscribeToNotifications:@[notificationName]];
}

- (void)unsubscribeFromNotification:(NSString *)notificationName
{
    [self unsubscribeFromNotifications:@[notificationName]];
}

- (void)unsubscribeFromAllNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)postNotificationWithName:(NSString *)notificationName
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
}

- (void)postNotificationWithName:(NSString *)notificationName object:(id)notificationObject
{
    [[NSNotificationCenter defaultCenter] postNotificationWithName:notificationName object:nil];
}

- (void)_notf_received_ipdf:(NSNotification *)notification
{
    [self performSelector:@selector(receivedNotificationWithName:object:) withObject:notification.name withObject:notification.object];
}

- (void)beginNotificationLogging
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_notf_log_ipdf:) name:nil object:nil];
}

- (void)endNotificationLogging
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
}

- (void)_notf_log_ipdf:(NSNotification *)notification
{
    NSLog(@"%@",notification);
}

@end
