//
//  CustomTabBarViewController.m
//  Vision
//
//  Created by dllo on 16/3/16.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "CustomTabBarViewController.h"
#import "CustomTabBarButton.h"
#import "CustomTabBar.h"

@interface CustomTabBarViewController () <CustomTabBarDelegate>

@property (nonatomic, strong) CustomTabBarButton *selectedBtn;

@property (nonatomic, strong) CustomTabBar *myView;

@end

@implementation CustomTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CGRect rect = self.tabBar.bounds;
    
    self.myView = [[CustomTabBar alloc] initWithFrame:rect];
    //设置代理
    self.myView.delegate = self;
    //添加到系统自带的tabBar上, 这样可以用的的事件方法. 而不必自己去写
    [self.tabBar addSubview:self.myView];
    
    
}

- (void)setTitleArray:(NSArray *)titleArray {
    for (int i = 0; i < titleArray.count; i++) {
        [self.myView addButtonWithTitle:titleArray[i]];
    }
}

- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers {
    [super setViewControllers:viewControllers];
   
}

- (void)tabBar:(CustomTabBar *)tabBar selectedFrom:(NSInteger)from to:(NSInteger)to {
    self.selectedIndex = to;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
