//
//  PYMSignupViewController.m
//  Oi
//
//  Created by Pavel on 28/6/14.
//  Copyright (c) 2014 p4sh4. All rights reserved.
//

#import "OiSignupViewController.h"
#import "UIColor+OiColor.h"
#import "NSTimer+PYMBlocksSupport.h"
#import "PYMAuthManager.h"

static const NSTimeInterval kTimeoutTime = 15.0;

@interface OiSignupViewController ()
@property (weak, nonatomic) IBOutlet UITableViewCell *usernameCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *passwordCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *actionCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *backCell;

@property (weak, nonatomic) IBOutlet UITextField *usernameField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;
@end

@implementation OiSignupViewController

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

- (IBAction)signup:(id)sender
{
    if (self.activityIndicatorView == nil) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.actionCell addSubview:self.activityIndicatorView];
        [self.activityIndicatorView setFrame:self.actionButton.frame];
    }
    
    NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *password = [self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    __weak OiSignupViewController *weakSelf = self; // to not get retained by the block
    
    if ([username length] == 0) {
        return;
    }
    else if ([password length] < 2) {
        [self.usernameField becomeFirstResponder];
        self.actionButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        [self.actionButton setTitle:@"SELECT LONGER PASSWORD" forState:UIControlStateNormal];
        [self performSelector:@selector(resetSignupTitle) withObject:nil afterDelay:2];
    }
    else {
        NSTimer *networkTimer = [NSTimer pym_scheduledTimerWithTimeInterval:kTimeoutTime block:^{
            OiSignupViewController *strongSelf = weakSelf;
            [strongSelf timeout];
        } repeats:NO];

        self.actionButton.hidden = YES;
        [self.activityIndicatorView startAnimating];
        [PYMAuthManager signupWithUsername:username password:password completionHandler:^(BOOL successful) {
            if (successful) {
                [networkTimer invalidate];
                [self.activityIndicatorView stopAnimating];
                [self performSegueWithIdentifier:@"showFriends" sender:self];
            }
            else {
                [networkTimer invalidate];
                [self.activityIndicatorView stopAnimating];
                [self.actionButton setTitle:@"USERNAME TAKEN" forState:UIControlStateNormal];
                self.actionButton.hidden = NO;
                [self performSelector:@selector(resetSignupTitle) withObject:nil afterDelay:2];
            }
        }];
    }
}

- (IBAction)goBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self.actionButton setTitle:@"TAP TO SIGNUP" forState:UIControlStateNormal];
    return YES;
}

// handling "Next" and "Return" buttons on keyboard
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.usernameField) {
        [self.passwordField becomeFirstResponder];
    }
    else if (textField == self.passwordField) {
        [self signup:nil];
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

- (void)resetSignupTitle
{
    self.actionButton.titleLabel.font = [UIFont boldSystemFontOfSize:30];
    [self.actionButton setTitle:@"SIGN UP" forState:UIControlStateNormal];
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

- (void)timeout
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Unavailable" message:@"The connection has timed out" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    [self.activityIndicatorView stopAnimating];
    [self resetSignupTitle];
}

@end
