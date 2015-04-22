//
//  UserCell.h
//  Twitter
//
//  Created by Diana Stefania Daia on 28/03/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCell : UITableViewCell

@property(nonatomic, retain) UIImageView *userImage;
@property(nonatomic, retain) UILabel *username;
@property(nonatomic, retain) UILabel *followers;

@end
