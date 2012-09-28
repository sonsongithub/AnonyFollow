//
//  CopyrightContactViewController.m
//  AnonyFollow
//
//  Created by sonson on 2012/09/09.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "CopyrightContactViewController.h"

@interface CopyrightContactViewController ()

@end

@implementation CopyrightContactViewController

#pragma mark - Instance method

- (void)openAppStoreWithID:(int)contentID {
	
	SKStoreProductViewController* vc = [[SKStoreProductViewController alloc] init];
	vc.delegate = self;
	NSNumber* itemId = [NSNumber numberWithInt:contentID];
	NSDictionary* parametersDict = [NSDictionary dictionaryWithObject:itemId
															   forKey:SKStoreProductParameterITunesItemIdentifier];
	
	// Request the product details from the Store.
	// When it completes and if it passes, show the viewcontroller to the user.
	[vc loadProductWithParameters:parametersDict completionBlock:^(BOOL result, NSError *error)
	 {
		 DNSLog(@"[SKStoreProductViewController loadProductWithParameters:] completed. result=%u, error=%@", result, error);
		 if(result)
		 {
			 [self presentViewController:vc animated:YES completion:^
			  {
				  DNSLog(@"presentViewController completed!");
			  }];
		 } else {
			 UIAlertView* alertFailed = [[UIAlertView alloc] initWithTitle:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
																   message:@"Error: Can't display the SKStoreProductViewController."
																  delegate:nil
														 cancelButtonTitle:@"Ok"
														 otherButtonTitles:nil, nil];
			 [alertFailed show];
		 }
	 }];
}

#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:^{
		 DNSLog(@"dismissModalViewControllerAnimated completed!")
	}];
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
	if (indexPath.section == 0 && indexPath.row == 2) {
		[self openAppStoreWithID:297925776];
	}
	if (indexPath.section == 1 && indexPath.row == 1) {
		// sonson
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://twitter.com/sonson_twit"]];
	}
	if (indexPath.section == 1 && indexPath.row == 2) {
		[self openAppStoreWithID:286074067];
	}
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
