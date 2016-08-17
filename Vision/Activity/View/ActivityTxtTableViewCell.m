//
//  ActivityTxtTableViewCell.m
//  Vision
//
//  Created by dllo on 16/3/22.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "ActivityTxtTableViewCell.h"

@implementation ActivityTxtTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self createView];
    }
    return self;
}

-(void)createView{    
    self.discLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.discLabel];
    self.discLabel.font = [UIFont fontWithName:@"PingFang SC" size:15];
    self.discLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    //计算文字的高度
    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[UIFont systemFontOfSize:18],NSFontAttributeName ,nil];
    //根据文本的内容和文本的字体进行计算高度
    //参数1：告诉系统，文本显示的最大范围
    CGRect rect = [self.discLabel.text boundingRectWithSize:CGSizeMake(SELF_WIDTH - 20,0)  options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil];
    self.discLabel.frame = CGRectMake(10, 0, SELF_WIDTH - 20, rect.size.height);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {        
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
