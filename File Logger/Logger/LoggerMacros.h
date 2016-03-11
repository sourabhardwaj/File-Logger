//
//  LoggerMacros.h
//  File Logger
//
//  Created by Sourabh Bhardwaj on 11/03/16.
//  Copyright © 2016 Sourabh Bhardwaj. All rights reserved.
//

#import "Logger.h"

#define LogLevelDebugFlag LogLevelDebug
#define LogLevelInfoFlag LogLevelInfo
#define LogLevelWarnFlag LogLevelWarn
#define LogLevelErrorFlag LogLevelError


#define LOG_MACRO(lvl, fnct, frmt, ...) \
[Logger writeToFileWithlevel : lvl                       \
                        file : __FILE__                  \
                    function : fnct                      \
                        line : __LINE__                  \
                      format : (frmt), ## __VA_ARGS__]



#define LOG_MAYBE(lvl, fnct, frmt, ...) \
do { if(frmt) LOG_MACRO(lvl, fnct, frmt, ##__VA_ARGS__); } while(0)

/**
 * Call these macros to save logs
 **/
#define LogError(frmt, ...)   LOG_MAYBE(LogLevelErrorFlag,   __PRETTY_FUNCTION__, frmt, __VA_ARGS__)
#define LogWarning(frmt, ...) LOG_MAYBE(LogLevelWarnFlag, __PRETTY_FUNCTION__, frmt, __VA_ARGS__)
#define LogInfo(frmt, ...)    LOG_MAYBE(LogLevelInfoFlag,    __PRETTY_FUNCTION__, frmt, __VA_ARGS__)
#define LogDebug(frmt, ...)   LOG_MAYBE(LogLevelDebugFlag,   __PRETTY_FUNCTION__, frmt, __VA_ARGS__)



