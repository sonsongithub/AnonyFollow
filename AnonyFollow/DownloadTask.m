//
//  DownloadTask.m
//
//  Created by sonson on 11/09/04.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "DownloadTask.h"

@implementation DownloadTask

- (void)dump {

	NSLog(@"Response");
	NSLog(@"Status=%d", [self.httpResponse statusCode]);
	for (NSString *key in [[self.httpResponse allHeaderFields] allKeys]) {
		NSLog(@"%@=%@", key, [[self.httpResponse allHeaderFields] objectForKey:key]);
	}
}

- (void)dealloc {
}

@end
