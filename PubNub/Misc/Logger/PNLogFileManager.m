/**
@author Sergey Mamontov
@since 4.0
@copyright © 2009-2016 PubNub, Inc.
*/
#import "PNLogFileManager.h"

@interface PNLogFileManager()

@property (nonatomic, readwrite, strong) NSDateFormatter *dateFormatter;

@end

#pragma mark Interface implementation

@implementation PNLogFileManager

- (instancetype)init {
// Configure file manager with default storage in application's Documents folder.
NSArray *documents = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
#if __MAC_OS_X_VERSION_MIN_REQUIRED
NSString *documentsPath = documents.lastObject;
NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
if (NSClassFromString(@"XCTestExpectation")) { bundleIdentifier = @"com.pubnub.objc-tests"; }
documents = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
documentsPath = [[documents.lastObject stringByAppendingPathComponent:bundleIdentifier]
stringByAppendingPathComponent:@"logs"];

if (![[NSFileManager defaultManager] fileExistsAtPath:documentsPath isDirectory:NULL]) {

[[NSFileManager defaultManager] createDirectoryAtPath:documentsPath withIntermediateDirectories:YES
attributes:nil error:nil];
}
#endif
if (self = [self initWithLogsDirectory:[documents lastObject]]) {
NSString *dateFormat = @"yyyy'-'MM'-'dd'T'HH'-'mm'-'ss'";
_dateFormatter = [[NSDateFormatter alloc] init];
[_dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
[_dateFormatter setDateFormat:dateFormat];
[_dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
}
return self;
}

- (NSString *)newLogFileName {
NSString *formattedDate = [self.dateFormatter stringFromDate:[NSDate date]];
return [[NSString alloc] initWithFormat:@"pubnub-console-dump-%@.log", formattedDate];
}

- (BOOL)isLogFile:(NSString *)fileName {
return [fileName hasPrefix:@"pubnub-console-dump-"]
&& [fileName hasSuffix:@".log"];
}

#pragma mark -


@end