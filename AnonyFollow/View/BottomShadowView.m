//
//  BottomShadowView.m
//  AnonyFollow
//
//  Created by sonson on 2012/11/02.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "BottomShadowView.h"
#import <QuartzCore/QuartzCore.h>

@implementation BottomShadowView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		self.backgroundColor = [UIColor clearColor];
	}
	return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGContextSaveGState(context);
	
	CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 4, [UIColor blackColor].CGColor);
	
	CGContextFillRect(context, CGRectMake(-1, -10, rect.size.width+2, 10));
	
	CGContextRestoreGState(context);
}

@end
