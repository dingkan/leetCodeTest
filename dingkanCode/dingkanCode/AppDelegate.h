//
//  AppDelegate.h
//  dingkanCode
//
//  Created by 丁侃 on 2020/3/30.
//  Copyright © 2020 丁侃. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

