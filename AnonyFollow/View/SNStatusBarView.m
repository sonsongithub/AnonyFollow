/*
 * SNStatusBarView
 * SNStatusBarView.m
 *
 * Copyright (c) Yuichi YOSHIDA, 12/08/24.
 * All rights reserved.
 *
 * BSD License
 *
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 * - Redistributions of source code must retain the above copyright notice, this list of
 *  conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, this list
 *  of conditions and the following disclaimer in the documentation and/or other materia
 * ls provided with the distribution.
 * - Neither the name of the "Yuichi Yoshida" nor the names of its contributors may be u
 * sed to endorse or promote products derived from this software without specific prior
 * written permission.
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY E
 * XPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES O
 * F MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SH
 * ALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENT
 * AL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROC
 * UREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS I
 * NTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRI
 * CT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF T
 * HE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SNStatusBarView.h"

#import <QuartzCore/QuartzCore.h>

@interface SNStatusBarBackView : UIView
@property (nonatomic, assign) CGGradientRef gradientRef;
- (id)initWithFrame:(CGRect)frame color:(UIColor*)color;
@end

@interface SNStatusBarBackView()
+ (CAAnimation*)alphaAnimation;
@end

@implementation SNStatusBarBackView

+ (CAAnimation*)alphaAnimation {
	// alpha
	CAKeyframeAnimation *alphaAnimation = [CAKeyframeAnimation	animationWithKeyPath:@"opacity"];
	alphaAnimation.values = [NSArray arrayWithObjects:
							 [NSNumber numberWithFloat:0.0],
							 [NSNumber numberWithFloat:1.0],
							 [NSNumber numberWithFloat:1.0],
							 [NSNumber numberWithFloat:0.0],
							 nil];
	alphaAnimation.keyTimes = [NSArray arrayWithObjects:
							   [NSNumber numberWithFloat:0],
							   [NSNumber numberWithFloat:0.45],
							   [NSNumber numberWithFloat:0.55],
							   [NSNumber numberWithFloat:1],
							   nil];
	return alphaAnimation;
}

- (id)initWithFrame:(CGRect)frame color:(UIColor*)color {
	self = [super initWithFrame:frame];
	if (self) {
		
		CGFloat red = 0;
		CGFloat green = 0;
		CGFloat blue = 0;
		CGFloat alpha = 0;
		
		[color getRed:&red green:&green blue:&blue alpha:&alpha];
		
		int step = 10;
		
		CGFloat *components = (CGFloat*)malloc(sizeof(CGFloat) * step * 4);
		CGFloat *locations = (CGFloat*)malloc(sizeof(CGFloat) * step);
		
		CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
		
		for (int i = 0; i < step; i++) {
			float rest_ratio = (float)(step - i) / step;
			float color_params = rest_ratio * rest_ratio;
			float ratio = (float)i / step;
			*(components + 4 * i + 0) = red * color_params;
			*(components + 4 * i + 1) = green * color_params;
			*(components + 4 * i + 2) = blue * color_params;
			*(components + 4 * i + 3) = alpha * color_params;
			*(locations + i) = ratio;
		}
		self.gradientRef = CGGradientCreateWithColorComponents(rgb, components, locations, step);
		CGColorSpaceRelease(rgb);
		
		free(components);
		free(locations);
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGPoint center = CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
	CGContextDrawRadialGradient(context, self.gradientRef, center, 0, center, rect.size.width * 2.5, 0);
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    CGGradientRelease(self.gradientRef);
}

@end

@interface SNStatusBarView()
@property (nonatomic, strong) SNStatusBarBackView *lightingView;
@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) NSString *defaultMessage;
@property (nonatomic, strong) NSMutableArray *queueingMessages;
@property (nonatomic, strong) NSTimer *temporaryMessageTimer;

@end

@implementation SNStatusBarView

- (void)startBlinkingAnimation {
	CAAnimation *alphaAnimation = [SNStatusBarBackView alphaAnimation];
	
	// make group
	alphaAnimation.duration = 2;
	alphaAnimation.repeatCount = HUGE_VALF;
	
	// commit animation
	[self.lightingView.layer addAnimation:alphaAnimation forKey:@"BlinkingAnimation"];
}

- (UILabel*)makeMessageLabel {
	UILabel *messageLabel = [[UILabel alloc] initWithFrame:self.frame];
	messageLabel.backgroundColor = [UIColor clearColor];
	messageLabel.font = [UIFont boldSystemFontOfSize:14];
	messageLabel.textColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
	messageLabel.shadowColor = [UIColor darkGrayColor];
	messageLabel.shadowOffset = CGSizeMake(0, -0.5);
	messageLabel.textAlignment = NSTextAlignmentCenter;
	
	return messageLabel;
}

- (void)setColor:(UIColor*)color {
	[self.lightingView removeFromSuperview];
	self.lightingView = [[SNStatusBarBackView alloc] initWithFrame:self.frame color:color];
	[self addSubview:self.lightingView];
	[self sendSubviewToBack:self.lightingView];
	[self startBlinkingAnimation];
}

- (void)pushTemporaryMessage:(NSString*)string {
	[self.queueingMessages addObject:string];
	
	if (self.temporaryMessageTimer == nil) {
		[self pop];
		[self.temporaryMessageTimer invalidate];
		self.temporaryMessageTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(update) userInfo:nil repeats:YES];
	}
}

- (void)pop {
	if ([self.queueingMessages count]) {
		NSString *newMessage = [self.queueingMessages objectAtIndex:0];
		[self.queueingMessages removeObjectAtIndex:0];
		[self updateMessageLabelWithString:newMessage];
	}
	else {
		[self updateMessageLabelWithString:self.defaultMessage];
		[self.temporaryMessageTimer invalidate];
		self.temporaryMessageTimer = nil;
	}
}

- (void)update {
	DNSLogMethod
	[self pop];
}

- (void)setMessage:(NSString*)message {
	
	if ([self.defaultMessage isEqualToString:message])
		return;
	
	self.defaultMessage = message;
	if (self.temporaryMessageTimer == nil)
		[self updateMessageLabelWithString:message];
}

- (void)updateMessageLabelWithString:(NSString*)string {
	UILabel *previous = self.messageLabel;
	
	// frame out previous label
	{
		CGRect from = self.frame;
		CGRect to = from;
		to.origin.y = -from.size.height;
		previous.frame = from;
		[UIView animateWithDuration:0.4
						 animations:^(void) {
							 previous.frame = to;
						 }
						 completion:^(BOOL success) {
							 [previous removeFromSuperview];
						 }];
	}
	
	// frame in next label
	self.messageLabel = [self makeMessageLabel];
	self.messageLabel.text = string;
	[self addSubview:self.messageLabel];
	[self bringSubviewToFront:self.messageLabel];
	{
		CGRect from = self.frame;
		CGRect to = from;
		from.origin.y = from.size.height;
		self.messageLabel.frame = from;
		[UIView animateWithDuration:0.4 animations:^(void){
			self.messageLabel.frame = to;
		}];
	}
}

- (void)startClosingAnimation {
	CGRect from = self.frame;
	CGRect to = from;
	to.origin.y = from.size.height;
	self.messageLabel.frame = from;
	
	[UIView animateWithDuration:0.4
					 animations:^(void) {
						 self.messageLabel.frame = to;
					 }
					 completion:^(BOOL success) {
						 self.defaultMessage = nil;
					 }];
}

- (void)willEnterForeground:(NSNotification*)notification {
	[self startBlinkingAnimation];
}

- (void)appplicationWillChangeStatusBarFrameNotification:(NSNotification*)notification {
	NSValue *newFrameValue = [[notification userInfo] objectForKey:UIApplicationStatusBarFrameUserInfoKey];
	CGRect newFrame = [newFrameValue CGRectValue];
	CGRect f = self.frame;
	f.size.height = newFrame.size.height;
	self.frame = f;
	CGRect from = self.frame;
	CGRect to = from;
	from.origin.y = from.size.height;
	self.messageLabel.frame = from;
	[UIView animateWithDuration:0.4 animations:^(void){
		self.messageLabel.frame = to;
	}];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.queueingMessages = [NSMutableArray array];
		self.clipsToBounds = YES;
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appplicationWillChangeStatusBarFrameNotification:) name:UIApplicationWillChangeStatusBarFrameNotification object:nil];
    }
    return self;
}

@end
