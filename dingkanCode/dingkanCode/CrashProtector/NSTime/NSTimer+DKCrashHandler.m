//
//  NSTimer+DKCrashHandler.m
//  dingkanCode
//
//  Created by 丁侃 on 2020/4/26.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import "NSTimer+DKCrashHandler.h"
#import "DKRuntime.h"
#import "DKTimeProxy.h"

//1、NSTimer对其target是否可以不强引用
//2、是否找到一个合适的时机，在确定NSTimer已经失效的情况下，让NSTimer自动invalidate

//

@interface NSTimer ()
@property (nonatomic, strong) DKTimeProxy *timeProxy;
@end

@implementation NSTimer (DKCrashHandler)

static const void* DKTimeCrashHandlerKey;

-(void)setTimeProxy:(DKTimeProxy *)timeProxy{
    objc_setAssociatedObject(self, DKTimeCrashHandlerKey, timeProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(DKTimeProxy *)timeProxy{
    return objc_getAssociatedObject(self, DKTimeCrashHandlerKey);
}

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DKEXChangeClassMethod([NSTimer class], @selector(scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:), @selector(DK_scheduledTimerWithTimeInterval:target:selector:userInfo:repeats:));
    });
}

+ (NSTimer *)DK_scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo{
    if (yesOrNo) {
        
        NSTimer *time = nil;
        
        @autoreleasepool {
            DKTimeProxy *timeProxy = [[DKTimeProxy alloc]init];
            timeProxy.aSelector = aSelector;
            timeProxy.target = aTarget;
            
            
            
            time.timeProxy = timeProxy;
            timeProxy.sourceTime = time;
        }
        
        return time;
        
    }else{
        return [self DK_scheduledTimerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
    }
}


@end
