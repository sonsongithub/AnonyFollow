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

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	int page = scrollView.contentOffset.x / scrollView.frame.size.width;
	[self.pageControl setCurrentPage:page];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width * 5, self.view.frame.size.height)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
