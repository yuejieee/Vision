//
//  DetailsViewController.h
//  Vision
//
//  Created by dllo on 16/3/12.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "BaseViewController.h"

@interface DetailsViewController : BaseViewController

@property(nonatomic, strong) NSString *detailsID;

@property (nonatomic, strong) NSString *name;

@property (weak, nonatomic) IBOutlet UICollectionView *backCollectionView;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, assign) CGRect finalCellRect;

@end
