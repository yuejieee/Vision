//
//  Data.m
//  Vision
//
//  Created by dllo on 16/3/11.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "Data.h"

@implementation Data

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    if ([key isEqualToString:@"description"]) {
        self.descrip = value;
    }
    if ([key isEqualToString:@"id"]) {
        self.ID = [value stringValue];
    }
    if ([key isEqualToString:@"duration"]) {
        self.duration = [value integerValue];
    }
}

// 两个必须实现的协议方法, 第一个存入到本地时用
- (void)encodeWithCoder:(NSCoder *)aCoder {
    // 先对这些内容进行编码, 然后存储
    [aCoder encodeObject:self.category forKey:@"category"];
    [aCoder encodeObject:self.cover forKey:@"cover"];
    [aCoder encodeObject:self.descrip forKey:@"descrip"];
    [aCoder encodeObject:self.ID forKey:@"ID"];
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeInteger:self.duration forKey:@"duration"];
    [aCoder encodeObject:self.playUrl forKey:@"playUrl"];

}

// 本地读取时用
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.category = [aDecoder decodeObjectForKey:@"category"];
        self.cover = [aDecoder decodeObjectForKey:@"cover"];
        self.descrip = [aDecoder decodeObjectForKey:@"descrip"];
        self.ID = [aDecoder decodeObjectForKey:@"ID"];
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.duration = [aDecoder decodeIntegerForKey:@"duration"];
        self.playUrl = [aDecoder decodeObjectForKey:@"playUrl"];
    }
    return self;
}

@end
