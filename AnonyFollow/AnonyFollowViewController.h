//
//  AnonyFollowViewController.h
//  AnonyFollow
//
//  Created by Sekikawa Yusuke on 8/23/12.
//  Copyright (c) 2012 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CBAdvertizer.h"
#import "CBScanner.h"
@interface AnonyFollowViewController : UIViewController<CBScannerDelegate>{
    NSString *twitterUserName;
    NSString *twitterUserID;
    
    CBAdvertizer *advertizer;
    CBScanner    *scanner;
}
@property (retain) CBAdvertizer *advertizer;
@property (retain) CBScanner *scanner;
@property (copy) NSString *twitterUserName;
@property (copy) NSString *twitterUserID;

@end
