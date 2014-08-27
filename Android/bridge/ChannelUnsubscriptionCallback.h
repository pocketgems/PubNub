//
//  ChannelUnsubscriptionCallback.h
//
//  Created on 8/26/14.
//

#ifdef APPORTABLE

#import "AbstractCallback.h"
#import "PNStructures.h"

@class PubNub;

@interface ChannelUnsubscriptionCallback : AbstractCallback

- (id)initWithChannelUnsubscriptionBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock
                             andDelegate:(PubNub *)pubnubDelegate;

- (void)removeFromUnsubscriptionCallbackList:(NSString *)channelName;

@end

#endif
