//
//  HotViewController.h
//  Vision
//
//  Created by dllo on 16/3/10.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "BaseViewController.h"

@interface HotViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UICollectionView *contentCollectionView;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, assign) CGRect finalCellRect;

@end
