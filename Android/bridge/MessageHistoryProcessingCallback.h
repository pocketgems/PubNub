//
//  MessageHistoryProcessingCallback.h
//
//  Created on 8/26/14.
//

#ifdef APPORTABLE

#import "AbstractCallback.h"
#import "PNStructures.h"

@class PubNub;

@interface MessageHistoryProcessingCallback : AbstractCallback

- (id)initWithHistoryLoadHandlingBlock:(PNClientHistoryLoadHandlingBlock)handlerBlock andDelegate:(PubNub *)pubnubDelegate;

@end

#endif
