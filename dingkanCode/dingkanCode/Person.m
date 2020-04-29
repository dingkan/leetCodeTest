//
//  Person.m
//  dingkanCode
//
//  Created by 丁侃 on 2020/4/21.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import "Person.h"

@implementation Person

-(void)tmp{
    NSLog(@"tmp");
}


@end
//
//
//+ (void)load {
//
//    Method system_arrayWithObjectsCountMethod = class_getClassMethod(self, @selector(arrayWithObjects:count:));
//    Method my_arrayWithObjectsCountMethod = class_getClassMethod(self, @selector(yxc_arrayWithObjects:count:));
//    method_exchangeImplementations(system_arrayWithObjectsCountMethod, my_arrayWithObjectsCountMethod);
//
//    Method system_objectAtIndexedSubscriptMethod = class_getInstanceMethod(NSClassFromString(@"__NSArrayI"), @selector(objectAtIndexedSubscript:));
//    Method my_objectAtIndexedSubscriptMethod = class_getInstanceMethod(self, @selector(yxc_objectAtIndexedSubscript:));
//    method_exchangeImplementations(system_objectAtIndexedSubscriptMethod, my_objectAtIndexedSubscriptMethod);
//
//    Method system_objectAtIndexMethod = class_getInstanceMethod(NSClassFromString(@"__NSArrayI"), @selector(objectAtIndex:));
//    Method my_objectAtIndexMethod = class_getInstanceMethod(self, @selector(yxc_objectAtIndex:));
//    method_exchangeImplementations(system_objectAtIndexMethod, my_objectAtIndexMethod);
//
//    Method system_addObjectMethod = class_getInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(addObject:));
//    Method my_addObjectMethod = class_getInstanceMethod(self, @selector(yxc_addObject:));
//    method_exchangeImplementations(system_addObjectMethod, my_addObjectMethod);
//
//    Method system_insertObjectAtIndexMethod = class_getInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(insertObject:atIndex:));
//    Method my_insertObjectAtIndexMethod = class_getInstanceMethod(self, @selector(yxc_insertObject:atIndex:));
//    method_exchangeImplementations(system_insertObjectAtIndexMethod, my_insertObjectAtIndexMethod);
//
//    Method system_removeObjectAtIndexMethod = class_getInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(removeObjectAtIndex:));
//    Method my_removeObjectAtIndexMethod = class_getInstanceMethod(self, @selector(yxc_removeObjectAtIndex:));
//    method_exchangeImplementations(system_removeObjectAtIndexMethod, my_removeObjectAtIndexMethod);
//
//    // 此处是可变数组的取值方法替换
//    Method system_objectAtIndexedSubscriptMethod1 = class_getInstanceMethod(NSClassFromString(@"__NSArrayM"), @selector(objectAtIndexedSubscript:));
//    Method my_objectAtIndexedSubscriptMethod1 = class_getInstanceMethod(self, @selector(yxc_objectAtIndexedSubscript1:));
//    method_exchangeImplementations(system_objectAtIndexedSubscriptMethod1, my_objectAtIndexedSubscriptMethod1);
//}
//
///**
// @[] 字面量初始化调用方法
//
// @param objects 对象
// @param cnt 数组个数
// @return 数组
// */
//+ (instancetype)yxc_arrayWithObjects:(id  _Nonnull const [])objects count:(NSUInteger)cnt {
//
//    NSMutableArray *objectArray = [NSMutableArray array];
//
//    for (int i = 0; i < cnt; i++) {
//        id object = objects[i];
//        if (object && ![object isKindOfClass:[NSNull class]]) {
//            [objectArray addObject:object];
//        }
//    }
//
//    return [NSArray arrayWithArray:objectArray];
//}
//
///**
// 数组添加一个对象
// */
//- (void)yxc_addObject:(id)anObject {
//
//    if (!anObject) return;
//    [self yxc_addObject:anObject];
//}
//
///**
// 数组插入一个对象
//
// @param anObject 对象
// @param index 待插入的下标
// */
//- (void)yxc_insertObject:(id)anObject atIndex:(NSUInteger)index {
//
//    if (!anObject) return;
//    if (index > self.count) return; // 数组可以插入下标为0这个位置，如果此处 >= 会有问题
//
//    [self yxc_insertObject:anObject atIndex:index];
//}
//
///**
// 根据下标移除某个对象
//
// @param index 需要移除的下标
// */
//- (void)yxc_removeObjectAtIndex:(NSUInteger)index {
//
//    if (index >= self.count) return;
//
//    [self yxc_removeObjectAtIndex:index];
//}
//
///**
// 通过 index 获取对象
//
// @param index 数组下标
// */
//- (id)yxc_objectAtIndex:(NSUInteger)index {
//
//    if (index >= self.count) return nil;
//
//    return [self yxc_objectAtIndex:index];
//}
//
///**
// @[] 形式获取数组对象
//
// @param idx 数组下标
// */
//- (id)yxc_objectAtIndexedSubscript:(NSUInteger)idx {
//
//    if (idx >= self.count) return nil;
//
//    return [self objectAtIndex:idx];
//}
//
///**
// @[] 形式获取数组对象
//
// @param idx 数组下标
// */
//- (id)yxc_objectAtIndexedSubscript1:(NSUInteger)idx {
//
//    if (idx >= self.count) return nil;
//
//    return [self objectAtIndex:idx];
//}
