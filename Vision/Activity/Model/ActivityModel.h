//
//  ActivityModel.h
//  Vision
//
//  Created by dllo on 16/3/18.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "BaseModel.h"

@interface ActivityModel : BaseModel <NSCoding>

@property(nonatomic,copy)NSString *id;
@property(nonatomic,copy)NSString *address;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,retain)NSDictionary *topImage;
@property(nonatomic,retain)NSNumber *st;
@property(nonatomic,retain)NSNumber *et;

@end
