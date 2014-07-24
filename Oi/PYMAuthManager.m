//
//  PYMAuthManager.m
//  Oi
//
//  Created by Pavel on 9/7/14.
//  Copyright (c) 2014 p4sh4. All rights reserved.
//

#import "PYMAuthManager.h"
#import <Parse/Parse.h>

@implementation PYMAuthManager

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password completionHandler:(PYMAuthManagerCompletionHandler)handler
{
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
        if (error) {
            NSLog(@"Login error: %@ %@", error, [error userInfo]);
            handler(NO);
        }
        else {
            // assosiate user with device to receive push notifications
            PFInstallation *installation = [PFInstallation currentInstallation];
            installation[@"user"] = [PFUser currentUser];
            [installation saveInBackground];

            handler(YES);
        }
    }];
}

+ (void)signupWithUsername:(NSString *)username password:(NSString *)password completionHandler:(PYMAuthManagerCompletionHandler)handler
{
    PFUser *newUser = [PFUser user];
    newUser.username = username;
    newUser.password = password;
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            NSLog(@"Signup error: %@ %@", error, [error userInfo]);
            handler(NO);
        }
        else {
            // assosiate user with device to receive push notifications
            PFInstallation *installation = [PFInstallation currentInstallation];
            installation[@"user"] = [PFUser currentUser];
            [installation saveInBackground];

            handler(YES);
        }
    }];
}

+ (void)logout
{
    [PFUser logOut];
}

+ (PFUser *)currentUser
{
    return [PFUser currentUser];
}


@end
