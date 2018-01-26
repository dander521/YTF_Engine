/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    YTFWeChatModule Plugin.
 * =============================================================================
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "WXApi.h"
#import "AppDelegate.h"
#import "YTFModule.h"

// XIUGAI
@interface YTFWeChatModule : YTFModule <UIApplicationDelegate>


+ (YTFWeChatModule *)shareInstance;

/**
 *  是否安装微信
 *
 *  @param paramsDictionary JS参数字典
 */
- (NSNumber *)isInstalled:(NSDictionary *)paramsDictionary;

/**
 *  授权登录
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)auth:(NSDictionary *)paramsDictionary;

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
 *  分享音乐
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)shareMusic:(NSDictionary *)paramsDictionary;

/**
 *  分享视频
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)shareVideo:(NSDictionary *)paramsDictionary;

/**
 *  分享网页
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)shareWebPage:(NSDictionary *)paramsDictionary;


//  当前版本是否支持分享到朋友圈
- (NSNumber *)checkShareTimeline:(NSDictionary *)paramsDictionary;

/**
 *  获取token
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)getToken:(NSDictionary *)paramsDictionary;

/**
 *  获取用户信息
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)getUserInfo:(NSDictionary *)paramsDictionary;

/**
 *  重新获取token
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)refreshToken:(NSDictionary *)paramsDictionary;


/**
 *  微信支付
 *
 *  @param paramsDictionary JS参数字典
 */
- (void)pay:(NSDictionary *)paramsDictionary;



@end
