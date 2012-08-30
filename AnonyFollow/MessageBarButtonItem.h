//
//  MessageBarButtonItem.h
//  AnonyFollow
//
//  Created by sonson on 2012/08/28.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessageBarButtonItem;

@interface NSObject(MessageBarButtonItem)
- (void)didTouchMessageBarButtonItem:(MessageBarButtonItem*)item;
@end

@interface MessageBarButtonItem : UIBarButtonItem

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, assign) id delegate;

- (void)setTwitterAccountUserName:(NSString*)string;

@end
