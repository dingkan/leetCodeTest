//
//  tesmVC.m
//  dingkanCode
//
//  Created by 丁侃 on 2020/4/24.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import "tesmVC.h"

@interface tesmVC()
@property (nonatomic, strong) NSTimer *time;
@end

@implementation tesmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view.backgroundColor = [UIColor redColor];
// 
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(test) name:UIApplicationDidEnterBackgroundNotification object:nil];
//    
//    UIButton *tmp = [UIButton buttonWithType:UIButtonTypeSystem];
//    [tmp setTitle:@"11" forState:UIControlStateNormal];
//    tmp.frame = CGRectMake(0, 0, 100, 100);
//    [tmp setTitleColor:UIColor.blueColor forState:UIControlStateNormal];
//    [tmp addTarget:self action:@selector(didClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:tmp];
    
    self.time = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(run) userInfo:nil repeats:YES];
    [self.time fire];
}

-(void)run{
    NSLog(@"--------------  ----");
}

-(void)didClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dealloc{
    
}


@end
