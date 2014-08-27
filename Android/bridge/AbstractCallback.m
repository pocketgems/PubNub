//
//  AbstractCallback.m
//
//  Created on 8/26/14.
//

#ifdef APPORTABLE

#import "AbstractCallback.h"

#import "PNErrorCodes.h"
#import "PNMacro.h"
#import "PubNub.h"
#import "PubNub+Protected.h"

@interface AbstractCallback ()

@property (nonatomic, readwrite, assign) PubNub *pubnubDelegate;

@end

@implementation AbstractCallback

@synthesize pubnubDelegate = _pubnubDelegate;

- (id)initWithDelegate:(PubNub *)pubnubDelegate {
    if (self = [super init]) {
        _pubnubDelegate = pubnubDelegate;
        PNLog(PNLogGeneralLevel, self, @"INITIALIZING CALLBACK");
    }
    return self;
}

- (void)dealloc {
    PNLog(PNLogGeneralLevel, self, @"DEALLOCING CALLBACK");
    _pubnubDelegate = nil;
    [super dealloc];
}

- (void)sendNotification:(NSString *)notificationName withObject:(id)object {
    // Send notification to all who is interested in it (observation center will track it as well)
    [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self.pubnubDelegate userInfo:object];
}

@end


#endif