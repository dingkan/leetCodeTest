//
//  DKKVOProxy.m
//  dingkanCode
//
//  Created by 丁侃 on 2020/4/23.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import "DKKVOProxy.h"

@implementation DKKVOProxy
{
    @private
    NSMutableDictionary <NSString *, NSHashTable <NSObject *>*>*_kvoInfoMap;
}

-(instancetype)init{
    if (self = [super init]) {
        _kvoInfoMap = [NSMutableDictionary dictionary];
    }
    return self;
}

//添加KVO信息操作
-(BOOL)addInfoMapObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
//    会根据给定的对象，自动创建一个锁，并等待块中的代码执行完毕
    @synchronized (self) {
        if (!observer || !keyPath || ([keyPath isKindOfClass:[NSString class]] && keyPath.length <= 0)) {
            return NO;
        }
        
        NSHashTable <NSObject *>*infoMap = _kvoInfoMap[keyPath];
        if (infoMap.count == 0) {
            infoMap = [[NSHashTable alloc]initWithOptions:(NSPointerFunctionsWeakMemory) capacity:0];
            [infoMap addObject:observer];
            
            _kvoInfoMap[keyPath] = infoMap;
            return YES;
        }
        
        if (![infoMap containsObject:observer]) {
            [infoMap addObject:observer];
            return YES;
        }
        
        return NO;
    }
}

-(BOOL)removeInfoMapObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    return [self removeInfoMapObserver:observer forKeyPath:keyPath context:nil];
}


-(BOOL)removeInfoMapObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context{
    @synchronized (self) {
        
        if (!keyPath || !observer || ([keyPath isKindOfClass:[NSString class]] && keyPath.length <= 0) ) {
            return NO;
        }
        
        NSHashTable <NSObject *>*infoMap = _kvoInfoMap[keyPath];
        
        if (infoMap.count == 0) {
            return NO;
        }
        
        [infoMap removeObject:observer];
        
        if (infoMap.count == 0) {
            [_kvoInfoMap removeObjectForKey:keyPath];
            return YES;
        }
        
        return NO;
    }
}

//实际通过 DKKVOProxy 进行监听 并分发
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context{
    NSHashTable <NSObject *>*info = _kvoInfoMap[keyPath];
    
    for (NSObject *objc in info) {
        @try {
            [objc observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        } @catch (NSException *exception) {
            
            NSString *reason = [NSString stringWithFormat:@"KVO Warning : %@", [exception description]];
            NSLog(@"%@",reason);
        }
    }
    
}

-(NSArray <NSString *>*)getAllKeyPaths{
    return _kvoInfoMap.allKeys;
}


@end
