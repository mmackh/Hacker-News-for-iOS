//
//  NSObject+Notifications.h
//  InstaPDF
//
//  Created by Maximilian Mackh on 18/09/13.
//  Copyright (c) 2013 mackh ag. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (Notifications)

/// Subscribe to multiple NSNotifications
- (void)subscribeToNotifications:(NSArray *)notifications;

/// Unsubscribe from multiple NSNotifications
- (void)unsubscribeFromNotifications:(NSArray *)notifications;

/// Convenience method to subscribe to a single NSNotifications
- (void)subscribeToNotification:(NSString *)notificationName;

/// Convenience method to unsubscribe from a single NSNotifications
- (void)unsubscribeFromNotification:(NSString *)notificationName;

/// Unsubscribe from all NSNotifications. Seriously, unsubscribe from all notification to keep NSNotificationCenter clean
- (void)unsubscribeFromAllNotifications;

/// Post a NSNotification
- (void)postNotificationWithName:(NSString *)notificationName;

/// Post a NSNotification with an Object
- (void)postNotificationWithName:(NSString *)notificationName object:(id)notificationObject;

/// REQUIRED: When subscribing to any NSNotification, implement this method. Object can be nil
- (void)receivedNotificationWithName:(NSString *)notificationName object:(id)notificationObject;


// Begin logging all NSNotifications
- (void)beginNotificationLogging;

// End logging all NSNotifications
- (void)endNotificationLogging;

@end
