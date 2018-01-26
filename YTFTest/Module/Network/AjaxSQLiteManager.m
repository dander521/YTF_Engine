/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Network data persistence manager.
 * =============================================================================
 */

#import "AjaxSQLiteManager.h"
#import "YTFFMDB.h"
@implementation AjaxSQLiteManager
{
    
    YTFFMDatabase*_database;
    
}
+(instancetype)sharedManager{
    
    static AjaxSQLiteManager *ajaxSQLiteManager=nil;

    if (!ajaxSQLiteManager) {
        ajaxSQLiteManager=[[AjaxSQLiteManager alloc]init];
    }
 
    return ajaxSQLiteManager;
}

-(instancetype)init{
    if (self=[super init]) {
        NSString*dbPath=[NSString stringWithFormat:@"%@/Documents/YTFTest.sqlite",NSHomeDirectory()];
        
        _database=[[YTFFMDatabase alloc]initWithPath:dbPath];
        
        [_database open];
        
        NSString*createSql=@"create table if not exists collection(jsonText varchar(255))";
        
        
        [_database executeUpdate:createSql];
    }
    return  self;
    
}

/**
 *  根据标示符 cacheKey 检查 是否已经存在对应的 数据
 *
 *  @param cacheKey 数据的唯一标示符
 *
 *  @return BOOL
 */
- (BOOL)isExsitsWithCacheKey:(NSString *) cacheKey
{
    NSString * querySql = [NSString stringWithFormat:@"select * from Collection where cacheKey=%@", cacheKey];
    
  //  NSLog(@"appId=========%@",cacheKey);
    
    YTFFMResultSet * set = [_database executeQuery:querySql];
    // 判断是否已存在数据
    if ([set next]) {
        return YES;
    }
    else
        return NO;
}

/**
 *  存储数据
 *
 *  @param JsonString 要存的数据
 *  @param cacheKey   数据的唯一标示符
 *
 *  @return BOOL
 */

- (BOOL)addJsonString:(NSString*) JsonString cacheKey:(NSString *)cacheKey{

    BOOL isExsits = [self isExsitsWithCacheKey:cacheKey];
    
    // 如果已存在数据，先删除已有的数据，再添加新数据
    if (isExsits) {
        NSString * deleteSql = [NSString stringWithFormat:@"delete from Collection where appid=%@",JsonString];
        [_database executeUpdate:deleteSql];
    }
    // 添加新数据
    NSString * insertSql = @"insert into collection(jsonText) values (?)";
    
    BOOL success = [_database executeUpdate:insertSql,JsonString];
    
    return success;
}

/**
 *  删除数据
 *
 *  @param JsonString 要删除的数据
 *  @param cacheKey   数据的唯一标示符
 *
 *  @return
 */

- (BOOL)deletJsonString:(NSString *) JsonString cacheKey:(NSString *)cacheKey
{
    // 判断将要删除的应用记录是否存在
    BOOL isExists = [self isExsitsWithCacheKey:cacheKey];
    if (isExists) {
        // 删除对应的记录
        BOOL success = [_database executeUpdate:@"delete from collection where cacheKey=?", cacheKey];
        return success;
    }
    else
    {
       // NSLog(@"该记录不存在");
        return NO;
    }
}

/**
 *  取出缓存的数据
 *
 *  @return NSArray
 */

- (NSArray *)fetchAllData{

    // 找出Collection表中所有的数据
    NSString * fetchSql = @"select * from collection";
    
    // 执行sql
    YTFFMResultSet * set = [_database executeQuery:fetchSql];
    
    // 循环遍历取出数据
    NSMutableArray * array = [[NSMutableArray alloc] init];
    while ([set next]) {
        [array addObject:[set stringForColumn:@"jsonText"]];
    }
    return array;



}


@end
