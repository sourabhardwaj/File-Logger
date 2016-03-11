//
//  Logger.h
//  File Logger
//
//  Created by Sourabh Bhardwaj on 09/03/16.
//  Copyright © 2016 Sourabh Bhardwaj. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define LOG_SELECTOR()  NSLog(@"%@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

//#define CALL_ORIGIN NSLog(@"Origin: [%@]", [[[[NSThread callStackSymbols] objectAtIndex:1] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]] objectAtIndex:1])

#ifdef DEBUG
#define DebugLog( s, ... ) NSLog( @"<%p %@ %s:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent],__PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#else
#define DebugLog( s, ... )
#endif

#define DEBUG_MODE 1

#ifdef DEBUG_MODE
#define DebugLogLevel(var, ... ) [[Logger sharedInstance] writeDebugLog:(@"<%p %@ %s:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent],__PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:(var), ##__VA_ARGS__])]
#else
#define DebugLogLevel( ... )
#endif


//#ifdef DEBUG
//#define ReleaseLogLevel( s, ... ) [Logger writeReleaseLog( @"<%p %@ %s:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent],__PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )]
//#else
//#define ReleaseLogLevel( s, ... )
//#endif



//#ifdef DEBUG
//#define InfoLogLevel( s, ... ) [Logger writeInfoLog( @"<%p %@ %s:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent],__PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )]
//#else
//#define InfoLogLevel( s, ... )
//#endif


//#ifdef DEBUG
//#define WarnLogLevel( s, ... ) [Logger writeWarningLog( @"<%p %@ %s:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent],__PRETTY_FUNCTION__, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__] )]
//#else
//#define WarnLogLevel( s, ... )
//#endif



//#define DLog(...) [Logger writeDebugLog:(##__VA_ARGS__)]
//#define WLog(...) [Logger writeWarningLog:(##__VA_ARGS__)]
//#define ILog(...) [Logger writeInfoLog:(##__VA_ARGS__)]
//#define RLog(...) [Logger writeReleaseLog:(##__VA_ARGS__)]



typedef NS_ENUM(NSUInteger, LoggerLevel) {
    LogLevelDebug,
    LogLevelInfo,
    LogLevelWarn,
    LogLevelRelease,
};

typedef NS_ENUM(NSUInteger, LoggerWriteOption) {
    WriteToConsole,
    WriteToFile,
};

@interface Logger : NSObject

@property(nonatomic, assign, getter = currentLogLevel) LoggerLevel level; // LogLevelDebug will be default
@property(nonatomic, assign) LoggerWriteOption writingOption; // WriteToConsole will be default
@property(nonatomic, strong, getter = currentFilePath) NSString *filePath;
@property(nonatomic, strong) NSString *previousFilePath;


#pragma mark - Singleton
+ (instancetype)sharedInstance;

#pragma mark - Helper Methods for Writing
- (void)writeDebugLog:(id)param;
- (void)writeWarningLog:(id)param;
- (void)writeReleaseLog:(id)param;
- (void)writeInfoLog:(id)param;

#pragma mark - -- Serialization --
#pragma mark NSDictionary to NSString
- (NSString *)serializeData:(id)jsonDictionary;

#pragma mark NSString to NSDictionary
- (NSMutableDictionary *)deSerializeData:(NSString *)strData;

@end
