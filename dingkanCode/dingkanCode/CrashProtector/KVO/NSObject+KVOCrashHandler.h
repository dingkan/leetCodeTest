//
//  NSObject+KVOCrashHandler.h
//  dingkanCode
//
//  Created by 丁侃 on 2020/4/22.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DKKVOProxy;
NS_ASSUME_NONNULL_BEGIN

@interface NSObject (KVOCrashHandler)

@property (nonatomic, strong) DKKVOProxy *kvoProxy;

@end

NS_ASSUME_NONNULL_END
