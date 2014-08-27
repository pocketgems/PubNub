//
//  MessageProcessingCallback.h
//
//  Created on 8/26/14.
//

#ifdef APPORTABLE

#import "AbstractCallback.h"
#import "PNStructures.h"

@class PubNub;

@interface MessageProcessingCallback : AbstractCallback

- (id)initWithMessageProcessingBlock:(PNClientMessageProcessingBlock)handlerBlock andDelegate:(PubNub *)pubnubDelegate;

@end

#endif
