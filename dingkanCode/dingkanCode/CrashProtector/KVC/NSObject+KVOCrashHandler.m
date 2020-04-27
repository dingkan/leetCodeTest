//
//  NSObject+KVOCrashHandler.m
//  dingkanCode
//
//  Created by 丁侃 on 2020/4/22.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import "NSObject+KVOCrashHandler.h"
#import "DKRuntime.h"
#import "DKKVOProxy.h"

@implementation NSObject (KVOCrashHandler)

static void*DKKVOProxyKey = &DKKVOProxyKey;
static NSString *const KVODefenderValue = @"dk_KVODefender";
static void*DKKVODefenderKey = &DKKVODefenderKey;


-(void)setKvoProxy:(DKKVOProxy *)kvoProxy{
    objc_setAssociatedObject(self, DKKVOProxyKey, kvoProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(DKKVOProxy *)kvoProxy{
    id kvoProxy = objc_getAssociatedObject(self, DKKVOProxyKey);
    
    if (!kvoProxy) {
        kvoProxy = [[DKKVOProxy alloc] init];
        self.kvoProxy = kvoProxy;
    }
    return kvoProxy;
}


/**
 我使用了 YSCKVOProxy 对象，在 YSCKVOProxy 对象 中使用 {keypath : [observer1, observer2 , ...](NSHashTable)} 结构的 关系哈希表 进行 observer、keyPath 之间的维护。
 然后利用 YSCKVOProxy 对象 对添加、移除、观察方法进行分发处理。
 在分类中自定义了 dealloc 的实现，移除了多余的观察者。
 */

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DKEXChangeImplementations([NSObject class], @selector(addObserver:forKeyPath:options:context:), @selector(DK_addObserver:forKeyPath:options:context:));
        
        DKEXChangeImplementations([NSObject class], @selector(removeObserver:forKeyPath:), @selector(DK_removeObserver:forKeyPath:));
        
        DKEXChangeImplementations([NSObject class], @selector(removeObserver:forKeyPath:context:), @selector(DK_removeObserver:forKeyPath:context:));
        
        DKEXChangeImplementations([NSObject class], NSSelectorFromString(@"dealloc"), @selector(DK_dealloc));
    });
}

-(void)DK_addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
    if (!isSystemClass([self class])) {
        objc_setAssociatedObject(self, DKKVODefenderKey, KVODefenderValue, OBJC_ASSOCIATION_RETAIN);
        if ([self.kvoProxy addInfoMapObserver:observer forKeyPath:keyPath options:options context:context]) {
            [self DK_addObserver:self.kvoProxy forKeyPath:keyPath options:options context:context];
        }else{
            // 添加 KVO 信息操作失败：重复添加
            NSString *className = (NSStringFromClass(self.class) == nil) ? @"" : NSStringFromClass(self.class);
            NSString *reason = [NSString stringWithFormat:@"KVO Warning : Repeated additions to the observer:%@ for the key path:'%@' from %@",
                                observer, keyPath, className];
            NSLog(@"%@",reason);
        }
    }else{
        [self DK_addObserver:observer forKeyPath:keyPath options:options context:context];
    }
}

-(void)DK_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    if (!isSystemClass([self class])) {
        
        if ([self.kvoProxy removeInfoMapObserver:observer forKeyPath:keyPath]) {
            [self DK_removeObserver:self.kvoProxy forKeyPath:keyPath];
        }else{
            
            // 移除 KVO 信息操作失败：移除了未注册的观察者
            NSString *className = NSStringFromClass(self.class) == nil ? @"" : NSStringFromClass(self.class);
            NSString *reason = [NSString stringWithFormat:@"KVO Warning : Cannot remove an observer %@ for the key path '%@' from %@ , because it is not registered as an observer", observer, keyPath, className];
            NSLog(@"%@",reason);
        }
        
    }else{
        [self DK_removeObserver:observer forKeyPath:keyPath];
    }
}

-(void)DK_removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context{
    if (!isSystemClass([self class])) {
        if ([self.kvoProxy removeInfoMapObserver:observer forKeyPath:keyPath context:context]) {
            [self DK_removeObserver:self.kvoProxy forKeyPath:keyPath context:context];
        }else{
            
            // 添加 KVO 信息操作失败：重复添加
            NSString *className = (NSStringFromClass(self.class) == nil) ? @"" : NSStringFromClass(self.class);
            NSString *reason = [NSString stringWithFormat:@"KVO Warning : Repeated additions to the observer:%@ for the key path:'%@' from %@",
                                observer, keyPath, className];
            NSLog(@"%@",reason);
        }
    }else{
        [self DK_removeObserver:observer forKeyPath:keyPath context:context];
    }
}

-(void)DK_dealloc{
    @autoreleasepool {
        if (!isSystemClass([self class])) {
            NSString *value = objc_getAssociatedObject(self, DKKVODefenderKey);
            
            if ([value isEqualToString:KVODefenderValue]) {
                NSArray *keys = [self.kvoProxy getAllKeyPaths];
                
                //任然监听
                if (keys.count > 0) {
                    
                    NSString *reason = [NSString stringWithFormat:@"KVO Warning : An instance %@ was deallocated while key value observers were still registered with it. The Keypaths is:'%@'", self, [keys componentsJoinedByString:@","]];
                    NSLog(@"%@",reason);
                }
                
                for (NSString *keyPath in keys) {
                    [self DK_removeObserver:self.kvoProxy forKeyPath:keyPath];
                }
            }
        }
    }
    
    [self DK_dealloc];
}

@end
