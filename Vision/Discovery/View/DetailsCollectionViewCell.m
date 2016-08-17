//
//  DetailsCollectionViewCell.m
//  Vision
//
//  Created by dllo on 16/3/12.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "DetailsCollectionViewCell.h"
#import "DetailsTableViewCell.h"
#import "DetailsModel.h"
#import "VideoViewController.h"
#import "DetailPushAnimation.h"

@interface DetailsCollectionViewCell ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)NSMutableArray *dataArr;
@property(nonatomic,strong)NSMutableArray *shareArr;

@end

@implementation SDWebImageManager (cache)

- (BOOL)memoryCachedImageExistsForURL:(NSURL *)url {
    NSString *key = [self cacheKeyForURL:url];
    return ([self.imageCache imageFromMemoryCacheForKey:key] != nil) ?  YES : NO;
}
@end

@implementation DetailsCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [self createView];
}

#pragma mark ---------- 重新给ID赋值，同时解析数据 ----------
- (void)setCellID:(NSString *)cellID {
    
    // 数据缓存本地
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *pathData = [path stringByAppendingPathComponent:@"myData"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathData]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:pathData withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *pathDataContent = [pathData stringByAppendingPathComponent:@"detailsData.plist"];
        //数据解析
        [[AFHTTPSessionManager manager]GET:[NSString stringWithFormat:@"http://baobab.wandoujia.com/api/v3/videos?categoryId=%@&num=20&start=0&strategy=date",cellID] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSArray *temp = responseObject[@"itemList"];
            self.dataArr = [NSMutableArray array];
            for (NSDictionary *dicS in temp) {
                if ([dicS[@"type"] isEqualToString:@"video"]) {
                    DetailsModel *model = [[DetailsModel alloc] init];
                    [model setValuesForKeysWithDictionary:dicS[@"data"]];
                    [self.dataArr addObject:model];
                }
            }
            [self.detailsTableView reloadData];
            [SVProgressHUD dismiss];
            [NSKeyedArchiver archiveRootObject:self.dataArr toFile:pathDataContent];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            self.dataArr = [NSKeyedUnarchiver unarchiveObjectWithFile:pathDataContent];
            [SVProgressHUD dismiss];
        }];
    
    NSString *pathShareContent = [pathData stringByAppendingPathComponent:@"detailsShare.plist"];
    [[AFHTTPSessionManager manager]GET:[NSString stringWithFormat:@"http://baobab.wandoujia.com/api/v3/videos?categoryId=%@&num=20&start=0&strategy=shareCount",cellID] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *temp = responseObject[@"itemList"];
        self.shareArr = [NSMutableArray array];
        for (NSDictionary *dicS in temp) {
            if ([dicS[@"type"] isEqualToString:@"video"]) {
                DetailsModel *model = [[DetailsModel alloc] init];
                [model setValuesForKeysWithDictionary:dicS[@"data"]];
                [self.shareArr addObject:model];
            }
        }
        [self.detailsTableView reloadData];
        [NSKeyedArchiver archiveRootObject:self.shareArr toFile:pathShareContent];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.shareArr = [NSKeyedUnarchiver unarchiveObjectWithFile:pathShareContent];
        [self.detailsTableView reloadData];
    }];
}

#pragma mark ---------- 设置页面 ----------
-(void)createView{
    [self.detailsTableView registerNib:[UINib nibWithNibName:NSStringFromClass([DetailsTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([DetailsTableViewCell class])];
    self.detailsTableView.rowHeight = 230;

}

#pragma mark ---------- tableView协议方法 ----------
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.detailsTableView.tag == 1000) {
        return self.dataArr.count;
    }else {
        return self.shareArr.count;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DetailsTableViewCell class]) forIndexPath:indexPath];
    if (self.detailsTableView.tag == 1000) {
        DetailsModel *model = self.dataArr[indexPath.row];
        [cell.myImageView sd_setImageWithURL:[NSURL URLWithString:model.cover[@"feed"]] placeholderImage:[UIImage imageNamed:@"selectedPlaceImage.png"]] ;
        cell.titleLabel.text = model.title;
        cell.conentLabel.text = [NSString stringWithFormat:@"#%@ / %.2ld' %.2ld\"",model.category,model.duration / 60, model.duration % 60];
        return cell;
    }else {
        DetailsModel *model = self.shareArr[indexPath.row];
       [cell.myImageView sd_setImageWithURL:[NSURL URLWithString:model.cover[@"feed"]] placeholderImage:[UIImage imageNamed:@"selectedPlaceImage.png"]] ;
        cell.titleLabel.text = model.title;
        cell.conentLabel.text = [NSString stringWithFormat:@"#%@ / %.2ld' %.2ld\"",model.category,model.duration / 60, model.duration % 60];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    VideoViewController *videoVC = [[VideoViewController alloc] init];
    self.VC.hidesBottomBarWhenPushed = YES;
    if (self.detailsTableView.tag == 1000) {
        videoVC.data = self.dataArr[indexPath.row];
    } else if (self.detailsTableView.tag == 1001){
        videoVC.data = self.shareArr[indexPath.row];
    }
    [self.VC.navigationController pushViewController:videoVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 230 * WIDTH / 375;
}

#pragma mark ---------- 3D旋转 ----------
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.detailsTableView.tag == 1000) {
        DetailsModel *model = self.dataArr[indexPath.row];
        if (![[SDWebImageManager sharedManager] memoryCachedImageExistsForURL:[NSURL URLWithString:model.cover[@"feed"]]]) {
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

    } else if (self.detailsTableView.tag == 1001) {
        DetailsModel *model = self.shareArr[indexPath.row];
        if (![[SDWebImageManager sharedManager] memoryCachedImageExistsForURL:[NSURL URLWithString:model.cover[@"feed"]]]) {
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

@end
