//
//  MessageProcessingCallback.m
//
//  Created on 8/26/14.
//

#ifdef APPORTABLE

#import "MessageProcessingCallback.h"

#import "PNChannel.h"
#import "PNErrorCodes.h"
#import "PNNotifications.h"
#import "PNMacro.h"
#import "PNMessage+Protected.h"
#import "PNMessage.h"
#import "PubNub.h"
#import "PubNub+Protected.h"

@interface PubNub ()

@property (nonatomic, pn_desired_weak) id<PNDelegate> delegate;

@end

@interface MessageProcessingCallback ()

@property (nonatomic, readwrite, copy) PNClientMessageProcessingBlock handlerBlock;

@end

@implementation MessageProcessingCallback

@synthesize handlerBlock = _handlerBlock;

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
    return @"com.pubnub.bridge.MessageProcessingCallback";
}

- (id)initWithMessageProcessingBlock:(PNClientMessageProcessingBlock)handlerBlock andDelegate:(PubNub *)pubnubDelegate {
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

- (void)successCallback:(NSString *)channel response:(NSString *)response {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        PNLog(PNLogGeneralLevel, self, @"SUCCESS CALLBACK %@ %@", channel, response);
        if ([self.pubnubDelegate.delegate respondsToSelector:@selector(pubnubClient:didSendMessage:)]) {
            [self.pubnubDelegate.delegate pubnubClient:self.pubnubDelegate
                                        didSendMessage:nil];
        }
        if (self.handlerBlock) {
            self.handlerBlock(PNMessageSent, nil);
        }
        PNLog(PNLogCommunicationChannelLayerWarnLevel, self, @"DON'T HAVE ACCESS TO THE MESSAGE OBJECT SO SENDING NIL");
        [self sendNotification:kPNClientDidSendMessageNotification withObject:nil];
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
        [self sendNotification:kPNClientMessageSendingDidFailNotification withObject:error];
        [self release];
    });
}

@end

#endif
