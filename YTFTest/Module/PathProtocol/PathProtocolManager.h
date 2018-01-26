/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Path protocol manager.
 * =============================================================================
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BaseWebView;

@interface PathProtocolManager : NSObject

// 单例
+ (instancetype)shareManager;

/**
 *  获取路径
 *
 *  @param pathString       路径参数
 *  @param excuteWebView    执行环境
 *
 *  @return 转换的可用路径
 */
- (NSString *)getWebViewUrlWithString:(NSString *)pathString excuteWebView:(BaseWebView *)excuteWebView;

/**
 *  widget://协议
 *
 *  @param widgetProtocolPath widget相对路径
 *
 *  @return widget绝对路径
 */
+ (NSString *)getWebViewUrlWithWidgetProtocolPath:(NSString *)widgetProtocolPath;

/**
 *  cache://协议
 *
 *  @param cacheprotocolPath cache相对路径
 *
 *  @return cache绝对路径
 */
+ (NSString *)getWebViewUrlWithCacheProtocolPath:(NSString *)cacheprotocolPath;

/**
 *  fs://协议
 *
 *  @param fsProtocolPath fs相对路径
 *
 *  @return fs绝对路径
 */
+ (NSString *)getWebViewUrlWithFSProtocolPath:(NSString *)fsProtocolPath;

/**
 *  download://协议
 *
 *  @param downloadProtocolPath download相对路径
 *
 *  @return download绝对路径
 */
+ (NSString *)getWebViewUrlWithDownloadProtocolPath:(NSString *)downloadProtocolPath;

@end
