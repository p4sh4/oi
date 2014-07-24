//
//  NSTimer+PYMBlocksSupport.h
//  Oi
//
//  Created by Pavel on 10/7/14.
//  Copyright (c) 2014 p4sh4. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (PYMBlocksSupport)

+ (NSTimer *)pym_scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void(^)())block repeats:(BOOL)repeats;

@end
