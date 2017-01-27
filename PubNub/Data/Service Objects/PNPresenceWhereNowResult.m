/**
@author Sergey Mamontov
@since 4.0
@copyright © 2009-2016 PubNub, Inc.
*/
#import "PNPresenceWhereNowResult.h"
#import "PNServiceData+Private.h"
#import "PNResult+Private.h"


#pragma mark Interface implementation

@implementation PNPresenceWhereNowData


#pragma mark - Information

- (NSArray *)channels {

return (self.serviceData[@"channels"]?: @[]);
}

#pragma mark -


@end


#pragma mark - Private interface declaration

@interface PNPresenceWhereNowResult ()


#pragma mark - Properties

@property (nonatomic, strong) PNPresenceWhereNowData *data;

#pragma mark -


@end


#pragma mark - Interface implementation

@implementation PNPresenceWhereNowResult


#pragma mark - Information

- (PNPresenceWhereNowData *)data {

if (!_data) { _data = [PNPresenceWhereNowData dataWithServiceResponse:self.serviceData]; }
return _data;
}

#pragma mark -


@end