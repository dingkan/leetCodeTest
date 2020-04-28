//
//  DKTimeProxy.m
//  dingkanCode
//
//  Created by 丁侃 on 2020/4/26.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import "DKTimeProxy.h"

@implementation DKTimeProxy


-(instancetype)initWithTarget:(id)target selector:(SEL)aSelector timer:(NSTimer *)timer{
    if (self = [super init]) {
        self.target = target;
        self.aSelector = aSelector;
        self.sourceTime = timer;
    }
    return self;
}

- (void)trigger:(id)userinfo{
    
    if (self.target && [self.target respondsToSelector:self.aSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.target performSelector:self.aSelector withObject:userinfo];
#pragma clang diagnostic pop
    }else{
        
        NSTimer *timer = self.sourceTime;
    
        if (timer) {
            [timer invalidate];
        }
        
        NSString *reason = [NSString stringWithFormat:@"*****Warning***** logic error target is %@ method is %@, reason : an object dealloc not invalidate Timer.",[self class], NSStringFromSelector(self.aSelector)];
        NSLog(@"%@",reason);
    }
    
}


@end
