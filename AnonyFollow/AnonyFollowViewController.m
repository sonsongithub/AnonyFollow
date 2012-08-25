//
//  AnonyFollowViewController.m
//  AnonyFollow
//
//  Created by Sekikawa Yusuke on 8/23/12.
//  Copyright (c) 2012 Y.Yoshida,Y.Sekikawa. All rights reserved.
//

#import "AnonyFollowViewController.h"
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import <AudioToolbox/AudioServices.h>


@interface AnonyFollowViewController ()

@end

@implementation AnonyFollowViewController
@synthesize scanner;
@synthesize advertizer;
@synthesize twitterUserID;
@synthesize twitterUserName;

- (void)followOnTwitter:(NSString*)userName
{    
    NSLog(@"followOnTwitter:%@",userName);
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            if ([accountsArray count] > 0) {
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                
                NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] init];
                [tempDict setValue:userName forKey:@"screen_name"];
                
                SLRequest *postRequest;
                [tempDict setValue:@"true" forKey:@"follow"];
                postRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:[NSURL URLWithString:@"https://api.twitter.com/1/friendships/create.json"] parameters:tempDict];
                
                [postRequest setAccount:twitterAccount];
                [postRequest performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                    NSString *output = [NSString stringWithFormat:@"HTTP response status: %i", [urlResponse statusCode]];
                    NSLog(@"%@", output);
                }];
            }
        }
    }];
}

- (void)getTwitterAcount{
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        if(granted) {
            NSArray *accountsArray = [accountStore accountsWithAccountType:accountType];
            if ([accountsArray count] > 0) {
                // Grab the initial Twitter account to tweet from.
                ACAccount *twitterAccount = [accountsArray objectAtIndex:0];
                self.twitterUserName =twitterAccount.username;
                self.twitterUserID   =twitterAccount.identifier;
                
                self.advertizer=[[CBAdvertizer alloc] initWithUserName:twitterUserName];
                self.scanner=[[CBScanner alloc] initinitWithDelegate:self ServiceUUIDStr:nil];
                NSLog(@"getTwitterAcount,%@,%@",self.twitterUserName,self.twitterUserID);
            }else{
                NSLog(@"No Twitter Account");
            }
        }else{
            NSLog(@"accountStore accesss denied");
        }
    }];
}
- (void)presentLocalNotification{
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif) {
        localNotif.hasAction=NO;
        localNotif.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication] presentLocalNotificationNow:localNotif];
    }
}
- (void)incrementBadge{
    UIApplication* app = [UIApplication sharedApplication];
    [UIApplication sharedApplication].applicationIconBadgeNumber = app.applicationIconBadgeNumber+1;
}

#pragma delegate
-(void)CBScannerDidDiscoverUser:(NSString *)userName{
    [self followOnTwitter:userName];
    userNames.text=[NSString stringWithFormat:@"%@%@%@",userNames.text,userName,@"\n"];
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }else{
        [self presentLocalNotification];
    }
}
-(void)CBScannerDidCangeState:(CBScannerState)state{
    
}
-(void)CBAdvertizerDidCangeState:(CBAdvertizerState)state{
    
}



-(void)binarySearchTest{
    // create twitter following DB
    NSUInteger amount = 10000;
    followingDB = [NSMutableArray arrayWithCapacity:amount];

    for (NSUInteger i = 0; i < amount-2; ++i) {
        //tekitou ID
        [followingDB addObject:[NSNumber numberWithLongLong:i*2000000]];
    }
    
    [followingDB addObject:[NSNumber numberWithLongLong:75743284]];//yusukeSekikawa
    [followingDB addObject:[NSNumber numberWithLongLong:9677332]]; //sonson_twit
    
    for(NSNumber *hoge in followingDB){
        //NSLog(@"hoge %lld",[hoge longLongValue]);
    }
    
    NSLog(@"----------");

    // Sort DB
    [self sortDB];
    
    for(NSNumber *hoge in followingDB){
        //NSLog(@"hoge %lld",[hoge longLongValue]);
    }
    // Do binary Search!
    if([self isFollowing:[NSNumber numberWithLongLong:75743284]]){
        NSLog(@"Already following");
    }else{
        NSLog(@"Not following");
    }
}


-(NSComparisonResult (^) (id lhs, id rhs))compareNSNumber{
    return ^(id lhs, id rhs)
             {
                 //NSLog(@"compareNSNumber,%lld,%lld",[lhs longLongValue],[rhs longLongValue]);
                 return [lhs longLongValue] < [rhs longLongValue] ? (NSComparisonResult)NSOrderedAscending : [lhs longLongValue] > [rhs longLongValue] ? (NSComparisonResult)NSOrderedDescending : (NSComparisonResult)NSOrderedSame;
             };
}
-(void)sortDB{
    [followingDB sortUsingComparator:[self compareNSNumber]];
}
- (BOOL)isFollowing:(NSNumber*)queryTwitterID{
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];

    //long long int index1;
    NSInteger  index= [followingDB indexOfObject:queryTwitterID
                        inSortedRange:NSMakeRange(0, [followingDB count])
                              options:NSBinarySearchingFirstEqual
                      usingComparator:[self compareNSNumber]];
    NSTimeInterval stop1 = [NSDate timeIntervalSinceReferenceDate];
    NSLog(@"Binary: Found index position: %d in %f seconds.", index, stop1 - start);
    if(index!=0x7FFFFFFF){
        return true;
    }else{
        return false;
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self binarySearchTest];
    
    //return;
    [self getTwitterAcount];
    UIApplication* app = [UIApplication sharedApplication];
    [UIApplication sharedApplication].applicationIconBadgeNumber = app.applicationIconBadgeNumber+1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
