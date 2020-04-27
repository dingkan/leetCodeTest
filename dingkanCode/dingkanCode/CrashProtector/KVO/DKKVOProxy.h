//
//  DKKVOProxy.h
//  dingkanCode
//
//  Created by 丁侃 on 2020/4/23.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DKKVOProxy : NSObject

//添加KVO信息操作
-(BOOL)addInfoMapObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;

-(BOOL)removeInfoMapObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

-(BOOL)removeInfoMapObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(nullable void *)context;

//实际通过 DKKVOProxy 进行监听 并分发
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSKeyValueChangeKey,id> *)change context:(nullable void *)context;

-(NSArray <NSString *>*)getAllKeyPaths;
@end

NS_ASSUME_NONNULL_END
