//
//  Item.h
//  TwitterApp
//
//  Created by Diana Stefania Daia on 27/04/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Item : NSObject

@property(nonatomic, retain) PFObject *obj;
@property(nonatomic) BOOL isTweet;

@end
