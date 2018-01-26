/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Error message manager.
 * =============================================================================
 */


#import <Foundation/Foundation.h>
#import "BaseWebView.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface ErrorManager : NSObject

// 单例
+ (instancetype)shareManager;

/**
 *  JS错误信息
 *
 *  @param webView
 */
- (void)errorMessageWithWebView:(BaseWebView *)webView;

@end
