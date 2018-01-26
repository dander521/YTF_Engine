/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    YTFWeiboModule Plugin.
 * =============================================================================
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AppDelegate.h"

// XIUGAI
@interface YTFWeiboModule : NSObject <UIApplicationDelegate>

+ (instancetype)shareInstance;

/**
 *  是否安装微博
 *
 *  @param paramsDictionary JS参数字典
 */
- (NSNumber *)isInstalled:(NSDictionary *)paramsDictionary;

/**
 *  微博授权
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)auth:(NSDictionary *)paramsDictionary;

/**
 *  微博取消授权
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)cancelAuth:(NSDictionary *)paramsDictionary;


/**
 获取用户信息

 @param paramsDictionary JS参数字典
 */
- (void)getUserInfo:(NSDictionary *)paramsDictionary;

/**
 *  分享文字
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)shareText:(NSDictionary *)paramsDictionary;

/**
 *  分享图片
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)shareImage:(NSDictionary *)paramsDictionary;


/**
 分享多媒体

 @param paramsDictionary  JS参数字典
 */
- (void)share:(NSDictionary *)paramsDictionary;

@end
