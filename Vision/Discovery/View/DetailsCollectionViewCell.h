//
//  DetailsCollectionViewCell.h
//  Vision
//
//  Created by dllo on 16/3/12.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailsCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UITableView *detailsTableView;
@property (nonatomic,strong) NSString *cellID;

@property (nonatomic, strong) UIViewController *VC;

@end
