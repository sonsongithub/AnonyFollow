//
//  TwitterTweet.h
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TwitterAccountInfo;

@interface TwitterTweet : NSObject

@property (nonatomic, strong) TwitterAccountInfo *accountInfo;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSDate *created_at;
@property (nonatomic, strong) NSString *created_at_string;
@property (nonatomic, assign) CGSize contentSize;

- (float)height;
+ (CGSize)sizeOfText:(NSString*)text withWidth:(float)width font:(UIFont*)font;
	
@end
