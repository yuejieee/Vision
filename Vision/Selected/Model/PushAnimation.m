//
//  PushAnimation.m
//  Vision
//
//  Created by dllo on 16/3/12.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "PushAnimation.h"
#import "SelectedViewController.h"
#import "VideoViewController.h"
#import "SelectedTableViewCell.h"

@implementation PushAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.4;
}


//Push动画逻辑
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    SelectedViewController *fromVC = (SelectedViewController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    VideoViewController *toVC = (VideoViewController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    //拿到当前点击的cell的imageView
    SelectedTableViewCell *cell = (SelectedTableViewCell *)[fromVC.selectedTableView cellForRowAtIndexPath:[fromVC.selectedTableView indexPathForSelectedRow]];
    fromVC.indexPath = [fromVC.selectedTableView indexPathForSelectedRow];
    UIView *containerView = [transitionContext containerView];
    //snapshotViewAfterScreenUpdates 对cell的imageView截图保存成另一个视图用于过渡，并将视图转换到当前控制器的坐标
    UIView *tempView = [cell.imgView snapshotViewAfterScreenUpdates:NO];
    tempView.frame = fromVC.finalCellRect = [containerView convertRect:cell.imgView.frame fromView:cell.imgView.superview];
    
    //设置动画前的各个控件的状态
    cell.imgView.hidden = YES;
    toVC.imageView.hidden = YES;
    toVC.playButton.hidden = YES;
    toVC.backView.hidden = YES;
    fromVC.tabBarController.tabBar.alpha = 0;

    
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.alpha = 0;
    //tempView 添加到containerView中，要保证在最前方，所以后添加
    [containerView addSubview:toVC.view];
    [containerView addSubview:tempView];
    //开始做动画
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        [containerView layoutIfNeeded];
        tempView.frame = [containerView convertRect:toVC.imageView.frame fromView:toVC.backView];
        toVC.view.alpha = 1;
    } completion:^(BOOL finished) {
        //为了让回来的时候，cell上的图片显示，必须要让cell上的图片显示出来
        toVC.playButton.hidden = NO;
        toVC.imageView.hidden = NO;
        cell.imgView.hidden = NO;
        toVC.backView.hidden = NO;
        [tempView removeFromSuperview];
        //告诉系统动画结束
        [transitionContext completeTransition:YES];
    }];

}


@end
