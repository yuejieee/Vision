//
//  ActivityViewController.m
//  Vision
//
//  Created by dllo on 16/3/18.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "ActivityViewController.h"
#import "ActivityTableViewCell.h"
#import "ActivityModel.h"
#import "ActivityContentViewController.h"

@interface ActivityViewController ()<UITableViewDataSource , UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *activityTableView;

@property(nonatomic, strong)NSMutableArray *activityArray;

@end

@implementation SDWebImageManager (cache)

- (BOOL)memoryCachedImageExistsForURL:(NSURL *)url {
    NSString *key = [self cacheKeyForURL:url];
    return ([self.imageCache imageFromMemoryCacheForKey:key] != nil) ?  YES : NO;
}
@end

@implementation ActivityViewController

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
    [self createData];
    
}

-(void)createData{
    // 数据缓存本地
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *pathData = [path stringByAppendingPathComponent:@"myData"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathData]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:pathData withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *pathDataContent = [pathData stringByAppendingPathComponent:@"activity.plist"];
    [[AFHTTPSessionManager manager]GET:@"http://songguolife.com/api/activity" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.activityArray = [NSMutableArray array];
        for (NSDictionary *temp in responseObject) {
            ActivityModel *model = [[ActivityModel alloc] init];
            [model setValuesForKeysWithDictionary:temp];
            [self.activityArray addObject:model];
        }
        [self.activityTableView reloadData];
        [NSKeyedArchiver archiveRootObject:self.activityArray toFile:pathDataContent];
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.activityArray = [NSKeyedUnarchiver unarchiveObjectWithFile:pathDataContent];
        [self.activityTableView reloadData];
        [SVProgressHUD dismiss];
    }];
}

-(void)createView{

    [self.activityTableView registerNib:[UINib nibWithNibName:NSStringFromClass([ActivityTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([ActivityTableViewCell class])];

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return self.activityArray.count;

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ActivityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ActivityTableViewCell class]) forIndexPath:indexPath];
    ActivityModel *model = self.activityArray[indexPath.row];
    [cell.activityImageView sd_setImageWithURL:[NSURL URLWithString:model.topImage[@"url"]]placeholderImage:[UIImage imageNamed:@"selectedPlaceImage"]];
    //开始时间
    NSTimeInterval stime = [model.st integerValue]/1000;
    NSDate *detaildate1=[NSDate dateWithTimeIntervalSince1970:stime];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"MM.dd"];
    NSString *startStr = [dateFormatter stringFromDate: detaildate1];
    //结束时间
    NSTimeInterval etime = [model.et integerValue]/1000;
    NSDate *detaildate2=[NSDate dateWithTimeIntervalSince1970:etime];
    NSString *endStr = [dateFormatter stringFromDate: detaildate2];
    
    cell.timeLabel.text = [NSString stringWithFormat:@"%@ - %@",startStr,endStr];
    cell.titleLabel.text = model.name;
    cell.placeLabel.text = model.address;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    self.hidesBottomBarWhenPushed = YES;
    ActivityContentViewController *contentVC = [[ActivityContentViewController alloc] init];
     ActivityModel *model = self.activityArray[indexPath.row];
    contentVC.ID = model.id;
    [self.navigationController pushViewController:contentVC animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 240 * WIDTH / 375;
}

#pragma mark ---------- 3D旋转 ----------
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    ActivityModel *model = self.activityArray[indexPath.row];
    if (![[SDWebImageManager sharedManager] memoryCachedImageExistsForURL:[NSURL URLWithString:model.topImage[@"url"]]]) {
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
