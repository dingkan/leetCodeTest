//
//  NSObject+KVCCrashHandler.m
//  dingkanCode
//
//  Created by 丁侃 on 2020/4/23.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import "NSObject+KVCCrashHandler.h"
#import "DKRuntime.h"

@implementation NSObject (KVCCrashHandler)

+(void)load{
#ifdef DEBUG
    
#else
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DKEXChangeImplementations([NSObject class], @selector(setValue:forKey:), @selector(DK_setValue:forKey:));
        
        DKEXChangeImplementations([NSObject class], @selector(setValue:forUndefinedKey:), @selector(DK_setValue:forUndefinedKey:));
        
        DKEXChangeImplementations([NSObject class], @selector(setNilValueForKey:), @selector(DK_setNilValueForKey:));
        
        DKEXChangeImplementations([NSObject class], @selector(valueForUndefinedKey:), @selector(DK_valueForUndefinedKey:));
        
    });
#endif

}

-(id)DK_valueForUndefinedKey:(NSString *)key{

    NSString *crashMessages = [NSString stringWithFormat:@"crashMessages :[<%@ %p> valueForUndefinedKey:]: this class is not key value coding-compliant for the key: %@",NSStringFromClass([self class]),self,key];
    NSLog(@"%@", crashMessages);
    
    return self;
}


-(void)DK_setNilValueForKey:(NSString *)key{

    NSString *crashMessages = [NSString stringWithFormat:@"crashMessages : [<%@ %p> setNilValueForKey]: could not set nil as the value for the key %@.",NSStringFromClass([self class]),self,key];
    NSLog(@"%@", crashMessages);
}

-(void)DK_setValue:(id)value forUndefinedKey:(NSString *)key{

    NSString *crashMessages = [NSString stringWithFormat:@"crashMessages : [<%@ %p> setNilValueForKey]: could not set nil as the value for the key %@.",NSStringFromClass([self class]),self,key];
    NSLog(@"%@", crashMessages);
}


-(void)DK_setValue:(id)value forKey:(NSString *)key{
    if (!key) {
        
        NSString *crashMessages = [NSString stringWithFormat:@"crashMessages : [<%@ %p> setNilValueForKey]: could not set nil as the value for the key %@.",NSStringFromClass([self class]),self,key];
        NSLog(@"%@", crashMessages);
        
        return;
    }
    
    [self DK_setValue:value forKey:key];
}



@end
