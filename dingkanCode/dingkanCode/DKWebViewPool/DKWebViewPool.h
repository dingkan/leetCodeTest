//
//  DKWebViewPool.h
//  dingkanCode
//
//  Created by 丁侃 on 2020/5/8.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DKWebViewPool : NSObject

+(DKWebViewPool *)sharedInstance;

-(__kindof WKWebView *)dequeueWebViewWithClass:(Class)webViewClass webViewHolder:(NSObject *)webViewHolder;

-(void)enqueueWebView:(__kindof WKWebView *)webView;

-(void)removeReusbaleWebView:(__kindof WKWebView *)webView;

-(void)clearAllReusableWebViews;

-(void)clearAllReusableWebViewsWithClass:(Class)webViewClass;

-(void)reloadAllReusableWebViews;

@end

NS_ASSUME_NONNULL_END
