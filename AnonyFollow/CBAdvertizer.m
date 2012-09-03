//
//  CBAdvertizer.m
//  AnonyFollow
//
//  Created by Sekikawa Yusuke on 8/23/12.
//  Copyright (c) 2012 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "CBAdvertizer.h"
#define PRIMALY_SERVICE_UUID @"1802"
#define ENABLE_BG_ADVERTIZE

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
	self.delegate = delegate;
    self.manager = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    return [super init];
}

- (BOOL)isAvailable {
	return (self.manager.state == CBPeripheralManagerStatePoweredOn);
}

- (void)didEnterBackgroundNotification:(NSNotification*)notification {
	//[self stopAdvertize];
    DNSLogMethod
}

- (void)startAdvertize{
    if ([self isAvailable]) {
		CBUUID* primaly_service_UUID=[CBUUID UUIDWithString:self.UUIDStr];
		CBMutableService *services=[[CBMutableService alloc] initWithType:primaly_service_UUID primary:YES];
        
        CBMutableService *services_02=[[CBMutableService alloc] initWithType:[CBUUID UUIDWithString:@"1800"] primary:YES];
		[self.manager addService:services];
        [self.manager addService:services_02];

#ifdef ENABLE_BG_ADVERTIZE
#define MAX_SERVICE (28-2)
        // maximun twitter user name length seems to be 15 characters(http://www.mediabistro.com/alltwitter/tag/maximum-username-length-on-twitter)
        char char_name[MAX_SERVICE];
        for(int i=0;i<(MAX_SERVICE-1);i++){
            char_name[i]=' ';
        }
        char_name[MAX_SERVICE-1]='\n';
        memcpy(char_name, [self.userName cStringUsingEncoding:NSASCIIStringEncoding], [self.userName length]);
        //NSLog(@"char_name: %s,%d",char_name,[self.userName length]);
        NSMutableArray *UUIDsArray=[NSMutableArray arrayWithObjects:primaly_service_UUID,nil];        
        for(int index=0;index<(int)(MAX_SERVICE/2);index ++){
            [UUIDsArray addObject:[CBUUID UUIDWithData:[NSData dataWithBytes:&char_name[2*index] length:2]]];
        }
        NSDictionary *adDict=[NSDictionary dictionaryWithObjectsAndKeys:
                              //UUIDsArray,			@"CBAdvertisementDataServiceUUIDsKey",
							  //self.userName,		@"CBAdvertisementDataLocalNameKey",
							  UUIDsArray,			@"kCBAdvDataServiceUUIDs",
							  @"",                  @"kCBAdvDataLocalName",
							  nil];
#if 0
        CBMutableCharacteristic *test_characteristics_01=
        [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:@"0f11"] properties:CBCharacteristicPropertyBroadcast value:[NSData dataWithBytes:char_name length:MAX_SERVICE] permissions:CBAttributePermissionsReadable];
        NSArray *c_a=[NSArray arrayWithObjects:test_characteristics_01,nil];
        [services setCharacteristics:c_a];
#endif
        
#else
        NSMutableArray *UUIDsArray=[NSMutableArray arrayWithObjects:primaly_service_UUID,nil];
        NSDictionary *adDict=[NSDictionary dictionaryWithObjectsAndKeys:
							  UUIDsArray,			@"kCBAdvDataServiceUUIDs",
							  self.userName,        @"kCBAdvDataLocalName",
							  nil];
#endif
		[self.manager startAdvertising:adDict];
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
