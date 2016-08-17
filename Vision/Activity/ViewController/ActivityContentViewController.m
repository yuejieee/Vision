//
//  ActivityContentViewController.m
//  Vision
//
//  Created by dllo on 16/3/21.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "ActivityContentViewController.h"
#import "ActivityContentModel.h"
#import "ActivityImgTableViewCell.h"
#import "ActivityTxtTableViewCell.h"
#import "ActivityTopTableViewCell.h"
#import "MapViewController.h"

@interface ActivityContentViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *activityContentTableView;
@property (nonatomic, strong) UIImageView *topImageView;
@property (nonatomic, strong) NSMutableArray *activityPicArr;
@property (nonatomic, strong) NSMutableArray *activityDisArr;
@property (nonatomic, strong) NSMutableArray *activityArr;
@property (nonatomic, strong) NSDictionary *activityDic;
@property (nonatomic, strong) UIView *myView;
@end

@implementation ActivityContentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"FZLTZCHJW--GB1-0" size:20];
    titleLabel.text = @"活动详情";
    self.navigationItem.titleView = titleLabel;
    
    [self setNavigationItem];
    [self createData];
    [self createView];
}

- (void)setNavigationItem {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_return"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)createData{
    [[AFHTTPSessionManager manager]GET:[NSString stringWithFormat:@"http://songguolife.com/api/activity/%@",self.ID] parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.activityPicArr = [NSMutableArray array];
        self.activityDisArr = [NSMutableArray array];
        self.activityArr = [NSMutableArray array];
        self.activityDic = responseObject;
        for (NSDictionary *temp in responseObject[@"resource"]) {
            ActivityContentModel *model = [[ActivityContentModel alloc] init];
            [model setValuesForKeysWithDictionary:temp];
            NSInteger width = [model.width integerValue];
            if (![model.txt isEqualToString:@""] || width != 0) {
                [self.activityArr addObject:model];
            }
        }
        [self.topImageView sd_setImageWithURL:[NSURL URLWithString:self.activityDic[@"topImage"][@"url"]]];
        [self.activityContentTableView reloadData];
    
    }
    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
    }];
}

-(void)createView{
    self.activityContentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, WIDTH, HEIGHT - 64) style:UITableViewStylePlain];
    [self.view addSubview:self.activityContentTableView];
    self.activityContentTableView.contentInset = UIEdgeInsetsMake(220 * WIDTH / 375, 0, 0, 0);
    self.activityContentTableView.separatorStyle = UITableViewCellSeparatorStyleNone
    ;
    self.activityContentTableView.delegate = self;
    self.activityContentTableView.dataSource = self;
    
    [self.activityContentTableView registerClass:[ActivityImgTableViewCell class] forCellReuseIdentifier:NSStringFromClass([ActivityImgTableViewCell class])];
    
    [self.activityContentTableView registerClass:[ActivityTxtTableViewCell class] forCellReuseIdentifier:NSStringFromClass([ActivityTxtTableViewCell class])];
    
    [self.activityContentTableView registerNib:[UINib nibWithNibName:NSStringFromClass([ActivityTopTableViewCell class]) bundle:nil]forCellReuseIdentifier:NSStringFromClass([ActivityTopTableViewCell class])];
    
    self.topImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -220 * WIDTH / 375, WIDTH, 220 * WIDTH / 375)];
    [self.activityContentTableView addSubview:self.topImageView];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat yOffest = self.activityContentTableView.contentOffset.y;
    CGFloat proportion = -yOffest / (220 * WIDTH / 375 + 64);
    if (self.activityContentTableView.contentOffset.y < 0 && proportion >= 1) {
        self.topImageView.frame = CGRectMake(0, yOffest, WIDTH * proportion, -yOffest);
        self.topImageView.center = CGPointMake(self.view.center.x, yOffest / 2);
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.activityArr.count + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        ActivityTopTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ActivityTopTableViewCell class])forIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.titleLabel.text = self.activityDic[@"name"];
        cell.placeLabel.text = self.activityDic[@"address"];
        cell.placeView.image = [UIImage imageNamed:@"iconfont-dizhi-3"];
        return cell;
    } else{
        ActivityContentModel *model = self.activityArr[indexPath.row - 1];
        NSInteger tp = [model.tp integerValue];
        if (tp == 2) {
            ActivityTxtTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ActivityTxtTableViewCell class])forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.discLabel.text = model.txt;
            cell.discLabel.numberOfLines = 0;
            [cell.discLabel sizeToFit];
            return cell;
        } else {
            ActivityImgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([ActivityImgTableViewCell class])forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            [cell.picImageView sd_setImageWithURL:[NSURL URLWithString:model.url]];
            cell.picHeight = model.height;
            cell.picWidth = model.width;
            return cell;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        self.hidesBottomBarWhenPushed = YES;
        MapViewController *mapVC = [[MapViewController alloc] init];
        [self.navigationController pushViewController:mapVC animated:YES];
        mapVC.latitude = self.activityDic[@"geo"][@"coordinates"][@"latitude"];
        mapVC.longitude = self.activityDic[@"geo"][@"coordinates"][@"longitude"];
        mapVC.city = self.activityDic[@"geo"][@"city"][@"name"];
    }

}

#pragma mark 设置tableView每行的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 120;
    }
    //通过图片的实际尺寸和屏幕固定的宽进行等比例计算
    ActivityContentModel *model = self.activityArr[indexPath.row - 1];
    NSInteger tp = [model.tp integerValue];
    if (tp == 0) {
//        NSLog(@"%@",model.height);
        double height = [model.height doubleValue];
        double width = [model.width doubleValue];
        return height * WIDTH / width;
    } else {
        //计算文字的高度
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:18],NSFontAttributeName ,nil];
        //根据文本的内容和文本的字体进行计算高度
        //参数1：告诉系统，文本显示的最大范围
        CGRect rect = [model.txt boundingRectWithSize:CGSizeMake(WIDTH - 20,0)  options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
        
        return rect.size.height;
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
