/**
 * =============================================================================
 *  [YTF] (C)2015-2099 Yuantuan Inc.
 *  Link            http://www.ytframework.cn
 * =============================================================================
 *  @author         Tangqian<tanufo@126.com>
 *  @created        2015-10-10
 *  @description    Basic notification event manager.
 * =============================================================================
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "BaseWebView.h"

UIKIT_EXTERN NSString *const NotificationWebViewScrollToBottom; /**<webView滑到底部 */

@interface MessageNotificationManager : NSObject


/**
 *  添加事件监听
 *
 *  @param webView JSContext
 */
- (void)addEventListenerWithWebView:(BaseWebView *)webView;

/**
 *  发送事件监听
 *
 *  @param webView JSContext
 */
- (void)postEventListenerWithWebView:(BaseWebView *)webView;

/**
 *  移除事件监听
 *
 *  @param webView JSContext
 */
- (void)removeEventListenerWithWebView:(BaseWebView *)webView;

@end
