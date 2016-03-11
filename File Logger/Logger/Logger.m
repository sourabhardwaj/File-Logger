//
//  Logger.m
//  File Logger
//
//  Created by Sourabh Bhardwaj on 09/03/16.
//  Copyright © 2016 Sourabh Bhardwaj. All rights reserved.
//

#import "Logger.h"
#import <MessageUI/MessageUI.h>

@interface Logger ()<MFMailComposeViewControllerDelegate>

#define LOGGER_FILE_NAME_INITIALS @"Logger_File_Dated"
#define LOGGER_PREVIOUS_FILE_NAME @"_Logger_Previous_File_Name_"

@end

@implementation Logger

#pragma mark - Singleton Instance
static Logger *sharedObject = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObject = [[super alloc] init];
    });
    return sharedObject;
}

+ (instancetype)alloc {
    @synchronized(self) {
//        NSAssert(sharedObject == nil, @"Attempted to allocate a second instance of a singleton.");
        return [self sharedInstance];
    }
    return nil;
}

- (id)init {
    self = [super init];
    if (self) {
        
        // load the last created file name:
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.previousFilePath = [defaults objectForKey:LOGGER_PREVIOUS_FILE_NAME];
        
        // create a new file name:
        NSString *filename = [NSString stringWithFormat:@"%@_%d.txt",LOGGER_FILE_NAME_INITIALS,(int)[[NSDate date] timeIntervalSince1970]];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths firstObject];
        self.filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,filename];

        [defaults setObject:self.filePath forKey:LOGGER_PREVIOUS_FILE_NAME];
        [defaults synchronize];
        
        //set up file header
        [self initiateFileWithHeader];
    }
    return self;
}


- (void)initiateFileWithHeader {
    [self writeToFile:[NSString stringWithFormat:@"<<<<<<<<<<<<<<<<<<<<<< START OF THE FILE on %@ >>>>>>>>>>>>>>>>>>>>>>>>>\n\n",[NSDate date]] withTraceInfo:@""];
}

#pragma mark - Helper Methods for Writing
- (void)writeDebugLog:(id)param {
#if DEBUG
    NSString *trace = [self traceInfo];
    
    NSString *content = [self formatContent:param];
    
    NSString *infoString = [NSString stringWithFormat:@"\n <%p %@ %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent],trace, __LINE__, content];
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    [mutableString appendString:infoString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self finishWriting:mutableString];
    });
#endif
}

- (void)writeWarningLog:(id)param {
#if DEBUG
    NSString *trace = [self traceInfo];
    
    NSString *content = [self formatContent:param];
    
    NSString *infoString = [NSString stringWithFormat:@"\n <%@ %@:(%d)> %@",[[NSString stringWithUTF8String:__FILE__] lastPathComponent],trace, __LINE__, content];
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    [mutableString appendString:infoString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self finishWriting:mutableString];
    });
#endif
}

- (void)writeReleaseLog:(id)param {
    NSString *trace = [self traceInfo];
    
    NSString *content = [self formatContent:param];
    
    NSString *infoString = [NSString stringWithFormat:@"\n <%@:(%d)> %@",trace, __LINE__, content];
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    [mutableString appendString:infoString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self finishWriting:mutableString];
    });
}

- (void)writeInfoLog:(id)param {
#if DEBUG
    NSString *content = [self formatContent:param];
    
    NSString *infoString = [NSString stringWithFormat:@"\n%@", content];
    NSMutableString *mutableString = [[NSMutableString alloc] init];
    [mutableString appendString:infoString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        [self finishWriting:param];
    });
#endif
}

#pragma mark Write Log (Internal)
- (void)finishWriting:(id)content {
    if (self.writingOption == WriteToFile) {
        @synchronized(self) {
            NSString *filePath = self.currentFilePath;
            
            // NSFileHandle won't create the file for us, so we need to check to make sure it exists
            if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                
                // the file doesn't exist yet, so we can just write out the text using the
                // NSString convenience method
                
                BOOL success = [content writeToFile:filePath atomically:YES];
                if (success) {
                    NSLog(@"file creation success");
                } else {
                    NSLog(@"file creation failure");
                }
                
            } else { // the file already exists, so we should append the text to the end
                
                // get a handle to the file
                NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
                
                if (fileHandle == nil) {
                    NSLog(@"File handle not found");
                    return; // file is not ready to write
                }
                
                @try {
                    // move to the end of the file
                    [fileHandle seekToEndOfFile];
                    
                    // add a separator at the end of current log
                    NSMutableString *mutableString = (NSMutableString *)content;
                    [mutableString appendFormat:@"\n\n=============== ===============  ===============  ===============  ===============  ===============\n"];
                    
                    // write the data to the end of the file
                    [fileHandle writeData:[mutableString dataUsingEncoding:NSUTF8StringEncoding]];
                    
//                    NSLog(@"mutableString = %@",mutableString);
                } @catch (NSException * e) {
                    NSLog(@"exception in adding log to file = %@",e.description);
                    // clean up
                    [fileHandle closeFile];
                }
            }
        }
    } else {
        NSLog(@"%@",content);
    }
}

- (NSString *)formatContent:(id)content {
    NSString *strData;
    if ([content isKindOfClass:[NSString class]]) {
        strData = (NSString *)content;
    } else if([content isKindOfClass:[NSArray class]] || [content isKindOfClass:[NSMutableArray class]]) {
        strData = [self serializeData:content];
    } else if([content isKindOfClass:[NSDictionary class]] || [content isKindOfClass:[NSMutableDictionary class]]) {
        strData = [self serializeData:content];
    } else if([content isKindOfClass:[NSError class]]) {
        strData = [content description];
    }
    return strData;
}

- (void)writeToFile:(id)content withTraceInfo:(NSString *)trace {
    NSString *filePath = self.currentFilePath;
    
    // NSFileHandle won't create the file for us, so we need to check to make sure it exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        // the file doesn't exist yet, so we can just write out the text using the
        // NSString convenience method
        
        BOOL success = [content writeToFile:filePath atomically:YES];
        if (success) {
            NSLog(@"file creation success");
        } else {
            NSLog(@"file creation failure");
        }
        
    } else { // the file already exists, so we should append the text to the end
        
        // get a handle to the file
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
        
        if (fileHandle == nil) {
            NSLog(@"File handle not found");
            return; // file is not ready to write
        }
        
        @try {
            // move to the end of the file
            [fileHandle seekToEndOfFile];
            
            NSString *strData;
            if ([content isKindOfClass:[NSString class]]) {
                strData = (NSString *)content;
            } else if([content isKindOfClass:[NSArray class]] || [content isKindOfClass:[NSMutableArray class]]) {
                strData = [self serializeData:content];
            } else if([content isKindOfClass:[NSDictionary class]] || [content isKindOfClass:[NSMutableDictionary class]]) {
                strData = [self serializeData:content];
            } else if([content isKindOfClass:[NSError class]]) {
                strData = [content description];
            }
            
            NSMutableString *mutableString = [[NSMutableString alloc] init];
            NSString *infoString = [NSString stringWithFormat:@"\n <%p %@ %@:(%d)> %@", self, [[NSString stringWithUTF8String:__FILE__] lastPathComponent],trace, __LINE__, content];
            
            [mutableString appendString:infoString];
            [mutableString appendFormat:@"\n\n=============== ===============  ===============  ===============  ===============  ===============\n"];
            
            // write the data to the end of the file
            //                    NSLog(@"mutableString = %@",mutableString);
            [fileHandle writeData:[mutableString dataUsingEncoding:NSUTF8StringEncoding]];
        } @catch (NSException * e) {
            NSLog(@"exception in adding log to file = %@",e.description);
            // clean up
            [fileHandle closeFile];
        }
    }
}

#pragma mark - -- Data Serialization --
#pragma mark NSDictionary to NSString
- (NSString *)serializeData:(id)jsonDictionary {
    NSString *strData = @"";
    NSError *objError = nil;
    if([NSJSONSerialization isValidJSONObject:jsonDictionary]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:NSJSONWritingPrettyPrinted error:&objError];
        strData = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//        NSLog(@"Serialized Payload :- %@",strData);
    } else {
        NSLog(@"Invalid json object. Use only top level object :- array or dictionary!!");
    }
    return strData;
}

#pragma mark NSString to NSDictionary
- (NSMutableDictionary *)deSerializeData:(NSString *)strData {
    NSError *objError = nil;
    NSData *deserializedData = [strData dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO];
    if(deserializedData) {
        NSMutableDictionary *jsonDictionary = (NSMutableDictionary*)[NSJSONSerialization JSONObjectWithData:deserializedData options:NSJSONReadingMutableContainers error:&objError];
//        NSLog(@"De-serialized Payload :- %@",jsonDictionary);
        return jsonDictionary;
    }
    return nil;
}

#pragma mark Stack Trace
- (NSString *)traceInfo {
    //Go back 2 frames to account for calling this helper method
    //If not using a helper method use 1
    NSArray* stack = [NSThread callStackSymbols];
    if (stack.count > 1) {
        return [NSString stringWithFormat:@"[%@]",[[[stack objectAtIndex:2] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]] objectAtIndex:1]];
//        return [stack objectAtIndex:2];
    }
    return @"NO_STACK_TRACE_FOUND";
}

@end
