//
//  DownloadQueue.h
//
//  Created by sonson on 11/09/04.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#import "DownloadTask.h"

@interface NSObject(DownloadTask)

- (void)didDownloadTask:(DownloadTask*)task;
- (void)didFailedDownloadTask:(DownloadTask*)task;

@end

@interface DownloadQueue : NSObject
	
@property (nonatomic, strong) NSMutableArray *queue;
@property (nonatomic, strong) NSMutableData *downloadData;
@property (nonatomic, strong) NSURLConnection *downloader;
@property (nonatomic, strong) DownloadTask *currentTask;
@property (nonatomic, assign) BOOL isOnline;

+ (DownloadQueue*)sharedInstance;

- (void)clearQueue;
- (void)removeTasksOfDelegate:(id)target;
- (void)startDownload;
- (void)addTask:(DownloadTask*)task;
- (void)removeTask:(DownloadTask*)task;
- (void)removeTasksWithIdentifier:(NSString*)identifier;
- (void)addTaskToTail:(DownloadTask*)task;

@end
