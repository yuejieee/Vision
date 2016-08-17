//
//  ActivityContentModel.h
//  Vision
//
//  Created by dllo on 16/3/21.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "BaseModel.h"

@interface ActivityContentModel : BaseModel

@property(nonatomic,copy)NSString *txt;
@property(nonatomic,copy)NSString *url;
@property(nonatomic,retain)NSNumber *width;
@property(nonatomic,retain)NSNumber *height;
@property(nonatomic, retain)NSNumber *tp;
@end
