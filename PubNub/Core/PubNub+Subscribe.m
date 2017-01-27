/**
@author Sergey Mamontov
@since 4.0
@copyright © 2009-2016 PubNub, Inc.
*/
#import "PubNub+Subscribe.h"
#import "PubNub+CorePrivate.h"
#import "PNSubscriber.h"
#import "PNHelpers.h"


#pragma mark - Interface implementation

@implementation PubNub (Subscribe)


#pragma mark - Subscription state information

- (NSArray *)channels {

return [self.subscriberManager channels];
}

- (NSArray *)channelGroups {

return [self.subscriberManager channelGroups];
}

- (NSArray *)presenceChannels {

return [self.subscriberManager presenceChannels];
}

- (BOOL)isSubscribedOn:(NSString *)name {

return ([[self channels] containsObject:name] || [[self channelGroups] containsObject:name] ||
[[self presenceChannels] containsObject:name]);
}


#pragma mark - Listeners

- (void)addListener:(id )listener {

// Forwarding calls to listener manager.
[self.listenersManager addListener:listener];
}

- (void)removeListener:(id )listener {

// Forwarding calls to listener manager.
[self.listenersManager removeListener:listener];
}


#pragma mark - Filtering

- (NSString *)filterExpression {

return self.subscriberManager.filterExpression;
}

- (void)setFilterExpression:( NSString *)filterExpression {

self.subscriberManager.filterExpression = filterExpression;
if ([[self.subscriberManager allObjects] count]) { [self subscribeToChannels:@[] withPresence:NO]; }
}


#pragma mark - Subscription

- (void)subscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence {

[self subscribeToChannels:channels withPresence:shouldObservePresence usingTimeToken:nil];
}

- (void)subscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence
usingTimeToken:( NSNumber *)timeToken {

[self subscribeToChannels:channels withPresence:shouldObservePresence usingTimeToken:timeToken
clientState:nil];
}

- (void)subscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence
clientState:( NSDictionary *)state {

[self subscribeToChannels:channels withPresence:shouldObservePresence usingTimeToken:nil
clientState:state];
}

- (void)subscribeToChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence
usingTimeToken:( NSNumber *)timeToken
clientState:( NSDictionary *)state {

NSArray *presenceChannelsList = nil;
if (shouldObservePresence) { presenceChannelsList = [PNChannel presenceChannelsFrom:channels]; }

[self.subscriberManager addChannels:[channels arrayByAddingObjectsFromArray:presenceChannelsList]];
[self.subscriberManager subscribeUsingTimeToken:timeToken withState:state completion:nil];
}

- (void)subscribeToChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence {

[self subscribeToChannelGroups:groups withPresence:shouldObservePresence usingTimeToken:nil];
}

- (void)subscribeToChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence
usingTimeToken:( NSNumber *)timeToken {

[self subscribeToChannelGroups:groups withPresence:shouldObservePresence usingTimeToken:timeToken
clientState:nil];
}

- (void)subscribeToChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence
clientState:( NSDictionary *)state {

[self subscribeToChannelGroups:groups withPresence:shouldObservePresence usingTimeToken:nil
clientState:state];
}

- (void)subscribeToChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence
usingTimeToken:( NSNumber *)timeToken
clientState:( NSDictionary *)state {

NSArray *groupsList = [NSArray arrayWithArray:groups];
if (shouldObservePresence) {

groupsList = [groups arrayByAddingObjectsFromArray:[PNChannel presenceChannelsFrom:groups]];
}
[self.subscriberManager addChannelGroups:groupsList];
[self.subscriberManager subscribeUsingTimeToken:timeToken withState:state completion:nil];
}

- (void)subscribeToPresenceChannels:(NSArray *)channels {

channels = [PNChannel presenceChannelsFrom:channels];
[self.subscriberManager addPresenceChannels:channels];
[self.subscriberManager subscribeUsingTimeToken:nil withState:nil completion:nil];
}


#pragma mark - Unsubscription

- (void)unsubscribeFromChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence {

[self unsubscribeFromChannels:channels withPresence:shouldObservePresence completion:nil];
}

- (void)unsubscribeFromChannels:(NSArray *)channels withPresence:(BOOL)shouldObservePresence
completion:( PNSubscriberCompletionBlock)block {

NSArray *presenceChannels = nil;
if (shouldObservePresence) { presenceChannels = [PNChannel presenceChannelsFrom:channels]; }
NSArray *fullChannelsList = [channels arrayByAddingObjectsFromArray:presenceChannels];
[self.subscriberManager removeChannels:fullChannelsList];
[self.subscriberManager unsubscribeFrom:YES objects:fullChannelsList completion:block];
}

- (void)unsubscribeFromChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence {

[self unsubscribeFromChannelGroups:groups withPresence:shouldObservePresence completion:nil];
}

- (void)unsubscribeFromChannelGroups:(NSArray *)groups withPresence:(BOOL)shouldObservePresence
completion:( PNSubscriberCompletionBlock)block {

NSArray *groupsList = [NSArray arrayWithArray:groups];
if (shouldObservePresence) {

groupsList = [groupsList arrayByAddingObjectsFromArray:[PNChannel presenceChannelsFrom:groups]];
}
[self.subscriberManager removeChannelGroups:groupsList];
[self.subscriberManager unsubscribeFrom:NO objects:groupsList completion:block];
}

- (void)unsubscribeFromPresenceChannels:(NSArray *)channels {

channels = [PNChannel presenceChannelsFrom:channels];
[self.subscriberManager removePresenceChannels:channels];
[self.subscriberManager unsubscribeFrom:YES objects:channels completion:nil];
}

- (void)unsubscribeFromAll {

[self.subscriberManager unsubscribeFromAll];
}

#pragma mark -


@end