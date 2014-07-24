//
//  UIColor+OiColor.m
//  Oi
//
//  Created by Pavel on 6/7/14.
//  Copyright (c) 2014 p4sh4. All rights reserved.
//

#import "UIColor+OiColor.h"

@implementation UIColor (OiColor)

+ (UIColor *) pym_oiRed {
    return [UIColor colorWithRed:208/255.0 green:15/255.0 blue:15/255.0 alpha:1.0];
}
+ (UIColor *) pym_oiBlack {
    return [UIColor colorWithRed:30/255.0 green:0/255.0 blue:0/255.0 alpha:1.0];
}
+ (UIColor *) pym_oiBlue {
    return [UIColor colorWithRed:51/255.0 green:128/255.0 blue:164/255.0 alpha:1.0];
}
+ (UIColor *) pym_oiYellow {
    return [UIColor colorWithRed:189/255.0 green:179/255.0 blue:73/255.0 alpha:1.0];
}
+ (UIColor *) pym_oiGreen {
    return [UIColor colorWithRed:38/255.0 green:148/255.0 blue:23/255.0 alpha:1.0];
}
+ (UIColor *) pym_oiPurple {
    return [UIColor colorWithRed:110/255.0 green:38/255.0 blue:155/255.0 alpha:1.0];
}
+ (UIColor *) pym_oiOrange {
    return [UIColor colorWithRed:200/255.0 green:95/255.0 blue:30/255.0 alpha:1.0];
}
+ (UIColor *) pym_oiDarkBlue {
    return [UIColor colorWithRed:51/255.0 green:85/255.0 blue:171/255.0 alpha:1.0];
}
+ (UIColor *) pym_oiDarkMarine {
    return [UIColor colorWithRed:44/255.0 green:99/255.0 blue:95/255.0 alpha:1.0];
}
+ (UIColor *) pym_oiDarkYellow {
    return [UIColor colorWithRed:115/255.0 green:111/255.0 blue:0/255.0 alpha:1.0];
}


+ (NSArray *) pym_oiColorArrayWithoutRedAndBlack {
    NSArray *colorArray = @[[UIColor pym_oiGreen], [UIColor pym_oiDarkMarine], [UIColor pym_oiOrange], [UIColor pym_oiPurple],[UIColor pym_oiDarkBlue], [UIColor pym_oiDarkYellow], [UIColor pym_oiBlue]];
    return colorArray;
}


@end

