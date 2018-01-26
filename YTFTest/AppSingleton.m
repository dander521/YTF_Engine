/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link        http://www.ytframework.cn
 * =============================================================================
 *  @author     Tangqian<tanufo@126.com>
 *  @created    2015-10-10
 *  @description
 * =============================================================================
 */

#import "AppSingleton.h"

@implementation AppSingleton

/**
 *  初始化单例对象
 *
 *  @return 类的实例对象
 */
+(instancetype)shareManager
{
    static AppSingleton * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AppSingleton alloc]init];
    });    
    return manager;
}


@end
