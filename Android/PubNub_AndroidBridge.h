//
//  PubNub_AndroidBridge.h
//
//  Created on 3/18/14.
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

+ (void)_loggingEnabled:(BOOL)loggingEnabled;

@end

#endif