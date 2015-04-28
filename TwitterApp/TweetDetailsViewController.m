//
//  TweetDetailsViewController.m
//  TwitterApp
//
//  Created by Diana Stefania Daia on 27/04/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import "TweetDetailsViewController.h"
#import "DatabaseHandler.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "Utils.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface TweetDetailsViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MFMailComposeViewControllerDelegate>
{
    UIView *topView;
    UIButton *back;
    UIImageView *userImage;
    UILabel *username;
    
    UIView *middleView;
    UILabel *message;
    NSMutableArray *imagesArray;
    NSMutableArray *imagesData;
    UICollectionView *tweetImages;
    
    UIView *bottomView;
    UIButton *email;
    UIButton *deleteTweet;
    
    PFObject *userProfile;
    PFObject *tweetDetails;
    
    MFMailComposeViewController *mailController;
    
}

@end

@implementation TweetDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getData];
    [self setupLayout];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getData
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[DatabaseHandler sharedInstance] getTweetWithId:self.tweetId];
    
    [[DatabaseHandler sharedInstance] setCompletionHandlerForTweet:^(NSDictionary *info) {
        
        //[MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (info != nil)
        {
            userProfile = [info valueForKey:@"user"];
            tweetDetails = [info valueForKey:@"tweet"];
            
            userImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[[DatabaseHandler sharedInstance] getGravatarURL:[userProfile valueForKey:@"email"]]]];
            username.text = [userProfile valueForKey:@"username"];
            
            message.text = [tweetDetails valueForKey:@"message"];
            imagesArray = [tweetDetails valueForKey:@"images"];
            
            if (imagesArray.count > 0)
            {
                [self getImages];
            }
            else
            {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }
            
            //[tweetImages reloadData];
            
            if ([[userProfile objectId] isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"id"]])
            {
                [self setBottomLayout:false];
            }
            else
            {
                [deleteTweet removeFromSuperview];
                [self setBottomLayout:true];
            }
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Tweet"
                                        message:@"Error. Come back later."
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            
            return;

        }
    
    }];

}

- (void)getImages
{
    //[MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    
    imagesData = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < imagesArray.count; i++)
    {
        
        dispatch_group_async(group, queue, ^{
            PFFile *imageData = [imagesArray objectAtIndex:i];
            
            [imageData getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
                
                [imagesData addObject:data];
                
                
            }];

        });
        
    }
    

    dispatch_group_notify(group, queue, ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [tweetImages reloadData];
    });
    
}

- (void)setupLayout
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    topView = [[UIView alloc] init];
    //topView.backgroundColor = [UIColor redColor];
    topView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:topView];
    
    middleView = [[UIView alloc] init];
    //middleView.backgroundColor = [UIColor orangeColor];
    middleView.layer.borderColor = [[Utils colorFromHex:@"#8471BA"] CGColor];
    middleView.layer.borderWidth = 2.0f;
    middleView.layer.cornerRadius = 10;
    middleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:middleView];
    
    bottomView = [[UIView alloc] init];
    //bottomView.backgroundColor = [UIColor greenColor];
    bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bottomView];
    
    NSDictionary *main = NSDictionaryOfVariableBindings(topView, middleView, bottomView);
    
    
    if (self.view.frame.size.width == 320)
    {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[topView][middleView(==250)][bottomView(==100)]-|" options:0 metrics:nil views:main]];
    }
    else
    {
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[topView][middleView(==400)][bottomView(==100)]-|" options:0 metrics:nil views:main]];
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[topView]-|" options:0 metrics:nil views:main]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[middleView]-|" options:0 metrics:nil views:main]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[bottomView]-|" options:0 metrics:nil views:main]];
    
    userImage = [[UIImageView alloc] init];
    userImage.contentMode = UIViewContentModeScaleAspectFit;
    userImage.translatesAutoresizingMaskIntoConstraints = NO;
    [topView addSubview:userImage];
    
    back = [[UIButton alloc] init];
    [back setBackgroundImage:[UIImage imageNamed:@"x"] forState:UIControlStateNormal];
    [back setContentMode:UIViewContentModeScaleAspectFit];
    [back addTarget:self action:@selector(onBackPressed) forControlEvents:UIControlEventTouchUpInside];
    back.translatesAutoresizingMaskIntoConstraints = NO;
    [topView addSubview:back];
    
    username = [[UILabel alloc] init];
    username.textAlignment = NSTextAlignmentLeft;
    username.textColor = [UIColor blackColor];
    username.lineBreakMode = NSLineBreakByWordWrapping;
    username.numberOfLines = 0;
    username.font = [Utils getMainFontBoldWithSize:14];
    username.translatesAutoresizingMaskIntoConstraints = NO;
    [topView addSubview:username];
    
    UIView *sep = [[UIView alloc] init];
    //sep.backgroundColor = [UIColor orangeColor];
    sep.translatesAutoresizingMaskIntoConstraints = NO;
    [topView addSubview:sep];
    
    NSDictionary *topDict = NSDictionaryOfVariableBindings(back, userImage, username, sep);
    
    if (self.view.frame.size.width == 320)
    {
        [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[sep(==20)]-[userImage]|" options:0 metrics:nil views:topDict]];
        [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[sep(==20)]-[username]|" options:0 metrics:nil views:topDict]];

    }
    else
    {
        [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[sep(==50)]-[userImage]|" options:0 metrics:nil views:topDict]];
        [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[sep(==50)]-[username]|" options:0 metrics:nil views:topDict]];

    }
    [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[back]-[username]|" options:0 metrics:nil views:topDict]];
    
    if (self.view.frame.size.width == 320)
    {
        [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[sep]-[back(==20)]-|" options:0 metrics:nil views:topDict]];
    }
    else
    {
        [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[sep]-[back(==50)]-|" options:0 metrics:nil views:topDict]];
    }
    
    [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[userImage]-[username(>=240)]-|" options:0 metrics:nil views:topDict]];
    
    email = [[UIButton alloc] init];
    [email setBackgroundColor:[Utils colorFromHex:@"#8471BA"]];
    [email setTitle:@"E-mail" forState:UIControlStateNormal];
    email.titleLabel.textColor = [UIColor whiteColor];
    email.titleLabel.font = [Utils getMainFontBoldWithSize:10];
    email.titleLabel.textAlignment = NSTextAlignmentCenter;
    email.layer.cornerRadius = 5;
    [email addTarget:self action:@selector(onEmailPressed) forControlEvents:UIControlEventTouchUpInside];
    email.translatesAutoresizingMaskIntoConstraints = NO;
    [bottomView addSubview:email];
    
    deleteTweet = [[UIButton alloc] init];
    [deleteTweet setBackgroundColor:[Utils colorFromHex:@"#8471BA"]];
    [deleteTweet setTitle:@"Delete" forState:UIControlStateNormal];
    deleteTweet.titleLabel.textColor = [UIColor whiteColor];
    deleteTweet.titleLabel.font = [Utils getMainFontBoldWithSize:10];
    deleteTweet.titleLabel.textAlignment = NSTextAlignmentCenter;
    deleteTweet.layer.cornerRadius = 5;
    [deleteTweet addTarget:self action:@selector(onDeletePressed) forControlEvents:UIControlEventTouchUpInside];
    deleteTweet.translatesAutoresizingMaskIntoConstraints = NO;
    [bottomView addSubview:deleteTweet];

    [middleView layoutIfNeeded];
    message = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, middleView.frame.size.width - 10, 50)];
    message.numberOfLines = 0;
    message.lineBreakMode = NSLineBreakByWordWrapping;
    message.textAlignment = NSTextAlignmentLeft;
    message.font = [Utils getMainFontWithSize:12];
    [middleView addSubview:message];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    tweetImages = [[UICollectionView alloc] initWithFrame:CGRectMake(5, 60, middleView.frame.size.width - 10, middleView.frame.size.height - 70) collectionViewLayout:layout];
    [tweetImages setDataSource:self];
    [tweetImages setDelegate:self];
    tweetImages.backgroundColor = [UIColor redColor];
    [tweetImages registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [tweetImages setBackgroundColor:[UIColor clearColor]];
    [middleView addSubview:tweetImages];
    
}

- (void)setBottomLayout:(BOOL)deleteHidden
{
    UIView *sep1 = [[UIView alloc] init];
    //sep1.backgroundColor = [UIColor yellowColor];
    sep1.translatesAutoresizingMaskIntoConstraints = NO;
    [bottomView addSubview:sep1];
    
    UIView *sep2 = [[UIView alloc] init];
    //sep2.backgroundColor = [UIColor orangeColor];
    sep2.translatesAutoresizingMaskIntoConstraints = NO;
    [bottomView addSubview:sep2];
    
    UIView *sep3 = [[UIView alloc] init];
    //sep3.backgroundColor = [UIColor yellowColor];
    sep3.translatesAutoresizingMaskIntoConstraints = NO;
    [bottomView addSubview:sep3];
    
    UIView *sep4 = [[UIView alloc] init];
    //sep4.backgroundColor = [UIColor orangeColor];
    sep4.translatesAutoresizingMaskIntoConstraints = NO;
    [bottomView addSubview:sep4];
    
    if (deleteHidden)
    {
        NSDictionary *bottomDict = NSDictionaryOfVariableBindings(email, sep1, sep2, sep3, sep4);
        
        [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[sep3(==15)]-[sep1]-[sep4(==sep3)]-|" options:0 metrics:nil views:bottomDict]];
        [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[sep3(==15)]-[email]-[sep4(==sep3)]-|" options:0 metrics:nil views:bottomDict]];
        [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[sep3(==15)]-[sep2(==sep1)]-[sep4(==sep3)]-|" options:0 metrics:nil views:bottomDict]];
        [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[sep1(==100)]-[email]-[sep2(==sep1)]-|" options:0 metrics:nil views:bottomDict]];
        [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[sep3]-|" options:0 metrics:nil views:bottomDict]];
        [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[sep4]-|" options:0 metrics:nil views:bottomDict]];
    }
    else
    {
        NSDictionary *bottomDict = NSDictionaryOfVariableBindings(email, deleteTweet, sep1, sep2, sep3, sep4);
        
        [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[sep3(==15)]-[sep1]-[sep4(==sep3)]-|" options:0 metrics:nil views:bottomDict]];
        [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[sep3(==15)]-[email]-[sep4(==sep3)]-|" options:0 metrics:nil views:bottomDict]];
        [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[sep3(==15)]-[deleteTweet(==email)]-[sep4(==sep3)]-|" options:0 metrics:nil views:bottomDict]];
        [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[sep3(==15)]-[sep2(==sep1)]-[sep4(==sep3)]-|" options:0 metrics:nil views:bottomDict]];
        [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[sep3]-|" options:0 metrics:nil views:bottomDict]];
        [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[sep1(==60)]-[email]-[deleteTweet(==email)]-[sep2(==sep1)]-|" options:0 metrics:nil views:bottomDict]];
        [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[sep4]-|" options:0 metrics:nil views:bottomDict]];
    }
}

- (void)onBackPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onEmailPressed
{
    mailController = [[MFMailComposeViewController alloc] init];
    mailController.mailComposeDelegate = self;
    [mailController setSubject:@"Tweet"];
    [mailController setMessageBody:[tweetDetails valueForKey:@"message"] isHTML:NO];
    
    for (int i = 0; i < imagesData.count; i++)
    {
        [mailController addAttachmentData:[imagesData objectAtIndex:i]
                           mimeType:@"image/png"
                           fileName:[NSString stringWithFormat:@"image%d",i]];
    }
    
    if ([MFMailComposeViewController canSendMail])
    {
        [self presentViewController:mailController animated:YES completion:nil];
    }
    else
    {
        [[[UIAlertView alloc] initWithTitle:@"Tweet"
                                    message:@"Error. Come back later."
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        
    }
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error;
{
    if (result == MFMailComposeResultSent)
    {
        [[[UIAlertView alloc] initWithTitle:@"Tweet"
                                    message:@"Your mail has been sent."
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];    }
    [self dismissViewControllerAnimated:mailController completion:nil];
}

- (void)onDeletePressed
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [tweetDetails deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (succeeded)
        {
            
            if ([self.delegate respondsToSelector:@selector(updateData)])
            {
                [self.delegate performSelector:@selector(updateData) withObject:nil];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:YES completion:nil];
            });
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Tweet"
                                        message:@"Error. Come back later."
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            
            return;

        }
        
    }];
}

#pragma mark - UICollectionView Delegate and Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (imagesArray.count > 2)
    {
        return 2;
    }
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (imagesArray.count == 4 || imagesArray.count == 2)
    {
        return 2;
    }
    
    if (imagesArray.count == 3)
    {
        if (section == 0)
        {
            return 2;
        }
    }
    
    return 1;
    
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    //cell.backgroundColor = [UIColor redColor];
    
    for (UIView *vw in [cell subviews])
    {
        [vw removeFromSuperview];
    }
    
    UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    img.contentMode = UIViewContentModeScaleAspectFit;
    [cell addSubview:img];
    
//    PFFile *imageData;
//    
//    if (indexPath.section == 0)
//    {
//        imageData = [imagesArray objectAtIndex:indexPath.row];
//    }
//    else
//    {
//        if (imagesArray.count == 3)
//        {
//            imageData = [imagesArray objectAtIndex:2];
//        }
//        else
//        {
//            imageData = [imagesArray objectAtIndex:indexPath.row + 1];
//        }
//    }
//    
//    [imageData getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
//        
//        img.image = [UIImage imageWithData:data];
//        img.contentMode = UIViewContentModeScaleAspectFit;
//        [cell addSubview:img];
//
//        
//    }];
    
    NSData *data;
    
    if (indexPath.section == 0)
    {
        data = [imagesData objectAtIndex:indexPath.row];
    }
    else
    {
        if (imagesArray.count == 3)
        {
            data = [imagesData objectAtIndex:2];
        }
        else
        {
            data = [imagesData objectAtIndex:indexPath.row + 1];
        }
    }

    img.image = [UIImage imageWithData:data];
    img.contentMode = UIViewContentModeScaleAspectFit;
    [cell addSubview:img];

    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(50, 70);
}


@end
