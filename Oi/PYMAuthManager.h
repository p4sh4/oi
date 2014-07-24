//
//  PYMAuthManager.h
//  Oi
//
//  Created by Pavel on 9/7/14.
//  Copyright (c) 2014 p4sh4. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PFUser;

typedef void(^PYMAuthManagerCompletionHandler)(BOOL successful);

@interface PYMAuthManager : NSObject

+ (void)loginWithUsername:(NSString *)username password:(NSString *)password completionHandler:(PYMAuthManagerCompletionHandler)handler;
+ (void)signupWithUsername:(NSString *)username password:(NSString *)password completionHandler:(PYMAuthManagerCompletionHandler)handler;
+ (void)logout;
+ (PFUser *)currentUser;


@end
