//
//  ChannelSubscriptionCallback.m
//
//  Created on 8/26/14.
//

#ifdef APPORTABLE

#import "ChannelSubscriptionCallback.h"

#import "PNChannel.h"
#import "PNErrorCodes.h"
#import "PNJSONSerialization.h"
#import "PNNotifications.h"
#import "PNMacro.h"
#import "PNMessage+Protected.h"
#import "PNMessagesHistory+Protected.h"
#import "PNMessage.h"
#import "PubNub+Protected.h"

@interface PubNub ()

@property (nonatomic, pn_desired_weak) id<PNDelegate> delegate;
@property (nonatomic, readwrite, strong) NSMutableDictionary *channelToSubscritionCallbacks;

@end

@interface ChannelSubscriptionCallback ()

@property (nonatomic, readwrite, copy) PNClientChannelSubscriptionHandlerBlock handlerBlock;

@end


@implementation ChannelSubscriptionCallback

@synthesize handlerBlock = _handlerBlock;

+ (void)initializeJava {
    static dispatch_once_t ChannelSubscriptionCallback_onceToken = 0;
    dispatch_once(&ChannelSubscriptionCallback_onceToken, ^ {
        [super initializeJava];

        [ChannelSubscriptionCallback registerConstructor];

        [ChannelSubscriptionCallback registerCallback:@"connectCallback_native"
                                             selector:@selector(connectCallback:response:)
                                          returnValue:nil
                                            arguments:[NSString className], [NSString className], NULL];

        [ChannelSubscriptionCallback registerCallback:@"disconnectCallback_native"
                                             selector:@selector(disconnectCallback:response:)
                                          returnValue:nil
                                            arguments:[NSString className], [NSString className], NULL];

        [ChannelSubscriptionCallback registerCallback:@"reconnectCallback_native"
                                             selector:@selector(reconnectCallback:response:)
                                          returnValue:nil
                                            arguments:[NSString className], [NSString className], NULL];

        [ChannelSubscriptionCallback registerCallback:@"successCallback_native"
                                             selector:@selector(successCallback:response:)
                                          returnValue:nil
                                            arguments:[NSString className], [NSString className], NULL];

        [ChannelSubscriptionCallback registerCallback:@"errorCallback_native"
                                             selector:@selector(errorCallback:errorCode:errorMessage:)
                                          returnValue:nil
                                            arguments:[NSString className], [JavaClass intPrimitive], [NSString className], NULL];

        [ChannelSubscriptionCallback registerCallback:@"retain_native"
                                             selector:@selector(retain)
                                          returnValue:[ChannelSubscriptionCallback className]
                                            arguments:nil];
        [ChannelSubscriptionCallback registerCallback:@"release_native"
                                             selector:@selector(release)
                                          returnValue:nil
                                            arguments:nil];

        [ChannelSubscriptionCallback registerCallback:@"removeFromSubscriptionCallbackList_native"
                                             selector:@selector(removeFromSubscriptionCallbackList:)
                                          returnValue:nil
                                            arguments:[NSString className], NULL];
    });
}

+ (NSString *)className {
    return @"com.pubnub.bridge.ChannelSubscriptionCallback";
}

- (id)initWithChannelSubscriptionBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock
                           andDelegate:(PubNub *)pubnubDelegate {
    self = [super initWithDelegate:pubnubDelegate];
    if (self) {
        self.handlerBlock = handlerBlock;
    }
    return self;
}

- (void)dealloc {
    [_handlerBlock release], _handlerBlock = nil;
    [super dealloc];
}

- (void)connectCallback:(NSString *)channel response:(NSString *)response {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        // Connect callback response contains 1, connected message and message
        PNLog(PNLogGeneralLevel, self, @"CONNECT CALLBACK %@ %@", channel, response);
        PNChannel *pubnubChannel = [PNChannel channelWithName:channel];
        if ([self.pubnubDelegate.delegate respondsToSelector:@selector(pubnubClient:didSubscribeOnChannels:)]) {
            [self.pubnubDelegate.delegate pubnubClient:self.pubnubDelegate
                                didSubscribeOnChannels:@[pubnubChannel]];
        }
        if (self.handlerBlock) {
            self.handlerBlock(PNSubscriptionProcessSubscribedState, @[pubnubChannel], nil);
        }

        // Send notification to all who is interested in it (observation center will track it as well)
        [self sendNotification:kPNClientSubscriptionDidCompleteNotification withObject:@[pubnubChannel]];
    });
}

- (void)disconnectCallback:(NSString *)channel response:(NSString *)response {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        PNLog(PNLogGeneralLevel, self, @"DISCONNECT CALLBACK %@ %@", channel, response);

        // Disconnect callback response contains 0, disconnected message, and message
        __block NSArray *responseArray = nil;
        [PNJSONSerialization JSONObjectWithString:response
                                  completionBlock:^(id result, BOOL isJSONP, NSString *callbackMethodName) {
                                      responseArray = (NSArray *)result;
                                  }
                                  errorBlock:^(NSError *error) {
                                      PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @"PROBLEM WHILE DECODING RESPONSE: %@", error);
                                  }];
        if (responseArray) {
            id errorMessage = responseArray[1];
            PNError *error = [PNError errorWithMessage:errorMessage code:kPNUnknownError];
            if ([self.pubnubDelegate.delegate respondsToSelector:@selector(pubnubClient:didDisconnectFromOrigin:withError:)]) {
                [self.pubnubDelegate.delegate pubnubClient:self.pubnubDelegate
                                   didDisconnectFromOrigin:self.pubnubDelegate.configuration.origin
                                                 withError:error];
            }
            if (self.handlerBlock) {
                PNChannel *pubnubChannel = [PNChannel channelWithName:channel];
                self.handlerBlock(PNSubscriptionProcessNotSubscribedState, @[pubnubChannel], error);
            }
            [self sendNotification:kPNClientConnectionDidFailWithErrorNotification withObject:error];
        }
    });
}

- (void)reconnect:(NSString *)channel response:(NSString *)response {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        // Reconnect callback response contains 1, reconnected message and message
        PNLog(PNLogGeneralLevel, self, @"RECONNECT CALLBACK %@ %@", channel, response);
        PNChannel *pubnubChannel = [PNChannel channelWithName:channel];
        if ([self.pubnubDelegate.delegate respondsToSelector:@selector(pubnubClient:didRestoreSubscriptionOnChannels:)]) {
            [self.pubnubDelegate.delegate pubnubClient:self.pubnubDelegate
                      didRestoreSubscriptionOnChannels:@[pubnubChannel]];
        }
        if (self.handlerBlock) {
            self.handlerBlock(PNSubscriptionProcessRestoredState, @[pubnubChannel], nil);
        }
        [self sendNotification:kPNClientSubscriptionDidRestoreNotification withObject:@[pubnubChannel]];
    });
}

- (void)successCallback:(NSString *)channel response:(NSString *)response {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        PNLog(PNLogGeneralLevel, self, @"SUCCESS CALLBACK %@ %@", channel, response);
        PNChannel *pubnubChannel = [PNChannel channelWithName:channel];
        __block id message = nil;
        [PNJSONSerialization JSONObjectWithString:response
                                  completionBlock:^(id result, BOOL isJSONP, NSString *callbackMethodName) {
                                      message = result;
                                  }
                                  errorBlock:^(NSError *error) {
                                      PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @"PROBLEM WHILE DECODING RESPONSE: %@", error);
                                  }];
        if (message) {
            PNMessage *pubnubMessage = [PNMessage messageFromServiceResponse:message onChannel:pubnubChannel atDate:nil];
            if ([self.pubnubDelegate.delegate respondsToSelector:@selector(pubnubClient:didReceiveMessage:)]) {
              [self.pubnubDelegate.delegate pubnubClient:self.pubnubDelegate
                                       didReceiveMessage:pubnubMessage];
            }
            [self sendNotification:kPNClientDidReceiveMessageNotification withObject:pubnubMessage];
        }
    });
}

- (void)errorCallback:(NSString *)channel errorCode:(int)errorCode errorMessage:(NSString *)errorMessage {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        PNLog(PNLogGeneralLevel, self, @"ERROR CALLBACK %@ %d %@", channel, errorCode, errorMessage);
        PNError *error = [PNError errorWithMessage:errorMessage code:errorCode];
        if ([self.pubnubDelegate.delegate respondsToSelector:@selector(pubnubClient:connectionDidFailWithError:)]) {
            [self.pubnubDelegate.delegate pubnubClient:self.pubnubDelegate
                            connectionDidFailWithError:error];
        }
        if (self.handlerBlock) {
            PNChannel *pubnubChannel = [PNChannel channelWithName:channel];
            self.handlerBlock(PNSubscriptionProcessNotSubscribedState, @[pubnubChannel], error);
        }
        [self sendNotification:kPNClientConnectionDidFailWithErrorNotification withObject:error];
    });
}

- (void)removeFromSubscriptionCallbackList:(NSString *)channelName {
    [self.pubnubDelegate.channelToSubscritionCallbacks removeObjectForKey:channelName];
    [self release];
}

@end

#endif
