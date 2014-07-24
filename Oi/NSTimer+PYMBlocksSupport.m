//
//  NSTimer+PYMBlocksSupport.m
//  Oi
//
//  Created by Pavel on 10/7/14.
//  Copyright (c) 2014 p4sh4. All rights reserved.
//

#import "NSTimer+PYMBlocksSupport.h"

@implementation NSTimer (PYMBlocksSupport)

+ (NSTimer *)pym_scheduledTimerWithTimeInterval:(NSTimeInterval)interval block:(void(^)())block repeats:(BOOL)repeats
{
    return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(pym_blockInvoke:) userInfo:[block copy] repeats:repeats];
}

+ (void)pym_blockInvoke:(NSTimer *)timer
{
    void (^block)() = timer.userInfo;
    if(block) {
        block();
    }
}

@end
