//
//  PYMTextFieldCell.m
//  wei
//
//  Created by Pavel on 1/7/14.
//  Copyright (c) 2014 p4sh4. All rights reserved.
//

#import "PYMTextFieldCell.h"

@implementation PYMTextFieldCell

- (void)swapLabelWithTextField {
    if (self.textLabel.hidden == NO && self.textField.hidden == YES) {
        self.textLabel.hidden = YES;
        self.textField.hidden = NO;
    }
    else if (self.textLabel.hidden == YES && self.textField.hidden == NO) {
        self.textLabel.hidden = NO;
        self.textField.hidden = YES;
    }
}

@end
