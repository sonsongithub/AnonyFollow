//
//  MyPinAnnotationView.m
//  AnonyFollow
//
//  Created by sonson on 2012/10/30.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "MyPinAnnotationView.h"

#import "TwitterAccountInfo.h"

@implementation MyPinAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
	if (self) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDownloadedIcon:) name:AccountCellUpdateNotification object:nil];
	}
	return self;
}

- (void)didDownloadedIcon:(NSNotification*)notification {
	TwitterAccountInfo *info = self.annotation;
	UIImageView *img = [[UIImageView alloc] initWithImage:info.iconImage];
	img.frame = CGRectMake(0, 0, 22, 22);
	self.leftCalloutAccessoryView = img;
}

@end
