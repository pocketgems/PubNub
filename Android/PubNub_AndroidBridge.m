//
//  PubNub_AndroidBridge.m
//  PGEngine
//
//  Created by Ravi Agarwal on 3/18/14.
//  Copyright (c) 2014 Pocket Gems. All rights reserved.
//

#ifdef PGDROID

#import "PubNub_AndroidBridge.h"

#import "GameLog.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-property-implementation"
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation PubNub_AndroidBridge

+ (void)initializeJava {
    static dispatch_once_t PubNub_AndroidBridge_onceToken = 0;
    dispatch_once(&PubNub_AndroidBridge_onceToken, ^ {
        if ([NSThread currentThread] != [NSThread mainThread]) {
            LOG(@"initializeJava MUST be called on the main thread");
        }

        [super initializeJava];
        [PubNub_AndroidBridge registerStaticMethod:@"shutdownPubnub"
                                          selector:@selector(_shutdownPubnub)
                                       returnValue:nil
                                         arguments:NULL];

        [PubNub_AndroidBridge registerStaticMethod:@"initialializePubnub"
                                          selector:@selector(_initializePubnubWithPublishKey:subscribeKey:secretKey:)
                                       returnValue:nil
                                         arguments:[NSString className], [NSString className], [NSString className], NULL];
        [PubNub_AndroidBridge registerStaticMethod:@"setClientIdentifier"
                                          selector:@selector(_setClientIdentifier:)
                                       returnValue:nil
                                         arguments:[NSString className], NULL];
        [PubNub_AndroidBridge registerStaticMethod:@"getClientIdentifier"
                                          selector:@selector(_getClientIdentifier)
                                       returnValue:[NSString className]
                                         arguments:NULL];
        [PubNub_AndroidBridge registerStaticMethod:@"subscribeOnChannel"
                                          selector:@selector(_subscribeOnChannel:withCallback:)
                                       returnValue:nil
                                         arguments:[NSString className], [ChannelSubscriptionCallback className], NULL];
        [PubNub_AndroidBridge registerStaticMethod:@"unsubscribeFromChannel"
                                          selector:@selector(_unsubscribeFromChannel:withCallback:)
                                       returnValue:nil
                                         arguments:[NSString className], [ChannelUnsubscriptionCallback className], NULL];
        [PubNub_AndroidBridge registerStaticMethod:@"requestHistory"
                                          selector:@selector(_requestHistoryForChannel:count:reverseHistory:withCallback:)
                                       returnValue:nil
                                         arguments:[NSString className], [JavaClass intPrimitive], [JavaClass boolPrimitive], [MessageHistoryProcessingCallback className], NULL];
        [PubNub_AndroidBridge registerStaticMethod:@"sendMessage"
                                          selector:@selector(_sendMessage:channel:withCallback:)
                                       returnValue:nil
                                         arguments:[NSString className], [NSString className], [MessageProcessingCallback className], NULL];
    });
}

+ (NSString *)className {
    return @"com.pubnub.api.Pubnub";
}

@end

#pragma clang diagnostic pop

#endif