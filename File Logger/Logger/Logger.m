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

#define LOGGER_FILE_NAME_INITIALS @"6_Logger_File_Dated"
#define LOGGER_PREVIOUS_FILE_NAME @"_Logger_Previous_File_Name_"

@end

@implementation Logger

#pragma mark - Singleton Instance
static Logger *sharedObject = nil;
+ (id)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedObject = [[self alloc] init];
    });
    return sharedObject;
}

- (id)init {
    self = [super init];
    if (self) {
        // set the current log level to Debug by default
        self.level = LogLevelDebug;
        
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
    [self finishWriting:[NSString stringWithFormat:@"<<<<<<<<<<<<<<<<<<<<<< START OF THE FILE on %@ >>>>>>>>>>>>>>>>>>>>>>>>>\n\n",[NSDate date]]];
}

#pragma mark - Helper Methods for Writing
+ (void)writeDebugLog:(id)param {
    [[self sharedInstance] writeContent:param forLogLevel:LogLevelDebug];
}

+ (void)writeWarningLog:(id)param {
    [[self sharedInstance] writeContent:param forLogLevel:LogLevelWarn];
}

+ (void)writeReleaseLog:(id)param {
    [[self sharedInstance] writeContent:param forLogLevel:LogLevelRelease];
}

+ (void)writeInfoLog:(id)param {
    [[self sharedInstance] writeContent:param forLogLevel:LogLevelInfo];
}

#pragma mark Write Log (Internal)
- (void)writeContent:(id)param forLogLevel:(LoggerLevel)level {
    switch (level) {
        case LogLevelInfo: {
            // do any specific related to Info log level
            [self finishWriting:param];
            break;
        }
        case LogLevelWarn: {
            // do any specific related to Warn log level
            [self finishWriting:param];
            break;
        }
        case LogLevelRelease: {
            // do any specific related to Info log level
            [self finishWriting:param];
            break;
        }
        default: { // LogLevelDebug
            [self finishWriting:param];
            break;
        }
    }
}

- (void)finishWriting:(id)content {
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
            
            NSMutableString *mutableString = [[NSMutableString alloc] initWithString:strData];
            [mutableString appendFormat:@"\n %s at line: %d",__PRETTY_FUNCTION__, __LINE__];
            [mutableString appendFormat:@"\n=============== ===============  ===============  ===============  ===============\n"];
            
            // write the data to the end of the file
            [fileHandle writeData:[mutableString dataUsingEncoding:NSUTF8StringEncoding]];
            
            // clean up
            [fileHandle closeFile];
        } @catch (NSException * e) {
            NSLog(@"exception in adding log to file = %@",e.description);
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

@end
