//
//  UIColor+OiColor.h
//  Oi
//
//  Created by Pavel on 6/7/14.
//  Copyright (c) 2014 p4sh4. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (OiColor)

+ (UIColor *) pym_oiRed;
+ (UIColor *) pym_oiBlack;
+ (UIColor *) pym_oiBlue;
+ (UIColor *) pym_oiYellow;
+ (UIColor *) pym_oiGreen;
+ (UIColor *) pym_oiPurple;
+ (UIColor *) pym_oiOrange;

+ (NSArray *) pym_oiColorArrayWithoutRedAndBlack;

@end
