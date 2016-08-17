//
//  ActivityModel.m
//  Vision
//
//  Created by dllo on 16/3/18.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "ActivityModel.h"

@implementation ActivityModel

// 两个必须实现的协议方法, 第一个存入到本地时用
- (void)encodeWithCoder:(NSCoder *)aCoder {
    // 先对这些内容进行编码, 然后存储
    [aCoder encodeObject:self.id forKey:@"id"];
    [aCoder encodeObject:self.address forKey:@"address"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.topImage forKey:@"topImage"];
    [aCoder encodeObject:self.st forKey:@"st"];
    [aCoder encodeObject:self.et forKey:@"et"];

    
}

// 本地读取时用
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.id = [aDecoder decodeObjectForKey:@"id"];
        self.address = [aDecoder decodeObjectForKey:@"address"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.topImage = [aDecoder decodeObjectForKey:@"topImage"];
        self.st = [aDecoder decodeObjectForKey:@"st"];
        self.et = [aDecoder decodeObjectForKey:@"et"];

    }
    return self;
}

@end
