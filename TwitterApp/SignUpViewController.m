//
//  SignUpViewController.m
//  Twitter
//
//  Created by Lucian Tarna on 21/03/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import "SignUpViewController.h"
#import "Utils.h"
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "DatabaseHandler.h"

#define APP ((AppDelegate*)[[UIApplication sharedApplication] delegate])

@interface SignUpViewController () <UITextFieldDelegate>
{
    UILabel *titleView;
    
    UITextField *username;
    UITextField *email;
    UITextField *password;
    
    UIButton *signUp;
    UIButton *cancel;
}

@end

@implementation SignUpViewController

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
    self.view.backgroundColor = [Utils colorFromHex:@"#8471BA"];
    
    titleView = [[UILabel alloc] init];
    titleView.text = @"Sign Up";
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.textColor = [UIColor whiteColor];
    titleView.font = [Utils getMainFontBoldWithSize:18];
    titleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:titleView];
    
    username = [[UITextField alloc] init];
    username.delegate = self;
    username.textAlignment = NSTextAlignmentLeft;
    username.placeholder = @"Username";
    username.font = [Utils getMainFontWithSize:12];
    username.textColor = [UIColor blackColor];
    username.layer.borderColor = [UIColor whiteColor].CGColor;
    username.layer.borderWidth = 1.0f;
    username.layer.cornerRadius = 5;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    username.leftView = paddingView;
    username.leftViewMode = UITextFieldViewModeAlways;
    username.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:username];
    
    email = [[UITextField alloc] init];
    email.delegate = self;
    email.textAlignment = NSTextAlignmentLeft;
    email.placeholder = @"E-mail";
    email.font = [Utils getMainFontWithSize:12];
    email.textColor = [UIColor blackColor];
    email.layer.borderColor = [UIColor whiteColor].CGColor;
    email.layer.borderWidth = 1.0f;
    email.layer.cornerRadius = 5;
    UIView *paddingView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    email.leftView = paddingView1;
    email.leftViewMode = UITextFieldViewModeAlways;
    email.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:email];
    
    password = [[UITextField alloc] init];
    password.delegate = self;
    password.textAlignment = NSTextAlignmentLeft;
    password.placeholder = @"Password";
    password.secureTextEntry = true;
    password.font = [Utils getMainFontWithSize:12];
    password.textColor = [UIColor blackColor];
    password.layer.borderColor = [UIColor whiteColor].CGColor;
    password.layer.borderWidth = 1.0f;
    password.layer.cornerRadius = 5;
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    password.leftView = paddingView2;
    password.leftViewMode = UITextFieldViewModeAlways;
    password.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:password];
    
    signUp = [[UIButton alloc] init];
    [signUp setBackgroundColor:[UIColor whiteColor]];
    [signUp setTitle:@"Sign Up" forState:UIControlStateNormal];
    [signUp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    signUp.layer.cornerRadius = 5;
    [signUp addTarget:self action:@selector(onSignUpPressed) forControlEvents:UIControlEventTouchUpInside];
    signUp.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:signUp];
    
    cancel = [[UIButton alloc] init];
    [cancel setBackgroundColor:[UIColor whiteColor]];
    [cancel setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancel.layer.cornerRadius = 5;
    [cancel addTarget:self action:@selector(onCancelPressed) forControlEvents:UIControlEventTouchUpInside];
    cancel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:cancel];
    
    NSDictionary *dict = NSDictionaryOfVariableBindings(titleView, username, email, password, signUp, cancel);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[titleView]-[username(==titleView)]-[email(==titleView)]-[password(==titleView)]-[signUp(==titleView)]-[cancel(==titleView)]-(<=250)-|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[titleView]-|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[username]-|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[email]-|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[password]-|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[signUp]-|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[cancel]-|" options:0 metrics:nil views:dict]];
}

- (void)onSignUpPressed
{
    NSCharacterSet *set = [NSCharacterSet whitespaceCharacterSet];
    if ([[email.text stringByTrimmingCharactersInSet: set] length] == 0 || [[password.text stringByTrimmingCharactersInSet: set] length] == 0 || [[username.text stringByTrimmingCharactersInSet: set] length] == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"Sign Up"
                                    message:@"You must fill in all the fields."
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        
        return;

    }
    
    
    if ([email.text isEqualToString:@""] || [password.text isEqualToString:@""] || [username.text isEqualToString:@""])
    {
        [[[UIAlertView alloc] initWithTitle:@"Sign Up"
                                    message:@"You must fill in all the fields."
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        
        return;
    }
    
    if (![self NSStringIsValidEmail:email.text])
    {
        [[[UIAlertView alloc] initWithTitle:@"Sign Up"
                                    message:@"The e-mail is not valid."
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        
        return;
    }
    
    if (password.text.length < 6)
    {
        [[[UIAlertView alloc] initWithTitle:@"Sign Up"
                                    message:@"Password must be at least 6 characters."
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        
        return;
    }

    
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
    [userInfo setValue:email.text forKey:@"email"];
    [userInfo setValue:password.text forKey:@"password"];
    [userInfo setValue:username.text forKey:@"username"];
    
    
    [[DatabaseHandler sharedInstance] checkUniqueMail:email.text];
    
    [[DatabaseHandler sharedInstance] setCompletionResponseHandler:^(NSString *response) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        if ([response isEqualToString:@"duplicate"])
        {
            
            [[[UIAlertView alloc] initWithTitle:@"Sign Up"
                                        message:@"There is already an account with this email address."
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            
            
        }
        else
        {
            [[DatabaseHandler sharedInstance] saveUser:userInfo];
        }
        
    }];

    
    [[DatabaseHandler sharedInstance] setCompletionHandler:^(BOOL response) {
        
        if (response)
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            //salveaza in nsuserdefaults
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"LoggedIn"];
            [[NSUserDefaults standardUserDefaults] setValue:email.text forKey:@"loggedIn"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                [[DatabaseHandler sharedInstance] getCurrentUser];
                
                [[DatabaseHandler sharedInstance] setCompletionResponseHandlerUserInfo:^(NSDictionary *userInfo) {
                    
                    
                    if (userInfo == nil)
                    {
                        [[[UIAlertView alloc] initWithTitle:@"Me"
                                                    message:@"Error. Try later."
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil] show];
                    }
                    else
                    {
                        [[NSUserDefaults standardUserDefaults] setValue:[userInfo valueForKey:@"username"] forKey:@"username"];
                        [[NSUserDefaults standardUserDefaults] setValue:[userInfo valueForKey:@"password"] forKey:@"password"];
                        [[NSUserDefaults standardUserDefaults] setValue:[userInfo valueForKey:@"id"] forKey:@"id"];
                        [[NSUserDefaults standardUserDefaults] synchronize];
                        
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            APP.window.rootViewController = APP.tabBarController;
                        });
                        
                    }
                    
                }];
                
            });

            
        }
        else
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            [[[UIAlertView alloc] initWithTitle:@"Sign Up"
                                        message:@"Error. Try later."
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            
        }
        
    }];
    
    
    
}

- (void)onCancelPressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL)NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
