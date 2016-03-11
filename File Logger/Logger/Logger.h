//
//  Logger.h
//  File Logger
//
//  Created by Sourabh Bhardwaj on 09/03/16.
//  Copyright © 2016 Sourabh Bhardwaj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LoggerMacros.h"

typedef NS_ENUM(NSUInteger, LoggerLevel) {
    LogLevelDebug,
    LogLevelInfo,
    LogLevelWarn,
    LogLevelError,
};

typedef NS_ENUM(NSUInteger, LoggerWriteOption) {
    WriteToConsole,
    WriteToFile,
};

typedef NS_ENUM(NSUInteger, LoggerSavingOption) {
    SaveAsynchronously,
    SaveSynchronously,
};

@interface Logger : NSObject

@property(nonatomic, assign, getter = currentLogLevel) LoggerLevel level; // LogLevelDebug will be default
@property(nonatomic, assign) LoggerWriteOption writingOption; // WriteToConsole will be default
@property(nonatomic, assign) LoggerSavingOption savingOption; // SaveAsynchronously will be default
@property(nonatomic, strong, getter = currentFilePath) NSString *filePath;
@property(nonatomic, strong) NSString *previousFilePath;


#pragma mark - Singleton
+ (instancetype)sharedInstance;

+ (void)writeToFileWithlevel:(LoggerLevel)level
                        file:(const char *)file
                    function:(const char *)function
                        line:(NSUInteger)line
                      format:(NSString *)format, ...;

@end
