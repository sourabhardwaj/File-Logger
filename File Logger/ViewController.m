//
//  ViewController.m
//  File Logger
//
//  Created by Sourabh Bhardwaj on 09/03/16.
//  Copyright © 2016 Sourabh Bhardwaj. All rights reserved.
//

#import "ViewController.h"
#import <MessageUI/MessageUI.h>
#import "Logger.h"

@interface ViewController ()<MFMailComposeViewControllerDelegate>
- (IBAction)emailPreviousLog:(id)sender;
- (IBAction)emailCurrentLog:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [Logger sharedInstance];
    
    [Logger writeDebugLog:@[@"123", @"456", @"789"]];
    
    [Logger writeInfoLog:@"This is the file log line"];
    
    [Logger writeReleaseLog:@{@"key":@"value", @"sex":@"M"}];

    [Logger writeWarningLog:@"The file log is of warning type"];
    
    [Logger writeDebugLog:@[@"123", @"456", @"789",@"123", @"456", @"789",@"123", @"456", @"789",@"123", @"456", @"789"]];
    
    [Logger writeReleaseLog:@{@"key":@"value", @"sex":@"M",@"key2":@"value", @"sex2":@"M",@"key3":@"value", @"sex3":@"M",@"key4":@"value", @"sex4":@"M",@"key5":@"value", @"sex5":@"M",@"key6":@"value", @"sex6":@"M",@"key7":@"value", @"sex7":@"M",@"key8":@"value", @"sex8":@"M"}];
    
    [Logger writeInfoLog:@"another info log line"];
    
    [Logger writeReleaseLog:@{@"key-release":@"value-release", @"sex-release":@"M-release"}];
    
    [Logger writeWarningLog:@"type warning type warning type"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)emailPreviousLog:(id)sender {
    [self exportWithAttachementFile:[[Logger sharedInstance] previousFilePath]];
}

- (IBAction)emailCurrentLog:(id)sender {
    [self exportWithAttachementFile:[[Logger sharedInstance] currentFilePath]];
}

- (void)exportWithAttachementFile:(NSString *)pathToFile {
    
    MFMailComposeViewController *composer = [[MFMailComposeViewController alloc] init];
    [composer.navigationBar setTintColor:[UIColor whiteColor]];
    [composer setMailComposeDelegate:self];
    if ([MFMailComposeViewController canSendMail]) {
        [composer setToRecipients:[NSArray arrayWithObjects:@"YOUR_EMAIL_GOES_HERE", nil]];
        [composer setSubject:@"Log Report"];
        
        [composer setMessageBody:@"Exporting log file to have more debug information." isHTML:NO];
        
        NSArray *filepart = [pathToFile componentsSeparatedByString:@"."];
        NSString *filename = [filepart firstObject];
        NSString *extension = [filepart lastObject];
        
        NSData *fileData = [NSData dataWithContentsOfFile:pathToFile];
        
        NSString *mimeType;
        if ([extension isEqualToString:@"jpg"]) {
            mimeType = @"image/jpeg";
        } else if ([extension isEqualToString:@"png"]) {
            mimeType = @"image/png";
        } else if ([extension isEqualToString:@"doc"]) {
            mimeType = @"application/msword";
        } else if ([extension isEqualToString:@"ppt"]) {
            mimeType = @"application/vnd.ms-powerpoint";
        } else if ([extension isEqualToString:@"html"]) {
            mimeType = @"text/html";
        } else if ([extension isEqualToString:@"txt"]) {
            mimeType = @"text/plain";
        } else if ([extension isEqualToString:@"pdf"]) {
            mimeType = @"application/pdf";
        }
        
        [composer addAttachmentData:fileData mimeType:mimeType fileName:[[filename componentsSeparatedByString:@"/"] lastObject]];
        
        [self.navigationController presentViewController:composer animated:YES completion:nil];
    } else {
        NSLog(@"Device does not have email functionality");
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"mail cencelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"mail cencelled");
            break;
        case MFMailComposeResultSent:
            NSLog(@"mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"mail failed");
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}


@end
