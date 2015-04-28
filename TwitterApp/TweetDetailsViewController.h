//
//  TweetDetailsViewController.h
//  TwitterApp
//
//  Created by Diana Stefania Daia on 27/04/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TweetDelegate <NSObject>

- (void)updateData;

@end

@interface TweetDetailsViewController : UIViewController

@property(nonatomic, retain) NSString *tweetId;

@property(nonatomic, weak) id delegate;

@end
