//
//  NSString+AnonyFollow.m
//  AnonyFollow
//
//  Created by sonson on 2012/09/03.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "NSString+AnonyFollow.h"

#import "GTMDefines.h"
#import "GTMNSData+zlib.h"
#import "NSData+AES256.h"
#import <zlib.h>
#import <Security/Security.h>

#include <assert.h>

@implementation NSString(AnonyFollow)

+ (char*)randomStringWithLength:(int)length {
	char *p = (char*)malloc(sizeof(char) * (length + 1));
	
	char *table = (char*)malloc(sizeof(char) * 27);
	
	table[0] = '_';
	for (int i = 1; i < 27; i++) {
		table[i] = i + 96;
	}
	
	for (int i = 0; i < length; i++) {
		uint16_t randomized_code = 0;
		SecRandomCopyBytes(kSecRandomDefault, sizeof(randomized_code), (uint8_t*)&randomized_code);
		*(p + i) = table[randomized_code % 27];
	}
	
	*(p + length + 1) = 0;
	
	free(table);
	
	return p;
}

+ (void)test_AnonyFollow {
	for (int length = 3; length < 16; length++) {
		for (int i = 0; i < 100; i++) {
			char *p = [self randomStringWithLength:length];
			
			NSString *string = [[NSString alloc] initWithBytes:p length:length encoding:NSASCIIStringEncoding];
			[string anonyFollowEncryptedString];
			free(p);
		}
	}
	
}

- (NSData*)anonyFollowEncryptedData {
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	return [data dataEncryptedWithKey:@"hoaaaage"];
}

- (NSString*)anonyFollowEncryptedString {
	NSData *encryptedData = [self anonyFollowEncryptedData];
	NSMutableString *buf = [NSMutableString string];
	char *p = (char*)[encryptedData bytes];
	for (int i = 0; i < [encryptedData length]; i++)
		[buf appendFormat:@"%02x", *(p + i)];
	
	return [NSString stringWithString:buf];
}

@end
