//
//  CBAdvertizer.m
//  AnonyFollow
//
//  Created by Sekikawa Yusuke on 8/23/12.
//  Copyright (c) 2012 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "CBAdvertizer.h"
#define PRIMALY_SERVICE_UUID @"1802"
@implementation CBAdvertizer
@synthesize p_manager;
@synthesize userName;
@synthesize delegate;
-(id)initWithUserName:(NSString*)_userName{
    self.userName=_userName;
    self.p_manager=[[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
    return [super init];
}

#pragma PERIPHERAL
- (void)advertise:(CBPeripheralManager*)manager withUserName:(NSString*)userName{
    CBUUID* primaly_service_UUID=[CBUUID UUIDWithString:PRIMALY_SERVICE_UUID];
    CBMutableService *services=[[CBMutableService alloc] initWithType:primaly_service_UUID primary:YES];
    [manager addService:services];
    NSArray *UUIDsArray=[NSArray arrayWithObjects:primaly_service_UUID,nil];
    NSDictionary *adDict=[NSDictionary dictionaryWithObjectsAndKeys:
                          UUIDsArray,@"kCBAdvDataServiceUUIDs",
                          @"yusukeSekikawa",@"kCBAdvDataLocalName",
                          nil];
    [manager startAdvertising:adDict];
}

#pragma CBPeripheralmanagerdelegate
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager*)manager{
    //NSLog(@"peripheral managerDidUpdateState %d",manager.state);
    if([self isLECapableHardware:manager]){
        [self advertise:manager withUserName:userName];
        [self.delegate CBAdvertizerDidCangeState:CBAdvertizerStatePoweredOnAdvertizeing];
    }else{
        [self.delegate CBAdvertizerDidCangeState:[p_manager state]];
    }
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager*)manager error:(NSError *)error{
    NSLog(@"peripheralc_managerDidStartAdvertising %@",error);
}

- (void)peripheralManager:(CBPeripheralManager*)manager didAddService:(CBService *)service error:(NSError *)error{
    NSLog(@"peripheralc_managerdidAddService");
    
}

- (void)peripheralManager:(CBPeripheralManager*)manager central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic{
    NSLog(@"peripheralc_managercentral didSubscribeToCharacteristic %@",characteristic.UUID);
}

- (void)peripheralManager:(CBPeripheralManager*)manager central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic{
    NSLog(@"peripheralc_managercentral didUnsubscribeFromCharacteristic %@",characteristic.UUID);
}


- (void)peripheralManager:(CBPeripheralManager*)manager didReceiveReadRequest:(CBATTRequest *)request{
    NSLog(@"peripheralManagerd idReceiveReadRequest %d",manager.isAdvertising);
}

- (void)peripheralManager:(CBPeripheralManager*)manager didReceiveWriteRequests:(NSArray *)requests{
    NSLog(@"peripheralc_managerdidReceiveWriteRequests %d",manager.isAdvertising);
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager*)manager{
    NSLog(@"peripheralc_managerIsReadyToUpdateSubscribers %d",manager.isAdvertising);
}
- (BOOL) isLECapableHardware:(CBPeripheralManager*)manager
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
    NSLog( @"CBPeripheralManager State:%@",state);
    return FALSE;
}
-(CBAdvertizerState)sartAdvertize{
    if([self isLECapableHardware:self.p_manager]){
        [self advertise:self.p_manager withUserName:self.userName];
        return CBAdvertizerStatePoweredOnAdvertizeing;
    }else{
        return [self.p_manager state];
    }
}
-(CBAdvertizerState)stopAdvertize{
    [self.p_manager stopAdvertising];
    return CBAdvertizerStatePoweredOnIdling;
}

@end
