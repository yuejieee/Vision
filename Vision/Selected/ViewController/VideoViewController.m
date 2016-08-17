//
//  VideoViewController.m
//  Vision
//
//  Created by dllo on 16/3/12.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "VideoViewController.h"
#import "PopAnimation.h"
#import "PlayerViewController.h"
#import <AVKit/AVKit.h>
#import "SelectedViewController.h"
#import "DetailsViewController.h"
#import "DetailPopAnimation.h"
#import "HotPopAnimation.h"
#import "HotViewController.h"
#import "XWInteractiveTransition.h"
#import "DataBaseHandle.h"

@interface VideoViewController ()<UINavigationControllerDelegate>

@property (nonatomic,strong) UIPercentDrivenInteractiveTransition *percentDrivenTransition;
@property (weak, nonatomic) IBOutlet UIImageView *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIView *edgeView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *blurView;
@property (nonatomic, strong) XWInteractiveTransition *interactiveTransition;
@end

@implementation VideoViewController

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.delegate = self;
//    self.navigationController.navigationBar.translucent = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
//    self.navigationController.navigationBar.translucent = YES;
}

#pragma mark <UINavigationControllerDelegate>
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC{
    if ([toVC isKindOfClass:[SelectedViewController class]]) {
        PopAnimation *popAnimation = [[PopAnimation alloc]init];
        return popAnimation;
    }else if ([toVC isKindOfClass:[DetailsViewController class]]) {
        DetailPopAnimation *detailPopAnimation = [[DetailPopAnimation alloc] init];
        return detailPopAnimation;
    } else if ([toVC isKindOfClass:[HotViewController class]]) {
        HotPopAnimation *hotPopAnimation = [[HotPopAnimation alloc]init];
        return hotPopAnimation;
    } else {
        return nil;
    }
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController{
    //手势开始的时候才需要传入手势过渡代理，如果直接点击pop，应该传入空，否者无法通过点击正常pop
    return self.interactiveTransition.interation ? self.interactiveTransition : nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"Lobster 1.4" size:25];
    titleLabel.text = @"Vision";
    self.navigationItem.titleView = titleLabel;
    
    [self setNavigationItem];
    
    //初始化手势过渡的代理
    self.interactiveTransition = [XWInteractiveTransition interactiveTransitionWithTransitionType:XWInteractiveTransitionTypePop GestureDirection:XWInteractiveTransitionGestureDirectionUp];
    //给当前控制器的视图添加手势
    [self.interactiveTransition addPanGestureForViewController:self];
    
    [self setStr];
    [self setValue];
}

- (void)setNavigationItem {
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_return"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconfont-collectselected"] style:UIBarButtonItemStyleDone target:self action:@selector(collect)];
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];

    if (![[DataBaseHandle shareDataBase] selectOneData:self.data]) {
        [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"iconfont-collect"]];
    }
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)collect {
    if (![[DataBaseHandle shareDataBase] selectOneData:self.data]) {
        [[DataBaseHandle shareDataBase] insertData:self.data];
        [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"iconfont-collectselected"]];
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    } else {
        [[DataBaseHandle shareDataBase] deleteData:self.data];
        [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"iconfont-collect"]];
        self.navigationItem.rightBarButtonItem.tintColor = [UIColor blackColor];
    }
}

- (void) setStr {
    NSThread *thread = [[NSThread alloc]initWithTarget:self selector:@selector(animationLabel) object:nil];
    [thread start];
    
}

#pragma mark ---------- Label动画 ----------
- (void)animationLabel {
    for (NSInteger i = 0; i < self.data.title.length; i++) {
        [self performSelectorOnMainThread:@selector(refreshTitleStr:) withObject:[self.self.data.title substringWithRange:NSMakeRange(0, i+1)] waitUntilDone:YES];
    }
    
    NSString *str = [NSString stringWithFormat:@"#%@ / %.2ld' %.2ld\"", self.data.category, self.data.duration / 60, self.data.duration % 60];
    for (NSInteger i = 0; i < str.length; i++) {
        [self performSelectorOnMainThread:@selector(refreshDetailStr:) withObject:[str substringWithRange:NSMakeRange(0, i+1)] waitUntilDone:YES];
    }
    
    for (NSInteger i = 0; i < self.data.descrip.length; i++)
    {
        [self performSelectorOnMainThread:@selector(refreshInfoStr:) withObject:[self.self.data.descrip substringWithRange:NSMakeRange(0, i+1)] waitUntilDone:YES];
    }
}

- (void)refreshTitleStr:(NSString *)titleStr {
    self.titleLabel.text = titleStr;
}

- (void)refreshDetailStr:(NSString *)detailStr {
    self.detailLabel.text = detailStr;
}

- (void)refreshInfoStr:(NSString *)infoStr {
    self.infoLabel.text = infoStr;
}

#pragma mark ---------- 赋值 ----------
- (void)setValue {
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:self.data.cover[@"detail"]] placeholderImage:[UIImage imageNamed:@"selectedPlaceImage"]];
    [self.contentLabel sd_setImageWithURL:[NSURL URLWithString:self.data.cover[@"blurred"]] placeholderImage:[UIImage imageNamed:@"selectedPlaceImage"]];
    self.titleLabel.text = self.data.title;
    [self.infoLabel sizeToFit];
}

- (IBAction)playbutton:(id)sender {
    PlayerViewController *playerVC = [[PlayerViewController alloc] init];
    playerVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    // alert提示网络状态
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"提醒" message:@"是否确定使用数据流量观看视频" preferredStyle:UIAlertControllerStyleAlert];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        playerVC.data = self.data;
        [self presentViewController:playerVC animated:YES completion:^{
        }];
    }]];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    if ([[AFNetworkReachabilityManager sharedManager] isReachableViaWWAN]) {
        [self presentViewController:alertCtrl animated:YES completion:^{
        }];
    } else {
        playerVC.data = self.data;
        [self presentViewController:playerVC animated:YES completion:^{
        }];
    }
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
