//
//  TwitterAccountInfo.h
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

// Private invariables
//extern NSString *TwitterAccountInfoCoderScreenNameKey;
//extern NSString *TwitterAccountInfoCoderUserIDKey;
//extern NSString *TwitterAccountInfoCoderFoundTimeKey;
//extern NSString *TwitterAccountInfoCoderFoundPlaceLatitudeKey;
//extern NSString *TwitterAccountInfoCoderFoundPlaceLongitudeKey;

@class DownloadTask;

@interface TwitterAccountInfo : NSObject

@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) UIImage *iconImage;

@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *URLString;
@property (nonatomic, strong) NSString *name;

@property (nonatomic, assign) NSTimeInterval foundTime;
@property (nonatomic, assign) CLLocationCoordinate2D foundCoordinate;

- (DownloadTask*)taskForUserTimeline;
- (DownloadTask*)taskForUserInfo;
- (BOOL)tryToDownloadIconImage;

@end
