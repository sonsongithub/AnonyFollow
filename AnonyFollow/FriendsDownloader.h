//
//  FriendsDownloader.h
//  AnonyFollow
//
//  Created by sonson on 2012/09/02.
//  Copyright (c) 2012年 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^blk_t)(BOOL);

@interface FriendsDownloader : NSObject

@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) blk_t blk;

- (void)startWithScreenName:(NSString*)screenName completion:(void (^)(BOOL))blk;

@end
