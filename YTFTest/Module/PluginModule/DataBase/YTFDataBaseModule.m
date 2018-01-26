//
//  YTFDataBaseModule.m
//  YTFDataBaseModule
//
//  Created by apple on 2016/10/24.
//  Copyright © 2016年 yuantuan. All rights reserved.
//

#import "YTFDataBaseModule.h"
#import "ToolsFunction.h"
#import "AppDelegate.h"

@interface YTFDataBaseModule ()

@end

@implementation YTFDataBaseModule

#pragma mark - Sync Method

/**
 同步打开数据库
 
 @param paramDictionary JS 参数
 */
- (NSDictionary *)openDataBaseSync:(NSDictionary *)paramDictionary
{
    /*
     name:
     path:
     */
    
    NSString *dbPath = nil;
    NSString *dbName = nil;
    
    if (paramDictionary[@"args"])
    {
        dbPath = paramDictionary[@"args"][@"path"];
        dbName = paramDictionary[@"args"][@"name"];
    } else {
        dbPath = paramDictionary[@"path"];
        dbName = paramDictionary[@"name"];
    }
    
    NSDictionary *dicResult = nil;
    
    if (dbName == nil)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"msg" : @"数据库名不能为空"};
        return dicResult;
    }
    
    if (dbPath == nil)
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"msg" : @"数据库路径不能为空"};
        return dicResult;
    }
    
    NSString *documentsPath = [[AppDelegate shareAppDelegate] getAbsolutePathWithRelativePath:dbPath];
    
    BOOL isDirectory;
    if (![[NSFileManager defaultManager] fileExistsAtPath:[documentsPath stringByDeletingLastPathComponent] isDirectory:&isDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:[documentsPath stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:documentsPath forKey:dbName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 文件路径
    // 实例化FMDataBase对象
    YTFFMDatabase *db = [YTFFMDatabase databaseWithPath:documentsPath];
    
    if ([db open])
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:1]};
    } else {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"msg" : @"打开数据库失败"};
    }

    return dicResult;
}

/**
 同步关闭数据库
 
 @param paramDictionary JS 参数
 */
- (NSDictionary *)closeDataBaseSync:(NSDictionary *)paramDictionary
{
    /*
     name:
     */
    
    NSString *dbName = nil;
    
    if (paramDictionary[@"args"])
    {
        dbName = paramDictionary[@"args"][@"name"];
    } else {
        dbName = paramDictionary[@"name"];
    }
    
    NSDictionary *dicResult = nil;
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:dbName])
    {
        return @{@"status" : [NSNumber numberWithInt:0],
                 @"msg" : @"数据库未打开"};
    }
    
    YTFFMDatabase *db = [YTFFMDatabase databaseWithPath:[[NSUserDefaults standardUserDefaults] objectForKey:dbName]];
    
    if (![db open])
    {
        return @{@"status" : [NSNumber numberWithInt:0],
                 @"msg" : @"数据库未打开"};
    }
    
    if ([db close])
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:1]};
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:dbName];
        [[NSUserDefaults standardUserDefaults] synchronize];
    } else {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"msg" : @"关闭数据库失败"};
    }
    
    return dicResult;
}


/**
 同步数据库事务
 
 @param paramDictionary JS 参数
 */
- (NSDictionary *)transactionSync:(NSDictionary *)paramDictionary
{
    /*
     name:
     operation:
     */
    
    NSString *dbName = nil;
    
    if (paramDictionary[@"args"])
    {
        dbName = paramDictionary[@"args"][@"name"];
    } else {
        dbName = paramDictionary[@"name"];
    }
    
    NSString *operation = nil;
    
    if (paramDictionary[@"args"])
    {
        operation = paramDictionary[@"args"][@"operation"];
    } else {
        operation = paramDictionary[@"operation"];
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:dbName])
    {
        return @{@"status" : [NSNumber numberWithInt:0],
                 @"msg" : @"数据库未打开"};
    }
    
    YTFFMDatabase *db = [YTFFMDatabase databaseWithPath:[[NSUserDefaults standardUserDefaults] objectForKey:dbName]];
    
    if (![db open])
    {
        return @{@"status" : [NSNumber numberWithInt:0],
                 @"msg" : @"数据库未打开"};
    }
    
    if (operation == nil)
    {
        return @{@"status" : [NSNumber numberWithInt:0],
                 @"msg" : @"事务操作类型不能为空"};
    }
    
    NSDictionary *dicResult = nil;
    
    if ([operation isEqualToString:@"begin"])
    {
        if ([db beginTransaction])
        {
            dicResult = @{@"status" : [NSNumber numberWithInt:1]};
        } else {
            dicResult = @{@"status" : [NSNumber numberWithInt:0],
                          @"msg" : @"开启数据库事务失败"};
        }

    } else if ([operation isEqualToString:@"rollback"])
    {
        if ([db rollback])
        {
            dicResult = @{@"status" : [NSNumber numberWithInt:1]};
        } else {
            dicResult = @{@"status" : [NSNumber numberWithInt:0],
                          @"msg" : @"回滚数据库事务失败"};
        }
    } else if ([operation isEqualToString:@"commit"])
    {
        if ([db commit])
        {
            dicResult = @{@"status" : [NSNumber numberWithInt:1]};
        } else {
            dicResult = @{@"status" : [NSNumber numberWithInt:0],
                          @"msg" : @"提交数据库事务失败"};
        }
    }
    
    return dicResult;
}

/**
 同步执行sql语句
 
 @param paramDictionary JS 参数
 */
- (NSDictionary *)executeSqlSync:(NSDictionary *)paramDictionary
{
    /*
     name:
     sql:
     */
    
    NSString *dbName = nil;
    
    if (paramDictionary[@"args"])
    {
        dbName = paramDictionary[@"args"][@"name"];
    } else {
        dbName = paramDictionary[@"name"];
    }
    
    NSString *sql = nil;
    
    if (paramDictionary[@"args"])
    {
        sql = paramDictionary[@"args"][@"sql"];
    } else {
        sql = paramDictionary[@"sql"];
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:dbName])
    {
        return @{@"status" : [NSNumber numberWithInt:0],
                 @"msg" : @"数据库未打开"};
    }

    YTFFMDatabase *db = [YTFFMDatabase databaseWithPath:[[NSUserDefaults standardUserDefaults] objectForKey:dbName]];
    
    if (![db open])
    {
        return @{@"status" : [NSNumber numberWithInt:0],
                 @"msg" : @"数据库未打开"};
    }
    
    if (sql == nil)
    {
        return @{@"status" : [NSNumber numberWithInt:0],
                 @"msg" : @"执行语句不能为空"};
    }

    NSDictionary *dicResult = nil;
    
    if ([db executeUpdate:sql])
    {
        dicResult = @{@"status" : [NSNumber numberWithInt:1]};
    } else {
        dicResult = @{@"status" : [NSNumber numberWithInt:0],
                      @"msg" : @"执行语句失败"};
    }
    
    return dicResult;
}

/**
 同步搜索sql语句
 
 @param paramDictionary JS 参数
 */
- (NSDictionary *)selectSqlSync:(NSDictionary *)paramDictionary
{
    /*
     name:
     sql:
     */
    
    NSString *dbName = nil;
    
    if (paramDictionary[@"args"])
    {
        dbName = paramDictionary[@"args"][@"name"];
    } else {
        dbName = paramDictionary[@"name"];
    }
    
    NSString *sql = nil;
    
    if (paramDictionary[@"args"])
    {
        sql = paramDictionary[@"args"][@"sql"];
    } else {
        sql = paramDictionary[@"sql"];
    }
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:dbName])
    {
        return @{@"status" : [NSNumber numberWithInt:0],
                 @"msg" : @"数据库未打开"};
    }
    
    YTFFMDatabase *db = [YTFFMDatabase databaseWithPath:[[NSUserDefaults standardUserDefaults] objectForKey:dbName]];
    
    if (![db open])
    {
        return @{@"status" : [NSNumber numberWithInt:0],
                 @"msg" : @"数据库未打开"};
    }
    
    if (sql == nil)
    {
        return @{@"status" : [NSNumber numberWithInt:0],
                 @"msg" : @"执行查询语句不能为空"};
    }
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    
    YTFFMResultSet *res = [db executeQuery:sql];
    NSArray *columnName = [[res columnNameToIndexMap] allKeys];
    
    while ([res next])
    {
        NSMutableDictionary *rowDic = [[NSMutableDictionary alloc] init];
        
        for (int i = 0; i < columnName.count; i++)
        {
            NSString *columnValue = [res stringForColumn:columnName[i]];
            if (columnValue==nil) {
                columnValue=@"";
            }
            
            [rowDic setValue:columnValue forKey:columnName[i]];
        }
        
        [dataArray addObject:rowDic];
    }
    
    return @{@"data" : dataArray};
}

#pragma mark - Async Method

/**
 打开数据库
 
 @param paramDictionary JS 参数
 */
- (void)openDataBase:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     name:
     sql:
     */

    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self openDataBaseSync:paramDictionary]]];
}

/**
 关闭数据库
 
 @param paramDictionary JS 参数
 */
- (void)closeDataBase:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     name:
     sql:
     */

    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self closeDataBaseSync:paramDictionary]]];
}

/**
 数据库事务
 
 @param paramDictionary JS 参数
 */
- (void)transaction:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     name:
     sql:
     */

    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self transactionSync:paramDictionary]]];
}

/**
 执行sql语句
 
 @param paramDictionary JS 参数
 */
- (void)executeSql:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     name:
     sql:
     */

    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self executeSqlSync:paramDictionary]]];
}

/**
 搜索sql语句
 
 @param paramDictionary JS 参数
 */
- (void)selectSql:(NSDictionary *)paramDictionary
{
    /*
     cbId:
     target:
     name:
     sql:
     */

    [self evaluatingWithJSParam:paramDictionary resultString:[ToolsFunction dicToJavaScriptString:[self selectSqlSync:paramDictionary]]];
}

#pragma mark - Custom Method

- (void)evaluatingWithJSParam:(NSDictionary *)paramDictionary resultString:(NSString *)jsonString
{
    [paramDictionary[@"target"] stringByEvaluatingJavaScriptFromString:[NSString                stringWithFormat:@"YTFcb.on('%@','%@','%@',false);", paramDictionary[@"cbId"], jsonString,jsonString]];
}

@end
