//
//  PYMSignupViewController.m
//  Oi
//
//  Created by Pavel on 28/6/14.
//  Copyright (c) 2014 p4sh4. All rights reserved.
//

#import "OiFirstViewController.h"
#import "UIResponder+KeyboardCache.h"
#import "UIColor+OiColor.h"
#import <Parse/Parse.h>

@interface OiFirstViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *signupCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *loginCell;
@end

@implementation OiFirstViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [UIResponder kc_cacheKeyboard:YES];
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([PFUser currentUser]) {
        [self performSegueWithIdentifier:@"showFriends" sender:nil];
    }
}

- (void)initView
{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"oi_background"]];
    [tempImageView setFrame:self.tableView.frame];
    self.tableView.backgroundView = tempImageView;
    
    self.signupCell.backgroundColor = [UIColor pym_oiRed];
    self.loginCell.backgroundColor = [UIColor pym_oiBlack];
}

@end
