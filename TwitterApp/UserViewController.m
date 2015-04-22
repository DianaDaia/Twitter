//
//  UserViewController.m
//  Twitter
//
//  Created by Diana Stefania Daia on 28/03/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import "UserViewController.h"
#import "DatabaseHandler.h"
#import "Utils.h"
#import "TweetsCell.h"
#import "MBProgressHUD.h"

@interface UserViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    UIButton *back;
    UIView *topView;
    UIImageView *profileImage;
    UILabel *username;
    UIButton *follow;
    
    UIView *followingView;
    UIButton *seeFollowing;
    UILabel *noOfFollowing;
    
    UIView *followersView;
    UIButton *seeFollowers;
    UILabel *noOfFollowers;
    
    UIView *bottomView;
    UITableView *tweetsList;

    NSMutableDictionary *contentOffsetDictionary;
    
    NSArray *following;
    NSArray *followers;
    
}


@end

@implementation UserViewController

- (void)viewDidLoad {
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
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = true;
    
    [self getFollowers];
    [self getFollowing];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
}

- (void)getFollowers
{
    [[DatabaseHandler sharedInstance] getFollowers:self.userProfile.objectId];
    
    [[DatabaseHandler sharedInstance] setCompletionHandlerForFollowers:^(NSArray *followersArray) {
        if (followersArray != nil)
        {
            followers = [[NSArray alloc] init];
            followers = followersArray;
            
            noOfFollowers.text = [NSString stringWithFormat:@"%lu", (unsigned long)followers.count];
            
            [follow setTitle:@"Follow" forState:UIControlStateNormal];
            
            for (int i = 0; i < followers.count; i++)
            {
                if ([[[followers objectAtIndex:i] valueForKey:@"followerId"] isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"id"]])
                {
                    [follow setTitle:@"Unfollow" forState:UIControlStateNormal];
                }
            }
        }
        else
        {
            
        }
    }];
}

- (void)getFollowing
{
    [[DatabaseHandler sharedInstance] getFollowing:self.userProfile.objectId];
    
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

- (void)setupLayout
{
    
    
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
    
    back = [[UIButton alloc] init];
    [back setBackgroundImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [back setContentMode:UIViewContentModeScaleAspectFit];
    [back addTarget:self action:@selector(onBackPressed) forControlEvents:UIControlEventTouchUpInside];
    back.translatesAutoresizingMaskIntoConstraints = NO;
    [leftView addSubview:back];
    
    profileImage = [[UIImageView alloc] init];
    profileImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[[DatabaseHandler sharedInstance] getGravatarURL:[self.userProfile valueForKey:@"email"]]]];
    profileImage.contentMode = UIViewContentModeScaleAspectFit;
    profileImage.translatesAutoresizingMaskIntoConstraints = NO;
    [leftView addSubview:profileImage];
    
    username = [[UILabel alloc] init];
    username.textAlignment = NSTextAlignmentCenter;
    username.text = [self.userProfile valueForKey:@"username"];
    username.textColor = [UIColor blackColor];
    username.lineBreakMode = NSLineBreakByWordWrapping;
    username.numberOfLines = 0;
    username.font = [Utils getMainFontBoldWithSize:14];
    username.translatesAutoresizingMaskIntoConstraints = NO;
    [leftView addSubview:username];
    
    NSDictionary *leftDict = NSDictionaryOfVariableBindings(back, profileImage, username);
    
    [leftView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[back(==20)]-|" options:0 metrics:nil views:leftDict]];
    [leftView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[profileImage]-[username(==40)]-|" options:0 metrics:nil views:leftDict]];
    [leftView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[back(==20)]-[profileImage]-|" options:0 metrics:nil views:leftDict]];
    [leftView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[back(==20)]-[username]-|" options:0 metrics:nil views:leftDict]];
    
    follow = [[UIButton alloc] init];
    [follow setBackgroundColor:[UIColor whiteColor]];
    [follow setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    follow.titleLabel.font = [Utils getMainFontBoldWithSize:14];
    [follow addTarget:self action:@selector(onFollowPressed) forControlEvents:UIControlEventTouchUpInside];
    follow.layer.cornerRadius = 5;
    follow.translatesAutoresizingMaskIntoConstraints = NO;
    [rightView addSubview:follow];
    
    followingView = [[UIView alloc] init];
    //followingView.backgroundColor = [UIColor purpleColor];
    followingView.translatesAutoresizingMaskIntoConstraints = NO;
    [rightView addSubview:followingView];
    
    followersView = [[UIView alloc] init];
    //followersView.backgroundColor = [UIColor yellowColor];
    followersView.translatesAutoresizingMaskIntoConstraints = NO;
    [rightView addSubview:followersView];
    
    NSDictionary *rightDict = NSDictionaryOfVariableBindings(follow, followersView, followingView);
    
    [rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[follow]-[followingView(==follow)][followersView(==follow)]-|" options:0 metrics:nil views:rightDict]];
    [rightView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[follow]-|" options:0 metrics:nil views:rightDict]];
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
    //noOfFollowing.text = @"12";
    noOfFollowing.textAlignment = NSTextAlignmentLeft;
    noOfFollowing.textColor = [UIColor blackColor];
    noOfFollowing.font = [Utils getMainFontBoldWithSize:14];
    noOfFollowing.translatesAutoresizingMaskIntoConstraints = NO;
    [followingView addSubview:noOfFollowing];
    
    NSDictionary *followingDict = NSDictionaryOfVariableBindings(seeFollowing, noOfFollowing);
    
    [followingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[seeFollowing]|" options:0 metrics:nil views:followingDict]];
    [followingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[noOfFollowing]|" options:0 metrics:nil views:followingDict]];
    [followingView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[seeFollowing]-[noOfFollowing]" options:0 metrics:nil views:followingDict]];
    
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
    //noOfFollowers.text = @"12";
    noOfFollowers.textAlignment = NSTextAlignmentLeft;
    noOfFollowers.textColor = [UIColor blackColor];
    noOfFollowers.font = [Utils getMainFontBoldWithSize:14];
    noOfFollowers.translatesAutoresizingMaskIntoConstraints = NO;
    [followersView addSubview:noOfFollowers];
    
    NSDictionary *followersDict = NSDictionaryOfVariableBindings(seeFollowers, noOfFollowers);
    
    [followersView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[seeFollowers]|" options:0 metrics:nil views:followersDict]];
    [followersView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[noOfFollowers]|" options:0 metrics:nil views:followersDict]];
    [followersView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[seeFollowers]-[noOfFollowers]" options:0 metrics:nil views:followersDict]];
    
    tweetsList = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, bottomView.frame.size.width, bottomView.frame.size.height) style:UITableViewStylePlain];
    tweetsList.delegate = self;
    tweetsList.dataSource = self;
    tweetsList.showsVerticalScrollIndicator = NO;
    [bottomView addSubview:tweetsList];

}

- (void)onFollowPressed
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if ([follow.titleLabel.text isEqualToString:@"Follow"])
    {
        noOfFollowers.text = [NSString stringWithFormat:@"%d", [noOfFollowers.text intValue] + 1];
        [[DatabaseHandler sharedInstance] followUser:[self.userProfile valueForKey:@"objectId"]];
    }
    else
    {
        noOfFollowers.text = [NSString stringWithFormat:@"%d", [noOfFollowers.text intValue] - 1];
        [[DatabaseHandler sharedInstance] unfollowUser:[self.userProfile valueForKey:@"objectId"]];
    }
    
        [[DatabaseHandler sharedInstance] setCompletionHandler:^(BOOL response) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            if (response)
            {
                if ([follow.titleLabel.text isEqualToString:@"Follow"])
                {
                    [follow setTitle:@"Unfollow" forState:UIControlStateNormal];
                }
                else
                {
                    [follow setTitle:@"Follow" forState:UIControlStateNormal];
                }
                
                if ([self.delegate respondsToSelector:@selector(updateData)])
                {
                    [self.delegate performSelector:@selector(updateData) withObject:nil];
                }

            
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@""
                                            message:@"Error. Try later."
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
            
        }];

    

}

- (void)onSeeFollowingPressed
{
    
}

- (void)onSeeFollowersPressed
{
    
}

- (void)onBackPressed
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"%lu", (unsigned long)self.userTweets.count);
    return self.userTweets.count;
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TweetsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (cell == nil)
    {
        cell = [[TweetsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.authorName.text = [self.userProfile valueForKey:@"username"];
    cell.authorImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[[DatabaseHandler sharedInstance] getGravatarURL:[self.userProfile valueForKey:@"email"]]]];
    cell.message.text = [[self.userTweets objectAtIndex:indexPath.row] valueForKey:@"message"];
    
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
    NSArray *numberOfImages = [[self.userTweets objectAtIndex:indexPath.row] valueForKey:@"images"];
    
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
    title.text = @"Tweets";
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
    NSArray *numberOfImages = [[self.userTweets objectAtIndex:collectionView.tag] valueForKey:@"images"];
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
    
    PFFile *imageData = [[[self.userTweets objectAtIndex:collectionView.tag] valueForKey:@"images"] objectAtIndex:indexPath.row];
    //NSData *imageD = [imageData getData];
    
    [imageData getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
        
        img.image = [UIImage imageWithData:data];
        img.contentMode = UIViewContentModeScaleAspectFit;
        [cell addSubview:img];
        
        
    }];
    
    return cell;
}


@end
