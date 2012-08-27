//
//  LockScreenView.m
//  AnonyFollow
//
//  Created by sonson on 2012/08/27.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "LockScreenView.h"

@implementation LockScreenView

- (void)awakeFromNib {
    [[NSBundle mainBundle] loadNibNamed:@"LockScreenView" owner:self options:nil];
	[self addSubview:self.contentView];
}

@end
