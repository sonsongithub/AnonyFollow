//
//  CBScanner.m
//  AnonyFollow
//
//  Created by Sekikawa Yusuke on 8/23/12.
//  Copyright (c) 2012 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "CBScanner.h"

@implementation CBScanner
@synthesize delegate;
@synthesize c_manager;
@synthesize UUIDStr;

-(id)initinitWithDelegate:(id<CBScannerDelegate>)_delegate ServiceUUIDStr:(NSString*)_UUIDStr{
    self.UUIDStr=_UUIDStr;
    self.delegate=_delegate;
    c_manager=[[CBCentralManager alloc] initWithDelegate:self queue:nil];
    return [super init];    
}

#pragma PERIPHERAL
- (void)scan:(CBCentralManager*)manager WithServices:(NSString*)_UUIDStr
{
    NSLog(@"Start Scan..%@",_UUIDStr);
    if(_UUIDStr){
        NSArray *services=[NSArray arrayWithObjects:
                           [CBUUID UUIDWithString:_UUIDStr],
                           nil];
        [manager scanForPeripheralsWithServices:services options:nil];
    }else{
        [manager scanForPeripheralsWithServices:nil options:nil];
    }
}

#pragma CBPeripheralmanagerdelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)manager{
    //NSLog(@"centrallManagerDidUpdateState %d",manager.state);
    if([self isLECapableHardware:manager]){
        [self scan:manager WithServices:UUIDStr];
        [self.delegate CBScannerDidCangeState:CBScannerStatePoweredOnScaning];
    }else{
        [self.delegate CBScannerDidCangeState:[manager state]];
    }
}

- (void) centralManager:(CBCentralManager*)manager didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSArray *services=[advertisementData objectForKey:@"kCBAdvDataServiceUUIDs"];
    NSString *userName=[advertisementData objectForKey:@"kCBAdvDataLocalName"];

    NSLog(@"Peripheral discovered %@ %@,%@,Name:%@,%d",RSSI,aPeripheral.UUID,advertisementData,userName,[services count]);
    [self.delegate CBScannerDidDiscoverUser:userName];
}


- (BOOL) isLECapableHardware:(CBCentralManager*)manager
{
    NSString * state = nil;
    switch ([manager state])
    {
        case CBPeripheralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBPeripheralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBPeripheralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
        case CBPeripheralManagerStateResetting:
            state = @"Bluetooth is currently resetting.";
            break;
        case CBPeripheralManagerStatePoweredOn:
            NSLog( @"Bluetooth is currently powered on.");
            return TRUE;
        case CBPeripheralManagerStateUnknown:
        default:
            state = @"Bluetooth is unknown.";
            break;
            
    }
    NSLog( @"CBCentralManager State:%@",state);
    return FALSE;
}

-(CBScannerState)sartScan{
    if([self isLECapableHardware:self.c_manager]){
        [self scan:self.c_manager WithServices:self.UUIDStr];
        return CBScannerStatePoweredOnScaning;
    }else{
        return [self.c_manager state];
    }
}
-(CBScannerState)stopScan{
    [self.c_manager stopScan];
    return CBScannerStatePoweredOnIdling;
}

@end
