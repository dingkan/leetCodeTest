//
//  DKRuntime.h
//  dingkanCode
//
//  Created by 丁侃 on 2020/4/20.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "NSMethodSignature+CrashHandler.h"

/*
 unrecognized selector sent to instance（找不到对象方法的实现）
 unrecognDKEXChangeImplementationss（找不到类方法实现）
 KVO Crash
 KVC Crash
 NSNotification Crash
 NSTimer Crash
 Container Crash（集合类操DKEXChangeClassMethod例如数组越界，插入 nil 等）
 NSString Crash （字符串类操作造成的崩溃）
 Bad Access Crash （野指针）
 Threading Crash （非主线程刷 UI）
 NSNull Crash
 */

//是否有覆盖的方法
CG_INLINE BOOL
DKHasOverrideSuperInstanceMethod(Class targetClass, SEL targetSelector){
    Method targetMethod = class_getInstanceMethod(targetClass, targetSelector);
    if (!targetMethod) {
        return NO;
    }
    
    Method superMethod = class_getInstanceMethod(class_getSuperclass(targetClass), targetSelector);
    if (!superMethod) {
        return YES;
    }
    
    return targetMethod != superMethod;
}

CG_INLINE BOOL
DKHasOverrideSuperClassMethod(Class targetClass, SEL targetSelector){
    Method targetMethod = class_getClassMethod(targetClass, targetSelector);
    
    if (!targetMethod) {
        return NO;
    }
    
    Method superMethod = class_getClassMethod(class_getSuperclass(targetClass), targetSelector);
    if (!superMethod) {
        return YES;
    }
    
    return targetMethod != superMethod;
}

//交换两个类中的对象方法
CG_INLINE BOOL
DKEXChangeImplementationsInTwoClasses(Class _fromClass, SEL _originSelector, Class _toClass, SEL _newSelector){
    if (!_fromClass || !_toClass) {
        return NO;
    }
    
    Method originMethod = class_getInstanceMethod(_fromClass, _originSelector);
    Method newMethod = class_getInstanceMethod(_toClass, _newSelector);
    
    if (!newMethod) {
        return NO;
    }
    
    BOOL isAddNewMethod = class_addMethod(_fromClass, _originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    
    if (isAddNewMethod) {
        
        //如果添加成功了，说明fromclass原先没有_originSelector方法，这里需要替换空方法，防止交换的时候崩溃
        IMP oriMethodIMP = method_getImplementation(originMethod) ?: imp_implementationWithBlock(^(id selfObject){});
        const char* oriMethodOfTypeEncoding = method_getTypeEncoding(originMethod) ?: "v@:";
        
        class_replaceMethod(_toClass, _newSelector, oriMethodIMP, oriMethodOfTypeEncoding);
        
    }else{
        method_exchangeImplementations(originMethod, newMethod);
    }
    
    return YES;
}

//交换两个类中的类方法
CG_INLINE BOOL
DKEXChangeClassMethodInTwoClass(Class _fromClass, SEL _originSelector, Class _toClass, SEL _newSelector){
    
    //类方法实际上是储存在类对象的类(即元类)中，即类方法相当于元类的实例方法,所以只需要把元类传入，其他逻辑和交互实例方法一样。
    Class MFromClass = object_getClass(_fromClass);
    Class MToClass = object_getClass(_toClass);
//       class_swizzleInstanceMethod(class2, originalSEL, replacementSEL);
    
    return DKEXChangeImplementationsInTwoClasses(MFromClass, _originSelector, MToClass, _newSelector);
    
    
//    if (!_fromClass || !_toClass) {
//        return NO;
//    }
//
//    Method originMethod = class_getClassMethod(_fromClass, _originSelector);
//    Method newMethod = class_getClassMethod(_toClass, _newSelector);
//
//    if (!newMethod) {
//        return NO;
//    }
//
//    BOOL isAddMethoded = class_addMethod(_fromClass, _originSelector, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
//
//    if (isAddMethoded) {
//
//        IMP oriMethodIMP = method_getImplementation(originMethod) ?: imp_implementationWithBlock(^(id selfObject){});
//        const char* oriMethodTypeEncoding = method_getTypeEncoding(originMethod) ?: "v@:";
//
//        class_replaceMethod(_toClass, _newSelector, oriMethodIMP, oriMethodTypeEncoding);
//
//    }else{
//        method_exchangeImplementations(originMethod, newMethod);
//    }
//
//    return YES;
}


CG_INLINE BOOL
DKEXChangeImplementations(Class _fromClass, SEL _originSelector, SEL newSelector){
    return DKEXChangeImplementationsInTwoClasses(_fromClass, _originSelector, _fromClass, newSelector);
}

CG_INLINE BOOL
DKEXChangeClassMethod(Class _fromClass, SEL _originSelector, SEL newSelector){
    return DKEXChangeClassMethodInTwoClass(_fromClass, _originSelector, _fromClass, newSelector);
}

//block重写某个对象方法
CG_INLINE BOOL
DKOverrideImplementation(Class targetClass, SEL targetSelector, id(^implementationBlock)(__unsafe_unretained Class originClass, SEL originCMD, IMP(^originalIMPProvider)(void))){
    Method originMethod = class_getInstanceMethod(targetClass, targetSelector);
    IMP originIMP = method_getImplementation(originMethod);
    
    BOOL hasOverride = DKHasOverrideSuperInstanceMethod(targetClass, targetSelector);
    
    IMP (^originalIMPProvider)(void) = ^IMP(void){
        IMP result = NULL;
        
        if (hasOverride) {
            result = originIMP;
        }else{
            Class superClass = class_getSuperclass(targetClass);
            result = class_getMethodImplementation(superClass, targetSelector);
        }
        
        if (!result) {
            result = imp_implementationWithBlock(^(id selfObject){
                NSLog(@"%@", [NSString stringWithFormat:@"%@ 没有初始实现，%@\n%@", NSStringFromSelector(targetSelector), selfObject, [NSThread callStackSymbols]]);
            });
        }
        
        return result;
    };

    if (hasOverride) {
        method_setImplementation(originMethod, imp_implementationWithBlock(implementationBlock(targetClass, targetSelector, originalIMPProvider)));
    }else{
        
        const char* typeEncoding = method_getTypeEncoding(originMethod) ?: [targetClass instanceMethodSignatureForSelector:targetSelector].DK_typeEncoding;
        class_addMethod(targetClass, targetSelector, imp_implementationWithBlock(implementationBlock(targetClass, targetSelector, originalIMPProvider)), typeEncoding);
    }
    return YES;
}

//block重写某个类方法
CG_INLINE BOOL
DKOverrideClassMethod(Class targetClass, SEL targetSelector, id(^implementationBlock)(__unsafe_unretained Class originClass, SEL originCMD, IMP(^originalIMPProvider)(void))){
    Method originMethod = class_getClassMethod(targetClass, targetSelector);
    IMP originIMP = method_getImplementation(originMethod);
    
    BOOL hasOverride = DKHasOverrideSuperClassMethod(targetClass, targetSelector);
    
    IMP (^originalIMPProvider)(void) = ^IMP(void){
        IMP result = NULL;
        
        if (hasOverride) {
            result = originIMP;
        }else{
            Class superClass = class_getSuperclass(targetClass);
            result = class_getMethodImplementation(superClass, targetSelector);
        }
        
        if (!result) {
            result = imp_implementationWithBlock(^(id selfObject){
                NSLog(@"%@", [NSString stringWithFormat:@"%@ 没有初始实现，%@\n%@", NSStringFromSelector(targetSelector), selfObject, [NSThread callStackSymbols]]);
            });
        }
            
        return result;
    };
    
    if (hasOverride) {
        method_setImplementation(originMethod, imp_implementationWithBlock(implementationBlock(targetClass, targetSelector, originalIMPProvider)));
    }else{
        
        const char* typeEncoding = method_getTypeEncoding(originMethod) ?: [targetClass methodSignatureForSelector:targetSelector].DK_typeEncoding;
        class_addMethod(targetClass, targetSelector, imp_implementationWithBlock(implementationBlock(targetClass, targetSelector, originalIMPProvider)), typeEncoding);
    
    }
    return YES;
}


/**
 用block 重写 无参数无返回值的方法
 */
CG_INLINE BOOL
DKExtendImplementationOfVoidMethodWithoutArguments(Class targetClass, SEL targetSelector, void(^implementationBlock)(__kindof NSObject *selfObject)){
    return DKOverrideClassMethod(targetClass, targetSelector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {
        
        void (^block)(__unsafe_unretained __kindof NSObject *selfObject) = ^(__unsafe_unretained __kindof NSObject *selfObject){
        
            void(* originIMPProvider)(id, SEL);
            originIMPProvider = (void(*)(id, SEL))originalIMPProvider();
            originIMPProvider(selfObject, originCMD);
            
            implementationBlock(selfObject);
        };
        
        #if __has_feature(objc_arc)
        return block;
        #else
        return [block copy];
        #endif
        
    });
 
}



/**
 用block重写 某个class 的某个无参数 && 带返回值的方法， 会自动在调用block之前先调用改方法原本的实现
 */
#define DKExtendImplementationOfNonVoidMethodWithoutArguments(_targetClass, _targetSelector, _returnType, _implementationBlock)    DKOverrideImplementation(_targetClass, _targetSelector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {\
        return ^_returnType(__unsafe_unretained __kindof NSObject *selfObject){\
            _returnType (*originSelectorIMP)(id,SEL);\
            originSelectorIMP = (_returnType(*)(id,SEL))originalIMPProvider();\
            _returnType result = originSelectorIMP(selfObject, originCMD);\
            return _implementationBlock(selfObject, result);\
    };\
});


/**
 用block重写某个class 的带一个参数返回值为void 的方法
 */
#define DKExtendImplementationOfVoidMethodWithSingleArguments(_targetClass, _targetSelector, _argumentType, _implementationBlock)    DKOverrideImplementation(_targetClass, _targetSelector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {\
        return ^(__unsafe_unretained __kindof NSObject *selfObject, _argumentType firstArgv){\
            void(*originSelectorIMP)(id, SEL, _argumentType);\
            originSelectorIMP = (void(*)(id, SEL, _argumentType))originalIMPProvider();\
            originSelectorIMP(selfObject, originCMD, firstArgv);\
            _implementationBlock(selfObject, firstArgv);\
    };\
});

#define DKExtendImplementationOfVoidMethodWithTwoArguments(_targetClass, _targetSelector, _argumentType1, _argumentType2, _implementationBlock)    DKOverrideImplementation(_targetClass, _targetSelector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {\
        return ^(__unsafe_unretained __kindof NSObject *selfObject, _argumentType1 firstArgv, _argumentType2 secondArgv){\
            void(*originSelectorIMP)(id, SEL, _argumentType1, _argumentType2);\
            originSelectorIMP = (void(*)(id, SEL, _argumentType1, _argumentType2))originalIMPProvider();\
            originSelectorIMP(selfObject, originCMD, firstArgv, secondArgv);\
            _implementationBlock(selfObject, firstArgv, secondArgv);\
    };\
});


/**
 用block重写某个class 的带一个参数带返回值 的方法
 */
#define DKExtendImplementationOfNonVoidMethodWithSingleArguments(_targetClass, _targetSelector, _argumentType, _returnType, _implementationBlock) DKOverrideImplementation(_targetClass, _targetSelector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {\
    return ^_returnType (__unsafe_unretained __kindof NSObject *selfObject, _argumentType firstArgv) {\
        \
        _returnType (*originSelectorIMP)(id, SEL, _argumentType);\
        originSelectorIMP = (_returnType (*)(id, SEL, _argumentType))originalIMPProvider();\
        _returnType result = originSelectorIMP(selfObject, originCMD, firstArgv);\
        \
        return _implementationBlock(selfObject, firstArgv, result);\
    };\
});


#define DKExtendImplementationOfNonVoidMethodWithTwoArguments(_targetClass, _targetSelector, _returnType, _argumentType1, _argumentType2, _implementationBlock) DKOverrideImplementation(_targetClass, _targetSelector, ^id(__unsafe_unretained Class originClass, SEL originCMD, IMP (^originalIMPProvider)(void)) {\
    return ^_returnType(__unsafe_unretained __kindof NSObject *selfObject, _argumentType1 firstArgv, _argumentType2 secondArgv){\
        _returnType (*originSelectorIMP)(id, SEL, _argumentType1, _argumentType2);\
        originSelectorIMP = (_returnType(*)(id, SEL, _argumentType1, _argumentType2))originalIMPProvider();\
        _returnType result = originSelectorIMP(selfObject, originCMD, firstArgv, secondArgv);\
        return _implementationBlock(selfObject, result, firstArgv, secondArgv);\
        };\
});\




//判断是否是系统类
static inline BOOL isSystemClass(Class cls){
    BOOL isSystem = NO;
    NSString *clsString = NSStringFromClass(cls);
    
    if ([clsString hasPrefix:@"NS"] || [clsString hasPrefix:@"__NS"] || [clsString hasPrefix:@"OS_xpc"]) {
        isSystem = YES;
        return isSystem;
    }
    
    NSBundle *mainBundle = [NSBundle bundleForClass:cls];
    if (mainBundle == [NSBundle mainBundle]) {
        isSystem = NO;
    }else{
        isSystem = YES;
    }
    return isSystem;
}


NS_ASSUME_NONNULL_BEGIN

@interface DKRuntime : NSObject

@end

NS_ASSUME_NONNULL_END
