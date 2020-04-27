//
//  DKTimeProxy.m
//  dingkanCode
//
//  Created by 丁侃 on 2020/4/26.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import "DKTimeProxy.h"

@implementation DKTimeProxy

- (void)trigger:(id)userinfo{
    id strongTarget = self.target;
    
    if (strongTarget && [strongTarget respondsToSelector:self.aSelector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [strongTarget performSelector:self.aSelector withObject:userinfo];
#pragma clang diagnostic pop
    }else{
        NSTimer *sourceTime = self.sourceTime;
        if (sourceTime) {
            [sourceTime invalidate];
        }
        
        NSString *reason = [NSString stringWithFormat:@"*****Warning***** logic error target is %@ method is %@, reason : an object dealloc not invalidate Timer.",[self class], NSStringFromSelector(self.aSelector)];
        NSLog(@"%@",reason);
        
    }
}

@end
