//
//  NSNotificationCenter+DKCrashHandler.m
//  dingkanCode
//
//  Created by 丁侃 on 2020/4/24.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import "NSNotificationCenter+DKCrashHandler.h"
#import "DKRuntime.h"
#import "DKNotificationRemover.h"

/**

 iOS 9.0之后，苹果已针对未移除做处理，这里之争对iOS9.0之前的奔溃做处理

 */

@implementation NSNotificationCenter (DKCrashHandler)

static void *DKNotificationRemoverKey = &DKNotificationRemoverKey;

+(void)load{
#ifdef DEBUG
    
#else
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DKEXChangeImplementations([NSNotificationCenter class], @selector(addObserver:selector:name:object:), @selector(DK_addObserver:selector:name:object:));
    });
#endif

}

-(void)DK_addObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)aName object:(id)anObject{
    
    @autoreleasepool {
        DKNotificationRemover *remover = objc_getAssociatedObject(observer, DKNotificationRemoverKey);
        if (!remover) {
            remover = [[DKNotificationRemover alloc]initWithObserver:observer];
            
            objc_setAssociatedObject(observer, DKNotificationRemoverKey, remover, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        
        [remover addCenter:self name:aName];
    }
 
    [self DK_addObserver:observer selector:aSelector name:aName object:anObject];
}

@end
