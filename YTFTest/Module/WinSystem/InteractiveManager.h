/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Javascript excute native, javascript excute javascript.
 * =============================================================================
 */

#import <UIKit/UIKit.h>
#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>

@class BaseWebView;
@interface InteractiveManager : UIViewController

// 单例
+ (instancetype)shareManager;

/**
 *  JS调原生
 *
 *  @param webView
 */
- (void)JSExcuteNative:(BaseWebView *)webView;

/**
 *  JS调JS
 *
 *  @param webView
 */
- (void)JSExcuteJS:(BaseWebView *)webView;

@end
