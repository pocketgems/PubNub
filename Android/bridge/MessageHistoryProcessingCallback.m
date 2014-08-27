//
//  MessageHistoryProcessingCallback.m
//
//  Created on 3/19/14.
//

#ifdef APPORTABLE

#import "MessageHistoryProcessingCallback.h"

#import "PNChannel.h"
#import "PNErrorCodes.h"
#import "PNJSONSerialization.h"
#import "PNNotifications.h"
#import "PNMacro.h"
#import "PNMessage.h"
#import "PNMessage+Protected.h"
#import "PNMessagesHistory+Protected.h"
#import "PubNub.h"
#import "PubNub+Protected.h"

@interface PubNub ()

@property (nonatomic, pn_desired_weak) id<PNDelegate> delegate;

@end

@interface MessageHistoryProcessingCallback ()

@property (nonatomic, readwrite, copy) PNClientHistoryLoadHandlingBlock handlerBlock;

@end

@implementation MessageHistoryProcessingCallback

@synthesize handlerBlock = _handlerBlock;

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
    return @"com.pubnub.bridge.MessageHistoryProcessingCallback";
}

- (id)initWithHistoryLoadHandlingBlock:(PNClientHistoryLoadHandlingBlock)handlerBlock andDelegate:(PubNub *)pubnubDelegate {
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
        PNChannel *pubnubChannel = [PNChannel channelWithName:channel];

        // Response object will be a JSON string
        __block NSArray *responseArray = nil;
        [PNJSONSerialization JSONObjectWithString:response
                                  completionBlock:^(id result, BOOL isJSONP, NSString *callbackMethodName) {
                                      responseArray = (NSArray *)result;
                                  }
                                  errorBlock:^(NSError *error) {
                                      PNLog(PNLogCommunicationChannelLayerErrorLevel, self, @"PROBLEM WHILE DECODING RESPONSE: %@", error);
                                  }];
        if (responseArray) {
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

            // Send notification to all who is interested in it (observation center will track it as well)
            PNMessagesHistory *history = [PNMessagesHistory historyBetween:nil andEndDate:nil];
            history.messages = messageArray;
            history.channel = pubnubChannel;
            [self sendNotification:kPNClientDidReceiveMessagesHistoryNotification withObject:history];
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
        [self sendNotification:kPNClientHistoryDownloadFailedWithErrorNotification withObject:error];
        [self release];
    });
}

@end

#endif
