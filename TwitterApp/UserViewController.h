//
//  UserViewController.h
//  Twitter
//
//  Created by Diana Stefania Daia on 28/03/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@protocol UserUpdate <NSObject>

- (void)updateData;

@end

@interface UserViewController : UIViewController

@property(nonatomic, retain) PFObject *userProfile;
@property(nonatomic, retain) NSArray *userTweets;

@property(nonatomic, weak) id delegate;

@end
