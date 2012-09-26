//
//  CBAdvertizer.h
//  AnonyFollow
//
//  Created by Sekikawa Yusuke on 8/23/12.
//  Copyright (c) 2012 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

// NOTE:make shure ENCODED_UNAME_LEN can be devided by 2 and smaller than 28
#define ENCODED_UNAME_LEN (16)
#define UNAME_MAX_LEN     (15)
#define USER_NAME_CHARACTRISTIC_UUID     @"fff1"


typedef NS_ENUM(NSInteger, CBAdvertizerState) {
	CBAdvertizerStateUnknown = 0,
	CBAdvertizerStateResetting,
	CBAdvertizerStateUnsupported,
	CBAdvertizerStateUnauthorized,
	CBAdvertizerStatePoweredOff,
    CBAdvertizerStatePoweredOnIdling,
    CBAdvertizerStatePoweredOnAdvertizeing,
} NS_ENUM_AVAILABLE(NA, 6_0);

@class CBAdvertizer;

@protocol CBAdvertizerDelegate <NSObject>
- (void)advertizerDidChangeStatus:(CBAdvertizer*)advertizer;
@end

@interface CBAdvertizer : NSObject<CBPeripheralManagerDelegate>

- (id)initWithDelegate:(id<CBAdvertizerDelegate>)delegate userName:(NSString*)userName serviceUUID:(NSString*)UUIDStr;
- (void)startAdvertize;
- (void)stopAdvertize;

@property (nonatomic, strong) id<CBAdvertizerDelegate> delegate;
@property (nonatomic, strong) CBPeripheralManager *manager;
@property (nonatomic, copy) NSString *userName;
@property (nonatomic, copy) NSString *UUIDStr;

@end
