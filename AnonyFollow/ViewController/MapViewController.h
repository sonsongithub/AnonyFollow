//
//  MapViewController.h
//  AnonyFollow
//
//  Created by sonson on 2012/10/26.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class TwitterAccountInfo;

@interface MapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) NSMutableArray *accounts;
@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) TwitterAccountInfo *savedAccountInfo;

@end
