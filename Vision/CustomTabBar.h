//
//  CustomTabBar.h
//  Vision
//
//  Created by dllo on 16/3/16.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CustomTabBar;

@protocol CustomTabBarDelegate <NSObject>
/**
 *  工具栏按钮被选中, 记录从哪里跳转到哪里. (方便以后做相应特效)
 */
- (void) tabBar:(CustomTabBar *)tabBar selectedFrom:(NSInteger)from to:(NSInteger)to;

@end

@interface CustomTabBar : UIView

@property(nonatomic,weak) id<CustomTabBarDelegate> delegate;

-(void) addButtonWithTitle:(NSString *)title;

@end
