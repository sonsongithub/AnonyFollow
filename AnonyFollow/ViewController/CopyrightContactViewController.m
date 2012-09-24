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
#import "UIDevice+AnonyFollow.h"
#import "UIApplication+AnonyFollow.h"

@interface CopyrightContactViewController ()

@end

@implementation CopyrightContactViewController

#pragma mark - Instance method

- (void)sendFeedbackMail {
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
		picker.mailComposeDelegate = self;
		
		[picker setSubject:NSLocalizedString(@"[AnonyFollow contact] ", nil)];
		[picker setToRecipients:[NSArray arrayWithObject:NSLocalizedString(@"SupportMailAddress", nil)]];
		
		NSString *body = [NSString stringWithFormat:NSLocalizedString(@"\n\nYour system's information ----------\nAnonyFollow %@\niOS %@\n Device %@", nil), [[UIApplication sharedApplication] versionString], [UIDevice currentDevice].systemVersion, [[UIDevice currentDevice] _platformString]];
		
		[picker setMessageBody:body isHTML:NO];
		
		if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad)
			picker.modalPresentationStyle = UIModalPresentationFormSheet;
		[self presentViewController:picker animated:YES completion:^(void){}];
	}
	else {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Mail error", nil)
														 message:NSLocalizedString(@"App needs a mail account in order to send your report.", nil)
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
	if (indexPath.section == 0 && indexPath.row == 0) {
		// sekikawa
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/YusukeSekikawa"]];
	}
	if (indexPath.section == 1 && indexPath.row == 0) {
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
