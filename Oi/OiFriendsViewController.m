//
//  PYMFriendsViewController.m
//  Oi
//
//  Created by Pavel on 28/6/14.
//  Copyright (c) 2014 p4sh4. All rights reserved.
//

#import "OiFriendsViewController.h"
#import "PYMTextFieldCell.h"
#import "UIColor+OiColor.h"
#import "NSTimer+PYMBlocksSupport.h"
#import "PYMAuthManager.h"
#import "OiUser.h"
#import <Parse/Parse.h>

static const int kNumberOfControlCells = 2;
static const int kFriendCellSection = 0;
static const int kControlCellSection = 1;
static const int kNumberOfSections = 2;
static const int kPlusRow = 0;
static const int kLogoutRow = 1;
static const int kNumberOfColors = 7;
static const NSTimeInterval kTimeoutTime = 15.0;

@interface OiFriendsViewController ()

//@property (strong, nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (weak, nonatomic) PYMTextFieldCell *textFieldCell;
@end

@implementation OiFriendsViewController

#pragma mark - View controller lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (![PYMAuthManager currentUser]) {
        [self.navigationController popToRootViewControllerAnimated:NO];
    }
    [self initView];
    
    // if not loaded in login view
    if (!self.user) {
        self.user = [[OiUser alloc] initWithParseUser:[PYMAuthManager currentUser]];
        
        __weak OiFriendsViewController *weakSelf = self; // to not get retained by the block
        [self.user populateFriendsFromParseWithCompletionHandler:^(BOOL successful, NSError *error) {
            if (successful) {
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:kFriendCellSection] withRowAnimation:UITableViewRowAnimationFade];
            }
        }];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tap];

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 1) {
        return kNumberOfControlCells;
    } else {
        return [self.user.friends count];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kControlCellSection && indexPath.row == kPlusRow) {
        cell.backgroundColor = [UIColor pym_oiRed];
    }
    else if (indexPath.section == kControlCellSection && indexPath.row == kLogoutRow) {
        cell.backgroundColor = [UIColor pym_oiBlack];
    }
    else {
        cell.backgroundColor = [[UIColor pym_oiColorArrayWithoutRedAndBlack] objectAtIndex:indexPath.row % kNumberOfColors];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kControlCellSection && indexPath.row == kPlusRow) {
        PYMTextFieldCell *cell = [tableView dequeueReusableCellWithIdentifier:@"staticCell" forIndexPath:indexPath];
        self.textFieldCell = cell; //save to handle keyboard return button
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:30.0];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.text = @"+";
        cell.textField.hidden = YES;
        return cell;
    }
    else if (indexPath.section == kControlCellSection && indexPath.row == kLogoutRow) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"staticCell2" forIndexPath:indexPath];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:30.0];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.text = @"LOGOUT";
        return cell;
    }
    else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"dynamicCell" forIndexPath:indexPath];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont boldSystemFontOfSize:30.0];
        cell.textLabel.textColor = [UIColor lightGrayColor];
        cell.textLabel.text = [[self.user.friends objectAtIndex:indexPath.row] username];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kControlCellSection && indexPath.row == kPlusRow) {
        PYMTextFieldCell *cell = (PYMTextFieldCell *)[tableView cellForRowAtIndexPath:indexPath];
        [cell swapLabelWithTextField];
        [cell.textField becomeFirstResponder];
    }
    else if (indexPath.section == kControlCellSection && indexPath.row == kLogoutRow) {
        NSString *actionSheetMessage = [NSString stringWithFormat:@"Logout user %@", self.user.currentUser.username];
        UIActionSheet *logoutActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                       delegate:self
                                                              cancelButtonTitle:@"Cancel"
                                                         destructiveButtonTitle:actionSheetMessage
                                                              otherButtonTitles: nil];
        [logoutActionSheet showInView:self.view];
    }
    else {
        // send Oi
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicatorView setFrame:cell.textLabel.frame];
        [cell.contentView addSubview:activityIndicatorView];
        cell.textLabel.hidden = YES;
        [activityIndicatorView startAnimating];
        
        __weak OiFriendsViewController *weakSelf = self;
        NSTimer *networkTimer = [NSTimer pym_scheduledTimerWithTimeInterval:kTimeoutTime block:^{
            OiFriendsViewController *strongSelf = weakSelf;
            [strongSelf timeout];
        } repeats:NO];
        
        [self.user sendOiToFriendAtIndex:indexPath.row completionHandler:^(BOOL successful, NSError *error) {
            if (successful) {
                [networkTimer invalidate];
                [activityIndicatorView stopAnimating];
                [activityIndicatorView removeFromSuperview];
                cell.textLabel.hidden = NO;
                cell.textLabel.text = @"SENT OI!";
                [cell.textLabel performSelector:@selector(setText:) withObject:[[self.user.friends objectAtIndex:indexPath.row] username] afterDelay:1];
            }
            else {
                [networkTimer invalidate];
                [activityIndicatorView stopAnimating];
                [activityIndicatorView removeFromSuperview];
                cell.textLabel.text = @"TRY AGAIN";
                [cell.textLabel performSelector:@selector(setText:) withObject:[[self.user.friends objectAtIndex:indexPath.row] username] afterDelay:1];

            }
        }];

    }
}

#pragma mark - UITextFieldDelegate methods

- (BOOL) textFieldShouldReturn:(UITextField *)textField {

    if (textField.text.length == 0) {
        [textField resignFirstResponder];
        [self.textFieldCell swapLabelWithTextField];
    }
    else {
        // add friend
        UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [activityIndicatorView setFrame:self.textFieldCell.textLabel.frame];
        [self.textFieldCell.contentView addSubview:activityIndicatorView];
        self.textFieldCell.textField.hidden = YES;
        [activityIndicatorView startAnimating];

        NSString *name = textField.text;
        
        __weak OiFriendsViewController *weakSelf = self; // to not get retained by the block
        NSTimer *networkTimer = [NSTimer pym_scheduledTimerWithTimeInterval:kTimeoutTime block:^{
            OiFriendsViewController *strongSelf = weakSelf;
            [strongSelf timeout];
        } repeats:NO];

        
        [self.user addFriendWithName:name completionHandler:^(BOOL successful, NSError *error) {
            if (successful) {
                [networkTimer invalidate];
                [activityIndicatorView stopAnimating];
                [activityIndicatorView removeFromSuperview];
                weakSelf.textFieldCell.textField.text = @"";
                weakSelf.textFieldCell.textField.hidden = NO;
                [weakSelf.textFieldCell swapLabelWithTextField];
                [weakSelf.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
                [textField resignFirstResponder];
            }
            else if (error) {
                [networkTimer invalidate];
                [activityIndicatorView stopAnimating];
                [activityIndicatorView removeFromSuperview];
                weakSelf.textFieldCell.textLabel.hidden = NO;
                weakSelf.textFieldCell.textLabel.text = @"NO SUCH USER";
                [weakSelf.textFieldCell.textLabel performSelector:@selector(setText:) withObject:@"+" afterDelay:1];
                [weakSelf.textFieldCell.textField resignFirstResponder];

            }
            else {
                [networkTimer invalidate];
                [activityIndicatorView stopAnimating];
                weakSelf.textFieldCell.textLabel.hidden = NO;
                weakSelf.textFieldCell.textLabel.text = @"FRIENDS ALREADY";
                [weakSelf.textFieldCell.textLabel performSelector:@selector(setText:) withObject:@"+" afterDelay:1];
                [weakSelf.textFieldCell.textField resignFirstResponder];

            }
        }];
    }
        return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    // force uppercase
    NSRange lowercaseRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
    if (lowercaseRange.location != NSNotFound) {
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:[string uppercaseString]];
        return NO;
    }
    // restrict spaces
    NSRange whitespaceRange = [string rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    if (whitespaceRange.location != NSNotFound) {
        textField.text = [textField.text stringByReplacingCharactersInRange:range withString:@""];
        return NO;
    }
    
    return YES;
}

#pragma mark - Helper methods

- (void)initView
{
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"oi_background"]];
    self.tableView.backgroundView = imageView;
}

- (void)dismissKeyboard
{
    if ([self.textFieldCell.textField isFirstResponder]) {
        [self.textFieldCell.textField resignFirstResponder];
        self.textFieldCell.textField.text = @"";
        [self.textFieldCell swapLabelWithTextField];
    }
}

- (void)timeout
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Unavailable" message:@"The connection has timed out" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
    [self.tableView reloadData];
}


#pragma mark - Table view cell editing

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kFriendCellSection) {
        return UITableViewCellEditingStyleDelete;
    } else {
        return UITableViewCellEditingStyleNone;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.user removeFriendAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {
            [PYMAuthManager logout];
            [self.navigationController popToRootViewControllerAnimated:YES];
            break;
        }
        default:
            break;
    }
}


@end
