//
//  SelectedViewController.h
//  Vision
//
//  Created by dllo on 16/3/10.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "BaseViewController.h"

@interface SelectedViewController : BaseViewController

@property (nonatomic,strong) NSIndexPath *indexPath;

@property (nonatomic,assign) CGRect finalCellRect;

@property (weak, nonatomic) IBOutlet UITableView *selectedTableView;


@end
