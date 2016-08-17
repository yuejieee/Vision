//
//  ActivityImgTableViewCell.m
//  Vision
//
//  Created by dllo on 16/3/22.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "ActivityImgTableViewCell.h"

@implementation ActivityImgTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createView];
    }
    return self;
}

-(void)createView{
    self.picImageView = [[UIImageView alloc] init];
    [self.contentView addSubview:self.picImageView];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    double height = [self.picHeight doubleValue] * SELF_WIDTH / [self.picWidth doubleValue];
    if (!isnan(height)) {
        self.picImageView.frame = CGRectMake(10, 10, SELF_WIDTH - 20, height - 20);
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
