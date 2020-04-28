//
//  DKTimeProxy.h
//  dingkanCode
//
//  Created by 丁侃 on 2020/4/26.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DKTimeProxy : NSObject

@property (nonatomic, weak) NSTimer *sourceTime;

@property (nonatomic, weak) id target;

@property (nonatomic) SEL aSelector;

- (void)trigger:(id)userinfo;

-(instancetype)initWithTarget:(id)target selector:(SEL)aSelector timer:(NSTimer *)timer;

@end

NS_ASSUME_NONNULL_END
