//
//  ChannelLimitTest.m
//  pubnub
//
//  Created by Valentin Tuller on 11/20/13.
//  Copyright (c) 2013 PubNub Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PNBaseRequest.h"
#import "PNBaseRequest+Protected.h"

#import <OCMock/OCMock.h>

#import "PubNub.h"
#import "PubNub+Protected.h"
#import "PNConfiguration.h"
#import "PNWriteBuffer.h"
#import "PNConstants.h"
#import "TestSemaphor.h"

@interface ChannelLimitTest : SenTestCase <PNDelegate>

@end

@implementation ChannelLimitTest 


-(void)resetConnection {
	[PubNub resetClient];
	int64_t delayInSeconds = 2;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void) {

		[PubNub setDelegate:self];
		[PubNub setConfiguration: [PNConfiguration defaultConfiguration]];

		[PubNub connectWithSuccessBlock:^(NSString *origin) {

			NSLog(@"PubNub client connected to: %@", origin);
			dispatch_semaphore_signal(semaphore);
		}
							 errorBlock:^(PNError *connectionError) {
								 NSLog(@"connectionError %@", connectionError);
								 dispatch_semaphore_signal(semaphore);
							 }];
	});
	while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
								 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
	[[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:5]];
}

-(void)sendMessage:(NSString*)message toChannelWithName:(NSString*)channelName
{
	PNChannel *channel = [PNChannel channelWithName: channelName];
	NSDate *start = [NSDate date];
	__block BOOL isCompletionBlockCalled = NO;
	[PubNub sendMessage: message toChannel: channel withCompletionBlock:^(PNMessageState messageSendingState, id data)
	   {
		   if( messageSendingState == PNMessageSending )
			   return;
		   NSTimeInterval interval = -[start timeIntervalSinceNow];
		   NSLog(@"sendMessage interval %f", interval);
		   isCompletionBlockCalled = YES;
		   STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %d instead of %d", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

		   STAssertFalse(messageSendingState==PNMessageSendingError, @"messageSendingState==PNMessageSendingError %@", data);
	   }];

	for( int j=0; /*j<[PubNub sharedInstance].configuration.subscriptionRequestTimeout+1*/ isCompletionBlockCalled == NO; j++ )
		[[NSRunLoop currentRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 1.0] ];
}

- (void)test60SubscribeOnChannelsByTurns {
	[self resetConnection];

	NSMutableArray *arr = [NSMutableArray array];
	int i=0;
	for( ; i<90; i++ ) {
		NSString *channelName = [NSString stringWithFormat: @"%@ %d", [NSDate date], i];
		[arr addObject: channelName];
	}

	NSDate *start = [NSDate date];
	[PubNub subscribeOnChannels: [PNChannel channelsWithNames: arr]
		withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
		 {
			 [[TestSemaphor sharedInstance] lift:@"arr"];
			 NSTimeInterval interval = -[start timeIntervalSinceNow];
			 NSLog(@"subscribed arr %f, %@", interval, subscriptionError);
			 STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %d instead of %d", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

			 STAssertNil( subscriptionError, @"arr subscriptionError %@", subscriptionError);
		 }];
	STAssertTrue([[TestSemaphor sharedInstance] waitForKey: @"arr" timeout: [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1], @"completion block not called, arr");

	for( ; i<110; i++ )
	{
		NSString *channelName = [NSString stringWithFormat: @"%@ %d", [NSDate date], i];
		NSArray *arr = [PNChannel channelsWithNames: @[channelName]];
		NSDate *start = [NSDate date];
		NSLog(@"Start subscribe to channel %@", channelName);
		__block NSArray *subscribedChannels = nil;
		[PubNub subscribeOnChannels: arr
		withCompletionHandlingBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *subscriptionError)
		 {
			[[TestSemaphor sharedInstance] lift:channelName];
			subscribedChannels = channels;
			NSTimeInterval interval = -[start timeIntervalSinceNow];
			NSLog(@"subscribed %f, %@", interval, subscriptionError);
			STAssertTrue( interval < [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1, @"Timeout error, %d instead of %d", interval, [PubNub sharedInstance].configuration.subscriptionRequestTimeout);

			STAssertNil( subscriptionError, @"channel %@, \nsubscriptionError %@", channelName, subscriptionError);
		 }];
		STAssertTrue([[TestSemaphor sharedInstance] waitForKey: channelName timeout: [PubNub sharedInstance].configuration.subscriptionRequestTimeout+1], @"completion block not called, %@", channelName);

		for( int j=0; j<subscribedChannels.count; j++ ) {
			if( [[subscribedChannels[j] name] isEqualToString: channelName] == YES ) {
				[self sendMessage: channelName toChannelWithName: channelName];
				break;
			}
		}
	}
}

@end
