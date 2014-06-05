//
//  PubNub_Android.m
//
//  Created on 3/19/14.
//

#ifdef APPORTABLE

#import "PubNub.h"

#import "PNConfiguration+Protected.h"
#import "PNConfiguration.h"
#import "PNCryptoHelper.h"
#import "PNJSONSerialization.h"
#import "PNMacro.h"
#import "PubNub_AndroidBridge.h"

BOOL _isLoggingEnabled = NO;

#pragma mark - PubNub Android

@interface PubNub ()

@property (nonatomic, readwrite, pn_desired_weak) id<PNDelegate> delegate;
@property (nonatomic, readwrite, strong) PNConfiguration *configuration;
@property (nonatomic, readwrite, assign) BOOL clientConnected;

@property (nonatomic, readwrite, strong) NSMutableDictionary *channelToSubscritionCallbacks;
@property (nonatomic, readwrite, strong) NSMutableDictionary *channelToUnsubscritionCallbacks;

@end

static PubNub *__sharedInstance;
static dispatch_once_t __pubNubOnceToken;

@implementation PubNub

#pragma mark - Class methods

+ (PubNub *)sharedInstance {
    dispatch_once(&__pubNubOnceToken, ^{
        [PubNub_AndroidBridge initializeJava];
        __sharedInstance = [[[self class] alloc] init];
        PNLog(PNLogGeneralLevel, __sharedInstance, @"INITIALIZING SHARED INSTANCE");
    });

    return __sharedInstance;
}

+ (void)resetClient {
    PNLog(PNLogGeneralLevel, __sharedInstance, @"CLIENT RESET.");

    [self disconnect];

    __pubNubOnceToken = 0;

    __sharedInstance.delegate = nil;
    __sharedInstance.configuration = nil;

    __sharedInstance = nil;
}

#pragma mark - Client connection management methods

+ (void)connect {
    [self connectWithSuccessBlock:nil errorBlock:nil];
}

+ (void)connectWithSuccessBlock:(PNClientConnectionSuccessBlock)success
                     errorBlock:(PNClientConnectionFailureBlock)failure {
    PNLog(PNLogDelegateLevel, [self sharedInstance], @"PUBNUB WILL CONNECT TO ORIGIN: %@)",
          [self sharedInstance].configuration.origin);
}

+ (void)disconnect {
    [self disconnectByUser:YES];
}

+ (void)disconnectByUser:(BOOL)isDisconnectedByUser {
    PNLog(PNLogGeneralLevel, [self sharedInstance], @"TRYING TO DISCONNECT%@",
          isDisconnectedByUser ? @" BY USER REQUEST." : @" BY INTERNAL REQUEST");

    for (NSString *channelName in [[[self sharedInstance] channelToSubscritionCallbacks] allKeys]) {
        ChannelSubscriptionCallback *callback = [[self sharedInstance] channelToSubscritionCallbacks][channelName];

        [callback removeFromSubscriptionCallbackList:channelName];
    }
    for (NSString *channelName in [[[self sharedInstance] channelToUnsubscritionCallbacks] allKeys]) {
        ChannelUnsubscriptionCallback *callback = [[self sharedInstance] channelToUnsubscritionCallbacks][channelName];

        [callback removeFromUnsubscriptionCallbackList:channelName];
    }

    [PubNub_AndroidBridge _shutdownPubnub];

    //    Remove all callbacks and make sure they get dealloced
    //
    //    Call Pubnub Shutdown on Java
    //    Remove all PNObjervation callback's call PNObservation reset
    //    Remove observing any notifications from PubNubObservation
}

#pragma mark - Client configuration

+ (void)setConfiguration:(PNConfiguration *)configuration {

    [self setupWithConfiguration:configuration andDelegate:[self sharedInstance].delegate];
}

+ (void)setupWithConfiguration:(PNConfiguration *)configuration andDelegate:(id<PNDelegate>)delegate {
    if ([configuration isValid]) {
        if (configuration && [[[self sharedInstance] configuration] isEqual:configuration]) {
            // Don't do anything as they are equal
            PNLog(PNLogGeneralLevel, [self sharedInstance], @"IGNORE CONFIGURATION UPDATE. IT IS THE SAME AS WAS SET BEFORE");
        }
        else if (![[self sharedInstance] configuration]) {
            // Initialize Java Pubnub
            [self sharedInstance].configuration = configuration;
            [PubNub_AndroidBridge _initializePubnubWithPublishKey:configuration.publishKey
                                                     subscribeKey:configuration.subscriptionKey
                                                        secretKey:configuration.secretKey];
        }
        else {
            PNLog(PNLogGeneralLevel, [self sharedInstance], @"SETTING A NEW CONFIGURATION IS NOT YET SUPPORTED %@", configuration);
        }
    }
    else {
        PNLog(PNLogGeneralLevel, [self sharedInstance], @"PROVIDED CONFIGURATION %@ IS NOT VALID", configuration);
    }
}

+ (void)setDelegate:(id<PNDelegate>)delegate {
    [self sharedInstance].delegate = delegate;
}

#pragma mark - Client identification

+ (void)setClientIdentifier:(NSString *)identifier {
    [self setClientIdentifier:identifier shouldCatchup:NO];
}

+ (void)setClientIdentifier:(NSString *)identifier shouldCatchup:(BOOL)shouldCatchup {
    if (shouldCatchup) {
        PNLog(PNLogGeneralLevel, [self sharedInstance], @"SHOULD CATCHUP IS NOT SUPPORTED ON ANDROID");
        DEBUG_BREAK();
    }
    else {
        PNLog(PNLogGeneralLevel, [self sharedInstance], @"UPDATING CLIENT IDENTIFIER %@", identifier);
        [PubNub_AndroidBridge _setClientIdentifier:identifier];
    }
}

+ (NSString *)clientIdentifier {
    return [PubNub_AndroidBridge _getClientIdentifier];
}

#pragma mark - Channels subscription management

+ (NSArray *)subscribedChannels {
    NSUnimplementedFunction();
    DEBUG_BREAK();
    return nil;
}

+ (BOOL)isSubscribedOnChannel:(PNChannel *)channel {
    if ([[self sharedInstance] channelToSubscritionCallbacks][channel.name]) {
        return YES;
    }
    else {
        return NO;
    }
}

+ (void)subscribeOnChannel:(PNChannel *)channel {

    [self subscribeOnChannels:@[channel]];
}

+ (void) subscribeOnChannel:(PNChannel *)channel
withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {

    [self subscribeOnChannels:@[channel] withCompletionHandlingBlock:handlerBlock];
}

+ (void)subscribeOnChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent {

    [self subscribeOnChannels:@[channel] withPresenceEvent:withPresenceEvent];
}

+ (void)subscribeOnChannel:(PNChannel *)channel
         withPresenceEvent:(BOOL)withPresenceEvent
andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {

    [self subscribeOnChannels:@[channel] withPresenceEvent:withPresenceEvent andCompletionHandlingBlock:handlerBlock];
}

+ (void)subscribeOnChannels:(NSArray *)channels {

    [self subscribeOnChannels:channels withCompletionHandlingBlock:nil];
}

+ (void)subscribeOnChannels:(NSArray *)channels
withCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {

    [self subscribeOnChannels:channels withPresenceEvent:YES andCompletionHandlingBlock:handlerBlock];
}

+ (void)subscribeOnChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent {

    [self subscribeOnChannels:channels withPresenceEvent:withPresenceEvent andCompletionHandlingBlock:nil];
}

+ (void)subscribeOnChannels:(NSArray *)channels
          withPresenceEvent:(BOOL)withPresenceEvent
 andCompletionHandlingBlock:(PNClientChannelSubscriptionHandlerBlock)handlerBlock {
    if (withPresenceEvent) {
        // Throw an error saying it's not supported
        PNLog(PNLogGeneralLevel, [self sharedInstance], @"WITH PRESENCE EVENT SUBSCRIBING ON A CHANNEL IS NOT SUPPORTED");
        DEBUG_BREAK();
    }
    else {
        PNLog(PNLogGeneralLevel, [self sharedInstance], @"TRYING TO SUBSCRIBE ON CHANNELS: %@", channels);
        for (PNChannel *channel in channels) {
            if (self.sharedInstance.channelToSubscritionCallbacks[channel.name]) {
                // Alreday Subscribed - Do nothing
            }
            else {
                // If in the process of unsubscription remove it
                id unsubscriptionCallback = [[self sharedInstance] channelToUnsubscritionCallbacks][channel.name];
                [unsubscriptionCallback removeFromUnsubscriptionCallbackList:channel.name];

                // Try to subscribe
                ChannelSubscriptionCallback *callback = [[ChannelSubscriptionCallback alloc] initWithChannelSubscriptionBlock:handlerBlock
                                                                                                                  andDelegate:[self sharedInstance]];
                [PubNub_AndroidBridge _subscribeOnChannel:channel.name withCallback:callback];
                [[self sharedInstance] channelToSubscritionCallbacks][channel.name] = callback;
            }
        }
    }
}

+ (void)unsubscribeFromChannel:(PNChannel *)channel {

    [self unsubscribeFromChannels:@[channel]];
}

+ (void)unsubscribeFromChannel:(PNChannel *)channel
   withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {

    [self unsubscribeFromChannels:@[channel] withPresenceEvent:YES andCompletionHandlingBlock:handlerBlock];
}

+ (void)unsubscribeFromChannel:(PNChannel *)channel withPresenceEvent:(BOOL)withPresenceEvent {

    [self unsubscribeFromChannels:@[channel] withPresenceEvent:withPresenceEvent andCompletionHandlingBlock:nil];
}

+ (void)unsubscribeFromChannel:(PNChannel *)channel
             withPresenceEvent:(BOOL)withPresenceEvent
    andCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {

    [self unsubscribeFromChannels:@[channel]
                withPresenceEvent:withPresenceEvent
       andCompletionHandlingBlock:handlerBlock];
}

+ (void)unsubscribeFromChannels:(NSArray *)channels {

    [self unsubscribeFromChannels:channels withPresenceEvent:YES];
}

+ (void)unsubscribeFromChannels:(NSArray *)channels
    withCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {

    [self unsubscribeFromChannels:channels withPresenceEvent:YES andCompletionHandlingBlock:handlerBlock];
}

+ (void)unsubscribeFromChannels:(NSArray *)channels withPresenceEvent:(BOOL)withPresenceEvent {

    [self unsubscribeFromChannels:channels withPresenceEvent:withPresenceEvent andCompletionHandlingBlock:nil];
}

+ (void)unsubscribeFromChannels:(NSArray *)channels
              withPresenceEvent:(BOOL)withPresenceEvent
     andCompletionHandlingBlock:(PNClientChannelUnsubscriptionHandlerBlock)handlerBlock {
    if (withPresenceEvent) {
        // Throw an error saying it's not supported
        PNLog(PNLogGeneralLevel, [self sharedInstance], @"WITH PRESENCE EVENT UNSUBSCRIBING ON A CHANNEL IS NOT SUPPORTED");
        DEBUG_BREAK();
    }
    else {
        PNLog(PNLogGeneralLevel, [self sharedInstance], @"TRYING TO UNSUBSCRIBE FROM CHANNELS: %@", channels);
        for (PNChannel *channel in channels) {
            if ([[self sharedInstance] channelToUnsubscritionCallbacks][channel.name]) {
                // Alreday in Unsubscribtion process - Do nothing
            }
            else {
                // If subscribed remove it.
                id subscriptionCallback = [[self sharedInstance] channelToSubscritionCallbacks][channel.name];
                [subscriptionCallback removeFromSubscriptionCallbackList:channel.name];

                // Try to subscribe
                ChannelUnsubscriptionCallback *callback = [[ChannelUnsubscriptionCallback alloc] initWithChannelUnsubscriptionBlock:handlerBlock
                                                                                                                        andDelegate:[self sharedInstance]];
                [PubNub_AndroidBridge _unsubscribeFromChannel:channel.name withCallback:callback];
                [[self sharedInstance] channelToUnsubscritionCallbacks][channel.name] = callback;
            }
        }
    }
}


#pragma mark - APNS management

+ (void)enablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken {

    [self enablePushNotificationsOnChannel:channel withDevicePushToken:pushToken andCompletionHandlingBlock:nil];
}

+ (void)enablePushNotificationsOnChannel:(PNChannel *)channel
                     withDevicePushToken:(NSData *)pushToken
              andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock {

    [self enablePushNotificationsOnChannels:@[channel] withDevicePushToken:pushToken andCompletionHandlingBlock:handlerBlock];
}

+ (void)enablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken {

    [self enablePushNotificationsOnChannels:channels withDevicePushToken:pushToken andCompletionHandlingBlock:nil];
}

+ (void)enablePushNotificationsOnChannels:(NSArray *)channels
                      withDevicePushToken:(NSData *)pushToken
               andCompletionHandlingBlock:(PNClientPushNotificationsEnableHandlingBlock)handlerBlock {
    NSUnimplementedFunction();
    return;
}

+ (void)disablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken {

    [self disablePushNotificationsOnChannel:channel withDevicePushToken:pushToken andCompletionHandlingBlock:nil];
}

+ (void)disablePushNotificationsOnChannel:(PNChannel *)channel withDevicePushToken:(NSData *)pushToken
               andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock {

    [self disablePushNotificationsOnChannels:@[channel] withDevicePushToken:pushToken andCompletionHandlingBlock:handlerBlock];
}

+ (void)disablePushNotificationsOnChannels:(NSArray *)channels withDevicePushToken:(NSData *)pushToken {

    [self disablePushNotificationsOnChannels:channels withDevicePushToken:pushToken andCompletionHandlingBlock:nil];
}

+ (void)disablePushNotificationsOnChannels:(NSArray *)channels
                       withDevicePushToken:(NSData *)pushToken
                andCompletionHandlingBlock:(PNClientPushNotificationsDisableHandlingBlock)handlerBlock {
    NSUnimplementedFunction();
    return;
}

+ (void)removeAllPushNotificationsForDevicePushToken:(NSData *)pushToken
                         withCompletionHandlingBlock:(PNClientPushNotificationsRemoveHandlingBlock)handlerBlock {
    NSUnimplementedFunction();
    return;
}

+ (void)requestPushNotificationEnabledChannelsForDevicePushToken:(NSData *)pushToken
                                     withCompletionHandlingBlock:(PNClientPushNotificationsEnabledChannelsHandlingBlock)handlerBlock {
    NSUnimplementedFunction();
    return;
}

#pragma mark - Presence management

+ (BOOL)isPresenceObservationEnabledForChannel:(PNChannel *)channel {

    BOOL observingPresence = NO;

    // Ensure that PubNub client currently connected to
    // remote PubNub services
    if ([[self sharedInstance] isConnected]) {
        NSUnimplementedFunction();
    }

    return observingPresence;
}

+ (void)enablePresenceObservationForChannel:(PNChannel *)channel {

    [self enablePresenceObservationForChannel:channel withCompletionHandlingBlock:nil];
}

+ (void)enablePresenceObservationForChannel:(PNChannel *)channel
                withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock {

    [self enablePresenceObservationForChannels:@[channel] withCompletionHandlingBlock:handlerBlock];
}

+ (void)enablePresenceObservationForChannels:(NSArray *)channels {

    [self enablePresenceObservationForChannels:channels withCompletionHandlingBlock:nil];
}

+ (void)enablePresenceObservationForChannels:(NSArray *)channels
                 withCompletionHandlingBlock:(PNClientPresenceEnableHandlingBlock)handlerBlock {
    NSUnimplementedFunction();
    return;
}

+ (void)disablePresenceObservationForChannel:(PNChannel *)channel {

    [self disablePresenceObservationForChannel:channel withCompletionHandlingBlock:nil];
}

+ (void)disablePresenceObservationForChannel:(PNChannel *)channel
                 withCompletionHandlingBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock {

    [self disablePresenceObservationForChannels:@[channel] withCompletionHandlingBlock:handlerBlock];
}

+ (void)disablePresenceObservationForChannels:(NSArray *)channels {

    [self disablePresenceObservationForChannels:channels withCompletionHandlingBlock:nil];
}

+ (void)disablePresenceObservationForChannels:(NSArray *)channels
                  withCompletionHandlingBlock:(PNClientPresenceDisableHandlingBlock)handlerBlock {
    NSUnimplementedFunction();
    return;
}

#pragma mark - Time token

+ (void)requestServerTimeToken {

    [self requestServerTimeTokenWithCompletionBlock:nil];
}

+ (void)requestServerTimeTokenWithCompletionBlock:(PNClientTimeTokenReceivingCompleteBlock)success {
    NSUnimplementedFunction();
    return;
}

#pragma mark - Messages processing methods

+ (PNMessage *)sendMessage:(id)message toChannel:(PNChannel *)channel {

    return [self sendMessage:message toChannel:channel withCompletionBlock:nil];
}

+ (PNMessage *)sendMessage:(id)message
                 toChannel:(PNChannel *)channel
       withCompletionBlock:(PNClientMessageProcessingBlock)success {
    // Maybe unregister self from older message sent?

    NSString *messageToBeSent = nil;
    MessageProcessingCallback *callback = [[MessageProcessingCallback alloc] initWithMessageProcessingBlock:success
                                                                                                andDelegate:[self sharedInstance]];

    if ([message isKindOfClass:[NSString class]]) {
        messageToBeSent = message;
        [PubNub_AndroidBridge _sendMessage:messageToBeSent channel:channel.name withCallback:callback];
    }
    else {
        messageToBeSent = [PNJSONSerialization stringFromJSONObject:message];
        [PubNub_AndroidBridge _sendJSONMessage:messageToBeSent channel:channel.name withCallback:callback];
    }

    // Return a proper PNMessage
    return nil;
}

+ (void)sendMessage:(PNMessage *)message {

    [self sendMessage:message.message withCompletionBlock:nil];
}

+ (void)sendMessage:(PNMessage *)message withCompletionBlock:(PNClientMessageProcessingBlock)success {

    [self sendMessage:message.message toChannel:message.channel withCompletionBlock:success];
}


#pragma mark - History methods

+ (void)requestFullHistoryForChannel:(PNChannel *)channel {

    [self requestFullHistoryForChannel:channel withCompletionBlock:nil];
}

+ (void)requestFullHistoryForChannel:(PNChannel *)channel
                 withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

    [self requestHistoryForChannel:channel from:nil to:nil withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate {

    [self requestHistoryForChannel:channel from:startDate to:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel from:(PNDate *)startDate to:(PNDate *)endDate {

    [self requestHistoryForChannel:channel from:startDate to:endDate withCompletionBlock:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(PNDate *)startDate
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

    [self requestHistoryForChannel:channel from:startDate to:nil withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(PNDate *)startDate
                              to:(PNDate *)endDate
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

    [self requestHistoryForChannel:channel from:startDate to:endDate limit:0 withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(PNDate *)startDate
                           limit:(NSUInteger)limit {

    [self requestHistoryForChannel:channel from:startDate to:nil limit:limit];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(PNDate *)startDate
                              to:(PNDate *)endDate
                           limit:(NSUInteger)limit {

    [self requestHistoryForChannel:channel from:startDate to:endDate limit:limit withCompletionBlock:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(PNDate *)startDate
                           limit:(NSUInteger)limit
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

    [self requestHistoryForChannel:channel from:startDate to:nil limit:limit withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(PNDate *)startDate
                              to:(PNDate *)endDate
                           limit:(NSUInteger)limit
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

    [self requestHistoryForChannel:channel
                              from:startDate
                                to:endDate
                             limit:limit
                    reverseHistory:NO
               withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(PNDate *)startDate
                           limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory {

    [self requestHistoryForChannel:channel from:startDate to:nil limit:limit reverseHistory:shouldReverseMessageHistory];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(PNDate *)startDate
                              to:(PNDate *)endDate
                           limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory {

    [self requestHistoryForChannel:channel
                              from:startDate
                                to:endDate
                             limit:limit
                    reverseHistory:shouldReverseMessageHistory
               withCompletionBlock:nil];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(PNDate *)startDate
                           limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {

    [self requestHistoryForChannel:channel
                              from:startDate
                                to:nil
                             limit:limit
                    reverseHistory:shouldReverseMessageHistory
               withCompletionBlock:handleBlock];
}

+ (void)requestHistoryForChannel:(PNChannel *)channel
                            from:(PNDate *)startDate
                              to:(PNDate *)endDate
                           limit:(NSUInteger)limit
                  reverseHistory:(BOOL)shouldReverseMessageHistory
             withCompletionBlock:(PNClientHistoryLoadHandlingBlock)handleBlock {
    if (startDate || endDate) {
        // Throw an error saying that it's not supported
    }
    else {
        // Remove old observer?
        MessageHistoryProcessingCallback *callback = [[MessageHistoryProcessingCallback alloc] initWithHistoryLoadHandlingBlock:handleBlock
                                                                                                                    andDelegate:[self sharedInstance]];
        [PubNub_AndroidBridge _requestHistoryForChannel:channel.name
                                                  count:limit
                                         reverseHistory:shouldReverseMessageHistory
                                           withCallback:callback];
    }
}


#pragma mark - Participant methods

+ (void)requestParticipantsListForChannel:(PNChannel *)channel {

    [self requestParticipantsListForChannel:channel withCompletionBlock:nil];
}

+ (void)requestParticipantsListForChannel:(PNChannel *)channel
                      withCompletionBlock:(PNClientParticipantsHandlingBlock)handleBlock {
    NSUnimplementedFunction();
    return;
}


#pragma mark - Crypto helper methods

+ (id)AESDecrypt:(id)object {

    return [self AESDecrypt:object error:NULL];
}

+ (id)AESDecrypt:(id)object error:(PNError **)decryptionError {

    __block id decryptedObject = nil;

    // Check whether user provided JSON string or not.
    if ([PNJSONSerialization isJSONString:object]) {

        if ([object isKindOfClass:[NSString class]]) {

            __block id decodedJSONObject = nil;
            [PNJSONSerialization JSONObjectWithString:object
                                      completionBlock:^(id result, BOOL isJSONP, NSString *callbackMethodName) {

                                          decodedJSONObject = result;
                                      }
                                           errorBlock:^(NSError *error) {

                                               PNLog(PNLogGeneralLevel, self, @"MESSAGE DECODING ERROR: %@", error);
                                           }];

            object = decodedJSONObject;
        }
        else {
            decryptedObject = object;
        }
    }

    if ([PNCryptoHelper sharedInstance].isReady) {

        PNError *processingError;
        NSInteger processingErrorCode = -1;

#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
        BOOL isExpectedDataType = [object isKindOfClass:[NSString class]];
#else
        BOOL isExpectedDataType = [object isKindOfClass:[NSString class]] ||
		[object isKindOfClass:[NSArray class]] ||
		[object isKindOfClass:[NSDictionary class]];
#endif
        if (isExpectedDataType) {

#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
            NSString *decodedMessage = [[PNCryptoHelper sharedInstance] decryptedStringFromString:object error:&processingError];
#else
            id decodedMessage = [[PNCryptoHelper sharedInstance] decryptedObjectFromObject:object error:&processingError];
#endif
            if (decodedMessage == nil || processingError != nil) {

                processingErrorCode = kPNCryptoInputDataProcessingError;
            }
            else if (decodedMessage != nil) {

                decryptedObject = decodedMessage;
            }

#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
            if (processingError == nil && processingErrorCode < 0) {

                [PNJSONSerialization JSONObjectWithString:decodedMessage
                                          completionBlock:^(id result, BOOL isJSONP, NSString *callbackMethodName) {

											  decryptedObject = result;
                                          }
                                               errorBlock:^(NSError *error) {

                                                   PNLog(PNLogGeneralLevel, self, @"MESSAGE DECODING ERROR: %@", error);
                                               }];
            }
#endif
        }
        else {

            processingErrorCode = kPNCryptoInputDataProcessingError;
        }

        if (processingError != nil || processingErrorCode > 0) {

            if (processingErrorCode > 0) {

                processingError = [PNError errorWithCode:processingErrorCode];
            }
            if (decryptionError != NULL) {

                *decryptionError = processingError;
            }

            PNLog(PNLogGeneralLevel, object, @" Message decoding failed because of error: %@", processingError);
            decryptedObject = @"DECRYPTION_ERROR";
        }
    }
    else {

        decryptedObject = object;
    }


    return decryptedObject;
}

+ (NSString *)AESEncrypt:(id)object {

    return [self AESEncrypt:object error:NULL];
}


+ (NSString *)AESEncrypt:(id)object error:(PNError **)encryptionError {

    PNError *processingError;
    NSString *encryptedObjectHash = nil;
    if ([PNCryptoHelper sharedInstance].isReady) {

#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
        object = object ? [PNJSONSerialization stringFromJSONObject:object] : @"";
#endif

        // Retrieve reference on encrypted message (if possible)
        if ([PNCryptoHelper sharedInstance].isReady) {

#ifndef CRYPTO_BACKWARD_COMPATIBILITY_MODE
            NSString *encryptedData = [[PNCryptoHelper sharedInstance] encryptedStringFromString:object error:&processingError];

            encryptedObjectHash = [NSString stringWithFormat:@"\"%@\"", encryptedData];
#else
            id encryptedMessage = [[PNCryptoHelper sharedInstance] encryptedObjectFromObject:object error:&processingError];
            NSString *encryptedData = [PNJSONSerialization stringFromJSONObject:encryptedMessage];

            encryptedObjectHash = [NSString stringWithFormat:@"%@", encryptedData];
#endif

            if (processingError != nil) {

                if (encryptionError != NULL) {

                    *encryptionError = processingError;
                }

                PNLog(PNLogCommunicationChannelLayerErrorLevel, self,
                      @"Message encryption failed with error: %@\nUnencrypted message will be sent.",
                      processingError);
            }
        }
    }
    return encryptedObjectHash;
}


#pragma mark - Instance methods

- (BOOL)isConnected {
    return self.clientConnected;
}

#pragma mark - Logging methods

+ (void)toggleLogging {
    if (_isLoggingEnabled) {
        PNLog(PNLogGeneralLevel, [self sharedInstance], @"DISABLING LOGGING.");
        _isLoggingEnabled = NO;
    } else {
        _isLoggingEnabled = YES;
        PNLog(PNLogGeneralLevel, [self sharedInstance], @"ENABLING LOGGING.");
    }
    [PubNub_AndroidBridge _loggingEnabled:_isLoggingEnabled];
}

#pragma mark - Instance Methods

- (id)init {
    self = [super init];

    if (self) {
        _channelToSubscritionCallbacks = [NSMutableDictionary dictionary];
        _channelToUnsubscritionCallbacks = [NSMutableDictionary dictionary];
    }
    return self;
}

@end

#endif