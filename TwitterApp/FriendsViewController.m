//
//  FriendsViewController.m
//  TwitterApp
//
//  Created by Diana Stefania Daia on 22/04/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import "FriendsViewController.h"
#import "UserViewController.h"
#import "UserCell.h"
#import "DatabaseHandler.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "Utils.h"

@interface FriendsViewController () <UITableViewDataSource, UITableViewDelegate, UserUpdate>
{
    UITableView *usersList;
    
    NSArray *usersIDs;
    NSArray *usersArray;
    NSMutableArray *nrOfFollowersForEveryUser;
    NSArray *followers;
}

@end

@implementation FriendsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupLayout];
    [self getData];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.view.backgroundColor = [Utils colorFromHex:@"#8471BA"];
    self.navigationController.navigationBarHidden = false;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];

}

- (void)updateData
{
    [self getData];
}

- (void)getData
{
    if ([self.friendsType isEqualToString:@"Followers"])
    {
        [[DatabaseHandler sharedInstance] getFollowers:[[NSUserDefaults standardUserDefaults] valueForKey:@"id"]];
        
        [[DatabaseHandler sharedInstance] setCompletionHandlerForFollowers:^(NSArray *followersArray) {
            
            if (followersArray != nil)
            {
                usersIDs = [[NSArray alloc] init];
                usersIDs = followersArray;
                
                NSLog(@"%@", usersIDs);
                
                
                [self getUsers];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Twitter"
                                            message:@"Error. Try later."
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];

            }
        }];

    }
    else
    {
        [[DatabaseHandler sharedInstance] getFollowing:[[NSUserDefaults standardUserDefaults] valueForKey:@"id"]];
        
        [[DatabaseHandler sharedInstance] setCompletionHandlerForFollowing:^(NSArray *followingArray) {
            
            if (followingArray != nil)
            {
                usersIDs = [[NSArray alloc] init];
                usersIDs = followingArray;
                
                NSLog(@"%@", usersIDs);
                
                
                [self getUsers];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Twitter"
                                            message:@"Error. Try later."
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];

            }
        }];

    }
}

- (void)getUsers
{
    NSMutableArray *usersID = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < usersIDs.count; i++)
    {
        if ([self.friendsType isEqualToString:@"Followers"])
        {
            [usersID addObject:[[usersIDs objectAtIndex:i] valueForKey:@"followerId"]];
        }
        else
        {
            [usersID addObject:[[usersIDs objectAtIndex:i] valueForKey:@"followedId"]];
        }
        
    }
    
    NSLog(@"%@", usersID);
    
    
    [[DatabaseHandler sharedInstance] getUsersWithIDs:usersID];
    
    [[DatabaseHandler sharedInstance] setCompletionHandlerForTweets:^(NSArray *usersProfile) {
        
        if (usersProfile != nil)
        {
            usersArray = [[NSArray alloc] init];
            usersArray = usersProfile;
            
            NSLog(@"%@", usersArray);
            
            
            [self getFollowersForEveryUser];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Twitter"
                                        message:@"Error. Try later."
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
        
        
        
    }];


}


- (void)getFollowersForEveryUser
{
    NSMutableArray *usersID = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < usersArray.count; i++)
    {
        [usersID addObject:[[usersArray objectAtIndex:i] objectId]];
    }
    
    
    [[DatabaseHandler sharedInstance] getFollowersForUsers:usersID];
    
    [[DatabaseHandler sharedInstance] setCompletionHandlerForFollowers:^(NSArray *followersArray) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (followersArray != nil)
        {
            followers = [[NSArray alloc] init];
            followers = followersArray;
            
            NSLog(@"%@", followers);
            
            
            
            [usersList reloadData];
            
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Twitter"
                                        message:@"Error. Try later."
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    }];
    
}

- (void)setupLayout
{
    
    usersList = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, self.view.frame.size.height - 30) style:UITableViewStylePlain];
    usersList.backgroundColor = [UIColor whiteColor];
    usersList.delegate = self;
    usersList.dataSource = self;
    [self.view addSubview:usersList];
}

- (int)getFollowerForUserWithID:(NSString*)userID
{
    //NSLog(@"%@", userID);
    
    int followersNo = 0;
    
    for (int i = 0; i < followers.count; i++)
    {
        if ([[[followers objectAtIndex:i] valueForKey:@"followedId"] isEqualToString:userID])
        {
            followersNo++;
        }
    }
    
    //NSLog(@"%d", followersNo);
    
    
    return followersNo;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"<<<%lu", (unsigned long)usersArray.count);
    
    return usersArray.count;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil)
    {
        cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.username.text = [[usersArray objectAtIndex:indexPath.row] valueForKey:@"username"];
    cell.userImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[[DatabaseHandler sharedInstance] getGravatarURL:[[usersArray objectAtIndex:indexPath.row] valueForKey:@"email"]]]];
    cell.followers.text = [NSString stringWithFormat:@"Followers: %d", [self getFollowerForUserWithID:[[usersArray objectAtIndex:indexPath.row] objectId]]];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    UserViewController *user = [[UserViewController alloc] init];
    user.delegate = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [user setUserProfile:[usersArray objectAtIndex:indexPath.row]];
        
        [[DatabaseHandler sharedInstance] getTweetsForId:[[usersArray objectAtIndex:indexPath.row] valueForKey:@"objectId"]];
        
        [[DatabaseHandler sharedInstance] setCompletionHandlerForTweets:^(NSArray *tweets) {
            
            [user setUserTweets:tweets];
            
            //NSLog(@"%@", tweets);
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self.navigationController pushViewController:user animated:YES];
            });
            
            
        }];
    });
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}


@end
