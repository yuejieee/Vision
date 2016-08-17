//
//  Data.h
//  Vision
//
//  Created by dllo on 16/3/11.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "BaseModel.h"

@interface Data : BaseModel<NSCoding>

@property (nonatomic, strong) NSString *category;

@property (nonatomic, strong) NSDictionary *cover;

@property (nonatomic, strong) NSString *descrip;

@property (nonatomic, strong) NSString *ID;

@property (nonatomic, assign) NSInteger duration;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSString *playUrl;

@property (nonatomic, strong) NSString *pic;

@end
