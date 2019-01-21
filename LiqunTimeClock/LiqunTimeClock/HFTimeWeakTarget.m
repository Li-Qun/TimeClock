//
//  HFTimeWeakTarget.m
//  LiqunTimeClock
//
//  Created by HF on 2019/1/10.
//  Copyright © 2019年 HF. All rights reserved.
//

#import "HFTimeWeakTarget.h"

@implementation HFTimeWeakTarget

+ (NSTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval
                                     target:(id)aTarget
                                   selector:(SEL)aSelector
                                   userInfo:(id)userInfo
                                    repeats:(BOOL)repeats{
    
    HFTimeWeakTarget * timer = [HFTimeWeakTarget new];
    timer.target = aTarget;
    timer.selector = aSelector;
    //-------------------------------------------------------------此处的target已经被换掉了不是原来的VIewController而是TimerWeakTarget类的对象timer
    timer.timer = [NSTimer scheduledTimerWithTimeInterval:interval target:timer selector:@selector(fire:) userInfo:userInfo repeats:repeats];
    return timer.timer;
}

- (void)fire:(NSTimer *)timer {
    if (self.target) {
        [self.target performSelector:self.selector withObject:timer.userInfo];
    } else {
        [self.timer invalidate];
    }
}


@end
