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

#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "AppDelegate.h"
#import "QQApiInterface.h"
//#import "YTFModule.h"
@interface QQLoginShare : NSObject <TencentSessionDelegate,UIApplicationDelegate,QQApiInterfaceDelegate,TencentLoginDelegate>

@property(nonatomic ,strong)UIWebView   *shareWebView;// 分享执行的webView回调环境



/**
 *  判断用户是否安装 QQ
 */
- (NSNumber *)isInstalled:(NSDictionary *)paramsDictionary;

/**
 *  QQ 登陆
 *
 *  @param args JS传入的参数
 */
- (void)login:(NSDictionary *)args;

/**
 *  退出 登陆
 *
 *  @param args JS传入的参数
 */
- (void)logout:(NSDictionary *)args;

/**
 *  获取用户信息
 *
 *  @param args JS传入的参数
 */
- (BOOL)getUserInfo:(NSDictionary *)args;

/**
 *  纯文本 分享纯图片消息
 */
- (void)shareText:(NSDictionary *)args;

/**
 *  分享纯图片消息
 */
- (void)shareImage:(NSDictionary *)args;

/**
 *  分享新闻
 */
- (void)shareWebPage:(NSDictionary *)args;

/**
 *  分享音乐
 */
- (void)shareMusic:(NSDictionary *)args;

/**
 *  分享视频
 */
- (void)shareVideo:(NSDictionary *)args;


@end
