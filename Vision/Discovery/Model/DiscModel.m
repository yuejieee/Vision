//
//  DiscModel.m
//  Vision
//
//  Created by dllo on 16/3/11.
//  Copyright © 2016年 yue_zhang. All rights reserved.
//

#import "DiscModel.h"

@implementation DiscModel

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{

    if ([key isEqualToString:@"id"]) {
        self.ID = [value stringValue];
    }

}

// 两个必须实现的协议方法, 第一个存入到本地时用
- (void)encodeWithCoder:(NSCoder *)aCoder {
    // 先对这些内容进行编码, 然后存储
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.bgPicture forKey:@"bgPicture"];
    [aCoder encodeObject:self.ID forKey:@"ID"];
}

// 本地读取时用
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.bgPicture = [aDecoder decodeObjectForKey:@"bgPicture"];
        self.ID = [aDecoder decodeObjectForKey:@"ID"];
    }
    return self;
}

@end
