//
//  CBScanner.m
//  AnonyFollow
//
//  Created by Sekikawa Yusuke on 8/23/12.
//  Copyright (c) 2012 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "CBScanner.h"
//#define CBScannerAllowDuplicates
#define CBScannerFilterServices


NSString *kCBScannerInfoUserNameKey = @"kCBScannerInfoUserNameKey";

@implementation CBScanner

#pragma mark - Instance method

- (void)logState {
	if (self.manager.state == CBCentralManagerStateUnsupported) {
		NSLog(@"The platform/hardware doesn't support Bluetooth Low Energy.");
	}
	else if (self.manager.state == CBCentralManagerStateUnauthorized) {
		NSLog(@"The app is not authorized to use Bluetooth Low Energy.");
	}
	else if (self.manager.state == CBCentralManagerStatePoweredOff) {
		NSLog(@"Bluetooth is currently powered off.");
	}
	else if (self.manager.state == CBCentralManagerStateResetting) {
		NSLog(@"Bluetooth is currently resetting.");
	}
	else if (self.manager.state == CBCentralManagerStatePoweredOn) {
		NSLog(@"Bluetooth is currently powered on.");
	}
	else if (self.manager.state == CBCentralManagerStateUnknown) {
		NSLog(@"Bluetooth is an unknown status.");
	}
	else {
		NSLog(@"Unknown status code.");
	}
	
}

- (id)initWithDelegate:(id<CBScannerDelegate>)delegate serviceUUID:(NSString*)UUIDStr {
	self = [super init];
	if (self) {
		self.UUIDStr = UUIDStr;
		self.delegate = delegate;
		self.manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
	}
    return self;
}

- (void)didEnterBackgroundNotification:(NSNotification*)notification {
	DNSLogMethod
    //[self stopScan];
}

- (BOOL)isAvailable {
    return (self.manager.state == CBCentralManagerStatePoweredOn);
}

- (void)startScan {

#ifdef CBScannerAllowDuplicates
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
#else
    NSDictionary *options = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey]; 
#endif

#ifdef CBScannerFilterServices
    NSArray *serviceFilter  = [NSArray arrayWithObjects:[CBUUID UUIDWithString:@"1802"],nil];
#else
    NSArray *serviceFilter  = nil;
#endif
    if ([self isAvailable]) {
		[self.manager scanForPeripheralsWithServices:serviceFilter options:options];
    }
	else{
    }
    DNSLogMethod
}

- (void)stopScan {
    [self.manager stopScan];
    DNSLogMethod
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	DNSLogMethod
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)manager {
    [self logState];
	
	[self startScan];
	
	if ([self.delegate respondsToSelector:@selector(scannerDidChangeStatus:)])
		[self.delegate scannerDidChangeStatus:self];
}

- (void) centralManager:(CBCentralManager*)manager
  didDiscoverPeripheral:(CBPeripheral *)aPeripheral
	  advertisementData:(NSDictionary *)advertisementData
				   RSSI:(NSNumber *)RSSI {
	DNSLogMethod
    NSArray *services = [advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
    
#if 0
    NSString *userName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];
#else
    NSString *userName=@"";
    int cnt=0;
    for(CBUUID *uuid in services)
    {
        if(cnt>0){
            NSString *str= [[NSString alloc] initWithData:uuid.data encoding:NSASCIIStringEncoding];
            userName=[userName stringByAppendingString:[NSString stringWithFormat:@"%@",str]];
            NSLog(@"userName:%@",userName);
        }
        cnt++;
    }
    //NSLog(@"before userName:%d",[userName length]);
    userName = [userName stringByReplacingOccurrencesOfString:@" " withString:@""];
    //NSLog(@"after userName:%d",[userName length]);

#endif
    if(userName==nil){
        //Get twitter screen name from service UUIDs

    }else{
        ;
    }
    
    NSLog(@"Peripheral discovered %@ %@,%@,Name:%@",RSSI, aPeripheral.UUID, advertisementData, userName);
    NSLog(@"Peripheral discovered %@,%d",[advertisementData objectForKey:@"kCBAdvDataLocalName"], [services count]);
	if ([userName length]) {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  userName, kCBScannerInfoUserNameKey,
								  nil];
		
		if ([self.delegate respondsToSelector:@selector(scanner:didDiscoverUser:)])
			[self.delegate scanner:self didDiscoverUser:userInfo];
	}
}

@end
