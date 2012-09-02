//
//  BinarySearcher.h
//  AnonyFollow
//
//  Created by Sekikawa Yusuke on 9/2/12.
//  Copyright (c) 2012 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BinarySearcher : NSObject{
    NSMutableArray *db_key;
    NSMutableArray *db_obj;
}
@property (nonatomic, strong) NSMutableArray *db_key;
@property (nonatomic, strong) NSMutableArray *db_obj;

- (id)initWithDB:(NSMutableArray*)key andObj:(NSMutableArray*)obj;
- (BOOL)isKeyExist:(NSNumber*)queryTwitterID;
- (id)objectWithKey:(NSNumber*)queryTwitterID;
@end
