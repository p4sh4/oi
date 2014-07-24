//
//  OiUser.h
//  Oi
//
//  Created by Pavel on 9/7/14.
//  Copyright (c) 2014 p4sh4. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFUser;
@class PFRelation;

typedef void(^OiUserCompletionHandler)(BOOL successful, NSError *error);

@interface OiUser : NSObject

@property (strong, nonatomic) PFUser *currentUser;
@property (strong, nonatomic) PFRelation *friendsRelation;
@property (strong, nonatomic) NSMutableArray *friends;

//- (instancetype)initWithParseUser:(PFUser *)user; // designated initialiser
//- (instancetype)initWithCurrentUserAndFriends:(OiUserCompletionHandler)handler;

- (instancetype)initWithParseUser:(PFUser *)user;

- (void)addFriendWithName:(NSString *)name completionHandler:(OiUserCompletionHandler)handler;
- (void)removeFriendAtIndex:(NSInteger)index;
- (void)sendOiToFriendAtIndex:(NSInteger)index completionHandler:(OiUserCompletionHandler)handler;

- (void)populateFriendsFromParseWithCompletionHandler:(OiUserCompletionHandler)handler;

@end
