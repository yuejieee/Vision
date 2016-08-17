//
//  DataBaseHandle.m
//  FMDB
//
//  Created by dllo on 16/1/7.
//  Copyright © 2016年 dllo. All rights reserved.
//

#import "DataBaseHandle.h"

@interface DataBaseHandle ()

//存文件路径
@property(nonatomic,copy)NSString *dataPath;
@property(nonatomic,retain)FMDatabase *fmdb;

@end

@implementation DataBaseHandle

+(instancetype)shareDataBase{
    
    static DataBaseHandle *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DataBaseHandle alloc] init];
        [manager openDB];
    });
    return manager;
}

-(void)openDB{
    NSString *sandBoxPatn = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    self.dataPath =  [sandBoxPatn stringByAppendingPathComponent:@"data.sqlite"];
    NSLog(@"%@",self.dataPath);
    // 创建一个FMDB的对象
    self.fmdb = [[FMDatabase alloc] initWithPath:self.dataPath];
    BOOL result = [self.fmdb open];
    if (result) {
        NSLog(@"成功");
    }else{
        NSLog(@"失败");
    }
}

-(void)executeSql:(NSString *)sqlStr message:(NSString *)message{
    BOOL result = [self.fmdb executeUpdate:sqlStr];
    if (result) {
        NSLog(@"%@",[NSString stringWithFormat:@"%@成功",message]);
    }else{
        NSLog(@"%@",[NSString stringWithFormat:@"%@失败",message]);
    }
}

-(void)createTable{
    NSString *sqlStr = @"create table if not exists datalist(number integer primary key  autoincrement, title text ,pic text, duration text, category text, playUrl text)";
    //    执行sql语句
    [self executeSql:sqlStr message:@"创建表"];
}

-(void)insertData:(Data *)data{
    NSString *duration = [NSString stringWithFormat:@"%ld", data.duration];
    NSString *sqlStr = [NSString stringWithFormat:@"insert into datalist(title, pic, duration, category, playUrl) values ('%@','%@', '%@', '%@', '%@')",data.title, data.cover[@"feed"], duration, data.category, data.playUrl];
    [self executeSql:sqlStr message:@"添加菜单"];
}

-(void)deleteData:(Data *)data{
    NSString *sqlStr = [NSString stringWithFormat:@"delete from datalist where title = '%@'",data.title];
    [self executeSql:sqlStr message:@"删除"];
}

-(BOOL)selectOneData:(Data *)data{
    NSString *sqlStr = [NSString stringWithFormat:@"select * from datalist where title = '%@'",data.title];
    FMResultSet *resultSet = [self.fmdb executeQuery:sqlStr];
    BOOL result = NO;
    while ([resultSet next]) {
        NSString *title = [resultSet stringForColumn:@"title"];
        if ([title isEqualToString:data.title]) {
            result = YES;
            break;
        }
    }
    return result;
}

-(NSMutableArray *)selectAllData{
    
    NSString *sqlStr = @"select * from datalist";
    //执行查询的方法
    FMResultSet *resultSet = [self.fmdb executeQuery:sqlStr];
    
    //系统会把查询之后的结果赋值给resultSet
    NSMutableArray *array = [[NSMutableArray alloc] init];

    //进行遍历
    while ([resultSet next]) {
        NSString *title = [resultSet stringForColumn:@"title"];
        NSString *duration = [resultSet stringForColumn:@"duration"];
        NSString *pic = [resultSet stringForColumn:@"pic"];
        NSString *category = [resultSet stringForColumn:@"category"];
        NSString *playUrl = [resultSet stringForColumn:@"playUrl"];
        
        Data *data = [[Data alloc] init];
        data.title = title;
        data.duration = [duration integerValue];
        data.pic = pic;
        data.playUrl = playUrl;
        data.category = category;
        [array addObject:data];
    }
    return array;
}










@end
