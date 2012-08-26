//
//  TimerLengthViewController.m
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import "TimerLengthViewController.h"

#import "TimerLengthController.h"

@interface TimerLengthViewController ()

@end

@implementation TimerLengthViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[TimerLengthController timerLengthTitles] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
	cell.textLabel.text = [[TimerLengthController timerLengthTitles] objectAtIndex:indexPath.row];
	
	if ([cell.textLabel.text isEqualToString:[TimerLengthController currentTimerLengthTitle]])
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[TimerLengthController setCurrentTimerLength:indexPath.row];
	[self.tableView reloadData];
}

@end
