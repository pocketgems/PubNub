//
//  AbstractCallback.m
//
//  Created on 8/26/14.
//

#ifdef APPORTABLE

#import <BridgeKit/JavaObject.h>
#import <BridgeKit/AndroidActivity.h>

@class PubNub;

@interface AbstractCallback: JavaObject

@property (nonatomic, readonly, assign) PubNub *pubnubDelegate;

- (id)initWithDelegate:(PubNub *)pubnubDelegate;

@end


#endif