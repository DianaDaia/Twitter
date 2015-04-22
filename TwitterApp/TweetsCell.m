//
//  TweetsCell.m
//  Twitter
//
//  Created by Diana Stefania Daia on 24/03/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import "TweetsCell.h"
#import "Utils.h"

@implementation TweetsCell
@synthesize message, leftView, authorImage, authorName;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.message = [[UILabel alloc] init];
        self.message.textAlignment = NSTextAlignmentLeft;
        self.message.textColor = [UIColor blackColor];
        self.message.font = [Utils getMainFontWithSize:12];
        self.message.lineBreakMode = NSLineBreakByWordWrapping;
        self.message.numberOfLines = 0;
        [self.contentView addSubview:self.message];
        
        self.authorName = [[UILabel alloc] init];
        self.authorName.textAlignment = NSTextAlignmentLeft;
        self.authorName.textColor = [UIColor blackColor];
        //self.authorName.text = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
        self.authorName.font = [Utils getMainFontBoldWithSize:12];
        self.authorName.lineBreakMode = NSLineBreakByWordWrapping;
        self.authorName.numberOfLines = 0;
        [self.contentView addSubview:self.authorName];

        self.leftView = [[UIView alloc] init];
        //self.leftView.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:self.leftView];
        
        self.authorImage = [[UIImageView alloc] init];
        self.authorImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.leftView addSubview:self.authorImage];
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        //layout.sectionInset = UIEdgeInsetsMake(10, 10, 9, 10);
        layout.itemSize = CGSizeMake(60, 60);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:CollectionViewCellIdentifier];
        self.collectionView.backgroundColor = [UIColor whiteColor];
        self.collectionView.showsHorizontalScrollIndicator = NO;
        [self.contentView addSubview:self.collectionView];
        
        
    }
    return self;
    
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.leftView.frame = CGRectMake(5, 5, self.contentView.frame.size.width / 6, self.contentView.frame.size.height - 10);
    self.authorImage.frame = CGRectMake(0, 5, 50, 50);
    self.authorName.frame = CGRectMake(self.contentView.frame.size.width / 6 + 10, 5, self.contentView.frame.size.width - self.contentView.frame.size.width / 6 - 20, 20);
    
    self.message.frame = CGRectMake(self.contentView.frame.size.width / 6 + 10, 30, self.contentView.frame.size.width - self.contentView.frame.size.width / 6 - 20, 20);
    self.collectionView.frame = CGRectMake(self.contentView.frame.size.width / 6 + 10, 55, self.contentView.frame.size.width - self.contentView.frame.size.width / 6 - 20, self.contentView.frame.size.height - 60);
}

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index
{
    self.collectionView.dataSource = dataSourceDelegate;
    self.collectionView.delegate = dataSourceDelegate;
    self.collectionView.tag = index;
    
    [self.collectionView reloadData];
}


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
