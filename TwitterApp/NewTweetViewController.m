//
//  NewTweetViewController.m
//  Twitter
//
//  Created by Diana Stefania Daia on 22/03/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import "NewTweetViewController.h"
#import "Utils.h"
#import "DatabaseHandler.h"
#import "MBProgressHUD.h"

@interface NewTweetViewController () <UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIView *topView;
    UIButton *cancel;
    UIButton *postTweet;
    UIImageView *profileImage;
    UILabel *username;
    
    UIView *bottomView;
    //UIButton *addPhoto;
    UITextView *tweet;
    
    NSMutableArray *imagesArray;
    
    UICollectionView *tweetImages;
    
}

@end

@implementation NewTweetViewController
//@synthesize username;

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


- (void)setupLayout
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    imagesArray = [[NSMutableArray alloc] init];
    
    topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 150)];
    //topView.backgroundColor = [UIColor redColor];
    [self.view addSubview:topView];
    
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 150, self.view.frame.size.width, self.view.frame.size.height - 150)];
    //bottomView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:bottomView];
    
    UIView *sep = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 75)];
    [topView addSubview:sep];

    UIView *sep1 = [[UIView alloc] initWithFrame:CGRectMake(0, 75, self.view.frame.size.width, 75)];
    [topView addSubview:sep1];
    
    cancel = [[UIButton alloc] init];
    [cancel setBackgroundColor:[Utils colorFromHex:@"#8471BA"]];
    [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancel.titleLabel.font = [Utils getMainFontBoldWithSize:10];
    [cancel addTarget:self action:@selector(onCancelPressed) forControlEvents:UIControlEventTouchUpInside];
    cancel.layer.cornerRadius = 5;
    cancel.translatesAutoresizingMaskIntoConstraints = NO;
    [sep addSubview:cancel];
    
    postTweet = [[UIButton alloc] init];
    [postTweet setBackgroundColor:[Utils colorFromHex:@"#8471BA"]];
    [postTweet setTitle:@"Tweet" forState:UIControlStateNormal];
    [postTweet setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    postTweet.titleLabel.font = [Utils getMainFontBoldWithSize:10];
    [postTweet addTarget:self action:@selector(onPostTweetPressed) forControlEvents:UIControlEventTouchUpInside];
    postTweet.layer.cornerRadius = 5;
    postTweet.translatesAutoresizingMaskIntoConstraints = NO;
    [sep addSubview:postTweet];
    
    profileImage = [[UIImageView alloc] init];
    profileImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[[DatabaseHandler sharedInstance] getGravatarURL:[[NSUserDefaults standardUserDefaults] valueForKey:@"loggedIn"]]]];
    profileImage.contentMode = UIViewContentModeScaleAspectFit;
    profileImage.translatesAutoresizingMaskIntoConstraints = NO;
    [sep1 addSubview:profileImage];
    
    username = [[UILabel alloc] init];
    username.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    username.textAlignment = NSTextAlignmentLeft;
    username.textColor = [UIColor blackColor];
    username.font = [Utils getMainFontBoldWithSize:14];
    username.translatesAutoresizingMaskIntoConstraints = NO;
    [sep1 addSubview:username];
    
    NSDictionary *sepDict = NSDictionaryOfVariableBindings(cancel, postTweet);
    
    [sep addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[cancel]-20-|" options:0 metrics:nil views:sepDict]];
    [sep addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[postTweet]-20-|" options:0 metrics:nil views:sepDict]];
    [sep addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[cancel]-(==220)-[postTweet(==cancel)]-|" options:0 metrics:nil views:sepDict]];
    
    NSDictionary *sep1Dict = NSDictionaryOfVariableBindings(profileImage, username);
    
    [sep1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[profileImage]-|" options:0 metrics:nil views:sep1Dict]];
    [sep1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[username]-|" options:0 metrics:nil views:sep1Dict]];
    if (self.view.frame.size.width == 375)
    {
        [sep1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[profileImage]-[username(>=290)]-|" options:0 metrics:nil views:sep1Dict]];
    }
    else if (self.view.frame.size.width == 414)
    {
        [sep1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[profileImage]-[username(>=320)]-|" options:0 metrics:nil views:sep1Dict]];
    }
    else
    {
        [sep1 addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[profileImage]-[username(>=240)]-|" options:0 metrics:nil views:sep1Dict]];
    }
    
    tweet = [[UITextView alloc] initWithFrame:CGRectMake(10, 0, bottomView.frame.size.width - 20, bottomView.frame.size.height / 2)];
    tweet.delegate = self;
    tweet.layer.borderColor = [UIColor lightGrayColor].CGColor;
    tweet.layer.borderWidth = 1.0f;
    [bottomView addSubview:tweet];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    tweetImages = [[UICollectionView alloc] initWithFrame:CGRectMake(10, bottomView.frame.size.height / 2 + 10, bottomView.frame.size.width - 20, bottomView.frame.size.height / 2 - 10) collectionViewLayout:layout];
    [tweetImages setDataSource:self];
    [tweetImages setDelegate:self];
    [tweetImages registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [tweetImages setBackgroundColor:[UIColor clearColor]];
    [bottomView addSubview:tweetImages];
    
    
}

- (void)onCancelPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onPostTweetPressed
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSMutableDictionary *tweetInfo = [[NSMutableDictionary alloc] init];
    
    [tweetInfo setValue:tweet.text forKey:@"message"];
    
//    if (imagesArray.count > 0)
//    {
        //NSData *arrayDataImages = [NSKeyedArchiver archivedDataWithRootObject:imagesArray];
        [tweetInfo setValue:imagesArray forKey:@"images"];
//    }
//    else
//    {
//        [tweetInfo setValue:@"0" forKey:@"images"];
//    }
    
    [[DatabaseHandler sharedInstance] saveTweet:tweetInfo];
    
    
    [[DatabaseHandler sharedInstance] setCompletionHandler:^(BOOL response) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if (!response)
        {
            [[[UIAlertView alloc] initWithTitle:@"Tweet"
                                        message:@"Error. Try later."
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    
        [self dismissViewControllerAnimated:YES completion:nil];
    
    }];
    
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - UICollectionView Delegate and Data Source

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (imagesArray.count < 4)
    {
        return imagesArray.count + 1;
    }
    return 4;
    
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
    
    
    if (indexPath.row == imagesArray.count)
    {
        img.image = [UIImage imageNamed:@"addPicture"];
    }
    else
    {
        img.image = [UIImage imageWithData:[imagesArray objectAtIndex:indexPath.row]];
        
        UIImageView *minus = [[UIImageView alloc] initWithFrame:CGRectMake(img.frame.size.width - 25, img.frame.size.height - 45, 20, 20)];
        minus.image = [UIImage imageNamed:@"remove"];
        minus.contentMode = UIViewContentModeScaleAspectFit;
        [img addSubview:minus];
    }
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == imagesArray.count && imagesArray.count < 4)
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
    else if (indexPath.row != imagesArray.count)
    {
        [imagesArray removeObjectAtIndex:indexPath.row];
        [tweetImages reloadData];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(80, collectionView.frame.size.height/2);
}

#pragma mark - UIImagePickerController

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
   
    NSData *imageData = UIImagePNGRepresentation(chosenImage);
    [imagesArray addObject:imageData];
    
    [tweetImages reloadData];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}


@end
