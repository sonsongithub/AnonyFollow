//
//  HelpViewController.m
//  AnonyFollow
//
//  Created by sonson on 2012/10/01.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//	
//	CGRect r = self.view.frame;
//	
//	r.origin.y = 0;
//	
//	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:r];
//	scrollView.pagingEnabled = YES;
//	scrollView.backgroundColor = [UIColor clearColor];
//	[self.view addSubview:scrollView];
//	
//	
//	[scrollView addSubview:self.container1];
//	self.container1.frame = r;
//	
//	r.origin.x += r.size.width;
//	[scrollView addSubview:self.container2];
//	self.container2.frame = r;
//	
//	[scrollView setContentSize:CGSizeMake(r.origin.x + r.size.width, r.size.height)];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.scrollView setContentSize:CGSizeMake(320 * 4, 416)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
