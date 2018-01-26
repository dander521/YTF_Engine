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

#import <Foundation/Foundation.h>


@interface AjaxSQLiteManager : NSObject


+(instancetype)sharedManager;

/**
 *  根据标示符 cacheKey 检查 是否已经存在对应的 数据
 *
 *  @param cacheKey 数据的唯一标示符
 *
 *  @return BOOL
 */
- (BOOL)isExsitsWithCacheKey:(NSString *) cacheKey;

/**
 *  存储数据
 *
 *  @param JsonString 要存的数据
 *  @param cacheKey   数据的唯一标示符
 *
 *  @return BOOL
 */
- (BOOL)addJsonString:(NSString*) JsonString cacheKey:(NSString *)cacheKey;

/**
 *  删除数据
 *
 *  @param JsonString 要删除的数据
 *  @param cacheKey   数据的唯一标示符
 *
 *  @return
 */
- (BOOL)deletJsonString:(NSString *)JsonString cacheKey:(NSString *)cacheKey;

/**
 *  取出缓存的数据
 *
 *  @return NSArray
 */
- (NSArray *)fetchAllData;


@end
