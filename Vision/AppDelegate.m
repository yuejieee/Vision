//
//  AppDelegate.m
//  Vision
//
//  Created by dllo on 16/3/10.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "AppDelegate.h"
// 每日精选
#import "SelectedViewController.h"
// 发现
#import "DiscViewController.h"
// 热门
#import "HotViewController.h"
// 活动
#import "ActivityViewController.h"

#import "CustomTabBarViewController.h"

#import "PlayerViewController.h"
// 引导页
#import "GuideViewController.h"

#import "DataBaseHandle.h"

@interface AppDelegate ()<UITabBarControllerDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    SelectedViewController *selectedVC = [[SelectedViewController alloc] initWithNibName:NSStringFromClass([SelectedViewController class]) bundle:nil];
    UINavigationController *selectedNaVC = [[UINavigationController alloc] initWithRootViewController:selectedVC];
    
    DiscViewController *discVC = [[DiscViewController alloc] initWithNibName:NSStringFromClass([DiscViewController class]) bundle:nil];
    UINavigationController *discNaVC = [[UINavigationController alloc] initWithRootViewController:discVC];

    HotViewController *hotVC = [[HotViewController alloc] initWithNibName:NSStringFromClass([HotViewController class]) bundle:nil];
    UINavigationController *hotNaVC = [[UINavigationController alloc] initWithRootViewController:hotVC];
    
    ActivityViewController *actiVC = [[ActivityViewController alloc] initWithNibName:NSStringFromClass([ActivityViewController class]) bundle:nil];
    UINavigationController *actiNAVC = [[UINavigationController alloc] initWithRootViewController:actiVC];
    
    GuideViewController *guideVC = [[GuideViewController alloc] initWithNibName:NSStringFromClass([GuideViewController class]) bundle:nil];
    
    CustomTabBarViewController *tabBarCtrl = [[CustomTabBarViewController alloc] init];
    tabBarCtrl.titleArray = @[@"每日精选", @"发现更多", @"热门排行", @"活动精选"];
    tabBarCtrl.viewControllers = @[selectedNaVC, discNaVC, hotNaVC, actiNAVC];
    tabBarCtrl.delegate = self;
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"firsLaunch"]) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firsLaunch"];
        self.window.rootViewController = guideVC;
        void (^block)(void) = ^(void) {
            self.window.rootViewController = tabBarCtrl;
            [[DataBaseHandle shareDataBase] createTable];
        };
        guideVC.block = block;
    } else {
        self.window.rootViewController = tabBarCtrl;
    }
    
    // 网络弹窗
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"提醒" message:@"网络已断开" preferredStyle:UIAlertControllerStyleAlert];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];

    // 设置网络状态改变后的处理
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        // 当网络状态改变了, 就会调用这个block
        switch (status) {
            case AFNetworkReachabilityStatusUnknown: // 未知网络
                NSLog(@"未知网络");
                break;
            case AFNetworkReachabilityStatusNotReachable: // 没有网络(断网)
                [self.window.rootViewController presentViewController:alertCtrl animated:YES completion:^{
                }];
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN: // 手机自带网络
                NSLog(@"手机自带网络");
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi: // WIFI
                NSLog(@"WIFI");
                break;
        }
    }];
    
    // 开始监控
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    return YES;
}

-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController*)viewController {
    CATransition *transition = [CATransition animation];
    // 设置一下动画类型
    transition.type = @"fade";
    // 设置动画时长
    transition.duration = 0.2;
    transition.repeatCount = 1;
    [self.window.layer addAnimation:transition forKey:@"trasition"];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
 
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
