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

@interface TapLabel : UIView

@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) BOOL tapped;

@end

@implementation TapLabel

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	self.backgroundColor = [UIColor clearColor];
	return self;
}

// draw round corner rect
- (void)drawRoundCornerRect:(CGRect)rect mode:(CGPathDrawingMode)mode radius:(float)radius {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
	CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
	
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	CGContextClosePath(context);
    
    CGContextDrawPath(context, mode);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	self.tapped = YES;
	[self setNeedsDisplay];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	self.tapped = NO;
	[self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	self.tapped = NO;
	[self.delegate touched];
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	if (self.tapped) {
		[[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5] setFill];
		[self drawRoundCornerRect:rect mode:kCGPathEOFill radius:5];
	}
}

@end

@implementation MessageBarButtonItem

- (id)initWithCoder:(NSCoder *)aDecoder {
	self.back = [[TapLabel alloc] initWithFrame:CGRectMake(0, 0, 150, 26)];
	
	UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 10)];
	[title setBackgroundColor:[UIColor clearColor]];
	[title setBackgroundColor:[UIColor clearColor]];
	title.textColor = [UIColor whiteColor];
	title.shadowColor = [UIColor blackColor];
	title.shadowOffset = CGSizeMake(0, -1);
	title.text = NSLocalizedString(@"Your account is", nil);
	title.font = [UIFont boldSystemFontOfSize:10];
	title.textAlignment = NSTextAlignmentCenter;
	title.userInteractionEnabled = YES;
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, 150, 16)];
	((TapLabel*)self.back).delegate = self;
	self.label = label;
	[self.label setBackgroundColor:[UIColor clearColor]];
	self.label.textColor = [UIColor whiteColor];
	self.label.shadowColor = [UIColor blackColor];
	self.label.shadowOffset = CGSizeMake(0, -1);
	self.label.text = @"";
	self.label.font = [UIFont boldSystemFontOfSize:16];
	self.label.textAlignment = NSTextAlignmentCenter;
	self.label.userInteractionEnabled = YES;
	
	[self.back addSubview:title];
	[self.back addSubview:self.label];
	
	self = [super initWithCustomView:self.back];
	
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
