//
//  DatabaseHandler.m
//  Twitter
//
//  Created by Diana Stefania Daia on 21/03/15.
//  Copyright (c) 2015 Diana Stefania Daia. All rights reserved.
//

#import "DatabaseHandler.h"
#import <Parse/Parse.h>
#import <CommonCrypto/CommonDigest.h>

@implementation DatabaseHandler

+(instancetype)sharedInstance
{
    static DatabaseHandler * instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
    
}

- (void)checkUniqueMail:(NSString*)mail
{
    PFQuery *query = [PFQuery queryWithClassName:@"User"];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            //NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
            
            NSString *response = [[NSString alloc] init];
            response = @"unique";
            
            for (PFObject *object in objects)
            {
                if ([[object valueForKey:@"email"] isEqualToString:mail])
                {
                    response = @"duplicate";
                }
            }
            
            if (self.completionResponseHandler)
            {
                self.completionResponseHandler(response);
            }
            
            self.completionResponseHandler = nil;
            
        }
        else
        {
            if (self.completionResponseHandler)
            {
                self.completionResponseHandler(@"error");
            }
            
            self.completionResponseHandler = nil;
        }
    }];
}

- (void)saveUser:(NSDictionary*)userInfo
{
    
    PFObject *newUser = [PFObject objectWithClassName:@"User"];
    newUser[@"email"] = [userInfo valueForKey:@"email"];
    newUser[@"password"] = [userInfo valueForKey:@"password"];
    newUser[@"username"] = [userInfo valueForKey:@"username"];
    [newUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            if (self.completionHandler) {
                self.completionHandler(true);
            }
            
            self.completionHandler = nil;
        }
        else
        {
            if (self.completionHandler) {
                self.completionHandler(false);
            }
            
            self.completionHandler = nil;
        }
    }];
}

- (void)updateUser:(NSDictionary*)userInfo
{
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query getObjectInBackgroundWithId:[[NSUserDefaults standardUserDefaults] valueForKey:@"id"]  block:^(PFObject *currentUser, NSError *error)
     {
         currentUser[@"username"] = [userInfo valueForKey:@"username"];
         currentUser[@"password"] = [userInfo valueForKey:@"password"];
         
         [[NSUserDefaults standardUserDefaults] setValue:[userInfo valueForKey:@"username"] forKey:@"username"];
         [[NSUserDefaults standardUserDefaults] setValue:[userInfo valueForKey:@"password"] forKey:@"password"];
         [[NSUserDefaults standardUserDefaults] synchronize];
         
         [currentUser saveInBackground];
         
         if (self.completionHandler)
         {
             self.completionHandler(true);
         }
         
         self.completionHandler = nil;
     }];

}

- (void)saveTweet:(NSDictionary*)tweetInfo
{
    
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query getObjectInBackgroundWithId:[[NSUserDefaults standardUserDefaults] valueForKey:@"id"]  block:^(PFObject *currentUser, NSError *error)
    {
        PFObject *newTweet = [PFObject objectWithClassName:@"Tweet"];
        newTweet[@"message"] = [tweetInfo valueForKey:@"message"];
        
        
        NSMutableArray *images = [[NSMutableArray alloc] init];
        images = [tweetInfo valueForKey:@"images"];
        
        if (images.count > 0)
        {
            for (int i = 0; i < images.count; i++)
            {
                PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"image%d.png", i+1] data:[images objectAtIndex:i]];
                
                [newTweet addObject:imageFile forKey:@"images"];
            }
            
        }
        
        newTweet[@"parent"] = currentUser;
        newTweet[@"parentMail"] = [[NSUserDefaults standardUserDefaults] valueForKey:@"loggedIn"];
        newTweet[@"parentName"] = [[NSUserDefaults standardUserDefaults] valueForKey:@"username"];
        
        [newTweet saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                if (self.completionHandler) {
                    self.completionHandler(true);
                }
                
                self.completionHandler = nil;
            }
            else
            {
                if (self.completionHandler) {
                    self.completionHandler(false);
                }
                
                self.completionHandler = nil;
            }
        }];

    }];
    
}

- (void)checkLogInInfo:(NSString*)mail Password:(NSString*)password
{
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            //NSLog(@"Successfully retrieved %lu scores.", (unsigned long)objects.count);
            
            NSString *response = [[NSString alloc] init];
            response = @"wrongCredentials";
            
            for (PFObject *object in objects)
            {
                if ([[object valueForKey:@"email"] isEqualToString:mail] && [[object valueForKey:@"password"] isEqualToString:password])
                {
                    response = @"OK";
                }
            }
            
            if (self.completionResponseHandler)
            {
                self.completionResponseHandler(response);
            }
            
            self.completionResponseHandler = nil;
            
        }
        else
        {
            if (self.completionResponseHandler)
            {
                self.completionResponseHandler(@"error");
            }
            
            self.completionResponseHandler = nil;
        }
    }];

}

- (void)getCurrentUser
{
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"email" equalTo:[[NSUserDefaults standardUserDefaults] valueForKey:@"loggedIn"]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
            
            [userInfo setValue:[[objects objectAtIndex:0] valueForKey:@"username"] forKey:@"username"];
            [userInfo setValue:[[objects objectAtIndex:0] valueForKey:@"password"] forKey:@"password"];
            [userInfo setValue:[[objects objectAtIndex:0] objectId] forKey:@"id"];
            
            if (self.completionResponseHandlerUserInfo)
            {
                self.completionResponseHandlerUserInfo(userInfo);
            }
            
            self.completionResponseHandlerUserInfo = nil;
            
        }
        else
        {
            if (self.completionResponseHandlerUserInfo)
            {
                self.completionResponseHandlerUserInfo(nil);
            }
            
            self.completionResponseHandlerUserInfo = nil;
        }
    }];
     
}

- (void)getTweetsForId:(NSString *)userId
{
    
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query getObjectInBackgroundWithId:userId  block:^(PFObject *currentUser, NSError *error)
     {
         PFQuery *query = [PFQuery queryWithClassName:@"Tweet"];
         [query addDescendingOrder:@"createdAt"];
         [query whereKey:@"parent" equalTo:currentUser];
         
         [query findObjectsInBackgroundWithBlock:^(NSArray *tweets, NSError *error)
         {
             if (!error)
             {
                 if (self.completionHandlerForTweets)
                 {
                     self.completionHandlerForTweets(tweets);
                 }
                 
                 self.completionHandlerForTweets = nil;
             }
             else
             {
                 if (self.completionHandlerForTweets)
                 {
                     self.completionHandlerForTweets(nil);
                 }
                 
                 self.completionHandlerForTweets = nil;
             }
         }];
 
     
     }];

}

- (void)getAllTweets
{
    PFQuery *query = [PFQuery queryWithClassName:@"Relationship"];
    [query whereKey:@"followerId" equalTo:[[NSUserDefaults standardUserDefaults] valueForKey:@"id"]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *following, NSError *error)
     {
         if (!error)
         {
             PFQuery *queryT = [PFQuery queryWithClassName:@"Tweet"];
             [queryT addDescendingOrder:@"createdAt"];
             
             [queryT findObjectsInBackgroundWithBlock:^(NSArray *tweets, NSError *error)
              {
                  if (!error)
                  {
                      NSMutableArray *allTweets = [[NSMutableArray alloc] init];
                      
                      for (int i = 0; i < tweets.count; i++)
                      {
                          NSString *parent = [[[tweets objectAtIndex:i] objectForKey:@"parent"] objectId];
                          
                          if (![parent isEqualToString:[[NSUserDefaults standardUserDefaults] valueForKey:@"id"]])
                          {
                              
                              for (int j = 0; j < following.count; j++)
                              {
                                  if ([[[following objectAtIndex:j] valueForKey:@"followedId"] isEqualToString:parent])
                                  {
                                      [allTweets addObject:[tweets objectAtIndex:i]];
                                  }
                              }
                              
                          }
                          else
                          {
                              [allTweets addObject:[tweets objectAtIndex:i]];
                          }
                    }
                      
                      //NSLog(@"%@", allTweets);
                      
                      
                      if (self.completionHandlerForTweets)
                      {
                          self.completionHandlerForTweets(allTweets);
                      }
                      
                      self.completionHandlerForTweets = nil;
                      
                  }
                  else
                  {
                      if (self.completionHandlerForTweets)
                      {
                          self.completionHandlerForTweets(nil);
                      }
                      
                      self.completionHandlerForTweets = nil;
                  }
              }];

             
         }
         
     }];
}

- (NSURL*)getGravatarURL:(NSString*)mail
{
    NSString *gravatarEndPoint = [NSString stringWithFormat:@"http://www.gravatar.com/avatar/%@", [self md5:mail]];
    
    return [NSURL URLWithString:gravatarEndPoint];
}

- (NSString *)md5:(NSString *)input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

- (void)getUsersWithIDs:(NSMutableArray*)usersIDs;
{
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"objectId" containedIn:usersIDs];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error)
     {
         if (!error)
         {
             if (self.completionHandlerForTweets)
             {
                 self.completionHandlerForTweets(users);
             }
             
             self.completionHandlerForTweets = nil;
         }
         else
         {
             if (self.completionHandlerForTweets)
             {
                 self.completionHandlerForTweets(nil);
             }
             
             self.completionHandlerForTweets = nil;
         }
     }];

}

- (void)follow
{
    PFQuery *query = [PFQuery queryWithClassName:@"User"];
    [query whereKey:@"objectId" notEqualTo:[[NSUserDefaults standardUserDefaults] valueForKey:@"id"]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error)
     {
         if (!error)
         {
             PFQuery *query1 = [PFQuery queryWithClassName:@"Relationship"];
             [query1 whereKey:@"followerId" equalTo:[[NSUserDefaults standardUserDefaults] valueForKey:@"id"]];
             
             [query1 findObjectsInBackgroundWithBlock:^(NSArray *following, NSError *error)
              {
                  if (!error)
                  {
                      NSMutableArray *newUsers = [[NSMutableArray alloc] init];
                      
                      for (int i = 0; i < users.count; i++)
                      {
                          BOOL followed = false;
                          
                          for (int j = 0; j < following.count; j++)
                          {
                              if ([[[users objectAtIndex:i] objectId] isEqualToString:[[following objectAtIndex:j] objectForKey:@"followedId"]])
                              {
                                  followed = true;
                              }

                          }
                          
                          if (!followed)
                          {
                              [newUsers addObject:[users objectAtIndex:i]];
                          }
                      }
                      
                      //NSLog(@"%@", newUsers);
                      
                      
                      if (self.completionHandlerForFollowing)
                      {
                          self.completionHandlerForFollowing(newUsers);
                      }
                      
                  }
                  else
                  {
                      if (self.completionHandlerForFollowing)
                      {
                          self.completionHandlerForFollowing(nil);
                      }
                      
                  }
                  
                  self.completionHandlerForFollowing = nil;
              }];

         }
    }];

}

- (void)followUser:(NSString*)userId
{
    PFObject *newRelationship = [PFObject objectWithClassName:@"Relationship"];
    newRelationship[@"followerId"] = [[NSUserDefaults standardUserDefaults] valueForKey:@"id"];
    newRelationship[@"followedId"] = userId;
    
    [newRelationship saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            if (self.completionHandler)
            {
                self.completionHandler(true);
            }
            
            self.completionHandler = nil;
        }
        else
        {
            if (self.completionHandler)
            {
                self.completionHandler(false);
            }
            
            self.completionHandler = nil;
        }
    }];

}

- (void)unfollowUser:(NSString*)userId
{
    PFQuery *query = [PFQuery queryWithClassName:@"Relationship"];
    [query whereKey:@"followerId" equalTo:[[NSUserDefaults standardUserDefaults] valueForKey:@"id"]];
    [query whereKey:@"followedId" equalTo:userId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *relationships, NSError *error)
     {
         if (!error)
         {
             for (int i = 0; i < relationships.count; i++)
             {
                 PFObject *relationship = [relationships objectAtIndex:i];
                 [relationship deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                     if (succeeded)
                     {
                         if (self.completionHandler)
                         {
                             self.completionHandler(true);
                         }
                         
                         self.completionHandler = nil;
                     }
                     else
                     {
                         if (self.completionHandler)
                         {
                             self.completionHandler(false);
                         }
                         
                         self.completionHandler = nil;
                     }
                 }];

             }
         }
         
     }];

}

- (void)getFollowers:(NSString*)userId
{
    PFQuery *query = [PFQuery queryWithClassName:@"Relationship"];
    [query whereKey:@"followedId" equalTo:userId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *followers, NSError *error)
     {
         if (!error)
         {
             if (self.completionHandlerForFollowers)
             {
                 self.completionHandlerForFollowers(followers);
             }
             
         }
         else
         {
             if (self.completionHandlerForFollowers)
             {
                 self.completionHandlerForFollowers(nil);
             }
             
         }
         
         self.completionHandlerForFollowers = nil;
     }];

}

- (void)getFollowing:(NSString*)userId
{
    PFQuery *query = [PFQuery queryWithClassName:@"Relationship"];
    [query whereKey:@"followerId" equalTo:userId];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *following, NSError *error)
     {
         if (!error)
         {
             if (self.completionHandlerForFollowing)
             {
                 self.completionHandlerForFollowing(following);
             }
             
         }
         else
         {
             if (self.completionHandlerForFollowing)
             {
                 self.completionHandlerForFollowing(nil);
             }
             
         }
         
         self.completionHandlerForFollowing = nil;
     }];

}

- (void)getFollowersForUsers:(NSMutableArray*)users
{
    //NSLog(@"%@", users);
    PFQuery *query = [PFQuery queryWithClassName:@"Relationship"];
    [query whereKey:@"followedId" containedIn:users];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *followers, NSError *error)
     {
         
         NSLog(@"%@", followers);
         
         
         
         if (!error)
         {
             if (self.completionHandlerForFollowers)
             {
                 self.completionHandlerForFollowers(followers);
             }
             
         }
         else
         {
             if (self.completionHandlerForFollowers)
             {
                 self.completionHandlerForFollowers(nil);
             }
             
         }
         
         self.completionHandlerForFollowers = nil;
     }];

}


@end
