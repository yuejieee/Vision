//
//  PopAnimation.m
//  Vision
//
//  Created by dllo on 16/3/12.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "PopAnimation.h"
#import "SelectedTableViewCell.h"
#import "VideoViewController.h"
#import "SelectedViewController.h"

@implementation PopAnimation

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext{
    return 0.4;
}

//Pop动画逻辑
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    VideoViewController *fromVC = (VideoViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    SelectedViewController *toVC = (SelectedViewController *)[transitionContext     viewControllerForKey:UITransitionContextToViewControllerKey];
        UIView *containerView = [transitionContext containerView];
    
    //这里的lastView就是push时候初始化的那个tempView
    UIView *tempView = [fromVC.imageView snapshotViewAfterScreenUpdates:NO];
    tempView.backgroundColor = [UIColor clearColor];
    tempView.frame = [containerView convertRect:fromVC.imageView.frame fromView:fromVC.backView];
    //设置初始状态
    fromVC.imageView.hidden = YES;
    toVC.tabBarController.tabBar.alpha = 0;
    tempView.hidden = NO;
    
    //初始化后一个VC的位置
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    
    //获取toVC中图片的位置
    SelectedTableViewCell *cell = (SelectedTableViewCell *)[toVC.selectedTableView cellForRowAtIndexPath:toVC.indexPath];
    cell.imgView.hidden = YES;
    
    
    [containerView insertSubview:toVC.view belowSubview:fromVC.view];
    [containerView addSubview:tempView];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromVC.view.alpha = 0;
        toVC.tabBarController.tabBar.alpha = 1;
        tempView.frame = toVC.finalCellRect;
    } completion:^(BOOL finished) {
        //由于加入了手势必须判断
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        if ([transitionContext transitionWasCancelled]) {
            //手势取消了，原来隐藏的imageView要显示出来
            //失败了隐藏tempView，显示fromVC.imageView
            tempView.hidden = YES;
            fromVC.imageView.hidden = NO;
            [UIView animateWithDuration:0.2 animations:^{
                toVC.tabBarController.tabBar.alpha = 0;
            }];
        }else{
            //手势成功，cell的imageView也要显示出来
            //成功了移除tempView，下一次pop的时候又要创建，然后显示cell的imageView
            cell.imgView.hidden = NO;
            [tempView removeFromSuperview];
        }
    }];
}


@end
