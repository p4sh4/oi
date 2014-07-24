//
//  PYMTextFieldCell.h
//  wei
//
//  Created by Pavel on 1/7/14.
//  Copyright (c) 2014 p4sh4. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PYMTextFieldCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UITextField *textField;

- (void)swapLabelWithTextField;

@end
