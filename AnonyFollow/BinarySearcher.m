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

+ (void)test {
    // create twitter following DB
    NSUInteger amount = 10000;
    NSMutableArray *followingDB = [NSMutableArray arrayWithCapacity:amount];
    
    for (NSUInteger i = 0; i < amount-2; ++i)
        [followingDB addObject:[NSNumber numberWithLongLong:i*2000000]];
    
    [followingDB addObject:[NSNumber numberWithLongLong:75743284]];//yusukeSekikawa
    [followingDB addObject:[NSNumber numberWithLongLong:9677332]]; //sonson_twit
    
    for(NSNumber *hoge in followingDB)
        ;//NSLog(@"hoge %lld",[hoge longLongValue]);
    BinarySearcher *testSearcher =[[BinarySearcher alloc] initWithDB:followingDB andObj:followingDB];
    for(NSNumber *hoge in followingDB)
        ;//NSLog(@"hoge %lld",[hoge longLongValue]);
    // Do binary Search!
    if([testSearcher isKeyExist:[NSNumber numberWithLongLong:75743284]]){
        NSLog(@"Already following");
    }else{
        NSLog(@"Not following");
    }
}

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
