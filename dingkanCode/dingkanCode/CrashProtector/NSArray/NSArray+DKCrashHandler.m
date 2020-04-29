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
        
        //越界崩溃方式一：[array objectAtIndex:1000];
        DKEXChangeImplementations(NSClassFromString(@"__NSArrayI"), @selector(objectAtIndex:), @selector(DK_ObjectAtIndex:));
        
        //越界崩溃方式二：arr[1000];   Subscript n:下标、脚注
        DKEXChangeImplementations(NSClassFromString(@"__NSArrayI"), @selector(objectAtIndexedSubscript:), @selector(DK_objectAtIndexedSubscript:));
        
        
    });
}

-(id)DK_ObjectAtIndex:(NSUInteger)index{
    if (index > self.count - 1) {
        return nil;
    }else{
        return [self DK_ObjectAtIndex:index];
    }
}

-(id)DK_objectAtIndexedSubscript:(NSUInteger)idx{
    if (idx > self.count - 1) {
        return nil;
    }else{
        return [self DK_objectAtIndexedSubscript:idx];
    }
}

@end


@implementation NSMutableArray (DKCrashHandler)

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        DKEXChangeImplementations([NSMutableArray class], @selector(removeObject:), @selector(DK_removeObject:));
        
        DKEXChangeImplementations(objc_getClass("__NSArrayM"), @selector(addObject:), @selector(DK_addObject:));
        
        DKEXChangeImplementations(objc_getClass("__NSArrayM"), @selector(removeObjectAtIndex:), @selector(DK_removeObjectAtIndex:));
        
        DKEXChangeImplementations(objc_getClass("__NSArrayM"), @selector(insertObject:atIndex:), @selector(DK_insertObject:atIndex:));
        
        DKEXChangeImplementations(objc_getClass("__NSArrayM"), @selector(objectAtIndex:), @selector(DK_objectAtIndex:));
        
        DKEXChangeImplementations(objc_getClass("__NSArrayM"), @selector(objectAtIndexedSubscript:), @selector(DK_objectAtIndexedSubscript:));
        
        DKEXChangeImplementations(objc_getClass("__NSArrayM"), @selector(replaceObjectAtIndex:withObject:), @selector(DK_replaceObjectAtIndex:withObject:));
    });
}

-(void)DK_replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject{
    if (index >= self.count || anObject == nil) {
        
    }else{
        [self DK_replaceObjectAtIndex:index withObject:anObject];
    }
}

-(id)DK_objectAtIndexedSubscript:(NSUInteger)idx{
    if (idx > self.count - 1) {
        return nil;
    }else{
        return [self DK_objectAtIndexedSubscript:idx];
    }
}

-(id)DK_objectAtIndex:(NSUInteger)index{
    if (self.count == 0 || index >= self.count) {
        NSLog(@"%s call -objectAtIndex:", __FUNCTION__);
        return nil;
    }else{
        return [self DK_objectAtIndex:index];
    }
}

-(void)DK_insertObject:(id)anObject atIndex:(NSUInteger)index{
    if (anObject == nil || index >= self.count) {
        
        NSLog(@"%s call -insertObject:atIndex:", __FUNCTION__);
    }else{
        [self DK_insertObject:anObject atIndex:index];
    }
}

-(void)DK_removeObjectAtIndex:(NSUInteger)index{
    if (self.count <= 0) {
        NSLog(@"%s call -removeObjectAtIndex:, but argument obj is nil", __FUNCTION__);
        return;
    }
    
    if (index >= self.count) {
        NSLog(@"%s index out of bound", __FUNCTION__);
        return;
    }
    
    [self DK_removeObjectAtIndex:index];
}

-(void)DK_addObject:(id)anObject{
    if (anObject == nil) {
        NSLog(@"%s call -addObject:, but argument obj is nil", __FUNCTION__);
        return;
    }
    [self DK_addObject:anObject];
}

-(void)DK_removeObject:(id)anObject{
    if (anObject == nil) {
        NSLog(@"%s call -removeObject:, but argument obj is nil", __FUNCTION__);
        return;
    }
    [self DK_removeObject:anObject];
}


@end



@implementation NSDictionary (DKCrashHandler)

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DKEXChangeClassMethod([NSDictionary class], @selector(dictionaryWithObjects:forKeys:count:), @selector(DK_dictionaryWithObjects:forKeys:count:));
    });
}

+(instancetype)DK_dictionaryWithObjects:(id  _Nonnull const [])objects forKeys:(id<NSCopying>  _Nonnull const [])keys count:(NSUInteger)cnt{
    NSUInteger index = 0;
    id _Nonnull __unsafe_unretained newObjects[cnt];
    id _Nonnull __unsafe_unretained newKeys[cnt];
    for (int i = 0; i < cnt; i ++) {
        id tmpItem = objects[i];
        id tmpKey = keys[i];
        if (tmpItem == nil || tmpKey == nil) {
            NSString *reason = [NSString stringWithFormat:@"target is %@ method is %s, reason: NSDictionary constructor appear nil", NSStringFromClass([self class]),__FUNCTION__];
            NSLog(@"%@",reason);
            continue;
        }
        
        newObjects[index] = objects[i];
        newKeys[index] = keys[i];
        index ++;
    }
    return [self dictionaryWithObjects:newObjects forKeys:newKeys count:index];
}


@end



@implementation NSMutableDictionary (DKCrashHandler)


+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DKEXChangeImplementations(objc_getClass("__NSDictionaryM"), @selector(setObject:forKey:), @selector(DK_setObject:forKey:));
        
        DKEXChangeImplementations(objc_getClass("__NSDictionaryM"), @selector(setObject:forKeyedSubscript:), @selector(DK_setObject:forKeyedSubscript:));
        
        DKEXChangeImplementations(objc_getClass("__NSDictionaryM"), @selector(removeObjectForKey:), @selector(DK_removeObjectForKey:));
    });
}

-(void)DK_removeObjectForKey:(id)aKey{
    if (aKey) {
        [self DK_removeObjectForKey:aKey];
    }else{
        NSString *reason = [NSString stringWithFormat:@"target is %@ method is %s, reason: NSMutableDictionary constructor appear nil", NSStringFromClass([self class]),__FUNCTION__];
        NSLog(@"%@",reason);
    }
}

-(void)DK_setObject:(id)obj forKeyedSubscript:(id<NSCopying>)key{
    if (obj && key) {
        [self DK_setObject:obj forKeyedSubscript:key];
    }else{
        NSString *reason = [NSString stringWithFormat:@"target is %@ method is %s, reason: NSMutableDictionary constructor appear nil", NSStringFromClass([self class]),__FUNCTION__];
        NSLog(@"%@",reason);
    }
}

-(void)DK_setObject:(id)anObject forKey:(id<NSCopying>)aKey{
    if (anObject && aKey) {
        [self DK_setObject:anObject forKey:aKey];
    }else{
        NSString *reason = [NSString stringWithFormat:@"target is %@ method is %s, reason: NSMutableDictionary constructor appear nil", NSStringFromClass([self class]),__FUNCTION__];
        NSLog(@"%@",reason);
    }
    
}


@end


@implementation NSCache(DKCrashHandler)


+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DKEXChangeImplementations([self class], @selector(setObject:forKey:), @selector(DK_setObject:forKey:));
        
        DKEXChangeImplementations([self class], @selector(setObject:forKey:cost:), @selector(DK_setObject:forKey:cost:));
    });
}

-(void)DK_setObject:(id)obj forKey:(id)key cost:(NSUInteger)g{
    if (obj && key) {
        [self DK_setObject:obj forKey:key cost:g];
    }else{
        
        NSString *reason = [NSString stringWithFormat:@"target is %@ method is %s, reason: NSMutableDictionary constructor appear nil", NSStringFromClass([self class]),__FUNCTION__];
        NSLog(@"%@",reason);
    }
    
}

-(void)DK_setObject:(id)obj forKey:(id)key{
    if (obj && key) {
        [self DK_setObject:obj forKey:key];
    }else{
        NSString *reason = [NSString stringWithFormat:@"target is %@ method is %s, reason: NSMutableDictionary constructor appear nil", NSStringFromClass([self class]),__FUNCTION__];
        NSLog(@"%@",reason);
    }
}

@end
