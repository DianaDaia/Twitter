//
//  UserCell.m
//  Twitter
//
//  Created by Diana Stefania Daia on 28/03/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import "UserCell.h"
#import "Utils.h"

@implementation UserCell
@synthesize userImage, username, followers;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.userImage = [[UIImageView alloc] init];
        self.userImage.contentMode = UIViewContentModeScaleAspectFit;
        self.userImage.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.userImage];
        
        self.username = [[UILabel alloc] init];
        self.username.textAlignment = NSTextAlignmentLeft;
        self.username.textColor = [UIColor blackColor];
        self.username.font = [Utils getMainFontBoldWithSize:14];
        self.username.lineBreakMode = NSLineBreakByWordWrapping;
        self.username.numberOfLines = 0;
        self.username.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.username];
        
        self.followers = [[UILabel alloc] init];
        self.followers.textAlignment = NSTextAlignmentLeft;
        self.followers.textColor = [UIColor blackColor];
        self.followers.font = [Utils getMainFontWithSize:12];
        self.followers.lineBreakMode = NSLineBreakByWordWrapping;
        self.followers.numberOfLines = 0;
        self.followers.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.followers];

    }
    
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    NSDictionary *dict = NSDictionaryOfVariableBindings(username, userImage, followers);
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[userImage]-|" options:0 metrics:nil views:dict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[username]-[followers(==username)]-|" options:0 metrics:nil views:dict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[userImage(==50)]-[username]-|" options:0 metrics:nil views:dict]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[userImage(==50)]-[followers]-|" options:0 metrics:nil views:dict]];

}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
