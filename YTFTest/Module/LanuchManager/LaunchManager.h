/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    LaunchView manager.
 * =============================================================================
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class BaseWebView;
@interface LaunchManager : NSObject

// 单例
+ (instancetype)shareManager;

/**
 *  移除导航页
 *
 *  @param webView
 */
- (void)removeLaunchWithWebView:(BaseWebView *)webView;

// 显示自定义启动页
- (UIView *)showLaunchImageView;

// 隐藏自定义启动页
- (void)removeLaunchImageView;



@end
