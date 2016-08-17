//
//  DataBaseHandle.h
//  FMDB
//
//  Created by dllo on 16/1/7.
//  Copyright © 2016年 dllo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "Data.h"

@interface DataBaseHandle : NSObject

{
    
    sqlite3 *dataBasePoint;
    
}

+(instancetype)shareDataBase;

-(void)createTable;

-(void)openDB;

-(void)insertData:(Data *)data;

-(void)deleteData:(Data *)data;

-(BOOL)selectOneData:(Data *)data;

-(NSMutableArray *)selectAllData;

@end
