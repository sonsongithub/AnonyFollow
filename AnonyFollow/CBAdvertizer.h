//
//  CBAdvertizer.h
//  AnonyFollow
//
//  Created by Sekikawa Yusuke on 8/23/12.
//  Copyright (c) 2012 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface CBAdvertizer : NSObject<CBPeripheralManagerDelegate>{
    NSString *userName;
    CBPeripheralManager *p_manager;
}
-(id)initWithUserName:(NSString*)_userName;
@property (retain) CBPeripheralManager *p_manager;

@end
