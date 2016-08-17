//
//  SelectedViewController.m
//  Vision
//
//  Created by dllo on 16/3/10.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "SelectedViewController.h"
#import "SelectedTableViewCell.h"
#import "Data.h"
#import "PushAnimation.h"
#import "VideoViewController.h"
#import "CacheViewController.h"
#import "CollectViewController.h"
#import "AboutUsViewController.h"

// 滑动方向
typedef NS_ENUM(NSInteger, MoveDirection) {
    MoveDirectionNone,
    MoveDirectionUp,
    MoveDirectionDown,
};
CGFloat const gestureMinimumTranslations = 3.0 ;

@interface SelectedViewController ()<UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) NSMutableArray *array;
@property (nonatomic, strong) NSMutableArray *dateArray;
@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, strong) UITableView *listTableView;
@property (nonatomic, strong) NSArray *listArray;

// 方向
@property (nonatomic, assign) MoveDirection direction;
// 开始位置
@property (nonatomic, assign) CGPoint location;
// 实时位置
@property (nonatomic, assign) CGPoint curretn;

@end

@implementation SDWebImageManager (cache)

- (BOOL)memoryCachedImageExistsForURL:(NSURL *)url {
    NSString *key = [self cacheKeyForURL:url];
    return ([self.imageCache imageFromMemoryCacheForKey:key] != nil) ?  YES : NO;
}
@end

@implementation SelectedViewController

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.listTableView.frame = CGRectMake(0, 0, WIDTH, 0);
    self.isSelected = NO;
    [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"iconfont-xiangxia2"]];
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC{
    if ([toVC isKindOfClass:[VideoViewController class]]) {
        PushAnimation *animation = [[PushAnimation alloc]init];
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
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconfont-xiangxia2"] style:UIBarButtonItemStylePlain target:self action:@selector(list)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
    self.isSelected = NO;
    
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD show];
    
    [self createData];
    
    [self setListTableView];
    [self setSelectedTableView];
}

- (void)setBarButtonItem {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"iconfont-xiangxia2"] style:UIBarButtonItemStylePlain target:self action:@selector(list)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
    self.isSelected = NO;
}

#pragma mark 按钮点击方法
- (void)list {
    if (!self.isSelected) {
        [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"iconfont-xiangshang2"]];
            [UIView animateWithDuration:0.4 animations:^{
            self.listTableView.frame = CGRectMake(0, 64, WIDTH, HEIGHT - 64 - 49 - 70);
        }];
    } else {
        [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"iconfont-xiangxia2"]];
        [UIView animateWithDuration:0.4 animations:^{
            self.listTableView.frame = CGRectMake(0, 64, WIDTH, 0);
        }];
    }
    self.isSelected = !self.isSelected;
}

#pragma mark ---------- 数据解析 ----------
- (void)createData {
//    @"我的缓存",
    self.listArray = @[ @"我的收藏", @"清除缓存", @"关于我们", @"Version 1.0.0"];
    self.array = [NSMutableArray array];
    self.dateArray = [NSMutableArray arrayWithObject:@"Today"];
    
    // 数据缓存本地
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"%@", path);
    NSString *pathData = [path stringByAppendingPathComponent:@"myData"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathData]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:pathData withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *pathDataContent = [pathData stringByAppendingPathComponent:@"selected.plist"];
    NSString *pathDataSection = [pathData stringByAppendingPathComponent:@"section.plist"];
    // 数据解析
    [[AFHTTPSessionManager manager] GET:@"http://baobab.wandoujia.com/api/v2/feed?num=7" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *temp = responseObject[@"issueList"];
        for (NSDictionary *dicF in temp) {
            NSArray *itemList = dicF[@"itemList"];
            NSMutableArray *dataArray = [NSMutableArray array];
            for (NSDictionary *dicS in itemList) {
                if ([dicS[@"type"] isEqualToString:@"video"]) {
                    Data *data = [[Data alloc] init];
                    [data setValuesForKeysWithDictionary:dicS[@"data"]];
                    [dataArray addObject:data];
                } else if ([dicS[@"type"] isEqualToString:@"textHeader"]) {
                    NSString *str = dicS[@"data"][@"text"];
                    [self.dateArray addObject:str];
                } else if ([dicS[@"type"] isEqualToString:@"imageHeader"]) {
                    NSString *url = dicS[@"data"][@"image"];
                    [self.dateArray addObject:url];
                }
            }
            [self.array addObject:dataArray];
        }
        [self.selectedTableView reloadData];
        [SVProgressHUD dismiss];
        [NSKeyedArchiver archiveRootObject:self.array toFile:pathDataContent];
        [NSKeyedArchiver archiveRootObject:self.dateArray toFile:pathDataSection];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.array = [NSKeyedUnarchiver unarchiveObjectWithFile:pathDataContent];
        self.dateArray = [NSKeyedUnarchiver unarchiveObjectWithFile:pathDataSection];
        [self.selectedTableView reloadData];
        [SVProgressHUD dismiss];
    }];
}

#pragma mark ---------- 设置listTalbeView ----------
- (void)setListTableView {
    self.listTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, 0) style:UITableViewStylePlain];
    self.listTableView.backgroundColor = [UIColor colorWithWhite:0.904 alpha:0.946];
    [self.view addSubview:self.listTableView];
    self.listTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    [self.listTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"listTableViewReuse"];
    self.listTableView.scrollEnabled = NO;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self.listTableView addGestureRecognizer:pan];
}

- (void)panAction:(UIPanGestureRecognizer *)pan {
    CGFloat height = HEIGHT - 64 - 49 - 70;
    if (pan.state == UIGestureRecognizerStateBegan) {
        // 无方向
        self.direction = MoveDirectionNone;
        // 开始滑动位置
        self.location = [pan locationInView:self.view];
    }
    // 事实移动位置 增量
    CGPoint translation = [pan translationInView:self.view];
    CGPoint velocity = [pan velocityInView:self.view];
    self.direction = [self determineDirectionIfNeeded:translation];
    self.curretn = [pan locationInView:self.view];
    
    // list随手势变化高度
    if (self.direction == MoveDirectionUp || self.direction == MoveDirectionDown) {

        self.listTableView.frame = CGRectMake(0, 64, WIDTH, height + self.curretn.y - self.location.y);
    }
    if (pan.state == UIGestureRecognizerStateEnded) {
        if (velocity.y < - 1500 || self.listTableView.frame.size.height < height / 2) {
            [UIView animateWithDuration:0.4 animations:^{
                self.listTableView.frame = CGRectMake(0, 64, WIDTH, 0);
                self.isSelected = NO;
                [self.navigationItem.leftBarButtonItem setImage:[UIImage imageNamed:@"iconfont-xiangxia2"]];
            }];
        } else {
            [UIView animateWithDuration:0.4 animations:^{
                self.listTableView.frame = CGRectMake(0, 64, WIDTH, HEIGHT - 64 - 49 - 70);
            }];
        }
        
    }
}

#pragma mark ---------- 滑动方向判断 ---------
- (MoveDirection)determineDirectionIfNeeded:(CGPoint)translation {
    if (self.direction != MoveDirectionNone) {
        return self.direction;
    }
    if (fabs(translation.y) > gestureMinimumTranslations) {
        BOOL gestureVertical = NO;
        if (translation.x == 0.0 )
            gestureVertical = YES;
        else
            gestureVertical = (fabs(translation.y / translation.x) > 5.0 );
        if (gestureVertical) {
            if (translation.y > 0.0 ) {
                return MoveDirectionDown;
            } else {
                return MoveDirectionUp;
            }
        }
    }
    return self.direction;

}

#pragma mark ---------- 设置selectedTalbeView ----------
- (void)setSelectedTableView {
    [self.selectedTableView registerNib:[UINib nibWithNibName:NSStringFromClass([SelectedTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SelectedTableViewCell class])];
}

#pragma mark ---------- tableView协议方法 ----------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.selectedTableView) {
        return self.array.count;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.selectedTableView) {
        return [self.array[section] count];
    } else {
        return self.listArray.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.selectedTableView) {
        if ([self.dateArray[section] length] > 20) {
            return nil;
        } else {
            return self.dateArray[section];
        }
    } else {
        return nil;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.selectedTableView) {
        UIView *backView = [[UIView alloc] init];
        backView.alpha = 0.8;
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, WIDTH - 200, 30 * HEIGHT / 667)];
        textLabel.font = [UIFont fontWithName:@"Lobster 1.4" size:18];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.backgroundColor = [UIColor whiteColor];
        textLabel.layer.cornerRadius = 3;
        textLabel.layer.masksToBounds = YES;
        [backView addSubview:textLabel];
        if ([self.dateArray[section] length] > 20) {
            textLabel.text = @"- Weekend -";
        } else {
            textLabel.text = self.dateArray[section];
        }
        return backView;
    } else {
        UIView *backView = [[UIView alloc] init];
        backView.backgroundColor = [UIColor colorWithWhite:0.736 alpha:1.000];
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, WIDTH - 200, 30 * HEIGHT / 667)];
        textLabel.font = [UIFont fontWithName:@"FZLTZCHJW--GB1-0" size:20];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.textColor = [UIColor grayColor];
        [backView addSubview:textLabel];
        textLabel.text = @"视野";
        return backView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50 * HEIGHT / 667;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.selectedTableView) {
        return 230 * WIDTH / 375;
    } else {
        return (HEIGHT - 64 - 49 - 70 - 50 * HEIGHT / 667) / 4.3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.selectedTableView) {
        SelectedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SelectedTableViewCell class]) forIndexPath:indexPath];
        Data *data = self.array[indexPath.section][indexPath.row];
        [cell.imgView sd_setImageWithURL:[NSURL URLWithString:data.cover[@"detail"]] placeholderImage:[UIImage imageNamed:@"selectedPlaceImage.png"]];
        cell.titleLabel.text = data.title;
        cell.contentLabel.text = [NSString stringWithFormat:@"#%@ / %.2ld' %.2ld\"", data.category, data.duration / 60, data.duration % 60 ];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listTableViewReuse" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = self.listArray[indexPath.row];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont fontWithName:@"FZLTXIHJW--GB1-0" size:18];
        if (indexPath.row == 4) {
            cell.textLabel.font = [UIFont fontWithName:@"Lobster 1.4" size:14];
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.selectedTableView) {
        VideoViewController *videoVC = [[VideoViewController alloc] init];
        [self.navigationController pushViewController:videoVC animated:YES];
        videoVC.data = self.array[indexPath.section][indexPath.row];
    } else {
        if (0) {
            self.hidesBottomBarWhenPushed = YES;
            CacheViewController *cacheVC = [[CacheViewController alloc] init];
            [self.navigationController pushViewController:cacheVC animated:YES];
            self.hidesBottomBarWhenPushed = NO;
        } else if (indexPath.row == 0) {
            CollectViewController *collectVC = [[CollectViewController alloc] init];
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:collectVC animated:YES];
            self.hidesBottomBarWhenPushed = NO;
        } else if (indexPath.row == 1) {
            [self deleteCaches];
        } else if (indexPath.row == 2) {
            AboutUsViewController *aboutVC = [[AboutUsViewController alloc] init];
            self.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:aboutVC animated:YES];
            self.hidesBottomBarWhenPushed = NO;
        }
    }
}

- (void)deleteCaches {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *pathData = [path stringByAppendingPathComponent:@"myData"];
    NSFileManager* manager = [NSFileManager defaultManager];
    double size = [self folderSizeAtPath:pathData];
    double allSize = [[SDImageCache sharedImageCache] getSize]/(1024.0*1024.0) + size;
    NSString *cachesStr = [NSString stringWithFormat:@"缓存%.2fMB", allSize];
    UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"提示" message:cachesStr preferredStyle:UIAlertControllerStyleAlert];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [manager removeItemAtPath:pathData error:nil];
        [[SDImageCache sharedImageCache] clearDisk];
    }]];
    [alertCtrl addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alertCtrl animated:YES completion:^{
        
    }];
}

// 计算缓存大小
- (float) folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) {
        return 0;
    }
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    NSInteger folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

- (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

#pragma mark ---------- 滑动动画 -----------
/**
 *  @author yueJie, 16-03-11 17:03:44
 *
 *  tableViewCell即将出现时触发
 *
 **/
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.selectedTableView) {
        Data *data = self.array[indexPath.section][indexPath.row];
        if (![[SDWebImageManager sharedManager] memoryCachedImageExistsForURL:[NSURL URLWithString:data.cover[@"detail"]]]) {
            CATransform3D rotation;//3D旋转
            rotation = CATransform3DMakeTranslation(0 ,40 ,20);
            rotation = CATransform3DScale(rotation, 0.9, .9, 1);
            
            rotation.m34 = 1.0/ -600;
            
            cell.layer.shadowColor = [[UIColor blackColor]CGColor];
            cell.layer.shadowOffset = CGSizeMake(10, 10);
            cell.alpha = 0;
            
            cell.layer.transform = rotation;
            
            [UIView beginAnimations:@"rotation" context:NULL];
            //旋转时间
            [UIView setAnimationDuration:0.3];
            cell.layer.transform = CATransform3DIdentity;
            cell.alpha = 1;
            cell.layer.shadowOffset = CGSizeMake(0, 0);
            [UIView commitAnimations];
        }
    }
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    CGFloat sectionHeaderHeight = 50;
//    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
//        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//    }
//    else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
//        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
