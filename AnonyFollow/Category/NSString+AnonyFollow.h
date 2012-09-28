//
//  NSString+AnonyFollow.h
//  AnonyFollow
//
//  Created by sonson on 2012/09/03.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import <Foundation/Foundation.h>

#define KEY_ANONYFOLLOW @"sekky"

@interface NSString(AnonyFollow)

// test code
+ (void)test_AnonyFollow;

// encoder
- (NSData*)dataAnonyFollowEncodedWithKey:(NSString*)key;
- (NSString*)stringAnonyFollowEncodedWithKey:(NSString*)key;

// decoder
+ (NSString*)stringWithAnonyFollowEncodedData:(NSData*)data key:(NSString*)key;
+ (NSString*)stringWithAnonyFollowEncodedString:(NSString*)string key:(NSString*)key;

@end
