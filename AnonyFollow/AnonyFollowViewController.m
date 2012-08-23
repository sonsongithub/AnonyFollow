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
                // Grab the initial Twitter account to tweet from.
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
    NSLog(@"getTwitterAcount");
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

            }
        }
    }];
}

-(void)CBScannerDidDiscoverUser:(NSString *)userName{
    [self followOnTwitter:userName];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getTwitterAcount];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
