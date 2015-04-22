//
//  FollowViewController.m
//  Twitter
//
//  Created by Diana Stefania Daia on 21/03/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import "FollowViewController.h"
#import "UserCell.h"
#import "DatabaseHandler.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "Utils.h"
#import "UserViewController.h"

@interface FollowViewController () <UITableViewDataSource, UITableViewDelegate, UserUpdate>
{
    UITableView *usersList;
    
    NSArray *usersArray;
    NSMutableArray *nrOfFollowersForEveryUser;
    NSArray *followers;
}

@end

@implementation FollowViewController

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
    self.navigationController.navigationBarHidden = true;
    
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
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[DatabaseHandler sharedInstance] follow];
    
    [[DatabaseHandler sharedInstance] setCompletionHandlerForFollowing:^(NSArray *users) {
        
        
        if (users != nil)
        {
            usersArray = [[NSArray alloc] init];
            usersArray = users;
            
            //NSLog(@"%@", usersArray);
            
            [self getFollowersForEveryUser];

        }
        else
        {
            
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
            
            //NSLog(@"%@", followers);
            
            
            
            [usersList reloadData];
            
        }
        else
        {
            
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
