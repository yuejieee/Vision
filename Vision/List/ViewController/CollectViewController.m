//
//  CollectViewController.m
//  Vision
//
//  Created by dllo on 16/3/24.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "CollectViewController.h"
#import "PlayerViewController.h"
#import "SelectedTableViewCell.h"
#import "Data.h"
#import "DataBaseHandle.h"

@interface CollectViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (nonatomic, strong) NSMutableArray *collectArray;

@end

@implementation CollectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 150, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"FZLTZCHJW--GB1-0" size:20];
    titleLabel.text = @"我的收藏";
    self.navigationItem.titleView = titleLabel;
    
    [self setNavigationItem];
    
    [self createData];
    [self setListTableView];
}

- (void)setNavigationItem {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_return"] style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor blackColor];
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)createData {
    self.collectArray = [NSMutableArray array];
    self.collectArray = [[DataBaseHandle shareDataBase] selectAllData];
    if (self.collectArray.count == 0) {
        self.label.alpha = 1;
    } else {
        [self.tableView reloadData];
        self.label.alpha = 0;
    }
}

- (void)setListTableView {
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([SelectedTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([SelectedTableViewCell class])];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.collectArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SelectedTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SelectedTableViewCell class]) forIndexPath:indexPath];
    Data *data = self.collectArray[indexPath.row];
    [cell.imgView sd_setImageWithURL:[NSURL URLWithString:data.pic] placeholderImage:[UIImage imageNamed:@"selectedPlaceImage.png"]];
    cell.titleLabel.text = data.title;
    cell.contentLabel.text = [NSString stringWithFormat:@"#%@ / %.2ld' %.2ld\"", data.category, data.duration / 60, data.duration % 60];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayerViewController *player = [[PlayerViewController alloc] init];
    player.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    player.data = self.collectArray[indexPath.row];
    [self presentViewController:player animated:YES completion:^{
    }];
}

// 删除下载文件
- (nullable NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        Data *data = self.collectArray[indexPath.row];
        [self.collectArray removeObject:data];
        [[DataBaseHandle shareDataBase] deleteData:data];        
        // 单行刷新
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

        if (self.collectArray.count == 0) {
            self.label.alpha = 1;
        }
    }];
    action.backgroundColor = [UIColor colorWithWhite:0.729 alpha:1.000];
    
    return @[action];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 230 * WIDTH / 375;
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
