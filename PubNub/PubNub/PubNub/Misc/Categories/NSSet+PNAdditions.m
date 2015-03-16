//
//  NSSet+PNAdditions.m
//  pubnub
//
//  Created by Sergey Mamontov on 8/28/14.
//  Copyright (c) 2014 PubNub Inc. All rights reserved.
//

#import "NSSet+PNAdditions.h"


#pragma mark Public interface methods

@implementation NSSet (PNAdditions)


#pragma mark - Instance methods

- (NSString *)logDescription {
    
    NSMutableString *logDescription = [NSMutableString stringWithString:@"<["];
    __block NSUInteger entryIdx = 0;
    [self enumerateObjectsUsingBlock:^(id entry, BOOL *entryEnumeratorStop) {
        
        // Check whether parameter can be transformed for log or not
        if ([entry respondsToSelector:@selector(logDescription)]) {
            
            entry = [entry logDescription] ?: @"";
        }
        [logDescription appendFormat:entryIdx ? @"|%@" : @"%@", entry];

        entryIdx++;
    }];
    [logDescription appendString:@"]>"];

    
    return logDescription;
}

#pragma mark -


@end
