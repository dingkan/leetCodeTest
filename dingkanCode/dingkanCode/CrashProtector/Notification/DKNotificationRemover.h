//
//  DKNotificationRemover.h
//  dingkanCode
//
//  Created by 丁侃 on 2020/4/24.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DKNotificationRemover : NSObject

-(instancetype)initWithObserver:(id)observer;

-(void)addCenter:(NSNotificationCenter *)center name:(NSNotificationName)name;
@end

NS_ASSUME_NONNULL_END
