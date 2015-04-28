//
//  LoginViewController.m
//  Twitter
//
//  Created by Lucian Tarna on 21/03/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import "LoginViewController.h"
#import "Utils.h"
#import "SignUpViewController.h"
#import "DatabaseHandler.h"
#import "AppDelegate.h"

#define APP ((AppDelegate*)[[UIApplication sharedApplication] delegate])

@interface LoginViewController () <UITextFieldDelegate>
{
    UILabel *titleView;
    
    UITextField *email;
    UITextField *password;
    
    UIButton *login;
    UIButton *signUp;
}

@end

@implementation LoginViewController

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
    titleView.text = @"Log in";
    titleView.textAlignment = NSTextAlignmentCenter;
    titleView.textColor = [UIColor whiteColor];
    titleView.font = [Utils getMainFontBoldWithSize:18];
    titleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:titleView];
    
    email = [[UITextField alloc] init];
    email.delegate = self;
    email.textAlignment = NSTextAlignmentLeft;
    email.placeholder = @"E-mail";
    email.font = [Utils getMainFontWithSize:12];
    email.textColor = [UIColor blackColor];
    email.layer.borderColor = [UIColor whiteColor].CGColor;
    email.layer.borderWidth = 1.0f;
    email.layer.cornerRadius = 5;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    email.leftView = paddingView;
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
    UIView *paddingView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    password.leftView = paddingView1;
    password.leftViewMode = UITextFieldViewModeAlways;
    password.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:password];
    
    login = [[UIButton alloc] init];
    [login setBackgroundColor:[UIColor whiteColor]];
    [login setTitle:@"Log in" forState:UIControlStateNormal];
    [login setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    login.layer.cornerRadius = 5;
    [login addTarget:self action:@selector(onLoginPressed) forControlEvents:UIControlEventTouchUpInside];
    login.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:login];
    
    signUp = [[UIButton alloc] init];
    [signUp setBackgroundColor:[UIColor whiteColor]];
    [signUp setTitle:@"Sign Up" forState:UIControlStateNormal];
    [signUp setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    signUp.layer.cornerRadius = 5;
    [signUp addTarget:self action:@selector(onSignUpPressed) forControlEvents:UIControlEventTouchUpInside];
    signUp.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:signUp];
    
    
    NSDictionary *dict = NSDictionaryOfVariableBindings(titleView, email, password, login, signUp);
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[titleView]-[email(==titleView)]-[password(==titleView)]-[login(==titleView)]-[signUp(==titleView)]-(<=300)-|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[titleView]-|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[email]-|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[password]-|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[login]-|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[signUp]-|" options:0 metrics:nil views:dict]];
    
    
}

- (void)onLoginPressed
{
    if ([email.text isEqualToString:@""] || [password.text isEqualToString:@""])
    {
        [[[UIAlertView alloc] initWithTitle:@"Log In"
                                    message:@"You must fill in all the fields."
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        
        return;
    }
    
    [[DatabaseHandler sharedInstance] checkLogInInfo:email.text Password:password.text];
    
    [[DatabaseHandler sharedInstance] setCompletionResponseHandler:^(NSString *response)
    {
        if ([response isEqualToString:@"OK"])
        {
            
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
        else if ([response isEqualToString:@"wrongCredentials"])
        {
            [[[UIAlertView alloc] initWithTitle:@"Log In"
                                        message:@"Wrong Credentials. Try again."
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Log In"
                                        message:@"Error. Try later."
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
        
    }];

}

- (void)onSignUpPressed
{
    [self presentViewController:[SignUpViewController new] animated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
