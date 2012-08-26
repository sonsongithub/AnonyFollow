//
//  TimerLengthController.h
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimerLengthController : NSObject

+ (NSArray*)timerLengthTitles;
+ (int)indexOfCurrentTimerLength;
+ (void)setCurrentTimerLength:(int)idx;
+ (NSString*)currentTimerLengthTitle;
+ (float)currentTimerLength;

@end
