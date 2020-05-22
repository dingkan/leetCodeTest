//
//  DKWebViewPool.m
//  dingkanCode
//
//  Created by 丁侃 on 2020/5/8.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import "DKWebViewPool.h"
#import "WKWebView+Holder.h"

@interface DKWebViewPool()

@property (nonatomic, strong, readwrite) dispatch_semaphore_t lock;

@property (nonatomic, strong, readwrite) NSMutableDictionary <NSString *, NSMutableSet<__kindof WKWebView *> *>*dequeueWebViews;

@property (nonatomic, strong, readwrite) NSMutableDictionary <NSString *, NSMutableSet<__kindof WKWebView *> *>*enqueueWebViews;

@end

@implementation DKWebViewPool

+(DKWebViewPool *)sharedInstance{
    static dispatch_once_t onceToken;
    static DKWebViewPool *singleton;
    dispatch_once(&onceToken, ^{
        singleton = [[DKWebViewPool alloc]init];
    });
    return singleton;
}


-(instancetype)init{
    if (self = [super init]) {
        _dequeueWebViews = @{}.mutableCopy;
        _enqueueWebViews = @{}.mutableCopy;
        _lock = dispatch_semaphore_create(1);
        
        //memory
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearAllResuableWebViews) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.dequeueWebViews removeAllObjects];
    [self.enqueueWebViews removeAllObjects];
    self.dequeueWebViews = nil;
    self.enqueueWebViews = nil;
}

#pragma public
-(__kindof WKWebView *)dequeueWebViewWithClass:(Class)webViewClass webViewHolder:(NSObject *)webViewHolder{
    if (![webViewClass isSubclassOfClass:[WKWebView class]]) {
        return nil;
    }
    
    [self _tryCompactWeakHolderOfWebView];
    
    __kindof WKWebView *dequeueWebView = [self _getWebViewWithClass:webViewClass];
    dequeueWebView.holderObject = webViewHolder;
    return dequeueWebView;
}

-(void)enqueueWebView:(__kindof WKWebView *)webView{
    if (!webView) {
        return;
    }
    
    [webView removeFromSuperview];
    
    if (webView.reusedTimes >= 50 || webView.invalid) {
        [self removeReusbaleWebView:webView];
    }else{
        [self _recycleWebView:webView];
    }
}

-(void)reloadAllReusableWebViews{
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    for (NSMutableSet *viewSet in _enqueueWebViews.allValues) {
        for (__kindof WKWebView *webView in viewSet) {
            [webView componentViewWillEnterPool];
        }
    }
    dispatch_semaphore_signal(_lock);
}

-(void)clearAllReusableWebViews{
    [self _tryCompactWeakHolderOfWebView];
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    [_enqueueWebViews removeAllObjects];
    
    dispatch_semaphore_signal(_lock);
}

-(void)removeReusbaleWebView:(__kindof WKWebView *)webView{
    if (!webView) {
        return;
    }
    
    if ([webView respondsToSelector:@selector(componentViewWillEnterPool)]) {
        [webView componentViewWillEnterPool];
    }
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    NSString *webViewClassString = NSStringFromClass([webView class]);
    
    if ([[_dequeueWebViews allKeys] containsObject:webViewClassString]) {
        NSMutableSet *viewSet = [_dequeueWebViews objectForKey:webViewClassString];
        [viewSet removeObject:webView];
    }
    
    if ([[_enqueueWebViews allKeys] containsObject:webViewClassString]) {
        NSMutableSet *viewSet = [_enqueueWebViews objectForKey:webViewClassString];
        [viewSet removeObject:webView];
    }
    
    dispatch_semaphore_signal(_lock);
    
}

-(void)clearAllReusableWebViewsWithClass:(Class)webViewClass{
    NSString *webViewClassString = NSStringFromClass(webViewClass);
    if (!webViewClassString || webViewClassString.length <= 0) {
        return;
    }
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    if ([[_enqueueWebViews allKeys] containsObject:webViewClassString]) {
        [_enqueueWebViews removeObjectForKey:webViewClassString];
    }
    
    dispatch_semaphore_signal(_lock);
}


#pragma private
-(void)_tryCompactWeakHolderOfWebView{
    NSDictionary *dequeueWebViewsTmp = _dequeueWebViews.copy;
    if (dequeueWebViewsTmp && dequeueWebViewsTmp.count > 0) {
        for (NSMutableSet *viewSet in dequeueWebViewsTmp.allValues) {
            NSSet *webViewSetTmp = viewSet.copy;
            for (__kindof WKWebView *webView in webViewSetTmp) {
                if (!webView.holderObject) {
                    [self enqueueWebView:webView];
                }
            }
        }
    }
}

-(void)_recycleWebView:(__kindof WKWebView *)webView{
    if (!webView) {
        return;
    }
    
    //进入回收池前清理
    if ([webView respondsToSelector:@selector(componentViewWillEnterPool)]) {
        [webView componentViewWillEnterPool];
    }
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    NSString *webViewClassString = NSStringFromClass([webView class]);
    
    if ([[_dequeueWebViews allKeys] containsObject:webViewClassString]) {
        NSMutableSet *viewSet = [_dequeueWebViews objectForKey:webViewClassString];
        [viewSet removeObject:webView];
    }else{
        dispatch_semaphore_signal(_lock);
    }
    
    if ([[_enqueueWebViews allKeys] containsObject:webViewClassString]) {
        NSMutableSet *viewSet = [_enqueueWebViews objectForKey:webViewClassString];
        if (viewSet.count < 50) {
            [viewSet addObject:webView];
        }else{
            
        }
    }else{
        NSMutableSet *viewSet = [[NSSet set] mutableCopy];
        [viewSet addObject:webView];
        [_enqueueWebViews setValue:viewSet forKey:webViewClassString];
    }
    
    dispatch_semaphore_signal(_lock);
}

-(__kindof WKWebView *)_getWebViewWithClass:(Class)webViewClass{
    NSString *webViewClassString = NSStringFromClass(webViewClass);
    
    if (!webViewClassString || webViewClassString.length <= 0) {
        return nil;
    }
    
    
    __kindof WKWebView *webView;
    
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    
    if ([[_enqueueWebViews allKeys] containsObject:webViewClassString]) {
        NSMutableSet *viewSet = [_enqueueWebViews objectForKey:webViewClassString];
        if (viewSet && viewSet.count > 0) {
            webView = [viewSet anyObject];
            if ([webView isMemberOfClass:webViewClass]) {
                return nil;
            }
            [viewSet removeObject:webView];
        }
    }
    
    if (!webView) {
        webView = [[webViewClass alloc] initWithFrame:CGRectZero];
    }
    
    if ([[_dequeueWebViews allKeys] containsObject:webViewClassString]) {
        NSMutableSet *viewSet = [_dequeueWebViews objectForKey:webViewClassString];
        [viewSet addObject:webView];
    }else{
        NSMutableSet *viewSet = [[NSSet set] mutableCopy];
        [viewSet addObject:webView];
        [_dequeueWebViews setValue:viewSet forKey:webViewClassString];
    }
    
    dispatch_semaphore_signal(_lock);
    
    if ([webView respondsToSelector:@selector(componentViewWillLeavePool)]) {
        [webView componentViewWillLeavePool];
    }
    
    return webView;
    
}

@end
