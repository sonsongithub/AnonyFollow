//
//  CBScanner.h
//  AnonyFollow
//
//  Created by Sekikawa Yusuke on 8/23/12.
//  Copyright (c) 2012 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>


typedef NS_ENUM(NSInteger, CBScannerState) {
	CBScannerStateUnknown = 0,
	CBScannerStateResetting,
	CBScannerStateUnsupported,
	CBScannerStateUnauthorized,
	CBScannerStatePoweredOff,
    CBScannerStatePoweredOnIdling,
    CBScannerStatePoweredOnScaning,
} NS_ENUM_AVAILABLE(NA, 6_0);

@protocol CBScannerDelegate <NSObject>
-(void)CBScannerDidDiscoverUser:(NSString*)userName;
-(void)CBScannerDidCangeState:(CBScannerState)state;
@end

@interface CBScanner : NSObject<CBCentralManagerDelegate>{
    id<CBScannerDelegate> delegate;
    NSString *UUIDStr;
    CBCentralManager *c_manager;
}
@property (retain) id<CBScannerDelegate> delegate;
@property (retain) CBCentralManager *c_manager;
@property (copy) NSString *UUIDStr;
-(id)initinitWithDelegate:(id<CBScannerDelegate>)_delegate ServiceUUIDStr:(NSString*)_UUIDStr;
-(CBScannerState)sartScan;
-(CBScannerState)stopScan;
@end
