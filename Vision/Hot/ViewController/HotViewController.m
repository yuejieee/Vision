//
//  HotViewController.m
//  Vision
//
//  Created by dllo on 16/3/10.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "HotViewController.h"
#import "HotButtonCollectionViewCell.h"
#import "HotContentCollectionViewCell.h"
#import "VideoViewController.h"
#import "HotPushAnimation.h"

#define TITLE_ITEM_WIDTH (WIDTH - 76) / 3

@interface HotViewController ()<UICollectionViewDataSource, UICollectionViewDelegate,  UICollectionViewDelegateFlowLayout, UIScrollViewAccessibilityDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *hotButtonCollectionView;
@property (nonatomic,strong) NSArray *buttonArr;

@property (nonatomic, copy) void (^block)(void);

@property (nonatomic, strong) UIView *topLineView;

@property (nonatomic, strong) UIView *bottomLineView;

@end

@implementation HotViewController

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.delegate = self;
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC{
    if ([toVC isKindOfClass:[VideoViewController class]]) {
        HotPushAnimation *animation = [[HotPushAnimation alloc]init];
        return animation;
    }else{
        return nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"Lobster 1.4" size:25];
    titleLabel.text = @"Vision";
    self.navigationItem.titleView = titleLabel;
    
    [SVProgressHUD show];
    
    [self createView];
}

-(void)createView{
    //创建数组数据
    self.buttonArr = @[@"周排行",@"月排行",@"总排行"];
    
    //创建collectionView
    UICollectionViewFlowLayout *buttonFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    buttonFlowLayout.minimumInteritemSpacing = 0;
    buttonFlowLayout.minimumLineSpacing = 0 ;
    buttonFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.hotButtonCollectionView setCollectionViewLayout:buttonFlowLayout];
    [self.hotButtonCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HotButtonCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([HotButtonCollectionViewCell class])];
    
    UICollectionViewFlowLayout *contentFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    contentFlowLayout.minimumInteritemSpacing = 0 ;
    contentFlowLayout.minimumLineSpacing = 0;
    contentFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.contentCollectionView setCollectionViewLayout:contentFlowLayout];
    self.contentCollectionView.backgroundColor = [UIColor whiteColor];
    [self.contentCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HotContentCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([HotContentCollectionViewCell class])];
    
    self.topLineView = [[UIView alloc] initWithFrame:CGRectMake((TITLE_ITEM_WIDTH - 40) / 3, 5, 55, 1)];
    [self.hotButtonCollectionView addSubview:self.topLineView];
    self.topLineView.backgroundColor = [UIColor lightGrayColor];
    self.bottomLineView = [[UIView alloc] initWithFrame:CGRectMake((TITLE_ITEM_WIDTH - 40) / 3, 35, 55, 1)];
    [self.hotButtonCollectionView addSubview:self.bottomLineView];
    self.bottomLineView.backgroundColor = [UIColor lightGrayColor];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.buttonArr.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.hotButtonCollectionView) {
        HotButtonCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HotButtonCollectionViewCell class]) forIndexPath:indexPath];
        cell.buttonLabel.text = self.buttonArr[indexPath.item];
        return cell;
    }else{
        HotContentCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HotContentCollectionViewCell class]) forIndexPath:indexPath];
        cell.hotContentTableView.tag = 1000 + indexPath.item;
        void (^block)(void) = ^(void) {
            [cell.hotContentTableView reloadData];
        };
        cell.VC = self;
        self.block = block;
        return cell;
    }

}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.hotButtonCollectionView) {
        [self.contentCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.hotButtonCollectionView) {
        return CGSizeMake(TITLE_ITEM_WIDTH, 40);
    }else{
        return CGSizeMake(WIDTH, HEIGHT - 104);
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat proportion = TITLE_ITEM_WIDTH / WIDTH;
    if (scrollView == self.contentCollectionView) {   
        self.topLineView.frame = CGRectMake(scrollView.contentOffset.x * proportion + (TITLE_ITEM_WIDTH - 40) / 3, 5, 55, 1);
        self.bottomLineView.frame = CGRectMake(scrollView.contentOffset.x * proportion + (TITLE_ITEM_WIDTH - 40) / 3, 35, 55, 1);
    }
    self.block();
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
