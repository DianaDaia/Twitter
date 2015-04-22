//
//  TweetsCell.h
//  Twitter
//
//  Created by Diana Stefania Daia on 24/03/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *CollectionViewCellIdentifier = @"CollectionViewCellIdentifier";

@interface TweetsCell : UITableViewCell

@property(nonatomic, retain) UIView *leftView;
@property(nonatomic, retain) UIImageView *authorImage;
@property(nonatomic, retain) UILabel *authorName;
@property(nonatomic, retain) UILabel *message;
@property (nonatomic, strong) UICollectionView *collectionView;

-(void)setCollectionViewDataSourceDelegate:(id<UICollectionViewDataSource, UICollectionViewDelegate>)dataSourceDelegate index:(NSInteger)index;

@end
