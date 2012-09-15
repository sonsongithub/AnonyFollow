//
//  CBScanner.m
//  AnonyFollow
//
//  Created by Sekikawa Yusuke on 8/23/12.
//  Copyright (c) 2012 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "CBScanner.h"
#import "NSString+AnonyFollow.h"
#define CBScannerFilterServices

NSString *kCBScannerInfoUserNameKey = @"kCBScannerInfoUserNameKey";
NSString *kCBScannerInfoUserRSSIKey = @"kCBScannerInfoUserRSSIKey";

@implementation CBScanner
#pragma mark - Instance method

- (void)logState {
	if (self.manager.state == CBCentralManagerStateUnsupported) {
		DNSLog(@"The platform/hardware doesn't support Bluetooth Low Energy.");
	}
	else if (self.manager.state == CBCentralManagerStateUnauthorized) {
		DNSLog(@"The app is not authorized to use Bluetooth Low Energy.");
	}
	else if (self.manager.state == CBCentralManagerStatePoweredOff) {
		DNSLog(@"Bluetooth is currently powered off.");
	}
	else if (self.manager.state == CBCentralManagerStateResetting) {
		DNSLog(@"Bluetooth is currently resetting.");
	}
	else if (self.manager.state == CBCentralManagerStatePoweredOn) {
		DNSLog(@"Bluetooth is currently powered on.");
	}
	else if (self.manager.state == CBCentralManagerStateUnknown) {
		DNSLog(@"Bluetooth is an unknown status.");
	}
	else {
		DNSLog(@"Unknown status code.");
	}
	
}

- (id)initWithDelegate:(id<CBScannerDelegate>)delegate serviceUUID:(NSString*)UUIDStr {
	self = [super init];
	if (self) {
		self.UUIDStr    = UUIDStr;
		self.delegate   = delegate;
		self.manager    = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
                                              selector:@selector(didEnterBackgroundNotification:)
                                              name:UIApplicationDidEnterBackgroundNotification
                                              object:nil];
	}
    return self;
}

- (void)didEnterBackgroundNotification:(NSNotification*)notification {
    //We will continue scanning while in background.
    //[self stopScan];
	DNSLogMethod
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

    if(self.UUIDStr != nil)
		[self.manager scanForPeripheralsWithServices:[NSArray arrayWithObjects:[CBUUID UUIDWithString:self.UUIDStr], nil] options:options];
    else
		[self.manager scanForPeripheralsWithServices:nil options:options];

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
    NSMutableArray *services = [advertisementData objectForKey:CBAdvertisementDataServiceUUIDsKey];
    NSMutableData *encodedData=[NSMutableData dataWithCapacity:ENCODED_UNAME_LEN];
    if([services count]!=(ENCODED_UNAME_LEN/2)+1){
        return;
    }
    /* first byte should be self.UUIDStr */
    [services removeObjectAtIndex:0];
    
    for (CBUUID *uuid in services) {
        uint8_t _data[2];
        [uuid.data getBytes:_data];
        [encodedData appendBytes:_data length:2];
    }
    NSString *userName = [NSString stringWithAnonyFollowEncodedData:encodedData key:KEY_ANONYFOLLOW	];
    userName = [userName stringByReplacingOccurrencesOfString:@" " withString:@""];
    
	if ([userName length]) {
        DNSLog(@"Peer discovered RSSI:%@ UUID:%@,userName:%@",RSSI, aPeripheral.UUID, userName);
		NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
								  userName, kCBScannerInfoUserNameKey,
                                  RSSI,     kCBScannerInfoUserRSSIKey,
								  nil];
		
		if ([self.delegate respondsToSelector:@selector(scanner:didDiscoverUser:)])
			[self.delegate scanner:self didDiscoverUser:userInfo];
	}
}
@end
