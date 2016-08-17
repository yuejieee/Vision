//
//  HotContentCollectionViewCell.h
//  Vision
//
//  Created by dllo on 16/3/14.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HotContentCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UITableView *hotContentTableView;

@property (nonatomic, strong) UIViewController *VC;
@end
