//
//  BinarySearcher.m
//  AnonyFollow
//
//  Created by Sekikawa Yusuke on 9/2/12.
//  Copyright (c) 2012 Y.Yoshida,Y.Sekikawa. All rights reserved.
//


#import "BinarySearcher.h"

@implementation BinarySearcher
@synthesize db_key;
@synthesize db_obj;


- (id)initWithDB:(NSMutableArray*)key andObj:(NSMutableArray*)obj {
	self = [super init];
	if (self) {
        if([key count]!=[obj count]){
            NSLog(@"ERROR[BinarySearcher]:key and obj lenght must be same");
            return nil;
        }
		self.db_key = key;
		self.db_obj = obj;
        [self.db_key sortUsingComparator:[self compareNSNumber]];

	}
    return self;
}

-(NSComparisonResult (^) (id lhs, id rhs))compareNSNumber{
    return ^(id lhs, id rhs)
    {
        //NSLog(@"compareNSNumber,%lld,%lld",[lhs longLongValue],[rhs longLongValue]);
        return [lhs longLongValue] < [rhs longLongValue] ? (NSComparisonResult)NSOrderedAscending : [lhs longLongValue] > [rhs longLongValue] ? (NSComparisonResult)NSOrderedDescending : (NSComparisonResult)NSOrderedSame;
    };
}

- (BOOL)isKeyExist:(NSNumber*)queryTwitterID{
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];    
    NSInteger  index= [self.db_key indexOfObject:queryTwitterID
                                   inSortedRange:NSMakeRange(0, [self.db_key count])
                                         options:NSBinarySearchingFirstEqual
                                 usingComparator:[self compareNSNumber]];
    NSTimeInterval stop1 = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"Binary: Found index position: %d in %f seconds.", index, stop1 - start);
    if(index!=NSIntegerMax){
        return true;
    }else{
        return false;
    }
}
- (id)objectWithKey:(NSNumber*)queryTwitterID{
    if(self.db_obj==nil){
        return nil;
    }
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];    
    NSInteger  index= [self.db_key indexOfObject:queryTwitterID
                                  inSortedRange:NSMakeRange(0, [self.db_key count])
                                        options:NSBinarySearchingFirstEqual
                                usingComparator:[self compareNSNumber]];
    NSTimeInterval stop1 = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"Binary: Found index position: %d in %f seconds.", index, stop1 - start);
    if(index!=NSIntegerMax){
        return [self.db_obj objectAtIndex:index];
    }else{
        return nil;
    }
}
@end
