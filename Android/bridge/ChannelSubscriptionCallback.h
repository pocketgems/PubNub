//
//  ChannelSubscriptionCallback.h
//
//  Created on 8/26/14.
//

#ifdef APPORTABLE

#import "AbstractCallback.h"
#import "PNStructures.h"

@class PubNub;

@interface ChannelSubscriptionCallback : AbstractCallback

- (id)initWithChannelSubscriptionBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock
                           andDelegate:(PubNub *)pubnubDelegate;

- (void)removeFromSubscriptionCallbackList:(NSString *)channelName;

@end

#endif
