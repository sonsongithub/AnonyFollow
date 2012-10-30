//
//  MapViewController.m
//  AnonyFollow
//
//  Created by sonson on 2012/10/26.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "MapViewController.h"

#import "TwitterAccountInfo.h"
#import "MyPinAnnotationView.h"
#import "AppDelegate.h"
#import "SNReachablityChecker.h"
#import "TimeLineViewController.h"

@interface MapViewController ()

@end

@implementation MapViewController

#pragma mark - Lifecylcle

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	if ([segue.destinationViewController isKindOfClass:[TimeLineViewController class]]) {
		TimeLineViewController *vc = (TimeLineViewController*)segue.destinationViewController;
		vc.accountInfo = self.savedAccountInfo;
		self.savedAccountInfo = nil;
	}
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	// Do any additional setup after loading the view.
	double centerLatitude = 0, centerLongitude = 0;
	float minLatitude = 360, maxLatitude = -360;
	float minLongitude = 360, maxLongitude = -360;
	
	for (TwitterAccountInfo *info in self.accounts) {
		if (minLatitude > info.coordinate.latitude)
			minLatitude = info.coordinate.latitude;
		if (maxLatitude < info.coordinate.latitude)
			maxLatitude = info.coordinate.latitude;
		
		if (minLongitude > info.coordinate.longitude)
			minLongitude = info.coordinate.longitude;
		if (maxLongitude < info.coordinate.longitude)
			maxLongitude = info.coordinate.longitude;
		
		centerLatitude += info.coordinate.latitude;
		centerLongitude += info.coordinate.longitude;
	}
	
	centerLatitude /= [self.accounts count];
	centerLongitude /= [self.accounts count];
	
	MKCoordinateRegion region = MKCoordinateRegionMake(
													   CLLocationCoordinate2DMake(centerLatitude, centerLongitude),
													   MKCoordinateSpanMake(fabs(maxLatitude - minLatitude), fabs(maxLongitude - minLongitude))
													   );
	[self.mapView setRegion:region animated:YES];
	
	[self.mapView addAnnotations:self.accounts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
	DNSLogMethod
	AppDelegate *del = (AppDelegate*)[UIApplication sharedApplication].delegate;
	if (del.checker.status == SNReachablityCheckerReachableViaWiFi || del.checker.status == SNReachablityCheckerReachableViaWWAN) {
		self.savedAccountInfo = view.annotation;
		[self performSegueWithIdentifier:@"OpenTimeLine" sender:nil];
	}
}

- (MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
	MKPinAnnotationView *annotationView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"default"];
	
	if (annotationView == nil) {
		annotationView = [[MyPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"default"];
	}
	else {
		annotationView.annotation = annotation;
	}
	
	TwitterAccountInfo *info = (TwitterAccountInfo*)annotation;
	
	[info tryToDownloadIconImage];

	UIImageView *img = [[UIImageView alloc] initWithImage:info.iconImage];
	img.frame = CGRectMake(0, 0, 22, 22);
	annotationView.leftCalloutAccessoryView = img;
	annotationView.canShowCallout = YES;
	annotationView.animatesDrop = YES;
	annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	
	return annotationView;
}

@end
