//
//  CBScanner.h
//  AnonyFollow
//
//  Created by Sekikawa Yusuke on 8/23/12.
//  Copyright (c) 2012 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "CBAdvertizer.h"

// #define CBScannerAllowDuplicates
/* Commnet out <code>CBScannerAllowDuplicates<\code> to call <code>- (void)scanner:(CBScanner*)scanner didDiscoverUser:(NSDictionary*)userInfo;<\code> eveytime scanner found the service.May have an adverse effect on battery life */

extern NSString *kCBScannerInfoUserNameKey;

@class CBScanner;

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
- (void)scanner:(CBScanner*)scanner didDiscoverUser:(NSDictionary*)userInfo;
- (void)scannerDidChangeStatus:(CBScanner*)scanner;
@end

@interface CBScanner : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic, strong) id<CBScannerDelegate> delegate;
@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, copy) NSString *UUIDStr;
@property (nonatomic, retain) CBPeripheral *peripheral;

- (id)initWithDelegate:(id<CBScannerDelegate>)delegate serviceUUID:(NSString*)UUIDStr;
- (void)startScan;
- (void)stopScan;
- (BOOL)isAvailable;

@end
