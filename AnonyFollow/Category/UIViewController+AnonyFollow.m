//
//  UIViewController+AnonyFollow.m
//  AnonyFollow
//
//  Created by sonson on 2012/09/08.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "UIViewController+AnonyFollow.h"

@implementation UIViewController(AnonyFollow)

- (IBAction)dismiss:(id)sender {
	if ([UIApplication sharedApplication].statusBarHidden) {
		[UIView animateWithDuration:0.4
						 animations:^(void) {
							 UIScreen *screen = [UIScreen mainScreen];
							 CGSize size = screen.bounds.size;
							 CGRect frame = CGRectMake(0, 0, size.width, size.height);
							 self.navigationController.view.frame = frame;
						 }
						 completion:^(BOOL success) {
							 [self dismissViewControllerAnimated:YES completion:^(void){}];
						 }];
	}
	else {
		[self dismissViewControllerAnimated:YES completion:^(void){}];
	}
}

@end
