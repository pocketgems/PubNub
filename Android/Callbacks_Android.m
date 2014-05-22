//
//  Callbacks_Android.m
//  testapp
//
//  Created by Ravi Agarwal on 3/19/14.
//  Copyright (c) 2014 Pocket Gems. All rights reserved.
//

#ifdef APPORTABLE

#import "Callbacks_Android.h"

#import "PGJSONUtility.h"
#import "PNChannel.h"
#import "PNMacro.h"
#import "PNMessage.h"
#import "PNMessage+Protected.h"
#import "PubNub+Protected.h"
#import "PNErrorCodes.h"

@interface PubNub ()

@property (nonatomic, pn_desired_weak) id<PNDelegate> delegate;
@property (nonatomic, readwrite, strong) NSMutableDictionary *channelToSubscritionCallbacks;
@property (nonatomic, readwrite, strong) NSMutableDictionary *channelToUnsubscritionCallbacks;

@end


@interface MessageProcessingCallback ()

@property (nonatomic, readwrite, copy) PNClientMessageProcessingBlock handlerBlock;
@property (nonatomic, readwrite, assign) PubNub *pubnubDelegate;

@end



@interface MessageHistoryProcessingCallback ()

@property (nonatomic, readwrite, copy) PNClientHistoryLoadHandlingBlock handlerBlock;
@property (nonatomic, readwrite, assign) PubNub *pubnubDelegate;

@end



@interface ChannelSubscriptionCallback ()

@property (nonatomic, readwrite, copy) PNClientChannelSubscriptionHandlerBlock handlerBlock;
@property (nonatomic, readwrite, assign) PubNub *pubnubDelegate;

@end



@interface ChannelUnsubscriptionCallback ()

@property (nonatomic, readwrite, copy) PNClientChannelUnsubscriptionHandlerBlock handlerBlock;
@property (nonatomic, readwrite, assign) PubNub *pubnubDelegate;

@end






@implementation MessageProcessingCallback

@synthesize handlerBlock = _handlerBlock;
@synthesize pubnubDelegate = _pubnubDelegate;

+ (void)initializeJava {
    static dispatch_once_t MessageProcessingCallback_onceToken = 0;
    dispatch_once(&MessageProcessingCallback_onceToken, ^ {
        [super initializeJava];

        [MessageProcessingCallback registerConstructor];

        [MessageProcessingCallback registerCallback:@"successCallback_native"
                                           selector:@selector(successCallback:response:)
                                        returnValue:nil
                                          arguments:[NSString className], [NSString className], NULL];

        [MessageProcessingCallback registerCallback:@"errorCallback_native"
                                           selector:@selector(errorCallback:errorCode:errorMessage:)
                                        returnValue:nil
                                          arguments:[NSString className], [JavaClass intPrimitive], [NSString className], NULL];

        [MessageProcessingCallback registerCallback:@"retain_native"
                                           selector:@selector(retain)
                                        returnValue:[MessageProcessingCallback className]
                                          arguments:nil];
        [MessageProcessingCallback registerCallback:@"release_native"
                                           selector:@selector(release)
                                        returnValue:nil
                                          arguments:nil];
    });
}

+ (NSString *)className {
    return @"com.pocketgems.pgengine.pubnub.MessageProcessingCallback";
}

- (id)initWithMessageProcessingBlock:(PNClientMessageProcessingBlock)handlerBlock andDelegate:(PubNub *)pubnubDelegate {
    self = [super init];
    if (self) {
        self.handlerBlock = handlerBlock;
        self.pubnubDelegate = pubnubDelegate;
        PNLog(PNLogGeneralLevel, self, @"INITIALIZING MESSAGE PROCESSING CALLBACK");
    }
    return self;
}

- (void)successCallback:(NSString *)channel response:(NSString *)response {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        PNLog(PNLogGeneralLevel, self, @"SUCCESS CALLBACK %@ %@", channel, response);
        if ([self.pubnubDelegate.delegate respondsToSelector:@selector(pubnubClient:didSendMessage:)]) {
            PNLog(PNLogCommunicationChannelLayerWarnLevel, self, @"DON'T HAVE ACCESS TO THE MESSAGE OBJECT SO SENDING NIL");
            [self.pubnubDelegate.delegate pubnubClient:self.pubnubDelegate
                                        didSendMessage:nil];
        }
        if (self.handlerBlock) {
            PNLog(PNLogCommunicationChannelLayerWarnLevel, self, @"DON'T HAVE ACCESS TO THE MESSAGE OBJECT SO SENDING NIL");
            self.handlerBlock(PNMessageSent, nil);
        }
        [self release];
    });
}

- (void)errorCallback:(NSString *)channel errorCode:(int)errorCode errorMessage:(NSString *)errorMessage {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        PNLog(PNLogGeneralLevel, self, @"ERROR CALLBACK %@ %d %@", channel, errorCode, errorMessage);
        PNError *error = [PNError errorWithMessage:errorMessage code:errorCode];
        if ([self.pubnubDelegate.delegate respondsToSelector:@selector(pubnubClient:didFailMessageSend:withError:)]) {
            [self.pubnubDelegate.delegate pubnubClient:self.pubnubDelegate
                                    didFailMessageSend:nil
                                             withError:error];
        }
        if (self.handlerBlock) {
            self.handlerBlock(PNMessageSendingError, error);
        }
        [self release];
    });
}

- (void)dealloc {
    PNLog(PNLogGeneralLevel, self, @"DEALLOCING MESSAGE PROCESSING CALLBACK");
    [_handlerBlock release], _handlerBlock = nil;
    _pubnubDelegate = nil;
    [super dealloc];
}

@end






@implementation MessageHistoryProcessingCallback

@synthesize handlerBlock = _handlerBlock;
@synthesize pubnubDelegate = _pubnubDelegate;

+ (void)initializeJava {
    static dispatch_once_t MessageHistoryProcessingCallback_onceToken = 0;
    dispatch_once(&MessageHistoryProcessingCallback_onceToken, ^ {
        [super initializeJava];

        [MessageHistoryProcessingCallback registerConstructor];

        [MessageHistoryProcessingCallback registerCallback:@"successCallback_native"
                                                  selector:@selector(successCallback:response:)
                                               returnValue:nil
                                                 arguments:[NSString className], [NSString className], NULL];

        [MessageHistoryProcessingCallback registerCallback:@"errorCallback_native"
                                                  selector:@selector(errorCallback:errorCode:errorMessage:)
                                               returnValue:nil
                                                 arguments:[NSString className], [JavaClass intPrimitive], [NSString className], NULL];

        [MessageHistoryProcessingCallback registerCallback:@"retain_native"
                                                  selector:@selector(retain)
                                               returnValue:[MessageHistoryProcessingCallback className]
                                                 arguments:nil];
        [MessageHistoryProcessingCallback registerCallback:@"release_native"
                                                  selector:@selector(release)
                                               returnValue:nil
                                                 arguments:nil];
    });
}

+ (NSString *)className {
    return @"com.pocketgems.pgengine.pubnub.MessageHistoryProcessingCallback";
}

- (id)initWithHistoryLoadHandlingBlock:(PNClientHistoryLoadHandlingBlock)handlerBlock andDelegate:(PubNub *)pubnubDelegate {
    self = [super init];
    if (self) {
        self.handlerBlock = handlerBlock;
        self.pubnubDelegate = pubnubDelegate;
        PNLog(PNLogGeneralLevel, self, @"INITIALIZING MESSAGE HISTORY PROCESSING CALLBACK");
    }
    return self;
}

- (void)successCallback:(NSString *)channel response:(NSString *)response {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        PNLog(PNLogGeneralLevel, self, @"SUCCESS CALLBACK %@ %@", channel, response);
        PNChannel *pubnubChannel = [PNChannel channelWithName:channel];

        // Response object will be a JSON string
        NSArray *responseArray = [PGJSONUtility objectFromString:response];
        NSMutableArray *messageArray = [NSMutableArray arrayWithCapacity:responseArray.count];

        for (id message in responseArray) {
            PNError *error = nil;
            PNMessage *pubnubMessage = [PNMessage messageFromServiceResponse:message onChannel:pubnubChannel atDate:nil];
            if (error) {
                PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @"PROBLEM WHILE CREATING A PNMESSAGE OBJECT USING THE MESSAGE %@", message);
            }
            else {
                [messageArray addObject:pubnubMessage];
            }
        }
        if ([self.pubnubDelegate.delegate respondsToSelector:@selector(pubnubClient:didReceiveMessageHistory:forChannel:startingFrom:to:)]) {
            [self.pubnubDelegate.delegate pubnubClient:self.pubnubDelegate
                              didReceiveMessageHistory:messageArray
                                            forChannel:pubnubChannel
                                          startingFrom:nil
                                                    to:nil];
        }
        if (self.handlerBlock) {
            self.handlerBlock(messageArray, pubnubChannel, nil, nil, nil);
        }
        [self release];
    });
}

- (void)errorCallback:(NSString *)channel errorCode:(int)errorCode errorMessage:(NSString *)errorMessage {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        PNLog(PNLogGeneralLevel, self, @"ERROR CALLBACK %@ %d %@", channel, errorCode, errorMessage);
        PNError *error = [PNError errorWithMessage:errorMessage code:errorCode];
        PNChannel *pubnubChannel = [PNChannel channelWithName:channel];
        if ([self.pubnubDelegate.delegate respondsToSelector:@selector(pubnubClient:didFailHistoryDownloadForChannel:withError:)]) {
            [self.pubnubDelegate.delegate pubnubClient:self.pubnubDelegate
                      didFailHistoryDownloadForChannel:pubnubChannel
                                             withError:error];
        }
        if (self.handlerBlock) {
            self.handlerBlock(nil, pubnubChannel, nil, nil, error);
        }
        [self release];
    });
}

- (void)dealloc {
    PNLog(PNLogGeneralLevel, self, @"DEALLOCING MESSAGE HISTORY PROCESSING CALLBACK");
    [_handlerBlock release], _handlerBlock = nil;
    _pubnubDelegate = nil;
    [super dealloc];
}

@end





@implementation ChannelSubscriptionCallback

@synthesize handlerBlock = _handlerBlock;
@synthesize pubnubDelegate = _pubnubDelegate;


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
    return @"com.pocketgems.pgengine.pubnub.ChannelSubscriptionCallback";
}

- (id)initWithChannelSubscriptionBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock
                           andDelegate:(PubNub *)pubnubDelegate {
    self = [super init];
    if (self) {
        self.handlerBlock = handlerBlock;
        self.pubnubDelegate = pubnubDelegate;
        PNLog(PNLogGeneralLevel, self, @"INITIALIZING CHANNEL SUBSCRIPTION CALLBACK");
    }
    return self;
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
    });
}

- (void)disconnectCallback:(NSString *)channel response:(NSString *)response {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        PNLog(PNLogGeneralLevel, self, @"DISCONNECT CALLBACK %@ %@", channel, response);

        // Disconnect callback response contains 0, disconnected message, and message
        id responseArray = [PGJSONUtility objectFromString:response];
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
    });
}

- (void)successCallback:(NSString *)channel response:(NSString *)response {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        PNLog(PNLogGeneralLevel, self, @"SUCCESS CALLBACK %@ %@", channel, response);
        PNChannel *pubnubChannel = [PNChannel channelWithName:channel];
        id message = [PGJSONUtility objectFromString:response];
        PNMessage *pubnubMessage = [PNMessage messageFromServiceResponse:message onChannel:pubnubChannel atDate:nil];
        if ([self.pubnubDelegate.delegate respondsToSelector:@selector(pubnubClient:didReceiveMessage:)]) {
            [self.pubnubDelegate.delegate pubnubClient:self.pubnubDelegate
                                     didReceiveMessage:pubnubMessage];
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
    });
}

- (void)dealloc {
    PNLog(PNLogGeneralLevel, self, @"DEALLOCING CHANNEL SUBSCRIPTION CALLBACK");
    [_handlerBlock release], _handlerBlock = nil;
    _pubnubDelegate = nil;
    [super dealloc];
}

- (void)removeFromSubscriptionCallbackList:(NSString *)channelName {
    [self.pubnubDelegate.channelToSubscritionCallbacks removeObjectForKey:channelName];
    [self release];
}

@end







@implementation ChannelUnsubscriptionCallback

@synthesize handlerBlock = _handlerBlock;
@synthesize pubnubDelegate = _pubnubDelegate;

+ (void)initializeJava {
    static dispatch_once_t ChannelUnsubscriptionCallback_onceToken = 0;
    dispatch_once(&ChannelUnsubscriptionCallback_onceToken, ^ {
        [super initializeJava];

        [ChannelUnsubscriptionCallback registerConstructor];

        [ChannelUnsubscriptionCallback registerCallback:@"successCallback_native"
                                               selector:@selector(successCallback:response:)
                                            returnValue:nil
                                              arguments:[NSString className], [NSString className], NULL];

        [ChannelUnsubscriptionCallback registerCallback:@"errorCallback_native"
                                               selector:@selector(errorCallback:errorCode:errorMessage:)
                                            returnValue:nil
                                              arguments:[NSString className], [JavaClass intPrimitive], [NSString className], NULL];

        [ChannelUnsubscriptionCallback registerCallback:@"retain_native"
                                               selector:@selector(retain)
                                            returnValue:[ChannelUnsubscriptionCallback className]
                                              arguments:nil];
        [ChannelUnsubscriptionCallback registerCallback:@"release_native"
                                               selector:@selector(release)
                                            returnValue:nil
                                              arguments:nil];

        [ChannelUnsubscriptionCallback registerCallback:@"removeFromUnsubscriptionCallbackList_native"
                                               selector:@selector(removeFromUnsubscriptionCallbackList:)
                                            returnValue:nil
                                              arguments:[NSString className], NULL];
    });
}

+ (NSString *)className {
    return @"com.pocketgems.pgengine.pubnub.ChannelUnsubscriptionCallback";
}

- (id)initWithChannelUnsubscriptionBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock
                             andDelegate:(PubNub *)pubnubDelegate {
    self = [super init];
    if (self) {
        self.handlerBlock = handlerBlock;
        self.pubnubDelegate = pubnubDelegate;
        PNLog(PNLogGeneralLevel, self, @"INITIALIZING CHANNEL UNSUBSCRIPTION CALLBACK");
    }
    return self;
}

- (void)successCallback:(NSString *)channelName response:(NSString *)response {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        // Unsubscription success callback response contains 'Channel Unsubscribed' string
        PNLog(PNLogGeneralLevel, self, @"SUCCESS CALLBACK %@ %@", channelName, response);
        PNChannel *pubnubChannel = [PNChannel channelWithName:channelName];
        if ([self.pubnubDelegate.delegate respondsToSelector:@selector(pubnubClient:didUnsubscribeOnChannels:)]) {
            [self.pubnubDelegate.delegate pubnubClient:self.pubnubDelegate
                              didUnsubscribeOnChannels:@[pubnubChannel]];
        }
        if (self.handlerBlock) {
            self.handlerBlock(@[pubnubChannel], nil);
        }
    });
}

- (void)errorCallback:(NSString *)channelName errorCode:(int)errorCode errorMessage:(NSString *)errorMessage {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        PNLog(PNLogGeneralLevel, self, @"ERROR CALLBACK %@ %d %@", channelName, errorCode, errorMessage);
        PNError *error = [PNError errorWithMessage:errorMessage code:errorCode];
        if ([self.pubnubDelegate.delegate respondsToSelector:@selector(pubnubClient:unsubscriptionDidFailWithError:)]) {
            [self.pubnubDelegate.delegate pubnubClient:self.pubnubDelegate
                        unsubscriptionDidFailWithError:error];
        }
        if (self.handlerBlock) {
            PNChannel *pubnubChannel = [PNChannel channelWithName:channelName];
            self.handlerBlock(@[pubnubChannel], error);
        }
    });
}

- (void)dealloc {
    PNLog(PNLogGeneralLevel, self, @"DEALLOCING CHANNEL UNSUBSCRIPTION CALLBACK");
    [_handlerBlock release], _handlerBlock = nil;
    _pubnubDelegate = nil;
    [super dealloc];
}

- (void)removeFromUnsubscriptionCallbackList:(NSString *)channelName {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.pubnubDelegate.channelToUnsubscritionCallbacks removeObjectForKey:channelName];
        [self release];
    });
}

@end

#endif
