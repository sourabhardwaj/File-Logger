//
//  Logger.h
//  File Logger
//
//  Created by Sourabh Bhardwaj on 09/03/16.
//  Copyright © 2016 Sourabh Bhardwaj. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LoggerLevel) {
    LogLevelDebug,
    LogLevelInfo,
    LogLevelWarn,
    LogLevelRelease,
};

@interface Logger : NSObject

@property(nonatomic, assign, getter = currentLogLevel) LoggerLevel level;
@property(nonatomic, strong, getter = currentFilePath) NSString *filePath;
@property(nonatomic, strong) NSString *previousFilePath;


#pragma mark - Singleton
+ (id)sharedInstance;

#pragma mark - Helper Methods for Writing
+ (void)writeDebugLog:(id)param;
+ (void)writeWarningLog:(id)param;
+ (void)writeReleaseLog:(id)param;
+ (void)writeInfoLog:(id)param;

#pragma mark - -- Serialization --
#pragma mark NSDictionary to NSString
- (NSString *)serializeData:(id)jsonDictionary;

#pragma mark NSString to NSDictionary
- (NSMutableDictionary *)deSerializeData:(NSString *)strData;

@end
