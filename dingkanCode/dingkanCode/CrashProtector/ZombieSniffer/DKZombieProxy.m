//
//  DKZombieProxy.m
//  dingkanCode
//
//  Created by 丁侃 on 2020/4/30.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import "DKZombieProxy.h"

@implementation DKZombieProxy

- (BOOL)respondsToSelector: (SEL)aSelector
{
    return [self.originClass instancesRespondToSelector:aSelector];
}

- (NSMethodSignature *)methodSignatureForSelector: (SEL)sel
{
    return [self.originClass instanceMethodSignatureForSelector:sel];
}

- (void)forwardInvocation: (NSInvocation *)invocation
{
    [self _throwMessageSentExceptionWithSelector: invocation.selector];
}

#define LXDZombieThrowMesssageSentException() [self _throwMessageSentExceptionWithSelector: _cmd]
- (Class)class
{
    LXDZombieThrowMesssageSentException();
    return nil;
}

- (BOOL)isEqual:(id)object
{
    LXDZombieThrowMesssageSentException();
    return NO;
}

- (NSUInteger)hash
{
    LXDZombieThrowMesssageSentException();
    return 0;
}

- (id)self
{
    LXDZombieThrowMesssageSentException();
    return nil;
}

- (BOOL)isKindOfClass:(Class)aClass
{
    LXDZombieThrowMesssageSentException();
    return NO;
}

- (BOOL)isMemberOfClass:(Class)aClass
{
    LXDZombieThrowMesssageSentException();
    return NO;
}

- (BOOL)conformsToProtocol:(Protocol *)aProtocol
{
    LXDZombieThrowMesssageSentException();
    return NO;
}

- (BOOL)isProxy
{
    LXDZombieThrowMesssageSentException();
    
    return NO;
}

- (id)retain
{
    LXDZombieThrowMesssageSentException();
    return nil;
}

- (oneway void)release
{
    LXDZombieThrowMesssageSentException();
}

- (id)autorelease
{
    LXDZombieThrowMesssageSentException();
    return nil;
}

- (void)dealloc
{
    LXDZombieThrowMesssageSentException();
    [super dealloc];
}

- (NSUInteger)retainCount
{
    LXDZombieThrowMesssageSentException();
    return 0;
}

- (NSZone *)zone
{
    LXDZombieThrowMesssageSentException();
    return nil;
}

- (NSString *)description
{
    LXDZombieThrowMesssageSentException();
    return nil;
}

#pragma private
-(void)_throwMessageSentExceptionWithSelector:(SEL)selector{
//    @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"(-[%@ %@]) was sent to a zombie object at address: %p", NSStringFromClass(self.originClass), NSStringFromSelector(selector), self] userInfo:nil];
    
    NSLog(@"%@",[NSString stringWithFormat:@"(-[%@ %@]) was sent to a zombie object at address: %p", NSStringFromClass(self.originClass), NSStringFromSelector(selector), self]);
}

@end
