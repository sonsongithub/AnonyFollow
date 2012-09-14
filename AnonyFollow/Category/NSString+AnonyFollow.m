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

@implementation NSString(private)

- (unsigned int)hexIntValue {
    unsigned int result;
    [[NSScanner scannerWithString:self] scanHexInt:&result];
    return result;
}

+ (char*)randomStringWithLength:(int)length {
	char *p = (char*)malloc(sizeof(char) * (length + 1));
	
	char *table = (char*)malloc(sizeof(char) * 27);
	
	table[0] = '_';
	for (int i = 1; i < 27; i++)
		table[i] = i + 96;
	
	for (int i = 0; i < length; i++) {
		uint16_t randomized_code = 0;
		SecRandomCopyBytes(kSecRandomDefault, sizeof(randomized_code), (uint8_t*)&randomized_code);
		*(p + i) = table[randomized_code % 27];
	}
	
	*(p + length + 1) = 0;
	
	free(table);
	
	return p;
}

@end

@implementation NSString(AnonyFollow)

+ (void)test_AnonyFollow {
#if 1
	for (int length = 3; length < 16; length++) {
		for (int i = 0; i < 100; i++) {
			char *p = [self randomStringWithLength:length];
			
			NSString *string = [[NSString alloc] initWithBytes:p length:length encoding:NSASCIIStringEncoding];
			
			
			NSData *encodedData = [string dataAnonyFollowEncodedWithKey:@"test"];
			NSString *encodedString = [string stringAnonyFollowEncodedWithKey:@"test"];
			
			NSString *string_from_encodedData = [NSString stringWithAnonyFollowEncodedData:encodedData key:@"test"];
			NSString *string_from_encodedString = [NSString stringWithAnonyFollowEncodedString:encodedString key:@"test"];
			
			assert([string isEqualToString:string_from_encodedData]);
			assert([string isEqualToString:string_from_encodedString]);
			
			free(p);
		}
	}
	NSLog(@"decode and encode test is passed.");
#endif
}

- (NSData*)dataAnonyFollowEncodedWithKey:(NSString*)key {
	NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
	return [data dataEncryptedWithKey:key];
}

- (NSString*)stringAnonyFollowEncodedWithKey:(NSString*)key {
	NSData *data = [self dataAnonyFollowEncodedWithKey:key];
	NSMutableString *buf = [NSMutableString string];
	unsigned char *p = (unsigned char*)[data bytes];
	for (int i = 0; i < [data length]; i++)
		[buf appendFormat:@"%02x", *(p + i)];
	return [NSString stringWithString:buf];
}

+ (NSString*)stringWithAnonyFollowEncodedData:(NSData*)data key:(NSString*)key {
	NSData *decrypted = [data dataDecryptedWithKey:key];
	return [[NSString alloc] initWithBytes:[decrypted bytes] length:[decrypted length] encoding:NSUTF8StringEncoding];
}

+ (NSString*)stringWithAnonyFollowEncodedString:(NSString*)string key:(NSString*)key {
	NSMutableData *data = [NSMutableData data];
	for (int i = 0; i < [string length]; i+=2) {
		NSString *sub = [string substringWithRange:NSMakeRange(i, 2)];
		unsigned char c = [sub hexIntValue];
		[data appendBytes:&c length:sizeof(c)];
	}
	return [NSString stringWithAnonyFollowEncodedData:data key:key];
}

@end
