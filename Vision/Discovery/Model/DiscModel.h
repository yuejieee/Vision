//
//  DiscModel.h
//  Vision
//
//  Created by dllo on 16/3/11.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "BaseModel.h"

@interface DiscModel : BaseModel <NSCoding>

@property(nonatomic,strong)NSString *name;
@property(nonatomic,strong)NSString *bgPicture;
@property(nonatomic,strong)NSString *ID;

@end
