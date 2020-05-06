//
//  NSObject+DKCrashHandler.m
//  dingkanCode
//
//  Created by 丁侃 on 2020/4/20.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import "NSObject+DKCrashHandler.h"
#import "DKRuntime.h"

@implementation NSObject (DKCrashHandler)

+(void)load{
    #ifdef DEBUG
        
    #else
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            DKEXChangeImplementations([self class], @selector(forwardingTargetForSelector:), @selector(DK_forwardingTargetForSelector:));
            
            DKEXChangeClassMethod([self class], @selector(forwardingTargetForSelector:), @selector(DK_forwardingTargetForSelector:));
        });
    #endif

}

+ (id)DK_forwardingTargetForSelector:(SEL)aSelector{
    
    SEL forwarding_sel = @selector(forwardingTargetForSelector:);
    
    Method forwarding_NSObject_method = class_getClassMethod([NSObject class], forwarding_sel);
    
    Method forwarding_self_method = class_getClassMethod([self class], forwarding_sel);
    
    //判断是否有消息接受者重定向
    BOOL realize = method_getImplementation(forwarding_NSObject_method) != method_getImplementation(forwarding_self_method);
    
    if (!realize) {
        
        SEL methodSignature_sel = @selector(methodSignatureForSelector:);
        
        Method methodSignature_NSObject_method = class_getClassMethod([NSObject class], methodSignature_sel);
        
        Method methodSignature_self_method = class_getClassMethod([self class], methodSignature_sel);
        
        realize = method_getImplementation(methodSignature_NSObject_method) != method_getImplementation(methodSignature_self_method);
        
        //消息重定向
        if (!realize) {
            
            NSString *errorClassName = NSStringFromClass([self class]);
            NSString *errorSelName = NSStringFromSelector(aSelector);
            
            NSLog(@"出问题的类:%@----  出问题的方法---:%@",errorClassName, errorSelName);
            
            
            //转发处理类
            NSString *crashName = @"DKCrashObject";
            Class crashCls = NSClassFromString(crashName);
            
            if (!crashCls) {
                Class superClass = [NSObject class];
                crashCls = objc_allocateClassPair(superClass, crashName.UTF8String, 0);
                objc_registerClassPair(crashCls);
            }
            
            //如果没有这个方法
            if (!class_getClassMethod(crashCls, aSelector)) {
                Method crashMethod = class_getClassMethod(crashCls, NSSelectorFromString(@"Crash"));
                
                class_addMethod(crashCls, aSelector, method_getImplementation(crashMethod), method_getTypeEncoding(crashMethod));
            }
            
            
            return [[crashCls alloc]init];
        }
    }
    
    
    return [self DK_forwardingTargetForSelector:aSelector];
}


/**
 消息动态解析：Objective-C 运行时会调用 +resolveInstanceMethod: 或者 +resolveClassMethod:，让你有机会提供一个函数实现。我们可以通过重写这两个方法，添加其他函数实现，并返回 YES， 那运行时系统就会重新启动一次消息发送的过程。若返回 NO 或者没有添加其他函数实现，则进入下一步。
 
 消息接受者重定向：如果当前对象实现了 forwardingTargetForSelector:，Runtime 就会调用这个方法，允许我们将消息的接受者转发给其他对象。如果这一步方法返回 nil，则进入下一步。
 
 消息重定向：Runtime 系统利用 methodSignatureForSelector: 方法获取函数的参数和返回值类型。
 如果 methodSignatureForSelector: 返回了一个 NSMethodSignature 对象（函数签名），Runtime 系统就会创建一个 NSInvocation 对象，并通过 forwardInvocation: 消息通知当前对象，给予此次消息发送最后一次寻找 IMP 的机会。
 如果 methodSignatureForSelector: 返回 nil。则 Runtime 系统会发出 doesNotRecognizeSelector: 消息，程序也就崩溃了。
 */
- (id)DK_forwardingTargetForSelector:(SEL)aSelector{
    
    SEL forwarding_sel = @selector(forwardingTargetForSelector:);
    
    //获取 NSObject 的消息转发方法
    Method forwarding_NSObject_method = class_getInstanceMethod([NSObject class], forwarding_sel);
    
    //获取 当前对象的消息转发方法
    Method forwarding_objc_method = class_getInstanceMethod([self class], forwarding_sel);
    
    //是否有消息接受者重定向
    BOOL realize = method_getImplementation(forwarding_NSObject_method) != method_getImplementation(forwarding_objc_method);
    
    if (!realize) {
        
        SEL methodSignature_sel = @selector(methodSignatureForSelector:);
        
        Method methodSignature_NSObject_method = class_getInstanceMethod([NSObject class], methodSignature_sel);
        
        Method methodSignature_objc_method = class_getInstanceMethod([self class], methodSignature_sel);
        
        realize = method_getImplementation(methodSignature_NSObject_method) != method_getImplementation(methodSignature_objc_method);
        
        //是否有消息重定向
        if (!realize) {
            
            //创建一个新类
            NSString *errClassName = NSStringFromClass([self class]);
            NSString *errSelName = NSStringFromSelector(aSelector);
            
            NSLog(@"出问题的类:%@----  出问题的方法---:%@",errClassName, errSelName);
            
            //处理崩溃类
            NSString *className = @"DKCrashObject";
            Class cls = NSClassFromString(className);
            
            if (!cls) {
                Class superClass = [NSObject class];
                //创建一个新类
                cls = objc_allocateClassPair(superClass, className.UTF8String, 0);
                //注册类
                objc_registerClassPair(cls);
            }
            
            //如果没有此方法就动态创建一个
            if (!class_getInstanceMethod(cls, aSelector)) {
                Method crashMethod = class_getInstanceMethod(cls, NSSelectorFromString(@"Crash"));
                class_addMethod(cls, aSelector, method_getImplementation(crashMethod), method_getTypeEncoding(crashMethod));
            }
            
            return [[cls alloc]init];
        }
            
    }
    
    return [self DK_forwardingTargetForSelector:aSelector];
}



@end
