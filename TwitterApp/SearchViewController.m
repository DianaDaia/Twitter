//
//  SearchViewController.m
//  Twitter
//
//  Created by Diana Stefania Daia on 21/03/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import "SearchViewController.h"
#import "Utils.h"
#import "Item.h"
#import "MBProgressHUD.h"
#import "TweetsCell.h"
#import <Parse/Parse.h>
#import "UserCell.h"
#import "DatabaseHandler.h"
#import "UserViewController.h"
#import "TweetDetailsViewController.h"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UICollectionViewDataSource, UICollectionViewDelegate, TweetDelegate, UserUpdate>
{
    UISearchBar *searchBar;
    UITableView *foundItems;
    
    NSMutableArray *allTweets;
    NSMutableArray *allUsers;
    NSArray *followers;
    NSMutableArray *foundItemsArray;
    NSMutableDictionary *contentOffsetDictionary;
    
    NSString *searched;
}

@end

@implementation SearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self getData];
    [self setupLayout];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    self.navigationController.navigationBarHidden = YES;
    [self getData];

    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:YES];
    
    foundItemsArray = [[NSMutableArray alloc] init];
    [foundItems reloadData];
    
    searchBar.text = @"";
}

- (void)getData
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    allTweets = [[NSMutableArray alloc] init];
    allUsers = [[NSMutableArray alloc] init];
    
    [[DatabaseHandler sharedInstance] getTweets];
    
    [[DatabaseHandler sharedInstance] setCompletionHandlerForTweets:^(NSArray *tweets) {
        
        if (tweets != nil)
        {
            [allTweets  addObjectsFromArray:tweets];
        }
        
    }];
    
    [[DatabaseHandler sharedInstance] getUsers];
    
    [[DatabaseHandler sharedInstance] setCompletionHandlerForUsers:^(NSArray *users) {
        
        if (users != nil)
        {
            [allUsers addObjectsFromArray:users];
            [self getFollowersForEveryUser];
        }
        
    }];
}

- (void)getFollowersForEveryUser
{
    NSMutableArray *usersID = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < allUsers.count; i++)
    {
        [usersID addObject:[[allUsers objectAtIndex:i] objectId]];
    }
    
    followers = [[NSArray alloc] init];
    
    [[DatabaseHandler sharedInstance] getFollowersForUsers:usersID];
    
    [[DatabaseHandler sharedInstance] setCompletionHandlerForFollowers:^(NSArray *followersArray) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (followersArray != nil)
        {
            followers = followersArray;
            
        }
    
    }];
    
}

- (int)getFollowerForUserWithID:(NSString*)userID
{
    int followersNo = 0;
    
    for (int i = 0; i < followers.count; i++)
    {
        if ([[[followers objectAtIndex:i] valueForKey:@"followedId"] isEqualToString:userID])
        {
            followersNo++;
        }
    }
    
    return followersNo;
}



- (void)setupLayout
{
    self.view.backgroundColor = [Utils colorFromHex:@"#8471BA"];
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 80)];
    searchBar.placeholder = @"Search";
    searchBar.keyboardType = UIKeyboardTypeDefault;
    searchBar.delegate = self;
    searchBar.tintColor = [Utils colorFromHex:@"#8471BA"];
    [self.view addSubview:searchBar];
    
    foundItems = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, self.view.frame.size.height - self.tabBarController.tabBar.frame.size.height - 100) style:UITableViewStylePlain];
    foundItems.delegate = self;
    foundItems.dataSource = self;
    [self.view addSubview:foundItems];
}

- (void)updateData
{
    
//    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//    dispatch_group_t group = dispatch_group_create();
//    
//    dispatch_group_async(group, queue, ^{
//        [self getData];
//        
//        });
//    
//    
//    dispatch_group_notify(group, queue, ^{
//        
//        foundItemsArray = [[NSMutableArray alloc] init];
//        [self searchForString:searched];
//        
//    });

}

-(void)searchBarSearchButtonClicked:(UISearchBar *)search
{
    [search resignFirstResponder];
    
    searched = search.text;
    foundItemsArray = [[NSMutableArray alloc] init];
    [self searchForString:search.text];
}

- (void)searchForString:(NSString*)str
{
    //NSLog(@"%lu", (unsigned long)allUsers.count);
    //NSLog(@"%lu", (unsigned long)allTweets.count);
    
    
    for (int i = 0; i < allTweets.count; i++)
    {
        if ([[[allTweets objectAtIndex:i] valueForKey:@"message"] containsString:str])
        {
            Item *foundItem = [[Item alloc] init];
            foundItem.isTweet = true;
            foundItem.obj = [allTweets objectAtIndex:i];
            
            [foundItemsArray addObject:foundItem];
        }
    }
    
    for (int i = 0; i < allUsers.count; i++)
    {
        if ([[[allUsers objectAtIndex:i] valueForKey:@"username"] containsString:str])
        {
            Item *foundItem = [[Item alloc] init];
            foundItem.isTweet = false;
            foundItem.obj = [allUsers objectAtIndex:i];
            
            [foundItemsArray addObject:foundItem];
        }
    }
    
    [foundItems reloadData];

}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return foundItemsArray.count;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([[foundItemsArray objectAtIndex:indexPath.row] isTweet])
    {
        TweetsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tweetCell"];
        
        if (cell == nil)
        {
            cell = [[TweetsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tweetCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.authorName.text = [[[foundItemsArray objectAtIndex:indexPath.row] obj] valueForKey:@"parentName"];
        cell.authorImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[[DatabaseHandler sharedInstance] getGravatarURL:[[[foundItemsArray objectAtIndex:indexPath.row] obj] valueForKey:@"parentMail"]]]];
        cell.message.text = [[[foundItemsArray objectAtIndex:indexPath.row] obj] valueForKey:@"message"];
        
        return cell;

    }
    else
    {
        UserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"userCell"];
        
        if (cell == nil)
        {
            cell = [[UserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"userCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.username.text = [[[foundItemsArray objectAtIndex:indexPath.row] obj] valueForKey:@"username"];
        cell.userImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[[DatabaseHandler sharedInstance] getGravatarURL:[[[foundItemsArray objectAtIndex:indexPath.row] obj] valueForKey:@"email"]]]];
        cell.followers.text = [NSString stringWithFormat:@"Followers: %d", [self getFollowerForUserWithID:[[[foundItemsArray objectAtIndex:indexPath.row] obj] objectId]]];
        
        return cell;

    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[foundItemsArray objectAtIndex:indexPath.row] isTweet])
    {
        TweetDetailsViewController *seeTweet = [[TweetDetailsViewController alloc] init];
        seeTweet.delegate = self;
        [seeTweet setTweetId:[[[foundItemsArray objectAtIndex:indexPath.row] obj] objectId]];
        [self presentViewController:seeTweet animated:YES completion:nil];
    }
    else
    {
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        UserViewController *user = [[UserViewController alloc] init];
        user.delegate = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            [user setUserProfile:[[foundItemsArray objectAtIndex:indexPath.row] obj]];
            
            [[DatabaseHandler sharedInstance] getTweetsForId:[[[foundItemsArray objectAtIndex:indexPath.row] obj] valueForKey:@"objectId"]];
            
            [[DatabaseHandler sharedInstance] setCompletionHandlerForTweets:^(NSArray *tweets) {
                
                [user setUserTweets:tweets];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.navigationController pushViewController:user animated:YES];
                });
                
                
            }];
        });

    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[foundItemsArray objectAtIndex:indexPath.row] isTweet])
    {
        return 150;
    }
    
    return 90;
}

#pragma mark - UICollectionViewDataSource Methods

-(void)tableView:(UITableView *)tableView willDisplayCell:(TweetsCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[foundItemsArray objectAtIndex:indexPath.row] isTweet])
    {
        [cell setCollectionViewDataSourceDelegate:self index:indexPath.row];
        NSInteger index = cell.collectionView.tag;
        
        CGFloat horizontalOffset = [contentOffsetDictionary[[@(index) stringValue]] floatValue];
        [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
    }
}


-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *numberOfImages = [[[foundItemsArray objectAtIndex:collectionView.tag] obj] valueForKey:@"images"];
    //NSLog(@"***%lu", (unsigned long)numberOfImages.count);
    return numberOfImages.count;
    
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CollectionViewCellIdentifier forIndexPath:indexPath];
    
    //    NSArray *collectionViewArray = self.colorArray[collectionView.tag];
    //    cell.backgroundColor = collectionViewArray[indexPath.item];
    
    for (UIView *vw in [cell subviews])
    {
        [vw removeFromSuperview];
    }
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    
    PFFile *imageData = [[[[foundItemsArray objectAtIndex:collectionView.tag] obj] valueForKey:@"images"] objectAtIndex:indexPath.row];
    //NSData *imageD = [imageData getData];
    
    [imageData getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        
        img.image = [UIImage imageWithData:data];
        img.contentMode = UIViewContentModeScaleAspectFit;
        [cell addSubview:img];
        
        
    }];
    
    return cell;
}


@end
