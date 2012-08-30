//
//  CBScanner.m
//  AnonyFollow
//
//  Created by Sekikawa Yusuke on 8/23/12.
//  Copyright (c) 2012 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "CBScanner.h"

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
	[self stopScan];
}

- (BOOL)isAvailable {
    return (self.manager.state == CBCentralManagerStatePoweredOn);
}

- (void)startScan {
    if ([self isAvailable]) {
		[self.manager scanForPeripheralsWithServices:nil options:nil];
    }
	else{
    }
}

- (void)stopScan {
    [self.manager stopScan];
}

- (void)dealloc {
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
    NSString *userName = [advertisementData objectForKey:@"kCBAdvDataLocalName"];

    NSLog(@"Peripheral discovered %@ %@,%@,Name:%@,%d",RSSI, aPeripheral.UUID, advertisementData, userName, [services count]);
	
	if ([userName length]) {
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  userName, kCBScannerInfoUserNameKey,
								  nil];
		
		if ([self.delegate respondsToSelector:@selector(scanner:didDiscoverUser:)])
			[self.delegate scanner:self didDiscoverUser:userInfo];
	}
}

@end
