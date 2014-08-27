//
//  ChannelUnsubscriptionCallback.m
//
//  Created on 8/26/14.
//

#ifdef APPORTABLE

#import "ChannelUnsubscriptionCallback.h"

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
@property (nonatomic, readwrite, strong) NSMutableDictionary *channelToUnsubscritionCallbacks;

@end

@interface ChannelUnsubscriptionCallback ()

@property (nonatomic, readwrite, copy) PNClientChannelUnsubscriptionHandlerBlock handlerBlock;

@end

@implementation ChannelUnsubscriptionCallback

@synthesize handlerBlock = _handlerBlock;

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
    return @"com.pubnub.bridge.ChannelUnsubscriptionCallback";
}

- (id)initWithChannelUnsubscriptionBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock
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
        [self sendNotification:kPNClientUnsubscriptionDidCompleteNotification withObject:@[pubnubChannel]];
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
        [self sendNotification:kPNClientUnsubscriptionDidFailNotification withObject:error];
    });
}

- (void)removeFromUnsubscriptionCallbackList:(NSString *)channelName {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.pubnubDelegate.channelToUnsubscritionCallbacks removeObjectForKey:channelName];
        [self release];
    });
}

@end

#endif
