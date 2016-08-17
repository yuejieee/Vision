//
//  ActivityTopTableViewCell.h
//  Vision
//
//  Created by dllo on 16/3/22.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityTopTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *placeView;

@end
