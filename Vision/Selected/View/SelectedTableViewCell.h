//
//  SelectedTableViewCell.h
//  Vision
//
//  Created by dllo on 16/3/11.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectedTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end
