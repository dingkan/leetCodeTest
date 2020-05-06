//
//  DKZombieProxy.h
//  dingkanCode
//
//  Created by 丁侃 on 2020/4/30.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DKZombieProxy : NSProxy

@property (nonatomic, assign) Class originClass;

@end

NS_ASSUME_NONNULL_END
