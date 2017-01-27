#import <Foundation/Foundation.h>
#import "PNStructures.h"


#pragma mark Class forward

@class PNClientInformation, PNConfiguration;




/**
@brief      PubNub client core class which is responsible for communication with \b PubNub network and
provide responses back to completion block/delegates.
@discussion Basically used by \b PubNub categories (each for own API group) and manage communication with
\b PubNub service and share user-specified configuration.

@author Sergey Mamontov
@since 4.0
@copyright © 2009-2016 PubNub, Inc.
*/
@interface PubNub : NSObject


///------------------------------------------------
/// @name Information
///------------------------------------------------

/**
@brief  Retrive basic information about \b PubNub client.

@return Instance which hold information about \b PubNub client.
*/
+ (PNClientInformation *)information __attribute__((const));

/**
@brief  Retrieve reference on current client's configuration.

@return Currently used configuration instance copy. Changes to this instance won't affect receiver's
configuration.

@since 4.0
*/
- (PNConfiguration *)currentConfiguration;

/**
@brief  Retrieve UUID which has been used during client initialization.

@return User-provided or generated unique user identifier.

@since 4.0
*/
- (NSString *)uuid;


///------------------------------------------------
/// @name Initialization
///------------------------------------------------

/**
@brief      Construct new \b PubNub client instance with pre-defined configuration.
@discussion If all keys will be specified, client will be able to read and modify data on \b PubNub service.
@note       Client will make configuration deep copy and further changes in \b PNConfiguration after it has
been passed to the client won't take any effect on client.
@note       All completion block and delegate callbacks will be called on main queue.
@note       All required keys can be found on https://admin.pubnub.com
@discussion \b Example:

@code
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo"
subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration];
@endcode

@param configuration Reference on instance which store all user-provided information about how client should
operate and handle events.

@return Configured and ready to use \b PubNub client.

@since 4.0
*/
+ (instancetype)clientWithConfiguration:(PNConfiguration *)configuration;

/**
@brief      Construct new \b PubNub client instance with pre-defined configuration.
@discussion If all keys will be specified, client will be able to read and modify data on \b PubNub service.
@note       Client will make configuration deep copy and further changes in \b PNConfiguration after it has
been passed to the client won't take any effect on client.
@note       If \c queue is \ nil all completion block and delegate callbacks will be called on main queue.
@note       All required keys can be found on https://admin.pubnub.com
@discussion \b Example:

@code
dispatch_queue_t queue = dispatch_queue_create("com.my-app.callback-queue",
DISPATCH_QUEUE_SERIAL);
PNConfiguration *configuration = [PNConfiguration configurationWithPublishKey:@"demo"
subscribeKey:@"demo"];
self.client = [PubNub clientWithConfiguration:configuration callbackQueue:queue];
@endcode

@param configuration Reference on instance which store all user-provided information about how client should
operate and handle events.
@param callbackQueue Reference on queue which should be used by client fot completion block and delegate
calls.

@return Configured and ready to use \b PubNub client.

@since 4.0
*/
+ (instancetype)clientWithConfiguration:(PNConfiguration *)configuration
callbackQueue:( dispatch_queue_t)callbackQueue;

/**
@brief      Make copy of client with it's current state using new configuration.
@discussion Allow to retrieve reference on client which will have same state as receiver, but will use
updated configuration. If authorization and/or uuid keys has been changed while subscribed, this
method will trigger \c leave presence event on behalf of current uuid and subscribe using new
one.
@note       Copy will be returned asynchronous, because some operations may require communication with
\b PubNub network (like switching active \c uuid while subscribed).
@note       Re-subscription with new \c uuid will be done using catchup and all messages which has been sent
while client changed configuration will be handled.
@note       All listeners will be copied to new client.
@discussion \b Example:

@code
__weak __typeof(self) weakSelf = self;
PNConfiguration *configuration = [self.client currentConfiguration];
configuration.TLSEnabled = NO;
[self.client copyWithConfiguration:configuration completion:^(PubNub *client) {

// Store reference on new client with updated configuration.
weakSelf.client = client;
}];
@endcode

@param configuration Reference on configuration which should be used to create new instance from receiver.
@param block         Copy completion block which will pass only one argument - reference on new \b PubNub
client instance with updated configuration. Block will be called on custom queue (if has
been passed to receiver during instantiation) or main queue.

@since 4.0
*/
- (void)copyWithConfiguration:(PNConfiguration *)configuration completion:(void(^)(PubNub *client))block;

/**
@brief      Make copy of client with it's current state using new configuration.
@discussion Allow to retrieve reference on client which will have same state as receiver, but will use
updated configuration. If authorization and/or uuid keys has been changed while subscribed, this
method will trigger \c leave presence event on behalf of current uuid and subscribe using new
one.
@note       Copy will be returned asynchronous, because some operations may require communication with
\b PubNub network (like switching active \c uuid while subscribed).
@note       Re-subscription with new \c uuid will be done using catchup and all messages which has been sent
while client changed configuration will be handled.
@note       All listeners will be copied to new client.
@discussion \b Example:

@code
__weak __typeof(self) weakSelf = self;
dispatch_queue_t queue = dispatch_queue_create("com.my-app.callback-queue",
DISPATCH_QUEUE_SERIAL);
PNConfiguration *configuration = [self.client currentConfiguration];
configuration.TLSEnabled = NO;
[self.client copyWithConfiguration:configuration callbackQueue:queue completion:^(PubNub *client) {

// Store reference on new client with updated configuration.
weakSelf.client = client;
}];
@endcode

@param configuration Reference on configuration which should be used to create new instance from receiver.
@param callbackQueue Reference on queue which should be used by client fot completion block and delegate
calls.
@param block         Copy completion block which will pass only one argument - reference on new \b PubNub
client instance with updated configuration. Block will be called on custom queue (if has
been passed to receiver during instantiation) or main queue.

@since 4.0
*/
- (void)copyWithConfiguration:(PNConfiguration *)configuration
callbackQueue:( dispatch_queue_t)callbackQueue
completion:(void(^)(PubNub *client))block;

#pragma mark -


@end

