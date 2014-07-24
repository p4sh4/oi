//
//  OiLoginViewController.m
//  Oi
//
//  Created by Pavel on 28/6/14.
//  Copyright (c) 2014 p4sh4. All rights reserved.
//

#import "OiLoginViewController.h"
#import "OiFriendsViewController.h"
#import "UIColor+OiColor.h"
#import "NSTimer+PYMBlocksSupport.h"
#import "PYMAuthManager.h"
#import "OiUser.h"

static const NSTimeInterval kTimeoutTime = 15.0;

@interface OiLoginViewController ()
@property (strong, nonatomic) OiUser *currentUser;

@property (weak, nonatomic) IBOutlet UITableViewCell *passwordCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *usernameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *actionCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *backCell;

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation OiLoginViewController

#pragma mark - View controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
}

- (void)viewDidLayoutSubviews
{
    [self.usernameField becomeFirstResponder];
}

#pragma mark - Button actions

- (IBAction)login:(id)sender
{
    if (self.activityIndicatorView == nil) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.actionCell addSubview:self.activityIndicatorView];
        [self.activityIndicatorView setFrame:self.actionButton.frame];
    }
    
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    self.actionButton.hidden = YES;
    [self.activityIndicatorView startAnimating];
    
    __weak OiLoginViewController *weakSelf = self; // to not get retained by the block
    
    NSTimer *networkTimer = [NSTimer pym_scheduledTimerWithTimeInterval:kTimeoutTime block:^{
        OiLoginViewController *strongSelf = weakSelf;
        [strongSelf timeout];
    } repeats:NO];

    [PYMAuthManager loginWithUsername:username password:password completionHandler:^(BOOL successful) {
        if (successful) {
            [networkTimer invalidate];
            weakSelf.currentUser = [[OiUser alloc] initWithParseUser:[PYMAuthManager currentUser]];
            [weakSelf.currentUser populateFriendsFromParseWithCompletionHandler:^(BOOL successful, NSError *error) {
                if (successful) {
                    [weakSelf.activityIndicatorView stopAnimating];
                    [weakSelf.activityIndicatorView removeFromSuperview];
                    [weakSelf performSegueWithIdentifier:@"showFriends" sender:self];
                }
            }];            
        }
        else {
            [networkTimer invalidate];
            [weakSelf.actionButton setTitle:@"LOGIN FAILED" forState:UIControlStateNormal];
            weakSelf.actionButton.hidden = NO;
            [weakSelf.activityIndicatorView stopAnimating];
            [self performSelector:@selector(resetLoginTitle) withObject:nil afterDelay:3.0];
        }
    }];
}

- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate methods

// handling "Next" and "Return" buttons on keyboard
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameField) {
        [self.passwordField becomeFirstResponder];
    }
    else if (textField == self.passwordField) {
        [self login:nil];
    }
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSRange lowercaseRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
    if (lowercaseRange.location != NSNotFound) {
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:[string uppercaseString]];
        return NO;
    }
    NSRange whitespaceRange = [string rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if (whitespaceRange.location != NSNotFound) {
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:@""];
        return NO;
    }
    return YES;
}

#pragma mark - Helper methods

- (void)resetLoginTitle
{
    [self.actionButton setTitle:@"TAP TO LOGIN" forState:UIControlStateNormal];
}

- (void)initView
{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"oi_background"]];
    [tempImageView setFrame:self.tableView.frame];
    self.tableView.backgroundView = tempImageView;
    
    self.usernameCell.backgroundColor = [UIColor pym_oiBlue];
    self.passwordCell.backgroundColor = [UIColor pym_oiOrange];
    self.actionCell.backgroundColor = [UIColor pym_oiRed];
    self.backCell.backgroundColor = [UIColor pym_oiBlack];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    OiFriendsViewController *oiFriendsViewController = (OiFriendsViewController *)segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"showFriends"]) {
        oiFriendsViewController.user = self.currentUser;
    }
}

- (void)timeout
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Unavailable" message:@"The connection has timed out" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    [self.activityIndicatorView stopAnimating];
    [self resetLoginTitle];
}

@end
