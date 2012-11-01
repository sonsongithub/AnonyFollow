//
//  HistoryViewController.m
//  AnonyFollow
//
//  Created by sonson on 2012/10/31.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "HistoryViewController.h"

#import "TwitterAccountInfo.h"

#import "AppDelegate.h"
#import "SNReachablityChecker.h"

#import <QuartzCore/QuartzCore.h>

#import "MyPinAnnotationView.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
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

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (!self.isAlreadyLoadded) {
		self.isAlreadyLoadded = YES;
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
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		
	});
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back:(id)sender {
	[UIView animateWithDuration:0.4
					 animations:^(void) {
						 {
							 NSLog(@"%f", self.tableView.frame.size.height);
							 self.baseViewHeightConstraint.constant = 240;
							 [self.view layoutIfNeeded];
						 }
					 }
					 completion:^(BOOL finished) {
						 self.navigationItem.leftBarButtonItem = nil;
					 }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	TwitterAccountInfo *annotation = [self.accounts objectAtIndex:indexPath.row];
	
	NSArray *selectedAnnotations = [self.mapView selectedAnnotations];
	
	for (id obj in selectedAnnotations) {
		[self.mapView deselectAnnotation:obj animated:YES];
	}
	NSArray *annotations = [self.mapView annotations];
	
	int idx = [annotations indexOfObject:annotation];
	
	[UIView animateWithDuration:0.4
					 animations:^(void) {
						 self.baseViewHeightConstraint.constant = self.view.frame.size.height;
						 [self.view layoutIfNeeded];
					 }
					 completion:^(BOOL finished) {
						 self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil)
																								  style:UIBarButtonItemStyleBordered
																								 target:self action:@selector(back:)];
						 
						 if (idx != NSNotFound) {
							 [self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
							 [self.mapView selectAnnotation:annotation animated:YES];
						 }
					 }];
}

@end
