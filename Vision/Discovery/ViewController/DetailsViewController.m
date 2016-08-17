//
//  DetailsViewController.m
//  Vision
//
//  Created by dllo on 16/3/12.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "DetailsViewController.h"
#import "DetailsCollectionViewCell.h"
#import "DetailPushAnimation.h"
#import "VideoViewController.h"
#import "HotButtonCollectionViewCell.h"

#define TITLE_ITEM_WIDTH (WIDTH - 68) / 2

@interface DetailsViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *titleCollectionView;

@property (nonatomic, strong) UIView *topLineView;

@property (nonatomic, strong) UIView *bottomLineView;

@property (nonatomic, strong) NSArray *titleArray;

@property (nonatomic, copy) void(^block)(void);
@end

@implementation DetailsViewController

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.delegate = self;
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC{
    if ([toVC isKindOfClass:[VideoViewController class]]) {
        DetailPushAnimation *animation = [[DetailPushAnimation alloc]init];
        return animation;
    }else{
        return nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setNavigationItem];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"FZLTZCHJW--GB1-0" size:19];
    titleLabel.text = self.name;
    self.navigationItem.titleView = titleLabel;
    
    [SVProgressHUD show];
    
    self.titleArray = @[@"按时间排序", @"分享排行榜"];
    [self createView];
}

- (void)setNavigationItem {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_return"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark ---------- 设置页面 ----------
-(void)createView{
    UICollectionViewFlowLayout *titleFlowlayout = [[UICollectionViewFlowLayout alloc] init];
    titleFlowlayout.minimumInteritemSpacing = 0;
    titleFlowlayout.minimumLineSpacing = 0 ;
    titleFlowlayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.titleCollectionView setCollectionViewLayout:titleFlowlayout];
    [self.titleCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HotButtonCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([HotButtonCollectionViewCell class])];

    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    [self.backCollectionView setCollectionViewLayout:flowLayout];
    [self.backCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([DetailsCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([DetailsCollectionViewCell class])];
    
    self.topLineView = [[UIView alloc] initWithFrame:CGRectMake((TITLE_ITEM_WIDTH - 90) / 2, 5, 90, 1)];
    [self.titleCollectionView addSubview:self.topLineView];
    self.topLineView.backgroundColor = [UIColor lightGrayColor];
    self.bottomLineView = [[UIView alloc] initWithFrame:CGRectMake((TITLE_ITEM_WIDTH - 90) / 2, 35, 90, 1)];
    [self.titleCollectionView addSubview:self.bottomLineView];
    self.bottomLineView.backgroundColor = [UIColor lightGrayColor];
}
#pragma mark ---------- collectionView协议方法 ----------
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.titleArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.backCollectionView) {
        DetailsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DetailsCollectionViewCell class]) forIndexPath:indexPath];
        cell.cellID = self.detailsID;
        cell.detailsTableView.tag = 1000+indexPath.item;
        cell.VC = self;
        void (^block)(void) = ^(void) {
            [cell.detailsTableView reloadData];
        };
        self.block = block;
        return cell;
    } else {
        HotButtonCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([HotButtonCollectionViewCell class]) forIndexPath:indexPath];
        cell.buttonLabel.text = self.titleArray[indexPath.item];
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *   )indexPath {
    if (collectionView == self.titleCollectionView) {
        [self.backCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        self.block();
    }
}

#pragma mark --------- UICollectionViewDelegateFlowLayout协议方法 ---------
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.backCollectionView) {
        return CGSizeMake(WIDTH, HEIGHT - 104);
    } else {
        return CGSizeMake((WIDTH - 68) / 2, 40);
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.backCollectionView) {
        self.block();
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat proportion = TITLE_ITEM_WIDTH / WIDTH;
    if (scrollView == self.backCollectionView) {
        self.topLineView.frame = CGRectMake(scrollView.contentOffset.x * proportion + (TITLE_ITEM_WIDTH - 90) / 2, 5, 90, 1);
        self.bottomLineView.frame = CGRectMake(scrollView.contentOffset.x * proportion + (TITLE_ITEM_WIDTH - 90) / 2, 35, 90, 1);
    }
}

@end
