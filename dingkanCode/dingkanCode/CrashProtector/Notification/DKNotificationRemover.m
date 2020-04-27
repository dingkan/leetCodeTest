//
//  DKNotificationRemover.m
//  dingkanCode
//
//  Created by 丁侃 on 2020/4/24.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import "DKNotificationRemover.h"

@interface DKNotificationRemover()
{
    __unsafe_unretained id _observer;
}
@property (nonatomic, strong) NSMutableDictionary <NSString *, NSHashTable<NSObject *> *>*removes;

@end

@implementation DKNotificationRemover

-(instancetype)initWithObserver:(id)observer{
    if (self = [super init]) {
        self.removes = [NSMutableDictionary dictionary];
        _observer = observer;
    }
    return self;
}

-(void)addCenter:(NSNotificationCenter *)center name:(NSNotificationName)name{
    if (!center) {
        return;
    }
    
    NSHashTable <NSObject *>*infoMap = [self.removes valueForKey:name];
    
    if (infoMap.count == 0) {
        infoMap = [[NSHashTable alloc]initWithOptions:(NSPointerFunctionsWeakMemory) capacity:0];
        [infoMap addObject:center];
        self.removes[name] = infoMap;
    }

    if (![infoMap containsObject:center]) {
        [infoMap addObject:center];
    }
}

-(void)dealloc{
    
    @autoreleasepool {
        for (NSHashTable <NSObject *>*infoMap in self.removes.allValues) {
            for (NSNotificationCenter *center in infoMap.allObjects) {
                [center removeObserver:_observer];
            }
        }
    }
}

@end
