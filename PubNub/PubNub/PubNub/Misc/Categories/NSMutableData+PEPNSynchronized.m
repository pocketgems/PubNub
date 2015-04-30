//
//  NSMutableData+PEPNSynchronized.m
//  PubNub
//
//  Created by Scott Goodfriend on 4/29/15.
//  Copyright (c) 2015 PubNub, Inc. All rights reserved.
//

#import "NSMutableData+PEPNSynchronized.h"

@implementation NSData (PEPNSynchronized)

- (NSUInteger)pepnSynced_length {
    @synchronized(self) {
        return self.length;
    }
}

- (NSRange)pepnSynced_rangeOfData:(NSData *)dataToFind options:(NSDataSearchOptions)mask range:(NSRange)searchRange {
    @synchronized(self) {
        return [self rangeOfData:dataToFind
                         options:mask
                           range:searchRange];
    }
}

- (NSData *)pepnSynced_subdataWithRange:(NSRange)range {
    @synchronized(self) {
        return [self subdataWithRange:range];
    }
}

@end

@implementation NSMutableData (PEPNSynchronized)

- (void)pepnSynced_appendBytes:(const void *)bytes length:(NSUInteger)length {
    @synchronized(self) {
        [self appendBytes:bytes length:length];
    }
}

- (void)pepnSynced_appendData:(NSData *)other {
    NSData *otherCopy;
    @synchronized(other) {
        otherCopy = other.copy;
    }
    @synchronized(self) {
        [self appendData:otherCopy];
    }
}

- (void)pepnSynced_setData:(NSData *)data {
    NSData *dataCopy;
    @synchronized(data) {
        dataCopy = data.copy;
    }
    @synchronized(self) {
        self.data = dataCopy;
    }
}

@end
