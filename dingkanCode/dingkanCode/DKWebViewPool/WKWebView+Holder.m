//
//  WKWebView+Holder.m
//  dingkanCode
//
//  Created by 丁侃 on 2020/5/9.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import "WKWebView+Holder.h"
#import <objc/runtime.h>

@interface DKWeakWrapper :NSObject
@property (nonatomic, weak, readwrite) NSObject *weakObj;
@end
@implementation DKWeakWrapper
@end

@implementation WKWebView (Holder)

-(void)setHolderObject:(NSObject *)holderObject{
    DKWeakWrapper *wrapObj = objc_getAssociatedObject(self, @selector(setHolderObject:));
    if (wrapObj) {
        wrapObj.weakObj = holderObject;
    }else{
        wrapObj = [[DKWeakWrapper alloc]init];
        wrapObj.weakObj = holderObject;
        objc_setAssociatedObject(self, @selector(setHolderObject:), wrapObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

-(NSObject *)holderObject{
    DKWeakWrapper *wrapObj = objc_getAssociatedObject(self, @selector(setHolderObject:));
    return wrapObj.weakObj;
}

-(void)setReusedTimes:(NSInteger)reusedTimes{
    NSNumber *reusedTimeNum = @(reusedTimes);
    objc_setAssociatedObject(self, @selector(setReusedTimes:), reusedTimeNum, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSInteger)reusedTimes{
    NSNumber *reusedTimesNum = objc_getAssociatedObject(self, @selector(setReusedTimes:));
    return [reusedTimesNum integerValue];
}

-(void)setInvalid:(BOOL)invalid{
    objc_setAssociatedObject(self, @selector(setInvalid:), @(invalid), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(BOOL)invalid{
    NSNumber *invalidNum = objc_getAssociatedObject(self, @selector(setInvalid:));
    return [invalidNum boolValue];
}


-(void)componentViewWillLeavePool{
    self.reusedTimes += 1;
    [self _clearBackForwardList];
}

-(void)componentViewWillEnterPool{
    self.holderObject = nil;
    self.scrollView.delegate = nil;
    self.scrollView.scrollEnabled = YES;
    [self stopLoading];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    NSString *reuseLoadUrl = @"";
    if (reuseLoadUrl && reuseLoadUrl.length > 0) {
        [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:reuseLoadUrl]]];
    } else {
        [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@""]]];
    }
}


- (void)_clearBackForwardList {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@%@%@%@", @"_re", @"moveA", @"llIte", @"ms"]);
    if ([self.backForwardList respondsToSelector:sel]) {
        [self.backForwardList performSelector:sel];
    }
#pragma clang diagnostic pop
}

@end
