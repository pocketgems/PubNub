//
//  PubNub_AndroidBridge.h
//  PGEngine
//
//  Created by Ravi Agarwal on 3/18/14.
//  Copyright (c) 2014 Pocket Gems. All rights reserved.
//

#ifdef APPORTABLE

#import <BridgeKit/JavaObject.h>
#import <BridgeKit/AndroidActivity.h>

#import "Callbacks_Android.h"

@interface PubNub_AndroidBridge : JavaObject

+ (void)initializeJava;

+ (void)_initializePubnubWithPublishKey:(NSString *)publishKey
                           subscribeKey:(NSString *)subscriptionKey
                              secretKey:(NSString *)secretKey;

+ (void)_setClientIdentifier:(NSString *)clientIdntifier;

+ (NSString *)_getClientIdentifier;

+ (void)_subscribeOnChannel:(NSString *)channel withCallback:(ChannelSubscriptionCallback *)callback;

+ (void)_unsubscribeFromChannel:(NSString *)channnel withCallback:(ChannelUnsubscriptionCallback *)callback;

+ (void)_sendMessage:(NSString *)messageString channel:(NSString *)channelName withCallback:(MessageProcessingCallback *)callback;

+ (void)_sendJSONMessage:(NSString *)messageString channel:(NSString *)channelName withCallback:(MessageProcessingCallback *)callback;

+ (void)_requestHistoryForChannel:(NSString *)channelName
                            count:(int)limit
                   reverseHistory:(BOOL)shouldReverseHistory
                     withCallback:(MessageHistoryProcessingCallback *)callback;

+ (void)_shutdownPubnub;

@end

#endif