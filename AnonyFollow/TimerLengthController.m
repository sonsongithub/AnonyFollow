//
//  TimerLengthController.m
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import "TimerLengthController.h"

@implementation TimerLengthController

+ (NSArray*)timerLengthTitles {
	return [NSArray arrayWithObjects:
			NSLocalizedString(@"Off", nil),
			NSLocalizedString(@"5 min", nil),
			NSLocalizedString(@"10 min", nil),
			nil];
}

+ (int)indexOfCurrentTimerLength {
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"TimerLengthController"];
}

+ (void)setCurrentTimerLength:(int)idx {
	[[NSUserDefaults standardUserDefaults] setInteger:idx forKey:@"TimerLengthController"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString*)currentTimerLengthTitle {
	int idx = [[NSUserDefaults standardUserDefaults] integerForKey:@"TimerLengthController"];
	return [[TimerLengthController timerLengthTitles] objectAtIndex:idx];
}

+ (float)currentTimerLength {
	int idx = [[NSUserDefaults standardUserDefaults] integerForKey:@"TimerLengthController"];
	switch (idx) {
		case 0:
			return 0;
		case 1:
			return 5;
		case 2:
			return 10;
		default:
			return 10;
	}
}
@end
