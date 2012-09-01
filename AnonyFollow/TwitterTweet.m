//
//  TwitterTweet.m
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import "TwitterTweet.h"

@implementation TwitterTweet

+ (CGSize)sizeOfText:(NSString*)text withWidth:(float)width font:(UIFont*)font {
	return [text sizeWithFont:font constrainedToSize:CGSizeMake(width, 10000000) lineBreakMode:NSLineBreakByCharWrapping];
}

- (float)height {
	DNSLog(@"%f", self.contentSize.height);
	float height = self.contentSize.height + 31;
	return height > 60 ? height : 60;
}

@end
