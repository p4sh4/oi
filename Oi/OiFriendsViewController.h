//
//  PYMFriendsViewController.h
//  wei
//
//  Created by Pavel on 28/6/14.
//  Copyright (c) 2014 p4sh4. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OiUser;

@interface OiFriendsViewController : UITableViewController <UITextFieldDelegate, UIActionSheetDelegate>
@property (strong, nonatomic) OiUser *user;

@end
