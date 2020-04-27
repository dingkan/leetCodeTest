//
//  NSArray+DKCrashHandler.m
//  dingkanCode
//
//  Created by 丁侃 on 2020/4/23.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import "NSArray+DKCrashHandler.h"
#import "DKRuntime.h"

@implementation NSArray (DKCrashHandler)

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        DKEXChangeImplementations(NSClassFromString(@"__NSPlaceholderArray"), @selector(initWithObjects:count:), @selector(DK_initWithObjects:count:));
//        
//        DKEXChangeImplementations(NSClassFromString(@"__NSArray0"), @selector(objectAtIndex:), @selector(DK_objectAtIndex:));
//        DKEXChangeImplementations(NSClassFromString(@"__NSSingleObjectArrayI"), @selector(objectAtIndex:), @selector(DK_objectAtIndex:));
//        DKEXChangeImplementations(NSClassFromString(@"__NSArrayI"), @selector(objectAtIndex:), @selector(DK_objectAtIndex:));
//                                  
//        DKEXChangeImplementations(NSClassFromString(@"__NSArray0"), @selector(arrayByAddingObject:), @selector(DK_arrayByAddingObject:));
//        DKEXChangeImplementations(NSClassFromString(@"__NSSingleObjectArrayI"), @selector(arrayByAddingObject:), @selector(DK_arrayByAddingObject:));
//        DKEXChangeImplementations(NSClassFromString(@"__NSArrayI"), @selector(arrayByAddingObject:), @selector(DK_arrayByAddingObject:));
    });
}

-(NSArray *)DK_arrayByAddingObject:(id)anObject{
    if (!anObject) {
        return self;
    }
    
    return [self DK_arrayByAddingObject:anObject];
}


-(instancetype)DK_initWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)cnt{
    NSInteger newCnt = 0;
    for (int i = 0; i < cnt; i ++) {
        if (!objects[i]) {
            break;
        }
        newCnt ++;
    }
    
    return [self DK_initWithObjects:objects count:newCnt];
}


-(id)DK_objectAtIndex:(NSUInteger)index{
    if (index >= self.count) {
        return nil;
    }
    
    return [self DK_objectAtIndex:index];
}

@end
