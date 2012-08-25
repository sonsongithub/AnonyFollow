//
//  CBAdvertizer.h
//  AnonyFollow
//
//  Created by Sekikawa Yusuke on 8/23/12.
//  Copyright (c) 2012 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef NS_ENUM(NSInteger, CBAdvertizerState) {
	CBAdvertizerStateUnknown = 0,
	CBAdvertizerStateResetting,
	CBAdvertizerStateUnsupported,
	CBAdvertizerStateUnauthorized,
	CBAdvertizerStatePoweredOff,
    CBAdvertizerStatePoweredOnIdling,
    CBAdvertizerStatePoweredOnAdvertizeing,
} NS_ENUM_AVAILABLE(NA, 6_0);

@protocol CBAdvertizerDelegate <NSObject>
-(void)CBAdvertizerDidCangeState:(CBAdvertizerState)state;
@end

@interface CBAdvertizer : NSObject<CBPeripheralManagerDelegate>{
    id<CBAdvertizerDelegate> delegate;
    NSString *userName;
    CBPeripheralManager *p_manager;
}
-(id)initWithUserName:(NSString*)_userName;
-(CBAdvertizerState)sartAdvertize;
-(CBAdvertizerState)stopAdvertize;
@property (retain) id<CBAdvertizerDelegate> delegate;
@property (retain) CBPeripheralManager *p_manager;
@property (copy) NSString *userName;
@end
