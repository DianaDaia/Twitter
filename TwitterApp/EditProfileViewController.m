//
//  EditProfileViewController.m
//  Twitter
//
//  Created by Lucian Tarna on 25/03/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import "EditProfileViewController.h"
#import "Utils.h"
#import "DatabaseHandler.h"
#import "MBProgressHUD.h"

@interface EditProfileViewController () <UITextFieldDelegate>
{
    UIView *topView;
    UIView *bottomView;
    
    UIImageView *profileImage;
    UILabel *email;
    
    UILabel *usernameLabel;
    UIView *line;
    UITextField *usernameTxt;
    
    UILabel *passwordLabel;
    UIView *line1;
    UITextField *password;
    
    UIButton *save;
    UIButton *cancel;
    
    
}
@end

@implementation EditProfileViewController

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
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    
}

- (void)setupLayout
{
    topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 90)];
    topView.backgroundColor = [Utils colorFromHex:@"#8471BA"];
    //topView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:topView];
    
    bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 90, self.view.frame.size.width, self.view.frame.size.height - 90 - self.tabBarController.tabBar.frame.size.height)];
    bottomView.backgroundColor = [Utils colorFromHex:@"#8471BA"];
    //bottomView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:bottomView];
    
    profileImage = [[UIImageView alloc] init];
    profileImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[[DatabaseHandler sharedInstance] getGravatarURL:[[NSUserDefaults standardUserDefaults] valueForKey:@"loggedIn"]]]];
    profileImage.contentMode = UIViewContentModeScaleAspectFit;
    profileImage.translatesAutoresizingMaskIntoConstraints = NO;
    [topView addSubview:profileImage];
    
    email = [[UILabel alloc] init];
    email.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"loggedIn"];
    email.textAlignment = NSTextAlignmentLeft;
    email.textColor = [UIColor whiteColor];
    email.font = [Utils getMainFontBoldWithSize:14];
    email.translatesAutoresizingMaskIntoConstraints = NO;
    [topView addSubview:email];
    
    NSDictionary *topDict = NSDictionaryOfVariableBindings(profileImage, email);
    
    [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[profileImage]-|" options:0 metrics:nil views:topDict]];
    [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[email]-|" options:0 metrics:nil views:topDict]];
    if (self.view.frame.size.width == 375)
    {
        [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[profileImage]-[email(>=290)]-|" options:0 metrics:nil views:topDict]];
    }
    else if (self.view.frame.size.width == 414)
    {
        [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[profileImage]-[email(>=320)]-|" options:0 metrics:nil views:topDict]];
    }
    else
    {
        [topView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[profileImage]-[email(>=240)]-|" options:0 metrics:nil views:topDict]];
    }

    
    usernameLabel = [[UILabel alloc] init];
    usernameLabel.text = @"Username";
    usernameLabel.textAlignment = NSTextAlignmentLeft;
    usernameLabel.textColor = [UIColor whiteColor];
    usernameLabel.font = [Utils getMainFontBoldWithSize:14];
    usernameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [bottomView addSubview:usernameLabel];
    
    line = [[UIView alloc] init];
    line.backgroundColor = [UIColor whiteColor];
    line.translatesAutoresizingMaskIntoConstraints = NO;
    //[bottomView addSubview:line];
    
    usernameTxt = [[UITextField alloc] init];
    usernameTxt.delegate = self;
    usernameTxt.textAlignment = NSTextAlignmentLeft;
    usernameTxt.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
    usernameTxt.font = [Utils getMainFontWithSize:12];
    usernameTxt.textColor = [UIColor blackColor];
    usernameTxt.layer.borderColor = [UIColor whiteColor].CGColor;
    usernameTxt.layer.borderWidth = 1.0f;
    usernameTxt.layer.cornerRadius = 5;
    usernameTxt.translatesAutoresizingMaskIntoConstraints = NO;
    [bottomView addSubview:usernameTxt];
    
    passwordLabel = [[UILabel alloc] init];
    passwordLabel.text = @"Password";
    passwordLabel.textAlignment = NSTextAlignmentLeft;
    passwordLabel.textColor = [UIColor whiteColor];
    passwordLabel.font = [Utils getMainFontBoldWithSize:14];
    passwordLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [bottomView addSubview:passwordLabel];
    
    line1 = [[UIView alloc] init];
    line1.backgroundColor = [UIColor whiteColor];
    line1.translatesAutoresizingMaskIntoConstraints = NO;
    //[bottomView addSubview:line1];
    
    password = [[UITextField alloc] init];
    password.delegate = self;
    password.textAlignment = NSTextAlignmentLeft;
    password.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"password"];
    password.secureTextEntry = true;
    password.font = [Utils getMainFontWithSize:12];
    password.textColor = [UIColor blackColor];
    password.layer.borderColor = [UIColor whiteColor].CGColor;
    password.layer.borderWidth = 1.0f;
    password.layer.cornerRadius = 5;
    password.translatesAutoresizingMaskIntoConstraints = NO;
    [bottomView addSubview:password];
    
    UIView *sep = [[UIView alloc] init];
    sep.backgroundColor = [UIColor redColor];
    sep.translatesAutoresizingMaskIntoConstraints = NO;
    //[bottomView addSubview:sep];
    
    save = [[UIButton alloc] init];
    [save setBackgroundColor:[UIColor whiteColor]];
    [save setTitle:@"Save" forState:UIControlStateNormal];
    [save setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    save.layer.cornerRadius = 5;
    [save addTarget:self action:@selector(onSavePressed) forControlEvents:UIControlEventTouchUpInside];
    save.translatesAutoresizingMaskIntoConstraints = NO;
    [bottomView addSubview:save];
    
    cancel = [[UIButton alloc] init];
    [cancel setBackgroundColor:[UIColor whiteColor]];
    [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancel.layer.cornerRadius = 5;
    [cancel addTarget:self action:@selector(onCancelPressed) forControlEvents:UIControlEventTouchUpInside];
    cancel.translatesAutoresizingMaskIntoConstraints = NO;
    [bottomView addSubview:cancel];
    
    NSDictionary *bottomDict = NSDictionaryOfVariableBindings(usernameLabel, usernameTxt, passwordLabel, password, save, cancel);
    
    [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[usernameLabel(==50)][usernameTxt(==usernameLabel)]-[passwordLabel(==usernameLabel)][password(==usernameLabel)]-[save(==usernameLabel)]-[cancel(==save)]" options:0 metrics:nil views:bottomDict]];
    [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[usernameLabel]-|" options:0 metrics:nil views:bottomDict]];
//    [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[line]-|" options:0 metrics:nil views:bottomDict]];
    [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[usernameTxt]-|" options:0 metrics:nil views:bottomDict]];
    [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[passwordLabel]-|" options:0 metrics:nil views:bottomDict]];
//    [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[line1]-|" options:0 metrics:nil views:bottomDict]];
    [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[password]-|" options:0 metrics:nil views:bottomDict]];
    [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[save]-|" options:0 metrics:nil views:bottomDict]];
    [bottomView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[cancel]-|" options:0 metrics:nil views:bottomDict]];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)onSavePressed
{
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    
    if ([usernameTxt.text isEqualToString:@""] || [password.text isEqualToString:@""] || [[usernameTxt.text stringByTrimmingCharactersInSet: set] length] == 0 || [[password.text stringByTrimmingCharactersInSet: set] length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Edit"
                                    message:@"You must fill in all the fields."
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        
        return;
    }
    
    if (password.text.length < 6)
    {
        [[[UIAlertView alloc] initWithTitle:@"Edit"
                                    message:@"Password must be at least 6 characters."
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        
        return;
    }

    
    //request pentru update
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setValue:password.text forKey:@"password"];
    [userInfo setValue:usernameTxt.text forKey:@"username"];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[DatabaseHandler sharedInstance] updateUser:userInfo];
    
    [[DatabaseHandler sharedInstance] setCompletionHandler:^(BOOL response) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }];

}

- (void)onCancelPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
