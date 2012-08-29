//
//  SNReachablityChecker.h
//  SNReachabilityTest
//
//  Created by sonson on 2012/08/29.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

extern NSString *SNReachablityDidChangeNotification;

typedef enum SNReachablityCheckerType_ {
	SNReachablityCheckerHostConnectivity		= 0,
	SNReachablityCheckerInternetConnectivity	= 1,
	SNReachablityCheckerLocalWiFiConnectivity	= 2
}SNReachablityCheckerType;

typedef enum SNReachablityCheckerStatus_ {
	SNReachablityCheckerNotReachable			= 0,
	SNReachablityCheckerReachableViaWiFi		= 1,
	SNReachablityCheckerReachableViaWWAN		= 2
}SNReachablityCheckerStatus;

@interface SNReachablityChecker : NSObject

@property (nonatomic, assign) SCNetworkReachabilityRef networkReachability;
@property (nonatomic, assign) SNReachablityCheckerType type;

+ (SNReachablityChecker*)reachabilityWithHostName:(NSString*)hostName;
+ (SNReachablityChecker*)reachabilityForInternetConnection;
+ (SNReachablityChecker*)reachabilityForLocalWiFi;

- (BOOL)start;
- (void)stop;
- (SNReachablityCheckerStatus)status;

@end
