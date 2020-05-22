//
//  WKWebView+Holder.h
//  dingkanCode
//
//  Created by 丁侃 on 2020/5/9.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol WKWebViewResuableProtocol <NSObject>

@optional
-(void)componentViewWillLeavePool;
-(void)componentViewWillEnterPool;

@end

@interface WKWebView (Holder)

@property (nonatomic, weak, readwrite) NSObject *holderObject;

@property (nonatomic, assign, readwrite) NSInteger reusedTimes;

@property (nonatomic, assign, readwrite) BOOL invalid;

-(void)componentViewWillLeavePool __attribute__((objc_requires_super));
-(void)componentViewWillEnterPool __attribute__((objc_requires_super));

-(void)_clearBackForwardList;

@end

NS_ASSUME_NONNULL_END
