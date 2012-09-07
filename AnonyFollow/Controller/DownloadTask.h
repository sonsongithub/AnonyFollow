//
//  DownloadTask.h
//
//  Created by sonson on 11/09/04.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadTask : NSObject

@property (nonatomic, strong) NSMutableData *data;
@property (nonatomic, strong) NSURLRequest *request;
@property (nonatomic, strong) NSHTTPURLResponse *httpResponse;
@property (nonatomic, assign) id delegate;
@property (nonatomic, strong) NSString *identifier;
@property (nonatomic, assign) int contentLength;
- (void)dump;
@end
