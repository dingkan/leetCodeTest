//////
//////  ViewController.m
//////  dingkanCode
//////
//////  Created by 丁侃 on 2020/3/30.
//////  Copyright © 2020 丁侃. All rights reserved.
//////
////
//#import "ViewController.h"
////#import "NSObject+DKCrashHandler.h"
////#import "Person.h"
////
////@interface ViewController ()
////
////@property (nonatomic, strong) UIButton *btn;
////@end
////
////@implementation ViewController
////
////- (void)viewDidLoad {
////    [super viewDidLoad];
////    // Do any additional setup after loading the view.
////
////
////    self.btn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
////    [self.btn setTitle:@"XXX" forState:UIControlStateNormal];
////    [self.btn setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
////    [self.btn addTarget:self action:@selector(didClick:) forControlEvents:UIControlEventTouchUpInside];
////
////    [self.view addSubview:self.btn];
////
////    [Person demo];
////}
////
////
////
////
////
////
////
////@end
//
//#import "KVOCrashObject.h"
//
//@interface ViewController ()
//
//@property (nonatomic, strong) KVOCrashObject *objc;
//
//@end
//
//@implementation ViewController
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//
//    self.objc = [[KVOCrashObject alloc] init];
//}
//
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//
////    1.1 移除了未注册的观察者，导致崩溃
////     [self testKVOCrash11];
//
////    1.2 重复移除多次，移除次数多于添加次数，导致崩溃
////    [self testKVOCrash12];
//
////    1.3 重复添加多次，虽然不会崩溃，但是发生改变时，也同时会被观察多次。
//    [self testKVOCrash13];
//
////    2. 被观察者 dealloc 时仍然注册着 KVO，导致崩溃
////    [self testKVOCrash2];
//
////    3. 观察者没有实现 -observeValueForKeyPath:ofObject:change:context:导致崩溃
////    [self testKVOCrash3];
//
////    4. 添加或者移除时 keypath == nil，导致崩溃。
////    [self testKVOCrash4];
//}
//
///**
// 1.1 移除了未注册的观察者，导致崩溃
// */
//- (void)testKVOCrash11 {
//    // 崩溃日志：Cannot remove an observer XXX for the key path "xxx" from XXX because it is not registered as an observer.
//    [self.objc removeObserver:self forKeyPath:@"name"];
//}
//
///**
// 1.2 重复移除多次，移除次数多于添加次数，导致崩溃
// */
//- (void)testKVOCrash12 {
//    // 崩溃日志：Cannot remove an observer XXX for the key path "xxx" from XXX because it is not registered as an observer.
//    [self.objc addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
//    self.objc.name = @"0";
//    [self.objc removeObserver:self forKeyPath:@"name"];
//    [self.objc removeObserver:self forKeyPath:@"name"];
//}
//
///**
// 1.3 重复添加多次，虽然不会崩溃，但是发生改变时，也同时会被观察多次。
// */
//- (void)testKVOCrash13 {
//    [self.objc addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
//    [self.objc addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
//    self.objc.name = @"0";
//}
//
///**
// 2. 被观察者 dealloc 时仍然注册着 KVO，导致崩溃
// */
//- (void)testKVOCrash2 {
//    // 崩溃日志：An instance xxx of class xxx was deallocated while key value observers were still registered with it.
//    // iOS 10 及以下会导致崩溃，iOS 11 之后就不会崩溃了
//    KVOCrashObject *obj = [[KVOCrashObject alloc] init];
//    [obj addObserver: self
//          forKeyPath: @"name"
//             options: NSKeyValueObservingOptionNew
//             context: nil];
//}
//
///**
// 3. 观察者没有实现 -observeValueForKeyPath:ofObject:change:context:导致崩溃
// */
//- (void)testKVOCrash3 {
//    // 崩溃日志：An -observeValueForKeyPath:ofObject:change:context: message was received but not handled.
//    KVOCrashObject *obj = [[KVOCrashObject alloc] init];
//
//    [self addObserver: obj
//           forKeyPath: @"title"
//              options: NSKeyValueObservingOptionNew
//              context: nil];
//
//    self.title = @"111";
//}
//
///**
// 4. 添加或者移除时 keypath == nil，导致崩溃。
// */
//- (void)testKVOCrash4 {
//    // 崩溃日志： -[__NSCFConstantString characterAtIndex:]: Range or index out of bounds
//    KVOCrashObject *obj = [[KVOCrashObject alloc] init];
//
//    [self addObserver: obj
//           forKeyPath: @""
//              options: NSKeyValueObservingOptionNew
//              context: nil];
//
////    [self removeObserver:obj forKeyPath:@""];
//}
//
//
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void *)context {
//
//    NSLog(@"object = %@, keyPath = %@", object, keyPath);
//}
//
//@end





/********************* ViewController.m 文件 *********************/
#import "ViewController.h"
#import "DKCrashObject.h"
#import "tesmVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    dispatch_queue_t queue = dispatch_queue_create("flex", DISPATCH_QUEUE_CONCURRENT);
//    NSMutableArray *tmp = @[].mutableCopy;
//    
//    for (int i = 0; i < 1000; i ++) {
//        dispatch_async(queue, ^{
////            [tmp addObject:@(i)];
//            [tmp addObject:@"q4"];
//        });
//    }
//    NSLog(@"%lu",tmp.count);
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    1. key 不是对象的属性，造成崩溃
//    [self testKVCCrash1];

//    2. keyPath 不正确，造成崩溃
//    [self testKVCCrash2];

//    3. key 为 nil，造成崩溃
//    [self testKVCCrash4];

//    4. value 为 nil，为非对象设值，造成崩溃
//    [self testKVCCrash4];
    
    UIViewController *t1 = [[tesmVC alloc]init];
    
    [self presentViewController:t1 animated:YES completion:nil];
}

/**
 1. key 不是对象的属性，造成崩溃
 */
- (void)testKVCCrash1 {
    // 崩溃日志：[<DKCrashObject 0x600000d48ee0> setValue:forUndefinedKey:]: this class is not key value coding-compliant for the key XXX.;
    
    DKCrashObject *objc = [[DKCrashObject alloc] init];
    [objc setValue:@"value" forKey:@"address"];
}

/**
 2. keyPath 不正确，造成崩溃
 */
- (void)testKVCCrash2 {
    // 崩溃日志：[<DKCrashObject 0x60000289afb0> valueForUndefinedKey:]: this class is not key value coding-compliant for the key XXX.
    
    DKCrashObject *objc = [[DKCrashObject alloc] init];
    [objc setValue:@"后厂村路" forKeyPath:@"address.street"];
}

/**
 3. key 为 nil，造成崩溃
 */
- (void)testKVCCrash3 {
    // 崩溃日志：'-[DKCrashObject setValue:forKey:]: attempt to set a value for a nil key

    NSString *keyName;
    // key 为 nil 会崩溃，如果传 nil 会提示警告，传空变量则不会提示警告
    
    DKCrashObject *objc = [[DKCrashObject alloc] init];
    [objc setValue:@"value" forKey:keyName];
}

/**
 4. value 为 nil，造成崩溃
 */
- (void)testKVCCrash4 {
    // 崩溃日志：[<DKCrashObject 0x6000028a6780> setNilValueForKey]: could not set nil as the value for the key XXX.
    
    // value 为 nil 会崩溃
    DKCrashObject *objc = [[DKCrashObject alloc] init];
    [objc setValue:nil forKey:@"age"];
}

@end
