//
//  VideoViewController.h
//  Vision
//
//  Created by dllo on 16/3/12.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Data.h"
@interface VideoViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
- (IBAction)playbutton:(id)sender;
@property (nonatomic, strong) Data *data;
@end
