//
//  DatabaseHandler.h
//  Twitter
//
//  Created by Diana Stefania Daia on 21/03/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DatabaseHandler : NSObject

+(instancetype)sharedInstance;

@property (nonatomic, copy) void (^completionHandler)(BOOL response);
@property (nonatomic, copy) void (^completionHandlerForTweets)(NSArray *tweets);
@property (nonatomic, copy) void (^completionHandlerForFollowers)(NSArray *followers);
@property (nonatomic, copy) void (^completionHandlerForFollowing)(NSArray *following);
@property (nonatomic, copy) void (^completionResponseHandler)(NSString* response);
@property (nonatomic, copy) void (^completionResponseHandlerUserInfo)(NSDictionary* response);

- (void)checkUniqueMail:(NSString*)mail;
- (void)saveUser:(NSDictionary*)userInfo;
- (void)updateUser:(NSDictionary*)userInfo;
- (void)saveTweet:(NSDictionary*)tweetInfo;
- (void)checkLogInInfo:(NSString*)mail Password:(NSString*)password;
- (void)getCurrentUser;
- (NSURL*)getGravatarURL:(NSString*)mail;
- (void)getTweetsForId:(NSString*)userId;
- (void)getAllTweets;
- (void)getUsersWithIDs:(NSMutableArray*)usersIDs;
- (void)follow;
- (void)followUser:(NSString*)userId;
- (void)unfollowUser:(NSString*)userId;
- (void)getFollowers:(NSString*)userId;
- (void)getFollowing:(NSString*)userId;
- (void)getFollowersForUsers:(NSMutableArray*)users;

@end
