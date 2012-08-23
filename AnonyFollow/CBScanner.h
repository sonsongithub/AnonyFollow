//
//  CBScanner.h
//  AnonyFollow
//
//  Created by Sekikawa Yusuke on 8/23/12.
//  Copyright (c) 2012 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol CBScannerDelegate <NSObject>
-(void)CBScannerDidDiscoverUser:(NSString*)userName;
@end

@interface CBScanner : NSObject<CBCentralManagerDelegate>{
    id<CBScannerDelegate> delegate;
    NSString *UUIDStr;
    CBCentralManager *c_manager;
}
@property (retain) id<CBScannerDelegate> delegate;
@property (retain) CBCentralManager *c_manager;
-(id)initinitWithDelegate:(id<CBScannerDelegate>)_delegate ServiceUUIDStr:(NSString*)_UUIDStr;
@end
