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

//
- (NSString*)encode;
- (NSString*)decode;


// test
+ (void)test_AnonyFollow;
- (NSData*)anonyFollowEncryptedData;
- (NSString*)anonyFollowEncryptedString;

@end
