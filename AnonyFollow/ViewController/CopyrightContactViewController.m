//
//  CopyrightContactViewController.m
//  AnonyFollow
//
//  Created by sonson on 2012/09/09.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "CopyrightContactViewController.h"

#import <MessageUI/MessageUI.h>
#import "NSBundle+AnonyFollow.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@interface CopyrightContactViewController ()

@end

@implementation CopyrightContactViewController

#pragma mark - System value

- (NSString*)versionString {
	NSString *CFBundleShortVersionString = [NSBundle infoValueFromMainBundleForKey:@"CFBundleShortVersionString"];
	NSString *CFBundleVersion = [NSBundle infoValueFromMainBundleForKey:@"CFBundleVersion"];
	NSString *CFBundleSubversionRevision = [NSBundle infoValueFromMainBundleForKey:@"CFBundleSubversionRevision"];
	
	NSString *buildCharacter = @"";
	
#ifdef _TESTFLIGHT
	buildCharacter = @"T";
#elif defined _DEBUG
	buildCharacter = @"D";
#endif
	
	return [NSString stringWithFormat:@"%@.%d.%d%@", CFBundleShortVersionString, [CFBundleVersion intValue], [CFBundleSubversionRevision intValue], buildCharacter];
}

// Codes are from
// http://stackoverflow.com/questions/448162/determine-device-iphone-ipod-touch-with-iphone-sdk
// Thanks for sss and UIBuilder2
- (NSString *) _platform {
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return platform;
}

- (NSString *) _platformString {
    NSString *platform = [self _platform];
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad-3G (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad-3G (4G)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad-3G (4G)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

#pragma mark - Instance method


- (void)sendFeedbackMail {
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		
		[picker setSubject:NSLocalizedString(@"[AnonyFollow contact] ", nil)];
		[picker setToRecipients:[NSArray arrayWithObject:NSLocalizedString(@"SupportMailAddress", nil)]];
		
		NSString *body = [NSString stringWithFormat:NSLocalizedString(@"\n\nYour system's information ----------\nAnonyFollow %@\niOS %@\n Device %@", nil), [self versionString], [UIDevice currentDevice].systemVersion, [self _platformString]];
		
		[picker setMessageBody:body isHTML:NO];
		
		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
			picker.modalPresentationStyle = UIModalPresentationFormSheet;
		[self presentViewController:picker animated:YES completion:^(void){}];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Mail error", nil)
														 message:NSLocalizedString(@"AnonyFollow needs a mail account in order to send your report.", nil)
														delegate:nil
											   cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
											   otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
		[alert show];
	}
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error  {
	[self dismissViewControllerAnimated:YES completion:^(void){}];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 1) {
		// sekikawa
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/YusukeSekikawa"]];
	}
	if (indexPath.section == 1 && indexPath.row == 1) {
		// sonson
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/sonson_twit"]];
	}
	if (indexPath.section == 2 && indexPath.row == 0) {
		// send report
		[self sendFeedbackMail];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
