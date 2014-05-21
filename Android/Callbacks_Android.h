//
//  Callbacks_Android.h
//  testapp
//
//  Created by Ravi Agarwal on 3/19/14.
//  Copyright (c) 2014 Pocket Gems. All rights reserved.
//

#ifdef APPORTABLE

#import <BridgeKit/JavaObject.h>
#import <BridgeKit/AndroidActivity.h>

#import "PNStructures.h"
#import "PubNub.h"


@interface MessageProcessingCallback : JavaObject

- (id)initWithMessageProcessingBlock:(PNClientMessageProcessingBlock)handlerBlock andDelegate:(PubNub *)pubnubDelegate;

@end



@interface MessageHistoryProcessingCallback : JavaObject

- (id)initWithHistoryLoadHandlingBlock:(PNClientHistoryLoadHandlingBlock)handlerBlock andDelegate:(PubNub *)pubnubDelegate;

@end



@interface ChannelSubscriptionCallback : JavaObject

- (id)initWithChannelSubscriptionBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock
                           andDelegate:(PubNub *)pubnubDelegate;

- (void)removeFromSubscriptionCallbackList:(NSString *)channelName;

@end



@interface ChannelUnsubscriptionCallback : JavaObject

- (id)initWithChannelUnsubscriptionBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock
                             andDelegate:(PubNub *)pubnubDelegate;

- (void)removeFromUnsubscriptionCallbackList:(NSString *)channelName;

@end

#endif
