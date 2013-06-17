//
//  NSString+Hash.h
//  Orbitink
//
//  Created by mmackh on 5/3/13.
//  Copyright (c) 2013 Professional Consulting & Trading GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)

- (NSString *)urlFriendlyFileNameWithExtension:(NSString *)extension prefixID:(int)prefixID;
- (NSString *)urlFriendlyFileName;
- (NSString *)stringByAppendingURLPathComponent:(NSString *)pathComponent;

- (NSString *)sha512;
- (NSString *)base64Encode;
- (NSString *)base64Decode;

- (NSString*)stringBetweenString:(NSString *)start andString:(NSString *)end;

- (NSString *)stringByStrippingHTML;
- (NSString *)localCachePath;

@end
