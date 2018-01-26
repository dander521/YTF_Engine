//
//  YTFDataBaseModule.h
//  YTFDataBaseModule
//
//  Created by apple on 2016/10/24.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YTFModule.h"
#import "YTFFMDB.h"

@interface YTFDataBaseModule : YTFModule


#pragma mark - Sync Method

/**
 同步打开数据库

 @param paramDictionary JS 参数
 */
- (NSDictionary *)openDataBaseSync:(NSDictionary *)paramDictionary;

/**
 同步关闭数据库

 @param paramDictionary JS 参数
 */
- (NSDictionary *)closeDataBaseSync:(NSDictionary *)paramDictionary;


/**
 同步数据库事务

 @param paramDictionary JS 参数
 */
- (NSDictionary *)transactionSync:(NSDictionary *)paramDictionary;

/**
 同步执行sql语句

 @param paramDictionary JS 参数
 */
- (NSDictionary *)executeSqlSync:(NSDictionary *)paramDictionary;

/**
 同步搜索sql语句

 @param paramDictionary JS 参数
 */
- (NSDictionary *)selectSqlSync:(NSDictionary *)paramDictionary;

#pragma mark - Async Method

/**
 打开数据库

 @param paramDictionary JS 参数
 */
- (void)openDataBase:(NSDictionary *)paramDictionary;

/**
 关闭数据库

 @param paramDictionary JS 参数
 */
- (void)closeDataBase:(NSDictionary *)paramDictionary;

/**
 数据库事务

 @param paramDictionary JS 参数
 */
- (void)transaction:(NSDictionary *)paramDictionary;

/**
 执行sql语句

 @param paramDictionary JS 参数
 */
- (void)executeSql:(NSDictionary *)paramDictionary;

/**
 搜索sql语句

 @param paramDictionary JS 参数
 */
- (void)selectSql:(NSDictionary *)paramDictionary;


@end
