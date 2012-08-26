//
//  AccountCell.m
//  AnonyFollow
//
//  Created by sonson on 2012/08/26.
//  Copyright (c) 2012年 sonson. All rights reserved.
//

#import "AccountCell.h"

@implementation AccountCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	[self prepareForReuse];
}

- (void)prepareForReuse {
	[super prepareForReuse];
	
	UIImage *image = [UIImage imageNamed:@"PurchasePlusButton.png"];
	UIImage *strechable = [image stretchableImageWithLeftCapWidth:10 topCapHeight:10];
	[self.followButton setBackgroundImage:strechable forState:UIControlStateNormal];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
