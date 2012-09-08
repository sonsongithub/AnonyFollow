//
//  CBAdvertizer.m
//  AnonyFollow
//
//  Created by Sekikawa Yusuke on 8/23/12.
//  Copyright (c) 2012 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "CBAdvertizer.h"
#import "NSString+AnonyFollow.h"



@implementation CBAdvertizer

- (void)logState {
	if (self.manager.state == CBPeripheralManagerStateUnsupported) {
		NSLog(@"The platform/hardware doesn't support Bluetooth Low Energy.");
	}
	else if (self.manager.state == CBPeripheralManagerStateUnauthorized) {
		NSLog(@"The app is not authorized to use Bluetooth Low Energy.");
	}
	else if (self.manager.state == CBPeripheralManagerStatePoweredOff) {
		NSLog(@"Bluetooth is currently powered off.");
	}
	else if (self.manager.state == CBPeripheralManagerStateResetting) {
		NSLog(@"Bluetooth is currently resetting.");
	}
	else if (self.manager.state == CBPeripheralManagerStatePoweredOn) {
		NSLog(@"Bluetooth is currently powered on.");
	}
	else if (self.manager.state == CBPeripheralManagerStateUnknown) {
		NSLog(@"Bluetooth is an unknown status.");
	}
	else {
		NSLog(@"Unknown status code.");
	}
	
	if (self.manager.isAdvertising)
		NSLog(@"Now, advertising.");
	else
		NSLog(@"NOT advertising.");
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	DNSLogMethod
}

- (id)initWithDelegate:(id<CBAdvertizerDelegate>)delegate userName:(NSString*)userName serviceUUID:(NSString*)UUIDStr {
    self.userName = userName;
    self.UUIDStr = UUIDStr;
    while ([self.userName length]<UNAME_MAX_LEN) {
        self.userName=[self.userName stringByAppendingFormat:@" "];
    }
	self.delegate = delegate;
    self.manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    return [super init];
}

- (BOOL)isAvailable {
	return (self.manager.state == CBPeripheralManagerStatePoweredOn);
}

- (void)didEnterBackgroundNotification:(NSNotification*)notification {
	[self stopAdvertize];
    DNSLogMethod
}

- (void)startAdvertize{
    if ([self isAvailable]) {
		CBUUID* primaly_service_UUID=[CBUUID UUIDWithString:self.UUIDStr];
		CBMutableService *services=[[CBMutableService alloc] initWithType:primaly_service_UUID primary:YES];        
		[self.manager addService:services];

        // maximun twitter user name length seems to be 15 characters
        uint8_t encodedCData[ENCODED_UNAME_LEN];
        NSData *encodedData = [self.userName dataAnonyFollowEncoded];
        [encodedData getBytes:encodedCData];
        assert([encodedData length]==ENCODED_UNAME_LEN);
        NSMutableArray *UUIDsArray=[NSMutableArray arrayWithObjects:primaly_service_UUID,nil];
        
        for(int index=0;index<(int)(ENCODED_UNAME_LEN/2);index ++){
            CBUUID *tmp=[CBUUID UUIDWithData:[NSData dataWithBytes:&encodedCData[2*index+0] length:2]];
            [UUIDsArray addObject:tmp];
        }
        NSDictionary *adDict=[NSDictionary dictionaryWithObjectsAndKeys:
							  UUIDsArray,			@"kCBAdvDataServiceUUIDs",
                              @"",                  @"kCBAdvDataLocalName",
							  nil];
		[self.manager startAdvertising:adDict];
        NSLog(@"startAdvertize %d,%d,%@,%s",[encodedData length],[self.userName length],self.userName,encodedCData);
    }
	else{
    }
    DNSLogMethod
}

- (void)stopAdvertize {
    [self.manager stopAdvertising];
}

#pragma mark - CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager*)manager{
	[self logState];
	[self startAdvertize];
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager*)manager error:(NSError *)error{
	DNSLogMethod
}

- (void)peripheralManager:(CBPeripheralManager*)manager didAddService:(CBService *)service error:(NSError *)error{
	DNSLogMethod
}

- (void)peripheralManager:(CBPeripheralManager*)manager central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
	DNSLogMethod
}

- (void)peripheralManager:(CBPeripheralManager*)manager central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
	DNSLogMethod
}

- (void)peripheralManager:(CBPeripheralManager*)manager didReceiveReadRequest:(CBATTRequest *)request{
	DNSLogMethod
}

- (void)peripheralManager:(CBPeripheralManager*)manager didReceiveWriteRequests:(NSArray *)requests{
	DNSLogMethod
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager*)manager{
	DNSLogMethod
}

@end
