//
//  DiscViewController.m
//  Vision
//
//  Created by dllo on 16/3/10.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "DiscViewController.h"
#import "DiscCollectionViewCell.h"
#import "DiscModel.h"
#import "DetailsViewController.h"


@interface DiscViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *discCollectionView;
@property(nonatomic,strong)NSMutableArray *discArr;

@end

@implementation DiscViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"Lobster 1.4" size:25];
    titleLabel.text = @"Vision";
    self.navigationItem.titleView = titleLabel;
    
    [SVProgressHUD show];
    [self createData];
    [self setCollectionView];
    
}
#pragma mark ---------- 数据解析 ----------
-(void)createData{
    // 数据缓存本地
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *pathData = [path stringByAppendingPathComponent:@"myData"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathData]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:pathData withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *pathDataContent = [pathData stringByAppendingPathComponent:@"disc.plist"];
    [[AFHTTPSessionManager manager] GET:@"http://baobab.wandoujia.com/api/v2/categories" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        self.discArr = [NSMutableArray array];
        for (NSDictionary *temp in responseObject) {
            DiscModel *model = [[DiscModel alloc] init];
            [model setValuesForKeysWithDictionary:temp];
            [self.discArr addObject:model];
        }
        [self.discCollectionView reloadData];
        [SVProgressHUD dismiss];
        [NSKeyedArchiver archiveRootObject:self.discArr toFile:pathDataContent];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.discArr = [NSKeyedUnarchiver unarchiveObjectWithFile:pathDataContent];
        [self.discCollectionView reloadData];
        [SVProgressHUD dismiss];
    }];
}
#pragma mark ---------- 设置collectionView ----------
-(void)setCollectionView{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 3;
    flowLayout.minimumInteritemSpacing = 3;
    [self.discCollectionView setCollectionViewLayout:flowLayout];
    [self.discCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([DiscCollectionViewCell class]) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass([DiscCollectionViewCell class])];
}

#pragma mark ---------- collectionView协议方法 ----------
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.discArr.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DiscCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([DiscCollectionViewCell class]) forIndexPath:indexPath];
    DiscModel *model = self.discArr[indexPath.item];
    [cell.myView sd_setImageWithURL:[NSURL URLWithString:model.bgPicture]placeholderImage:[UIImage imageNamed:@"discPlaceHolder.png"]];
    cell.myLabel.text = [NSString stringWithFormat:@"#%@",model.name];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.hidesBottomBarWhenPushed = YES;
    DetailsViewController *detailsVC = [[DetailsViewController alloc] init];
    [self.navigationController pushViewController:detailsVC animated:YES];
    DiscModel *model = self.discArr[indexPath.item];
    detailsVC.detailsID = model.ID;
    detailsVC.name = model.name;
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark --------- UICollectionViewDelegateFlowLayout协议方法 ---------
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((self.view.frame.size.width - 3)/ 2, (self.view.frame.size.width - 3)/ 2);
}

#pragma mark ---------- 滑动动画 -----------
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
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
