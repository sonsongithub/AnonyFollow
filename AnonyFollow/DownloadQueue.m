//
//  DownloadQueue.m
//
//  Created by sonson on 11/09/04.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "DownloadQueue.h"

#import "DownloadTask.h"

static DownloadQueue *shared3tchDownloadQueue = nil;

@implementation DownloadQueue

+ (DownloadQueue*)sharedInstance {
	if (shared3tchDownloadQueue == nil) {
		shared3tchDownloadQueue = [[DownloadQueue alloc] init];
	}
	return shared3tchDownloadQueue;
}

- (id)init {
    self = [super init];
    if (self) {
        self.queue = [NSMutableArray array];
		self.isOnline = YES;
    }
    return self;
}

- (void)clearQueue {
	[self.downloader cancel];
	self.downloadData = nil;
	self.downloader = nil;
	[self.queue removeAllObjects];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (void)removeTasksWithIdentifier:(NSString*)identifier {
	BOOL needsToRestartDownloading = NO;
	
	if ([self.currentTask.identifier isEqualToString:identifier]) {
		// pause current downloader
		[self.downloader cancel];
		self.downloadData = nil;
		self.downloader = nil;
		if ([self.queue count])
			[self.queue removeObjectAtIndex:0];
		needsToRestartDownloading = YES;
	}
	
	for (DownloadTask *taskInQueue in [self.queue reverseObjectEnumerator]) {
		if ([taskInQueue.identifier isEqualToString:identifier]) {
			[self.queue removeObject:taskInQueue];
		}
	}
	
	// restart download
	if (needsToRestartDownloading)
		[self startDownload];
}

- (void)removeTask:(DownloadTask*)task {
	BOOL needsToRestartDownloading = NO;
	
	if (self.currentTask == task) {
		// pause current downloader
		[self.downloader cancel];
		self.downloadData = nil;
		self.downloader = nil;
		[self.queue removeObjectAtIndex:0];
		needsToRestartDownloading = YES;
	}
	
	for (DownloadTask *taskInQueue in [self.queue reverseObjectEnumerator]) {
		if (taskInQueue == task) {
			[self.queue removeObject:taskInQueue];
		}
	}
	
	// restart download
	if (needsToRestartDownloading)
		[self startDownload];
}

- (void)removeTasksOfDelegate:(id)target {
	
	// pause current downloader
	[self.downloader cancel];
	self.downloadData = nil;
	self.downloader = nil;
	
	for (int i = 0; i < [self.queue count]; i++) {
		DownloadTask *task = [self.queue objectAtIndex:i];
		if (task.delegate == target) {
			NSLog(@"Remove %s", class_getName([target class]));
			[self.queue removeObjectAtIndex:i];
		}
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	// restart download
	[self startDownload];
}

- (void)startDownload {
	if ([self.queue count] == 0) {
		// Stop network activity animation
		[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
		return;
	}
	
	//
	// Fetch first queue.
	//
	DownloadTask *task = [self.queue objectAtIndex:0];
	
	//
	// Start to download based on the queue.
	//
	self.downloader = nil;
	self.downloadData = nil;
	self.downloader = [[NSURLConnection alloc] initWithRequest:task.request delegate:self];
	self.downloadData = [NSMutableData data];
	self.currentTask = task;
	
	// UI activity
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)addTask:(DownloadTask*)task {
	if ([self.queue count] > 0) {
		[self.queue insertObject:task atIndex:1];		// like FIFO, first in first out
	}
	else {
		[self.queue addObject:task];					// can't insert at index 0 when queue stack is vacant.
	}
	
	if ([self.queue count] == 1) {						// Right now start to download when queue stack is vacant.
		[self startDownload];
	}
}

- (void)addTaskToTail:(DownloadTask*)task {
	[self.queue addObject:task];
	
	if ([self.queue count] == 1) {						// Right now start to download when queue stack is vacant.
		[self startDownload];
	}
}

- (void)showAlertViewWithErrorMessage:(NSString*)message {
	UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
														message:message
													   delegate:nil
											  cancelButtonTitle:nil
											  otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
	[alertview show];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response {
	self.currentTask.httpResponse = (NSHTTPURLResponse*)response;
	
	if (![[[response URL] absoluteString] isEqualToString:[[self.currentTask.httpResponse URL] absoluteString]]) {
		//
		// Differenct URL is loaded
		//
		[connection cancel];
		
		//
		// Call doTaskAfterReturnedDifferentURL to delegate
		//
		if ([self.currentTask.delegate respondsToSelector:@selector(didFailedDownloadTask:)]) {
			[self.currentTask.delegate didFailedDownloadTask:self.currentTask];
		}
		
		if ([self.queue count])
			[self.queue removeObjectAtIndex:0];
		self.currentTask = nil;
		[self startDownload];
	}
	else {
		NSString *contentLengthString = [[self.currentTask.httpResponse allHeaderFields] objectForKey:@"Content-Length"];
		self.currentTask.contentLength = [contentLengthString intValue];
	}
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data lengthReceived:(int)length {
	[self.downloadData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection {
	
	// Stop network activity animation
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	self.currentTask.data = self.downloadData;
	
	// callback
	if ([self.currentTask.delegate respondsToSelector:@selector(didDownloadTask:)]) {
		[self.currentTask.delegate didDownloadTask:self.currentTask];
	}
	
	if ([self.queue count])
		[self.queue removeObjectAtIndex:0];
	self.currentTask = nil;
	[self startDownload];
	self.isOnline = YES;
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error {
	NSLog(@"%@", [error description]);
	
	// Stop network activity animation
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
	if ([self.currentTask.delegate respondsToSelector:@selector(didFailedDownloadTask:)]) {
		[self.currentTask.delegate didFailedDownloadTask:self.currentTask];
	}
	
	if ([self.queue count])
		[self.queue removeObjectAtIndex:0];
	self.currentTask = nil;
	
	// if internet connection is lost, all queues must be removed.
	if ([error code] == -1009) {
		[self clearQueue];
		if (self.isOnline)
			[self showAlertViewWithErrorMessage:[error localizedDescription]];
		self.isOnline = NO;
	}
	else {
		// the other error, for example time out.
		[self startDownload];
		[self showAlertViewWithErrorMessage:[error localizedDescription]];
		self.isOnline = YES;
	}
}

@end
