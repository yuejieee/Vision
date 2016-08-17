//
//  HotContentCollectionViewCell.m
//  Vision
//
//  Created by dllo on 16/3/14.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "HotContentCollectionViewCell.h"
#import "HotContentTableViewCell.h"
#import "HotModel.h"
#import "VideoViewController.h"

@interface HotContentCollectionViewCell ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)NSMutableArray *weekArr;
@property(nonatomic,strong)NSMutableArray *monthArr;
@property(nonatomic,strong)NSMutableArray *historyArr;

@end

@implementation SDWebImageManager (cache)

- (BOOL)memoryCachedImageExistsForURL:(NSURL *)url {
    NSString *key = [self cacheKeyForURL:url];
    return ([self.imageCache imageFromMemoryCacheForKey:key] != nil) ?  YES : NO;
}
@end

@implementation HotContentCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    [self createData];
    [self createView];
    
}

-(void)createData{
    // 数据缓存本地
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *pathData = [path stringByAppendingPathComponent:@"myData"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:pathData]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:pathData withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *pathWeekContent = [pathData stringByAppendingPathComponent:@"hotWeekContent.plist"];

    [[AFHTTPSessionManager manager] GET:@"http://baobab.wandoujia.com/api/v3/ranklist?strategy=weekly" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *temp = responseObject[@"itemList"];
        self.weekArr = [NSMutableArray array];
        for (NSDictionary *dicS in temp) {
            if ([dicS[@"type"] isEqualToString:@"video"]) {
                HotModel *model = [[HotModel alloc] init];
                [model setValuesForKeysWithDictionary:dicS[@"data"]];
                [self.weekArr addObject:model];
            }
        }
        [self.hotContentTableView reloadData];
        [NSKeyedArchiver archiveRootObject:self.weekArr toFile:pathWeekContent];
        [SVProgressHUD dismiss];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.weekArr = [NSKeyedUnarchiver unarchiveObjectWithFile:pathWeekContent];
        [self.hotContentTableView reloadData];
        [SVProgressHUD dismiss];
    }];
   
    NSString *pathMonthContent = [pathData stringByAppendingPathComponent:@"hotMonthContent.plist"];
    [[AFHTTPSessionManager manager] GET:@"http://baobab.wandoujia.com/api/v3/ranklist?strategy=monthly" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *temp = responseObject[@"itemList"];
        self.monthArr = [NSMutableArray array];
        for (NSDictionary *dicS in temp) {
            if ([dicS[@"type"] isEqualToString:@"video"]) {
                HotModel *model = [[HotModel alloc] init];
                [model setValuesForKeysWithDictionary:dicS[@"data"]];
                [self.monthArr addObject:model];
            }
        }
        [self.hotContentTableView reloadData];
        [NSKeyedArchiver archiveRootObject:self.monthArr toFile:pathMonthContent];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.monthArr = [NSKeyedUnarchiver unarchiveObjectWithFile:pathMonthContent];
        [self.hotContentTableView reloadData];
        [SVProgressHUD dismiss];
    }];
    
    NSString *pathHistoryContent = [pathData stringByAppendingPathComponent:@"hotMonthContent.plist"];
    [[AFHTTPSessionManager manager] GET:@"http://baobab.wandoujia.com/api/v3/ranklist?strategy=historical" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *temp = responseObject[@"itemList"];
        self.historyArr = [NSMutableArray array];
        for (NSDictionary *dicS in temp) {
            if ([dicS[@"type"] isEqualToString:@"video"]) {
                HotModel *model = [[HotModel alloc] init];
                [model setValuesForKeysWithDictionary:dicS[@"data"]];
                [self.historyArr addObject:model];
            }
        }
        [self.hotContentTableView reloadData];
        [NSKeyedArchiver archiveRootObject:self.historyArr toFile:pathHistoryContent];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.historyArr = [NSKeyedUnarchiver unarchiveObjectWithFile:pathHistoryContent];
        [self.hotContentTableView reloadData];
        [SVProgressHUD dismiss];
    }];
}


-(void)createView{
    
    [self.hotContentTableView registerNib:[UINib nibWithNibName:NSStringFromClass([HotContentTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([HotContentTableViewCell class])];
    self.hotContentTableView.rowHeight = 230;

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
     if (self.hotContentTableView.tag == 1000) {
         return self.weekArr.count;
        }else if (self.hotContentTableView.tag == 1001) {
         return self.monthArr.count;
        }else{
         return self.historyArr.count;
        }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    HotContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([HotContentTableViewCell class]) forIndexPath:indexPath];

    if (self.hotContentTableView.tag == 1000) {
        HotModel *model = self.weekArr[indexPath.row];
        [cell.myImageView sd_setImageWithURL:[NSURL URLWithString:model.cover[@"feed"]]placeholderImage:[UIImage imageNamed:@"selectedPlaceImage.png"]];
        cell.titleLabel.text = model.title;
        cell.contentLabel.text = [NSString stringWithFormat:@"#%@ / %.2ld' %.2ld\"",model.category,model.duration / 60 , model.duration % 60];
        cell.numberLabel.text = [NSString stringWithFormat:@"|  %ld. |",indexPath.item + 1];
        return cell;
    }else if (self.hotContentTableView.tag == 1001) {
        HotModel *model = self.monthArr[indexPath.row];
        [cell.myImageView sd_setImageWithURL:[NSURL URLWithString:model.cover[@"feed"]]placeholderImage:[UIImage imageNamed:@"selectedPlaceImage.png"]];
        cell.titleLabel.text = model.title;
        cell.contentLabel.text = [NSString stringWithFormat:@"#%@ / %.2ld' %.2ld\"",model.category,model.duration / 60 , model.duration % 60];
        cell.numberLabel.text = [NSString stringWithFormat:@"|  %ld. |",indexPath.item + 1];
        return cell;
    }else {
        HotModel *model = self.historyArr[indexPath.row];
        [cell.myImageView sd_setImageWithURL:[NSURL URLWithString:model.cover[@"feed"]]placeholderImage:[UIImage imageNamed:@"selectedPlaceImage.png"]];
        cell.titleLabel.text = model.title;
        cell.contentLabel.text = [NSString stringWithFormat:@"#%@ / %.2ld' %.2ld\"",model.category,model.duration / 60 , model.duration % 60];
        cell.numberLabel.text = [NSString stringWithFormat:@"|  %ld. |",indexPath.item + 1];
        return cell;
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    VideoViewController *videoVC = [[VideoViewController alloc] init];
    if (tableView.tag == 1000) {
        videoVC.data = self.weekArr[indexPath.item];
    } else if (tableView.tag == 1001) {
        videoVC.data = self.monthArr[indexPath.item];
    } else if (tableView.tag == 1002) {
        videoVC.data = self.historyArr[indexPath.item];
    }
    [self.VC.navigationController pushViewController:videoVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 230 * WIDTH / 375;
}

#pragma mark ---------- 3D旋转 ----------
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.hotContentTableView.tag == 1000) {
        HotModel *model = self.weekArr[indexPath.row];
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
        
    }if (self.hotContentTableView.tag == 1001) {
        HotModel *model = self.monthArr[indexPath.row];
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
        
    }else if (self.hotContentTableView.tag == 1002) {
        HotModel *model = self.historyArr[indexPath.row];
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
