//
//  Logger.m
//  File Logger
//
//  Created by Sourabh Bhardwaj on 09/03/16.
//  Copyright © 2016 Sourabh Bhardwaj. All rights reserved.
//

#import "Logger.h"

@interface Logger () {
    dispatch_queue_t _logQueue;
}


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
        
        // create separate queue for logging
        NSString *queueLabel = [NSString stringWithFormat:@"%@.logger.%@",[self class],self];
        _logQueue = dispatch_queue_create([queueLabel UTF8String], NULL);
        
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
    [self writeContent:[NSString stringWithFormat:@"<<<<<<<<<<<<<<<<<<<<<< START OF THE FILE on %@ >>>>>>>>>>>>>>>>>>>>>>>>>\n\n",[NSDate date]] level:0 file:nil function:nil line:0];
}

+ (void)writeToFileWithlevel:(LoggerLevel)level
                             file:(const char *)file
                         function:(const char *)function
                             line:(NSUInteger)line
                           format:(NSString *)format, ... {
    
    // Don't save Debug, Info Warning logs to the file for production build
    switch (level) {
        case LogLevelDebug:
        case LogLevelWarn:
        case LogLevelInfo: {
            #if !DEBUG
                return;
            #endif
        }
        default: { // LogLevelError
            // proceed saving error logs
            break;
        }
    }
    
    
    va_list args;
    if (format) {
        va_start(args, format);
        
        NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
        [[Logger sharedInstance] writeLog:message level:level file:file function:function line:line];
        
        va_end(args);
    } else {
        NSLog(@"format is nil");
    }
}

- (void)writeLog:(id)content
           level:(LoggerLevel)level
            file:(const char *)file
        function:(const char *)function
            line:(NSUInteger)line {
     if (self.savingOption == SaveSynchronously) {
         dispatch_sync(_logQueue, ^{
             [self writeContent:content level:level file:file function:function line:line];
         });
     } else {
         dispatch_async(_logQueue, ^{
             [self writeContent:content level:level file:file function:function line:line];
         });
     }
}

- (void)writeContent:(id)content
               level:(LoggerLevel)level
                file:(const char *)file
            function:(const char *)function
                line:(NSUInteger)line {
    
    NSString *message = (NSString *)content;
    
    if (self.writingOption == WriteToFile) {
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
                
                NSString *infoString;
                switch (level) {
                    case LogLevelDebug: {
                        infoString = [NSString stringWithFormat:@"\n<%p %s %s:(%lu)> %@", self, file,function ,(unsigned long)line, message];
                        break;
                    }
                    case LogLevelWarn: {
                        infoString = [NSString stringWithFormat:@"\n%s:(%lu)> %@",function ,(unsigned long)line, message];
                        break;
                    }
                    case LogLevelError: {
                        infoString = [NSString stringWithFormat:@"\n <%p %s %s:(%lu)> %@", self, file,function ,(unsigned long)line, message];
                        break;
                    }
                    default: { // LogLevelInfo
                        infoString = [NSString stringWithFormat:@"\n%@",message];
                        break;
                    }
                }
                
                NSMutableString *mutableString = [[NSMutableString alloc] init];
                [mutableString appendString:infoString];
                [mutableString appendFormat:@"\n\n=============== ===============  ===============  ===============  ===============  ===============\n"];
                
                // write the data to the end of the file
                [fileHandle writeData:[mutableString dataUsingEncoding:NSUTF8StringEncoding]];
                
                //            NSLog(@"mutableString = %@",mutableString);
            } @catch (NSException * e) {
                NSLog(@"exception in adding log to file = %@",e.description);
                // clean up
                [fileHandle closeFile];
            }
        }
    } else {
        NSLog(@"\nConsole print:- %@",message);
    }
}



@end
