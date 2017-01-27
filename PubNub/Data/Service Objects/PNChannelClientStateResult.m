/**
@author Sergey Mamontov
@since 4.0
@copyright © 2009-2016 PubNub, Inc.
*/
#import "PNChannelClientStateResult.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark - Interface implementation

@implementation PNChannelClientStateData


#pragma mark - Information

- (NSDictionary *)state {

return (self.serviceData[@"state"]?: @{});
}

#pragma mark -


@end


#pragma mark - Private interface declaration

@interface PNChannelClientStateResult ()


#pragma mark - Properties

@property (nonatomic, strong) PNChannelClientStateData *data;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNChannelClientStateResult


#pragma mark - Information

- (PNChannelClientStateData *)data {

if (!_data) { _data = [PNChannelClientStateData dataWithServiceResponse:self.serviceData]; }
return _data;
}

#pragma mark -


@end