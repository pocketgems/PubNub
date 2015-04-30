//
//  NSMutableData+PEPNSynchronized.h
//  PubNub
//
//  Created by Scott Goodfriend on 4/29/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (PEPNSynchronized)

- (NSUInteger)pepnSynced_length;
- (NSRange)pepnSynced_rangeOfData:(NSData *)dataToFind options:(NSDataSearchOptions)mask range:(NSRange)searchRange;
- (NSData *)pepnSynced_subdataWithRange:(NSRange)range;

@end

@interface NSMutableData (PEPNSynchronized)

- (void)pepnSynced_appendBytes:(const void *)bytes length:(NSUInteger)length;
- (void)pepnSynced_appendData:(NSData *)other;
- (void)pepnSynced_setData:(NSData *)data;

@end
