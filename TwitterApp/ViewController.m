//
//  ViewController.m
//  TwitterApp
//
//  Created by Diana Stefania Daia on 18/04/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import "ViewController.h"
#import "TweetsCell.h"
#import "DatabaseHandler.h"
#import "MBProgressHUD.h"
#import <Parse/Parse.h>
#import "Utils.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
{
    UITableView *tweetsList;
    
    NSArray *tweetsArray;
    
    NSMutableDictionary *contentOffsetDictionary;
}


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    [self setupLayout];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    
    [self getData];
}

- (void)getData
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[DatabaseHandler sharedInstance] getAllTweets];
    
    [[DatabaseHandler sharedInstance] setCompletionHandlerForTweets:^(NSArray *tweets) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (tweets != nil)
        {
            tweetsArray = [[NSArray alloc] init];
            tweetsArray = tweets;
            
            
            
            [tweetsList reloadData];
        }
        else
        {
            
        }
    }];
    
}


- (void)setupLayout
{
    self.view.backgroundColor = [Utils colorFromHex:@"#8471BA"];
    
    tweetsList = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, self.view.frame.size.height - 30) style:UITableViewStylePlain];
    tweetsList.backgroundColor = [UIColor whiteColor];
    tweetsList.delegate = self;
    tweetsList.dataSource = self;
    [self.view addSubview:tweetsList];
    
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
    
    cell.authorName.text = [[tweetsArray objectAtIndex:indexPath.row] valueForKey:@"parentName"];
    cell.authorImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[[DatabaseHandler sharedInstance] getGravatarURL:[[tweetsArray objectAtIndex:indexPath.row] valueForKey:@"parentMail"]]]];
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
    //    header.layer.borderColor = [UIColor whiteColor].CGColor;
    //    header.layer.borderWidth = 1.0f;
    
    
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
