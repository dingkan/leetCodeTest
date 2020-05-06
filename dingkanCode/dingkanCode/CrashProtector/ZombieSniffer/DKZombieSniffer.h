//
//  DKZombieSniffer.h
//  dingkanCode
//
//  Created by 丁侃 on 2020/4/30.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DKZombieSniffer : NSObject


+(void)installSniffer;

+(void)uninstallSniffer;

//添加白名单类
+(void)appendIgnoreClass:(Class)cls;
@end

NS_ASSUME_NONNULL_END
