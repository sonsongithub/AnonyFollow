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
        self.peripherals= [[NSMutableArray alloc] initWithCapacity:0];
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
    NSMutableArray *hashedServices = [advertisementData objectForKey:CBAdvertisementDataOverflowServiceUUIDsKey];
    NSMutableData *encodedData=[NSMutableData dataWithCapacity:ENCODED_UNAME_LEN];
    CBUUID *hashedPrimalyServiceUUID=[hashedServices objectAtIndex:0];

    if([services count]!=(ENCODED_UNAME_LEN/2)+1){
        /* Peripheral may be in foreground */
        if(hashedPrimalyServiceUUID && [hashedPrimalyServiceUUID isEqual:[CBUUID UUIDWithString:self.UUIDStr]]){
            DNSLog(@"Peer discovered but maybe in Backgroud:%@,aPeripheral.UUID:%@",advertisementData,aPeripheral.UUID);
            [self.peripherals addObject:aPeripheral];
            [self.manager connectPeripheral:aPeripheral options:nil];
        }
    }else{
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
}
/*
 Invoked when the central manager retrieves the list of known peripherals.
 Automatically connect to first known peripheral
 */
#if 0
- (void) centralManager:(CBCentralManager *)central
 didRetrievePeripherals:(NSArray *)retrievedPeripherals
{
    DNSLogMethod
    CBPeripheral *firstPeripheral=[retrievedPeripherals objectAtIndex:0];
    DNSLog(@"Retrieved peripheral: %u,%@,%@,%@", [retrievedPeripherals count], retrievedPeripherals,firstPeripheral.description,firstPeripheral.UUID);
    /* If there are any known devices, automatically connect to it.*/
    if(firstPeripheral){
        [self.peripherals addObject:[retrievedPeripherals objectAtIndex:0]];
        [self.manager connectPeripheral:firstPeripheral options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    }
}
#endif
/*
 Invoked whenever a connection is succesfully created with the peripheral.
 Discover available services on the peripheral
 */
- (void) centralManager:(CBCentralManager *)central
   didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    DNSLogMethod
    [aPeripheral setDelegate:self];
    [aPeripheral discoverServices:[NSArray arrayWithObject:[CBUUID UUIDWithString:self.UUIDStr]]];
    
}


/*
 Invoked whenever an existing connection with the peripheral is torn down.
 Reset local variables
 */
- (void) centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)aPeripheral
                  error:(NSError *)error
{
    DNSLogMethod
}

/*
 Invoked whenever the central manager fails to create a connection with the peripheral.
 */
- (void) centralManager:(CBCentralManager *)central
didFailToConnectPeripheral:(CBPeripheral *)aPeripheral
                  error:(NSError *)error
{
    DNSLog(@"Fail to connect to peripheral: %@ with error = %@", aPeripheral, [error localizedDescription]);
}

#pragma mark - CBPeripheral delegate methods
/*
 Invoked upon completion of a -[discoverServices:] request.
 Discover available characteristics on interested services
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverServices:(NSError *)error
{
    DNSLogMethod
    for (CBService *aService in aPeripheral.services)
    {
        DNSLog(@"Service found with UUID: %@", aService.UUID);
        
        if ([aService.UUID isEqual:[CBUUID UUIDWithString:self.UUIDStr]])
        {
            [aPeripheral discoverCharacteristics:[NSArray arrayWithObject:[CBUUID UUIDWithString:USER_NAME_CHARACTRISTIC_UUID]] forService:aService];
            DNSLog(@"found PRIMALY_SERVICE_UUID");
        }
    }
}

/*
 Invoked upon completion of a -[discoverCharacteristics:forService:] request.
 Perform appropriate operations on interested characteristics
 */
- (void) peripheral:(CBPeripheral *)aPeripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    DNSLogMethod
    BOOL hasPreferredCharacteristic=NO;
    if ( [service.UUID isEqual:[CBUUID UUIDWithString:self.UUIDStr]] )
    {
        for (CBCharacteristic *aChar in service.characteristics)
        {
            /* Read device name */
            if ([aChar.UUID isEqual:[CBUUID UUIDWithString:USER_NAME_CHARACTRISTIC_UUID]])
            {
                [aPeripheral readValueForCharacteristic:aChar];
                hasPreferredCharacteristic=TRUE;
                DNSLog(@"Found AnonyFollow username characteristic");
            }
        }
    }
    if(!hasPreferredCharacteristic){
        DNSLog(@"Connected Periphel does NOT has preferred Serivices %@",USER_NAME_CHARACTRISTIC_UUID);
        [self.manager cancelPeripheralConnection:aPeripheral];
    }
}

- (void) peripheral:(CBPeripheral *)aPeripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    DNSLogMethod
    [self.manager cancelPeripheralConnection:aPeripheral];
    [self.peripherals removeObject:aPeripheral];
    /* USER_NAME_CHARACTRISTIC_UUID */
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:USER_NAME_CHARACTRISTIC_UUID]])
    {
        NSData * updatedValue = characteristic.value;
        if([updatedValue length]==ENCODED_UNAME_LEN)
        {
            NSString *userName = [NSString stringWithAnonyFollowEncodedData:updatedValue key:KEY_ANONYFOLLOW	];
            userName = [userName stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            if ([userName length]) {
                DNSLog(@"Peer discovered (with connection) UUID:%@,userName:%@", aPeripheral.UUID, userName);
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                          userName, kCBScannerInfoUserNameKey,
                                          nil];
                
                if ([self.delegate respondsToSelector:@selector(scanner:didDiscoverUser:)])
                    [self.delegate scanner:self didDiscoverUser:userInfo];
            }
        }
        
    }
}
@end
