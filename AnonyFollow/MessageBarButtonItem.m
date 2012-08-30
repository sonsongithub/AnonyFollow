//
//  MessageBarButtonItem.m
//  AnonyFollow
//
//  Created by sonson on 2012/08/28.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "MessageBarButtonItem.h"

@interface NSObject(TapLabelDelegate)
- (void)touched;
@end

@interface TapLabel : UILabel

@property (nonatomic, assign) id delegate;

@end

@implementation TapLabel

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self setBackgroundColor:[UIColor colorWithWhite:0.1 alpha:0.5]];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self setBackgroundColor:[UIColor clearColor]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self setBackgroundColor:[UIColor clearColor]];
	[self.delegate touched];
}

@end

@implementation MessageBarButtonItem

- (id)initWithCoder:(NSCoder *)aDecoder {
	TapLabel *label = [[TapLabel alloc] initWithFrame:CGRectMake(0, 0, 150, 32)];
	label.delegate = self;
	self.label = label;
	[self.label setBackgroundColor:[UIColor clearColor]];
	self.label.textColor = [UIColor whiteColor];
	self.label.shadowColor = [UIColor blackColor];
	self.label.shadowOffset = CGSizeMake(0, -1);
	self.label.text = @"";
	self.label.font = [UIFont boldSystemFontOfSize:16];
	self.label.textAlignment = NSTextAlignmentCenter;
	self.label.userInteractionEnabled = YES;
	
	self = [super initWithCustomView:self.label];
	
	return self;
}

- (void)touched {
	if ([self.delegate respondsToSelector:@selector(didTouchMessageBarButtonItem:)])
		[self.delegate didTouchMessageBarButtonItem:self];
}

- (void)setTwitterAccountUserName:(NSString*)string {
	self.label.text = [NSString stringWithFormat:@"%@", string];
}

@end
