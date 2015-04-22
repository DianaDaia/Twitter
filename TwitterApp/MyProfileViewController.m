//
//  MyProfileViewController.m
//  Twitter
//
//  Created by Diana Stefania Daia on 21/03/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import "MyProfileViewController.h"
#import "Utils.h"
#import "DatabaseHandler.h"
#import "NewTweetViewController.h"
#import "MBProgressHUD.h"
#import "TweetsCell.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "LoginViewController.h"
#import "EditProfileViewController.h"
#import "FriendsViewController.h"

#define APP ((AppDelegate*)[[UIApplication sharedApplication] delegate])

@interface MyProfileViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    UIView *topView;
    UIImageView *profileImage;
    UILabel *username;
    UIButton *newTweet;
    UIButton *editProfile;
    UIButton *signOut;
    
    UIView *followingView;
    UIButton *seeFollowing;
    UILabel *noOfFollowing;
    
    UIView *followersView;
    UIButton *seeFollowers;
    UILabel *noOfFollowers;
    
    NSArray *following;
    NSArray *followers;
    
    UIView *bottomView;
    UITableView *myTweets;
    NSArray *tweetsArray;
    
    NSMutableDictionary *contentOffsetDictionary;
    
}

@end

@implementation MyProfileViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    
    [self getFollowers];
    [self getFollowing];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    username.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];

//    [self getFollowers];
//    [self getFollowing];
    [self getTweets];
    
}

- (void)getFollowers
{
    [[DatabaseHandler sharedInstance] getFollowers:[[NSUserDefaults standardUserDefaults] valueForKey:@"id"]];
    
    [[DatabaseHandler sharedInstance] setCompletionHandlerForFollowers:^(NSArray *followersArray) {
        if (followersArray != nil)
        {
            followers = [[NSArray alloc] init];
            followers = followersArray;
            
            noOfFollowers.text = [NSString stringWithFormat:@"%lu", (unsigned long)followers.count];
        }
        else
        {
            
        }
    }];
}

- (void)getFollowing
{
    [[DatabaseHandler sharedInstance] getFollowing:[[NSUserDefaults standardUserDefaults] valueForKey:@"id"]];
    
    [[DatabaseHandler sharedInstance] setCompletionHandlerForFollowing:^(NSArray *followingArray) {
        if (followingArray != nil)
        {
            following = [[NSArray alloc] init];
            following = followingArray;
            
            noOfFollowing.text = [NSString stringWithFormat:@"%lu", (unsigned long)following.count];
            
            
        }
        else
        {
            
        }
    }];
}

- (void)getTweets
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[DatabaseHandler sharedInstance] getTweetsForId:[[NSUserDefaults standardUserDefaults] valueForKey:@"id"]];
    
    [[DatabaseHandler sharedInstance] setCompletionHandlerForTweets:^(NSArray *tweets) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (tweets != nil)
        {
            tweetsArray = [[NSArray alloc] init];
            tweetsArray = tweets;
            
            //NSLog(@"%@", tweetsArray);
            
            [myTweets reloadData];
        }
        else
        {
            
        }
    }];

}

- (void)setupLayout
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    contentOffsetDictionary = [[NSMutableDictionary alloc] init];
    
    topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
    topView.backgroundColor = [Utils colorFromHex:@"#8471BA"];
    [self.view addSubview:topView];
    
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 150, self.view.frame.size.width, self.view.frame.size.height - 150 - self.tabBarController.tabBar.frame.size.height)];
    [self.view addSubview:bottomView];
    
    
    UIView *leftView = [[UIView alloc] init];
    leftView.translatesAutoresizingMaskIntoConstraints = NO;
    [topView addSubview:leftView];
    
    UIView *rightView = [[UIView alloc] init];
    rightView.translatesAutoresizingMaskIntoConstraints = NO;
    [topView addSubview:rightView];
    
    NSDictionary *topDict = NSDictionaryOfVariableBindings(leftView, rightView);
    
    [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[leftView]|" options:0 metrics:nil views:topDict]];
    [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[rightView]|" options:0 metrics:nil views:topDict]];
    [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[leftView(==150)][rightView]|" options:0 metrics:nil views:topDict]];
    
    profileImage = [[UIImageView alloc] init];
    profileImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[[DatabaseHandler sharedInstance] getGravatarURL:[[NSUserDefaults standardUserDefaults] valueForKey:@"loggedIn"]]]];
    profileImage.contentMode = UIViewContentModeScaleAspectFit;
    profileImage.translatesAutoresizingMaskIntoConstraints = NO;
    [leftView addSubview:profileImage];
    
    username = [[UILabel alloc] init];
    username.textAlignment = NSTextAlignmentCenter;
    username.textColor = [UIColor blackColor];
    username.lineBreakMode = NSLineBreakByWordWrapping;
    username.numberOfLines = 0;
    username.font = [Utils getMainFontBoldWithSize:14];
    username.translatesAutoresizingMaskIntoConstraints = NO;
    [leftView addSubview:username];
    
    NSDictionary *leftDict = NSDictionaryOfVariableBindings(profileImage, username);
    
    [leftView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[profileImage]-[username(==40)]-|" options:0 metrics:nil views:leftDict]];
    [leftView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[profileImage]-|" options:0 metrics:nil views:leftDict]];
    [leftView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[username]-|" options:0 metrics:nil views:leftDict]];
    

    newTweet = [[UIButton alloc] init];
    [newTweet setBackgroundColor:[UIColor whiteColor]];
    [newTweet setTitle:@"New Tweet" forState:UIControlStateNormal];
    [newTweet setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    newTweet.titleLabel.font = [Utils getMainFontBoldWithSize:8];
    [newTweet addTarget:self action:@selector(onNewTweetPressed) forControlEvents:UIControlEventTouchUpInside];
    newTweet.layer.cornerRadius = 5;
    newTweet.translatesAutoresizingMaskIntoConstraints = NO;
    [rightView addSubview:newTweet];
    
    editProfile = [[UIButton alloc] init];
    [editProfile setBackgroundColor:[UIColor whiteColor]];
    [editProfile setTitle:@"Edit" forState:UIControlStateNormal];
    [editProfile setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    editProfile.titleLabel.font = [Utils getMainFontBoldWithSize:8];
    [editProfile addTarget:self action:@selector(onEditProfilePressed) forControlEvents:UIControlEventTouchUpInside];
    editProfile.layer.cornerRadius = 5;
    editProfile.translatesAutoresizingMaskIntoConstraints = NO;
    [rightView addSubview:editProfile];
    
    signOut = [[UIButton alloc] init];
    [signOut setBackgroundColor:[UIColor whiteColor]];
    [signOut setTitle:@"Sign Out" forState:UIControlStateNormal];
    [signOut setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    signOut.titleLabel.font = [Utils getMainFontBoldWithSize:8];
    [signOut addTarget:self action:@selector(onSignOutPressed) forControlEvents:UIControlEventTouchUpInside];
    signOut.layer.cornerRadius = 5;
    signOut.translatesAutoresizingMaskIntoConstraints = NO;
    [rightView addSubview:signOut];
    
    followingView = [[UIView alloc] init];
    followingView.backgroundColor = [UIColor whiteColor];
    followingView.layer.cornerRadius = 5;
    followingView.translatesAutoresizingMaskIntoConstraints = NO;
    [rightView addSubview:followingView];
    
    followersView = [[UIView alloc] init];
    followersView.backgroundColor = [UIColor whiteColor];
    followersView.layer.cornerRadius = 5;
    followersView.translatesAutoresizingMaskIntoConstraints = NO;
    [rightView addSubview:followersView];
    
    NSDictionary *rightDict = NSDictionaryOfVariableBindings(newTweet, editProfile, signOut, followersView, followingView);
    
    [rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[newTweet]-[followingView(==newTweet)]-[followersView(==newTweet)]-|" options:0 metrics:nil views:rightDict]];
    [rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[editProfile(==newTweet)]-[followingView(==newTweet)]-[followersView(==newTweet)]-|" options:0 metrics:nil views:rightDict]];
    [rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[signOut(==newTweet)]-[followingView(==newTweet)]-[followersView(==newTweet)]-|" options:0 metrics:nil views:rightDict]];
    [rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[newTweet]-[editProfile(==newTweet)]-[signOut(==newTweet)]-|" options:0 metrics:nil views:rightDict]];
    [rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[followingView]-|" options:0 metrics:nil views:rightDict]];
    [rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[followersView(==followingView)]-|" options:0 metrics:nil views:rightDict]];
    
    seeFollowing = [[UIButton alloc] init];
    [seeFollowing setBackgroundColor:[UIColor clearColor]];
    [seeFollowing setTitle:@"Following:" forState:UIControlStateNormal];
    [seeFollowing setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    seeFollowing.titleLabel.font = [Utils getMainFontBoldWithSize:14];
    [seeFollowing addTarget:self action:@selector(onSeeFollowingPressed) forControlEvents:UIControlEventTouchUpInside];
    seeFollowing.layer.cornerRadius = 5;
    seeFollowing.translatesAutoresizingMaskIntoConstraints = NO;
    [followingView addSubview:seeFollowing];
    
    noOfFollowing = [[UILabel alloc] init];
    noOfFollowing.textAlignment = NSTextAlignmentLeft;
    noOfFollowing.textColor = [UIColor blackColor];
    noOfFollowing.font = [Utils getMainFontBoldWithSize:14];
    noOfFollowing.translatesAutoresizingMaskIntoConstraints = NO;
    [followingView addSubview:noOfFollowing];
    
    NSDictionary *followingDict = NSDictionaryOfVariableBindings(seeFollowing, noOfFollowing);
    
    [followingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[seeFollowing]|" options:0 metrics:nil views:followingDict]];
    [followingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[noOfFollowing]|" options:0 metrics:nil views:followingDict]];
    [followingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[seeFollowing]-[noOfFollowing]|" options:0 metrics:nil views:followingDict]];
    
    seeFollowers = [[UIButton alloc] init];
    [seeFollowers setBackgroundColor:[UIColor clearColor]];
    [seeFollowers setTitle:@"Followers:" forState:UIControlStateNormal];
    [seeFollowers setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    seeFollowers.titleLabel.font = [Utils getMainFontBoldWithSize:14];
    [seeFollowers addTarget:self action:@selector(onSeeFollowersPressed) forControlEvents:UIControlEventTouchUpInside];
    seeFollowers.layer.cornerRadius = 5;
    seeFollowers.translatesAutoresizingMaskIntoConstraints = NO;
    [followersView addSubview:seeFollowers];
    
    noOfFollowers = [[UILabel alloc] init];
    noOfFollowers.textAlignment = NSTextAlignmentLeft;
    noOfFollowers.textColor = [UIColor blackColor];
    noOfFollowers.font = [Utils getMainFontBoldWithSize:14];
    noOfFollowers.translatesAutoresizingMaskIntoConstraints = NO;
    [followersView addSubview:noOfFollowers];
    
    NSDictionary *followersDict = NSDictionaryOfVariableBindings(seeFollowers, noOfFollowers);
    
    [followersView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[seeFollowers]|" options:0 metrics:nil views:followersDict]];
    [followersView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[noOfFollowers]|" options:0 metrics:nil views:followersDict]];
    [followersView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[seeFollowers]-[noOfFollowers]|" options:0 metrics:nil views:followersDict]];
    
    myTweets = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, bottomView.frame.size.width, bottomView.frame.size.height) style:UITableViewStylePlain];
    myTweets.delegate = self;
    myTweets.dataSource = self;
    myTweets.showsVerticalScrollIndicator = NO;
    [bottomView addSubview:myTweets];
    
    
}

- (void)onNewTweetPressed
{
    NewTweetViewController *newTweetController = [[NewTweetViewController alloc] init];
    [self presentViewController:newTweetController animated:YES completion:nil];
}

- (void)onEditProfilePressed
{
    [self presentViewController:[EditProfileViewController new] animated:YES completion:nil];
}

- (void)onSignOutPressed
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"LoggedIn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    APP.window.rootViewController = [[LoginViewController alloc] init];
    
}

- (void)onSeeFollowingPressed
{
    FriendsViewController *friendsView = [FriendsViewController new];
    [friendsView setFriendsType:@"Following"];
    [self.navigationController pushViewController:friendsView animated:YES];

}

- (void)onSeeFollowersPressed
{
    FriendsViewController *friendsView = [FriendsViewController new];
    [friendsView setFriendsType:@"Followers"];
    [self.navigationController pushViewController:friendsView animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"%lu", (unsigned long)tweetsArray.count);
    
    
    return tweetsArray.count;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TweetsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil)
    {
        cell = [[TweetsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.authorName.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    cell.authorImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[[DatabaseHandler sharedInstance] getGravatarURL:[[NSUserDefaults standardUserDefaults] valueForKey:@"loggedIn"]]]];
    cell.message.text = [[tweetsArray objectAtIndex:indexPath.row] valueForKey:@"message"];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}


#pragma mark - UITableViewDelegate Methods

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *numberOfImages = [[tweetsArray objectAtIndex:indexPath.row] valueForKey:@"images"];
    
    if (numberOfImages.count == 0)
    {
        return 60;
    }
    
    return 130;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 50)];
    header.backgroundColor = [Utils colorFromHex:@"#8471BA"];
    header.layer.borderColor = [UIColor whiteColor].CGColor;
    header.layer.borderWidth = 1.0f;
    
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, header.frame.size.width, header.frame.size.height - 10)];
    title.text = @"My tweets";
    title.textAlignment = NSTextAlignmentLeft;
    title.textColor = [UIColor whiteColor];
    title.font = [Utils getMainFontBoldWithSize:18];
    title.translatesAutoresizingMaskIntoConstraints = NO;
    [header addSubview:title];
    
    return header;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(TweetsCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setCollectionViewDataSourceDelegate:self index:indexPath.row];
    NSInteger index = cell.collectionView.tag;
    
    CGFloat horizontalOffset = [contentOffsetDictionary[[@(index) stringValue]] floatValue];
    [cell.collectionView setContentOffset:CGPointMake(horizontalOffset, 0)];
}



#pragma mark - UICollectionViewDataSource Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *numberOfImages = [[tweetsArray objectAtIndex:collectionView.tag] valueForKey:@"images"];
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
    
    PFFile *imageData = [[[tweetsArray objectAtIndex:collectionView.tag] valueForKey:@"images"] objectAtIndex:indexPath.row];
    //NSData *imageD = [imageData getData];
    
    [imageData getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        
        img.image = [UIImage imageWithData:data];
        img.contentMode = UIViewContentModeScaleAspectFit;
        [cell addSubview:img];

        
    }];
    
    return cell;
}

@end
