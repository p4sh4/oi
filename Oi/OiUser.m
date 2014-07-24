//
//  OiUser.m
//  Oi
//
//  Created by Pavel on 9/7/14.
//  Copyright (c) 2014 p4sh4. All rights reserved.
//

#import "OiUser.h"
#import "PYMAuthManager.h"
#import <Parse/Parse.h>

@implementation OiUser

- (instancetype)initWithParseUser:(PFUser *)user
{
    self = [super init];
    if (self) {
        _currentUser = user;
        _friendsRelation = [_currentUser objectForKey:@"friendsRelation"];
        _friends = [[NSMutableArray alloc] init];
        return self;
    }
    return nil;
}

- (void)populateFriendsFromParseWithCompletionHandler:(OiUserCompletionHandler)handler
{
    PFQuery *friendsQuery = [_friendsRelation query];
    [friendsQuery orderByAscending:@"username"];
    
    __weak OiUser *weakSelf = self;
    
    [friendsQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@" %@ %@", error, [error userInfo]);
            handler(NO, error);
        } else {
            [weakSelf.friends addObjectsFromArray:objects];
            handler(YES, nil);
        }
    }];
}

- (void)addFriendWithName:(NSString *)name completionHandler:(OiUserCompletionHandler)handler
{
    for (PFUser *user in _friends) {
        if ([user.username isEqual:name]) {
            NSLog(@"Friends already");
            handler(NO, nil);
            return;
        }
    }
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" equalTo:name];
    
    __weak OiUser *weakSelf = self;

    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            if (error.code == 101) {
                NSLog(@"No such user");
                handler(NO, error);
            }
        }
        else {
            PFUser *user = (PFUser *)object;
            [weakSelf.friendsRelation addObject:user];
            [weakSelf.friends addObject:user];
            [weakSelf.currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@" %@ %@", error, [error userInfo]);
                }
            }];
            handler(YES, nil);
        }
    }];

}

- (void)removeFriendAtIndex:(NSInteger)index
{
    PFUser *removedFriend = [_friends objectAtIndex:index];
    [_friends removeObject:removedFriend];
    [_friendsRelation removeObject:removedFriend];

    NSLog(@"Friend to remove: %@", removedFriend.username);
    
    [_currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@" %@ %@", error, [error userInfo]);
        } else {
            NSLog(@"Friend removed");
        }
    }];
}

- (void)sendOiToFriendAtIndex:(NSInteger)index completionHandler:(OiUserCompletionHandler)handler
{
    PFQuery *usernameQuery = [PFUser query];
    [usernameQuery whereKey:@"username" equalTo:[[_friends objectAtIndex:index] username]];
    
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" matchesQuery:usernameQuery];
    
    NSString *pushMessage = [NSString stringWithFormat:@"From %@", _currentUser.username];
    NSDictionary *pushData = @{@"alert": pushMessage, @"badge": @0, @"sound": @"oi_rev.wav"};
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery];
    [push setData:pushData];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Error: %@ %@", error, [error userInfo]);
            handler(NO, error);
        }
        else {
            handler(YES, nil);
        }
    }];

}

@end
